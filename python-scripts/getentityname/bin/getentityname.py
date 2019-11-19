#!/usr/bin/python3
# -*- coding: utf-8 -*-
#
# Copyright (C) 2012-2019 SUSE Linux GmbH
#
# Author:
# Thomas Schraitle <toms at opensuse dot org>
#
"""
This script finds every external parameter entity in the internal subset
of the DTD, for example:

 <!DOCTYPE book PUBLIC
      "-//OASIS//DTD DocBook XML V4.4//EN"
      "http://www.docbook.org/xml/4.4/docbookx.dtd"
 [
   <!-- The external subset -->
   <!ENTITY % entities SYSTEM "entity-decl.ent">
   %entities;
   <!ENTITY % entities SYSTEM "foo.ent">
   %foo.ent;
 ]>

The output will be:

   entity-decl.ent foo.ent

The script detects XML comments inside the internal subset and removes them.
"""

import argparse
import logging
import os.path
import re
import sys
from logging.config import dictConfig
from xml.sax import SAXParseException, make_parser
from xml.sax.handler import ContentHandler

__version__ = "2.0.0"
__author__ = "Thomas Schraitle <thomas DOT schraitle AT suse DOT de>"
__license__ = "GPL 3"

DEFAULT_LOGGING_DICT = {
    'version': 1,
    'disable_existing_loggers': False,
    'formatters': {
        'standard': {'format': '[%(levelname)s] %(funcName)s: %(message)s'},
    },
    'handlers': {
        'default': {
            'level': 'NOTSET',
            'formatter': 'standard',
            'class': 'logging.StreamHandler',
        },
    },
    'loggers': {
        __name__: {
            'handlers': ['default'],
            'level': 'INFO',
            'propagate': True
        }
    }
}

#: Map verbosity level (int) to log level
LOGLEVELS = {None: logging.WARNING,  # 0
             0: logging.WARNING,
             1: logging.INFO,
             2: logging.DEBUG,
             }

#: Instantiate our logger
log = logging.getLogger(__name__)

###
# Regular Expressions
SPACE = r'[ \t\r\n]'                   # whitespace
S = '%s+' % SPACE                     # One or more whitespace
opS = '%s*' % SPACE                     # Zero or more  whitespace
oS = '%s?' % SPACE                     # Optional whitespace
NAME = '[a-zA-Z_:][-a-zA-Z0-9._:]*'    # Valid XML name
QSTR = "(?:'[^']*'|\"[^\"]*\")"        # Quoted XML string
QUOTES = "(?:'[^']'|\"[^\"]\")"
SYSTEMLITERAL = '(?P<sysid>%s)' % QSTR
PUBLICLITERAL = (r'(?P<pubid>"[-\'\(\)+,./:=?;!*#@$_%% \n\ra-zA-Z0-9]*"|'
                 r"'[-\(\)+,./:=?;!*#@$_%% \n\ra-zA-Z0-9]*')"
                 )
EXTERNALID = ("""(?:SYSTEM|PUBLIC{S}{PUBLICLITERAL})"""
              """{S}{SYSTEMLITERAL}"""
              ).format(**locals())
ENTITY = ("""<!ENTITY{S}%{S}"""
          """(?P<PEDecl>{NAME}){S}"""
          """{EXTERNALID}{opS}>"""
          ).format(**locals())
r_ENTITY = re.compile(ENTITY, re.VERBOSE | re.DOTALL | re.MULTILINE)
DOCTYPE = ("""<!DOCTYPE{S}"""
           "(?P<Name>{NAME})"
           "("
             "({S}{EXTERNALID}{opS})?"  # noqa: 127
             r"(?:{S}\[(?P<IntSubset>.*)\])?"  # noqa: 127
           ")?"
           """{opS}>"""
           ).format(**locals())
r_DOCTYPE = re.compile(DOCTYPE, re.VERBOSE | re.DOTALL | re.MULTILINE)
COMMENTOPEN = re.compile('<!--')
COMMENTCLOSE = re.compile('-->')


def xmlsyntaxcheck(xmlfile):
    """Check if the XML file is well-formed

    :param str xmlfile: XML filename
    :return: Nothing if the XML is well-formed, otherwise it raises
       a SAXParseException
    :rtype: bool
    """
    parser = make_parser()
    parser.setContentHandler(ContentHandler())

    parser.parse(xmlfile)


def joinEnts(ents, sep):
    """Returns a string of names, separated by 'sep'."""
    return sep.join(ents)


def remove_xml_comments(content):
    """Remove all XML comments (<!-- ... -->) in a string

    :param str content: the content with possible XML comments
    :return: a string without any XML comments
    :rtype: str
    :raises: ValueError when the end comment '-->' couldn't be find
             or if there are double dashes '--' inside the comment.

    >>> remove_xml_comments('<!-- hello -->World')
    'World'
    >>> remove_xml_comments('<!-- h -->World<!-- is it? -->')
    'World'
    >>> remove_xml_comments('<!--A-->Hi <!--B--> World.')
    'Hi  World.'
    >>> remove_xml_comments('''<!-- <!ENTITY x\
    "X"> \
    -->Hello''')
    'Hello'
    """
    while True:
        if '<!--' not in content:
            return content
        start = COMMENTOPEN.search(content).start()
        match = COMMENTCLOSE.search(content)
        if not match:
            raise ValueError("ERROR: Missing '-->' in comment!")
        end = match.end()
        # Extract the comment
        comment = content[start:end][4:-3]
        if '--' in comment:
            raise ValueError("ERROR: '--' not allowed in comment")

        # Remove the comment
        content = content[0:start] + content[end:]


def parse_ent_file(entityfile, args):
    """Parse entity file for other referenced entities

    :param str entityfile: filename to the referenced
                           entity file from XML
    :param args: parsed arguments from CLI parser
    """
    # result = []
    # HINT: This reads the complete file.
    log.debug("Investigate entity file %r", entityfile)
    content = open(entityfile, 'r').read()
    for entity in r_ENTITY.finditer(content):
        if args.skip_public and entity['pubid']:
            log.debug("Skipping public parameter entity %s %s",
                      entity['pubid'].replace('\n', ''), entity['sysid'])
            continue
        log.debug("Found match %s", entity['sysid'])
        # result.append(entity['sysid'][1:-1])
        yield entity['sysid'][1:-1]
    # return result


def getentities(args, linenr=50):
    """Read first 50 lines (default) and return any parameter entity names

    :param args: parsed arguments from CLI parser
    :param int linenr: number of lines that should be investigated
    :return: a list of all found entities
    """
    ents = {}
    seen = set()

    for xmlfile in args.xmlfiles:
        # Checks for well-formed XML; does nothing if all is ok,
        # but if not, it raises a SAXParseException.
        xmlsyntaxcheck(xmlfile)

        # Prepare the lines:
        lines = []
        with open(xmlfile, 'r') as fh:
            for i in range(linenr):
                lines.append(fh.readline())
        if len(lines) > 5:
            log.debug("First six lines:")
            for i in range(6):
                log.debug("  line %d: %s", i+1, lines[i].strip())
        lines = "".join(lines)

        # Try to find matches
        match = r_DOCTYPE.search(lines)
        log.debug("Match: %s", match)
        if match:
            content = remove_xml_comments(match['IntSubset'])

            log.debug("Looking for entities...")
            for match in r_ENTITY.finditer(content):
                # Remove quotes:
                entity = match['sysid'][1:-1]
                # log.info("Found entity %r", entity)
                if entity in seen:
                    continue
                seen.add(entity)
                if entity.startswith("/"):
                    ents.append(entity)
                elif entity.startswith("http"):
                    ents.append(entity)
                else:
                    # ents.append(entity)
                    ents[entity] = os.path.join(os.path.dirname(xmlfile),
                                                entity)
                log.debug("ents: %s", ents)

    resultdict = ents.copy()
    # Process ents to find other referenced PEs
    for absolute in ents.values():
        for entity in parse_ent_file(absolute, args):
            if entity not in seen:
                seen.add(entity)
                resultdict[entity] = os.path.join(os.path.dirname(absolute),
                                                  entity)
    return resultdict


def parsecli(cliargs=None):
    """Parse CLI with :class:`argparse.ArgumentParser` and return parsed result

    :param list cliargs: Arguments to parse or None (=use sys.argv)
    :return: parsed CLI result
    :rtype: :class:`argparse.Namespace`
    """
    # Setup logging
    dictConfig(DEFAULT_LOGGING_DICT)

    parser = argparse.ArgumentParser(description=__doc__.strip(),
                                     formatter_class=argparse.RawDescriptionHelpFormatter,  # noqa: E501
                                     usage='%(prog)s [OPTIONS] XMLFILE...')
    parser.add_argument("--version",
                        action="version",
                        version=__version__)

    parser.add_argument('-v', '--verbose',
                        action="count",
                        help="Raise verbosity level",
                        )
    parser.add_argument("-A", "--absolute",
                        default=False,
                        action="store_true",
                        help="Make paths absolute")
    parser.add_argument("-P", "--skip-public",
                        default=True,
                        action="store_false",
                        help="Skip parameter entities with public reference")
    parser.add_argument("-s", "--separator",
                        default=' ',
                        help=("Set the separator between consecutive "
                              "filenames (default '%(default)s'). "
                              "Use '\\n' and '\\t' to "
                              "insert a CR and TAB character.")
                        )
    parser.add_argument("xmlfiles",
                        metavar="XMLFILES",
                        nargs="+",
                        help="One or more XML files")

    args = parser.parse_args(cliargs)

    log.setLevel(LOGLEVELS.get(args.verbose, logging.DEBUG))
    log.debug("CLI args: %s", args)
    log.debug("")
    # Save our parser instance:
    args.parser = parser

    # Fix separators
    if args.separator == '\\n':
        args.separator = '\n'
    elif args.separator == '\\t':
        args.separator = '\t'

    resultargs = []
    for fn in args.xmlfiles:
        if not os.path.isabs(fn):
            fn = os.path.abspath(fn)
        resultargs.append(fn)

    args.xmlfiles = resultargs

    return args


def main(cliargs=None):
    """Entry point for the application script

    :param list cliargs: Arguments to parse or None (=use :class:`sys.argv`)
    :return: error code; 0 => everything was succesfull, !=0 => error
    :rtype: int
    """
    try:
        args = parsecli(cliargs)

        if not args:
            args.parser.print_usage()
            sys.exit(1)

        ents = getentities(args)
        if args.absolute:
            print(joinEnts(ents.values(), args.separator))
        else:
            print(joinEnts(ents, args.separator))
        return 0

    except IOError as error:
        log.fatal(error)
    except SAXParseException as error:
        log.fatal(error)
    return 1


if __name__ == "__main__":
    sys.exit(main())
