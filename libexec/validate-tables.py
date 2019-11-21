#!/usr/bin/env python3
#
# validate-tables.py - Validate that DocBook tables are properly formatted
# Copyright (C) 2019 SUSE LLC / Martin Doucha <mdoucha@suse.cz>
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 2 or 3 of the License.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program.  If not, see <https://www.gnu.org/licenses/>.

import sys
import traceback
from lxml import etree

docbook_nsmap = {'d': 'http://docbook.org/ns/docbook'}

class DocBookError(RuntimeError):
    """Excepiton class for DocBook formatting errors"""

    def __init__(self, elem, message, *args, **kwargs):
        tmp = element_info(elem)
        super().__init__(tmp + ' ' + message, *args, **kwargs)

class CALSTable:
    """
    Validation class for CALS tables.
    https://www.oasis-open.org/specs/a502.htm
    """

    def __init__(self, node):
        self.node = node
        self.tgroups = []

        if node.tag == 'entrytbl':
            self.tgroups.append(parse_tgroup(node))
        else:
            tgroup_list = node.xpath('tgroup|d:tgroup',
                namespaces=docbook_nsmap)
            for item in tgroup_list:
                self.tgroups.append(parse_tgroup(item))

    def validate(self):
        err_list = []
        for colcount, blocks in self.tgroups:
            tmp = validate_table(blocks, colcount)
            if tmp:
                err_list.append(tmp)
        if err_list:
            raise DocBookError(self.node, 'Errors in table:\n' +
                '\n'.join(err_list))

class HTMLTable:
    """
    Validation class for HTML-style tables.
    """

    def __init__(self, node):
        self.node = node
        thead = optional_node(node, 'thead|d:thead')
        tfoot = optional_node(node, 'tfoot|d:tfoot')
        tbody_list = node.xpath('tbody|d:tbody', namespaces=docbook_nsmap)
        tr_list = node.xpath('tr|d:tr', namespaces=docbook_nsmap)

        if len(tbody_list) > 0 and len(tr_list) > 0:
            raise DocBookError(node, 'HTML table cannot contain both <tbody> and <tr>')

        if len(tbody_list) <= 0 and len(tr_list) <= 0:
            raise DocBookError(node, 'HTML table must contain <tbody> or <tr>')

        self.blocks = []
        self.colcount = count_coldefs(node)

        if thead is not None:
            self.blocks.append((thead, parse_html_tblock(thead)))

        for item in tbody_list:
            self.blocks.append((item, parse_html_tblock(item)))

        if len(tr_list) > 0:
            self.blocks.append((node, parse_html_tblock(node)))

        if tfoot is not None:
            self.blocks.append((tfoot, parse_html_tblock(tfoot)))

        if self.colcount is None:
            self.colcount = 0
            for cnum, rspan, cspan in self.blocks[0][1][0]:
                self.colcount += cspan

    def validate(self):
        msg = validate_table(self.blocks, self.colcount)

        if msg:
            raise DocBookError(self.node, 'Errors in table:\n' + msg)

def optional_node(parent, xpath):
    """Find single XML node or return NULL. Multiple nodes result in error."""
    tmp = parent.xpath(xpath, namespaces=docbook_nsmap)

    if len(tmp) > 1:
        raise DocBookError(parent, 'XPath returned too many results: ' + xpath)
    elif len(tmp) > 0:
        return tmp[0]
    return None

def element_info(elem):
    """Generate element info string: "filename:line: <tag>"."""
    return '%s:%d: <%s>' % (elem.base, elem.sourceline, elem.tag)

def intattr(node, attrname, default=None, required=True):
    """Get and validate int() value of XML attribute."""
    value = node.attrib.get(attrname, default)

    if value is None:
        if required:
            raise DocBookError(node, 'Missing attribute %s' % attrname)
        return None

    try:
        return int(value)
    except ValueError as err:
        raise DocBookError(node, 'Invalid %s value' % attrname) from err

def parse_tgroup(node):
    """Parse CALS table <tgroup> or <entrytbl> element"""
    blocks = []
    colcount = intattr(node, 'cols')

    if colcount is None or colcount < 1:
        raise DocBookError(node, 'Invalid cols attribute')

    colspec = parse_colspec(node, colcount)
    spanspec = parse_spanspec(node, colspec)
    thead = optional_node(node, 'thead|d:thead')
    tfoot = optional_node(node, 'tfoot|d:tfoot')
    tbody_list = node.xpath('tbody|d:tbody', namespaces=docbook_nsmap)

    if len(tbody_list) != 1:
        raise DocBookError(node, 'Element must contain exactly one <tbody>')

    if thead is not None:
        tmpspec = parse_colspec(thead, colcount)
        if tmpspec:
            blocks.append((thead, parse_cals_tblock(thead, tmpspec, dict())))
        else:
            blocks.append((thead, parse_cals_tblock(thead, colspec, spanspec)))
    tbody = tbody_list[0]
    blocks.append((tbody, parse_cals_tblock(tbody, colspec, spanspec)))
    if tfoot is not None:
        tmpspec = parse_colspec(tfoot, colcount)
        if tmpspec:
            blocks.append((tfoot, parse_cals_tblock(tfoot, tmpspec, dict())))
        else:
            blocks.append((tfoot, parse_cals_tblock(tfoot, colspec, spanspec)))

    return (colcount, blocks)

def parse_colspec(node, colcount):
    """Parse CALS table <colspec> list"""
    ret = dict()
    nodelist = node.xpath('colspec|d:colspec', namespaces=docbook_nsmap)
    checklist = [None] * colcount
    pos = 1

    for item in nodelist:
        pos = intattr(item, 'colnum', pos)
        if pos < 1 or pos > colcount:
            raise DocBookError(item, 'Invalid colnum attribute')
        if checklist[pos - 1] is not None:
            raise DocBookError(item, 'Duplicate <colspec> element for column %d'
                % pos)

        colname = item.attrib.get('colname')
        if colname is not None and colname in ret:
            raise DocBookError(item, 'Duplicate colname value')

        checklist[pos - 1] = item

        if colname is not None:
            ret[colname] = pos - 1
        pos += 1

    return ret

def parse_spanspec(node, colspec):
    """Parse CALS table <spanspec> list"""
    ret = dict()
    nodelist = node.xpath('spanspec|d:spanspec', namespaces=docbook_nsmap)

    for item in nodelist:
        name = item.attrib.get('spanname')
        startname = item.attrib.get('namest')
        endname = item.attrib.get('nameend')
        if name is None or startname is None or endname is None:
            raise DocBookError(item, 'Missing required attributes')
        if name in ret:
            raise DocBookError(item, 'Duplicate spanname value')

        startcol = colspec.get(startname)
        endcol = colspec.get(endname)
        if startcol is None:
            raise DocBookError(item, 'Invalid namest attribute')
        if endcol is None:
            raise DocBookError(item, 'Invalid nameend attribute')
        if startcol >= endcol:
            raise DocBookError(item, 'Span start column must be before end column')

        ret[name] = (startcol, endcol - startcol + 1)
    return ret

def parse_cals_tblock(node, colspec, spanspec):
    """Parse CALS table <thead>, <tfoot> or <tbody> element"""
    ret = []
    row_list = node.xpath('row|d:row', namespaces=docbook_nsmap)

    if len(row_list) <= 0:
        raise DocBookError(node, 'Element contains no <row>')

    for row in row_list:
        nodelist = row.xpath('entry|d:entry|entrytbl|d:entrytbl',
            namespaces=docbook_nsmap)
        col_list = []

        if len(nodelist) <= 0:
            raise DocBookError(row, 'Empty row')

        for col in nodelist:
            colname = col.attrib.get('colname')
            spanname = col.attrib.get('spanname')
            namest = col.attrib.get('namest')
            nameend = col.attrib.get('nameend')

            colnum = None
            rowspan = intattr(col, 'morerows', 0) + 1
            colspan = 1

            if rowspan <= 0:
                raise DocBookError(col, 'Invalid morerows value')

            if spanname is not None:
                tmp = spanspec.get(spanname)
                if tmp is None:
                    raise DocBookError(col, 'Invalid spanname value')
                colnum, colspan = tmp
            elif namest is not None:
                colnum = colspec.get(namest)
                if colnum is None:
                    raise DocBookError(col, 'Invalid namest value')
                if nameend is not None:
                    endcol = colspec.get(nameend)
                    if endcol is None:
                        raise DocBookError(col, 'Invalid nameend value')
                    if colnum >= endcol:
                        raise DocBookError(col, 'Span start column must be before end column')
                    colspan = endcol - colnum + 1
            elif colname is not None:
                colnum = colspec.get(colname)
                if colnum is None:
                    raise DocBookError(col, 'Invalid colname value')
            col_list.append((colnum, rowspan, colspan))
        ret.append(col_list)
    return ret

def parse_html_tblock(node):
    """
    Parse HTML table <thead>, <tfoot>, <tbody> element or rows directly
    under <table> or <informaltable>
    """
    ret = []
    row_list = node.xpath('tr|d:tr', namespaces=docbook_nsmap)

    if len(row_list) <= 0:
        raise DocBookError(node, 'Element contains no <tr>')

    for row in row_list:
        nodelist = row.xpath('td|d:td|th|d:th', namespaces=docbook_nsmap)
        col_list = []

        if len(nodelist) <= 0:
            raise DocBookError(row, 'Empty row')

        for col in nodelist:
            rowspan = intattr(col, 'rowspan', 1)
            colspan = intattr(col, 'colspan', 1)

            if rowspan <= 0:
                raise DocBookError(col, 'Invalid rowspan')
            if colspan <= 0:
                raise DocBookError(col, 'Invalid colspan')

            col_list.append((None, rowspan, colspan))
        ret.append(col_list)

    return ret

def count_coldefs(node):
    """Validate <col>/<colgroup> definitions and calculate column count"""
    ret = None
    coldef = node.xpath('col|d:col', namespaces=docbook_nsmap)

    if len(coldef) > 0:
        ret = len(coldef)

    coldef = node.xpath('colgroup|d:colgroup', namespaces=docbook_nsmap)

    if len(coldef) <= 0:
        return ret
    if ret is not None:
        raise DocBookError(node, 'Table cannot contain both <col> and <colgroup>')

    ret = 0
    for item in coldef:
        tmp = int(item.xpath('count(col|d:col)', namespaces=docbook_nsmap))
        if tmp > 0:
            ret += tmp
        else:
            ret += intattr(item, 'span', 1)
    return ret

def expand_cells(parent, tblock, colcount):
    """Generate table layout for validation/rendering"""
    ret = []
    for row in tblock:
        ret.append(colcount * [0])
    for rpos, row in enumerate(tblock):
        cpos = 0
        for startpos, rspan, cspan in row:
            # handle rowspan from preceding rows
            while cpos < len(ret[rpos]) and ret[rpos][cpos] > 0:
                cpos += 1
            if startpos is not None:
                if startpos < cpos:
                    raise DocBookError(parent, 'Swapped cells on row %d' %
                        (rpos+1))
                cpos = startpos
            for y in range(rspan):
                if rpos + y >= len(ret):
                    ret.append(colcount * [0])
                cell_list = ret[rpos + y]
                for x in range(cspan):
                    if cpos + x >= len(cell_list):
                        cell_list.append(1)
                    else:
                        cell_list[cpos + x] += 1
            cpos += cspan
    return ret

def render_cells(row_prefix, cell_block, rowcount, colcount):
    """Render table layout in ASCII art"""
    ret = []
    for rpos, row in enumerate(cell_block):
        err = (len(row) != colcount) or rpos >= rowcount
        err = err or bool([x for x in row if x != 1])
        tmp = []
        tmp.append('!!' if err else '  ')
        tmp.append(row_prefix if rpos < rowcount else (' ' * len(row_prefix)))
        tmp.append(' ')

        for cpos, item in enumerate(row):
            if item > 1:
                tmp.append('X')
            elif item <= 0:
                tmp.append(' ')
            elif cpos >= colcount or rpos >= rowcount:
                tmp.append('+')
            else:
                tmp.append('o')
        ret.append(''.join(tmp))
    return '\n'.join(ret)

def validate_cells(cell_block, rowcount, colcount):
    """
    Validate layout of a single table block (<thead>, <tfoot> or <tbody>).
    Check for holes, overflows and intersecting cells.
    """
    err_list = []
    if len(cell_block) > rowcount:
        err_list.append('Rowspan overflow')
    for rpos, row in enumerate(cell_block[:rowcount], start=1):
        if len(row) > colcount:
            err_list.append('Column overflow on row %d' % rpos)
        if [x for x in row if x < 1]:
            err_list.append('Holes in row %d' % rpos)
        if [x for x in row if x > 1]:
            err_list.append('Intersecting cells on row %d' % rpos)
    return err_list

def validate_table(blocklist, colcount):
    """Validate entire HTML table or CALS <tgroup> (from layout)"""
    pmap = dict(thead='H', tfoot='F', tbody='B', table='T', informaltable='T')
    cell_blocks = []
    for parent, rowlist in blocklist:
        cell_blocks.append((parent, rowlist, pmap.get(parent.tag, '?'),
            expand_cells(parent, rowlist, colcount)))

    err_list = []
    for parent, rowlist, prefix, block in cell_blocks:
        tmp = validate_cells(block, len(rowlist), colcount)
        if tmp:
            tmp.insert(0, '- ' + element_info(parent))
            err_list.append('\n  - '.join(tmp))

    if not err_list:
        return None

    block_list = []
    for parent, rowlist, prefix, block in cell_blocks:
        block_list.append(render_cells(prefix, block, len(rowlist), colcount))
    sep = '\n    ' + ('-' * colcount) + '\n'
    rendered = sep.join(block_list)
    return '\n'.join(err_list) + '\n\n' + rendered

# Validate entire table
def check_table(node):
    """Validate <table>, <informaltable> or <entrytbl> element"""
    tr_list = node.xpath('.//tr|.//d:tr', namespaces=docbook_nsmap)
    row_list = node.xpath('.//row|.//d:row', namespaces=docbook_nsmap)

    if len(tr_list) > 0 and len(row_list) > 0:
        raise DocBookError(node, 'Table cannot contain both CALS and HTML elements')

    if len(tr_list) <= 0 and len(row_list) <= 0:
        raise DocBookError(node, 'Empty table')

    if len(tr_list) > 0:
        table = HTMLTable(node)
    else:
        table = CALSTable(node)

    table.validate()

# Validate DocBook file
def check_file(filename):
    """Validate tables in DocBook file."""
    xml = etree.parse(filename)
    tablist = xml.xpath('//table|//informaltable|//entrytbl|//d:table|//d:informaltable|//d:entrytbl',
        namespaces=docbook_nsmap)
    ret = 0
    for table in tablist:
        try:
            check_table(table)
        except DocBookError as err:
            print(err.args[0], '\n', file=sys.stderr)
            ret = 1
    return ret

if __name__ == '__main__':
    ret = 0
    for filename in sys.argv[1:]:
        try:
            ret |= check_file(filename)
        except:
            print('Error checking file %s:' % filename, file=sys.stderr)
            traceback.print_exc()
            ret |= 2
    exit(ret)
