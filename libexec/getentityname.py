#!/usr/bin/env python3
# -*- coding: utf-8 -*-
#
# Copyright (C) 2012-2021 SUSE Linux GmbH
#
# Author:
# Tom Schraitle <toms at opensuse dot org>
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
   <!ENTITY % foo.ent SYSTEM "foo.ent">
   %foo.ent;
   <!--
   <!ENTITY % bar.ent SYSTEM "bar.ent">
   %bar.ent;
   -->
 ]>

The output will be:

   entity-decl.ent foo.ent

The script detects XML comments inside the internal subset and removes them. In
the above example, the "bar.ent" is therefor not in the result list.
"""

import argparse
import logging
import os.path
import re
import subprocess
import sys
from logging.config import dictConfig
from xml.sax import SAXParseException, make_parser
import xml.sax.handler as xmlsh

__version__ = "2.2.1"
__author__ = "Thomas Schraitle <thomas DOT schraitle AT suse DOT de>"
__license__ = "GPL 3"


#: The name of our logger
LOGGERNAME = "getentities"

#: Instantiate our logger
log = logging.getLogger(LOGGERNAME)

#: Our config setting for our logger
DEFAULT_LOGGING_DICT = {
    "version": 1,
    "disable_existing_loggers": False,
    "formatters": {
        "standard": {"format": "[%(levelname)s] %(funcName)s: %(message)s"},
    },
    "handlers": {
        "default": {
            "level": "NOTSET",
            "formatter": "standard",
            "class": "logging.StreamHandler",
        },
    },
    "loggers": {
        LOGGERNAME: {"handlers": ["default"], "level": "INFO", "propagate": True}
    },
}

#: Map verbosity level (int) to log level
LOGLEVELS = {
    None: logging.WARNING,  # 0
    0: logging.WARNING,
    1: logging.INFO,
    2: logging.DEBUG,
}


###
# Regular Expressions
SPACE = r"[ \t\r\n]"  # whitespace
S = "%s+" % SPACE  # One or more whitespace
opS = "%s*" % SPACE  # Zero or more  whitespace
oS = "%s?" % SPACE  # Optional whitespace
NAME = "[a-zA-Z_:][-a-zA-Z0-9._:]*"  # Valid XML name
QSTR = "(?:'[^']*'|\"[^\"]*\")"  # Quoted XML string
QUOTES = "(?:'[^']'|\"[^\"]\")"
SYSTEMLITERAL = "(?P<sysid>%s)" % QSTR
PUBLICLITERAL = (
    r'(?P<pubid>"[-\'\(\)+,./:=?;!*#@$_%% \n\ra-zA-Z0-9]*"|'
    r"'[-\(\)+,./:=?;!*#@$_%% \n\ra-zA-Z0-9]*')"
)
EXTERNALID = (
    """(?:SYSTEM|PUBLIC{S}{PUBLICLITERAL})""" """{S}{SYSTEMLITERAL}"""
).format(**locals())
ENTITY = (
    """<!ENTITY{S}%{S}""" """(?P<PEDecl>{NAME}){S}""" """{EXTERNALID}{opS}>"""
).format(**locals())
r_ENTITY = re.compile(ENTITY, re.VERBOSE | re.DOTALL | re.MULTILINE)
DOCTYPE = (
    """<!DOCTYPE{S}"""
    "(?P<Name>{NAME})"
    "("
    "({S}{EXTERNALID}{opS})?"  # noqa: 127
    r"(?:{S}\[(?P<IntSubset>.*)\])?"  # noqa: 127
    ")?"
    """{opS}>"""
).format(**locals())
r_DOCTYPE = re.compile(DOCTYPE, re.VERBOSE | re.DOTALL | re.MULTILINE)
COMMENTOPEN = re.compile("<!--")
COMMENTCLOSE = re.compile("-->")

#: The main catalog (default)
MAINCATALOG = "/etc/xml/catalog"


class XMLCatalogError(LookupError):
    pass


# class MyEntityResolver(xmlsh.EntityResolver):
#    def __init__(self, *args, **kwargs):
#        super().__init__(*args, **kwargs)
#        log.debug("Init in MyEntityResolver")
#
#    def resolveEntity(self, publicId, systemId):
#        log.debug("Trying to resolve publicid=%r, systemid=%r", publicId, systemId)


def xmlsyntaxcheck(xmlfile):
    """Check if the XML file is well-formed

    :param str xmlfile: XML filename
    :return: Nothing if the XML is well-formed, otherwise it raises
       an exception
    :raises: :class:`xml.sax.SAXParseException`
    """
    log.debug("Try XML parser for XML well-formedness...")
    parser = make_parser()

    # Set several features of the XML parser
    featureset = (
        (xmlsh.feature_validation, False),
        (xmlsh.feature_external_ges, False),
        (xmlsh.feature_external_pes, False),
    )
    for feature, state in featureset:
        parser.setFeature(feature, state)

    parser.setContentHandler(xmlsh.ContentHandler())
    # parser.setEntityResolver(MyEntityResolver())

    # This will fail with a SAXParseException when we have a XML file
    # with syntax errors:
    parser.parse(xmlfile)
    log.debug("XML syntax check ok")


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
        if "<!--" not in content:
            return content
        start = COMMENTOPEN.search(content).start()
        match = COMMENTCLOSE.search(content)
        if not match:
            raise ValueError("ERROR: Missing '-->' in comment!")
        end = match.end()
        # Extract the comment
        comment = content[start:end][4:-3]
        if "--" in comment:
            raise ValueError("ERROR: '--' not allowed in comment")

        # Remove the comment
        content = content[0:start] + content[end:]


def investigate_identifiers(content, args, base=""):
    """Investigate some content string for identifiers

    :param str content: string of internal subset
    :param args: parsed arguments from CLI parser
    :yield:
    """
    for entity in r_ENTITY.finditer(content):
        publicid = entity.group("pubid")
        systemid = entity.group("sysid")
        result = None

        # Remove any quotes from our regex result
        if systemid and (systemid[0] in ("'", '"')):
            systemid = systemid.strip()[1:-1]
        if publicid and (publicid[0] in ("'", '"')):
            publicid = publicid.strip()[1:-1]

        log.debug("publicid=%r, systemid=%r", publicid, systemid)
        if args.skip_public and publicid:
            log.debug(
                "Skipping public parameter entity %s %s",
                publicid,
                systemid,
            )
            continue
        elif publicid is not None:
            log.debug("Investigate public ID %r...", publicid)
            result = xmlcatalog(publicid, args.catalog)
            # check entity
        elif systemid.startswith("http"):
            log.debug("Investigate system <ID> %r...", systemid)
            result = xmlcatalog(systemid, args.catalog)
            log.debug("%s -> %s", systemid, result)
        else:
            log.debug("Investigate local path %r...", systemid)
            result = os.path.join(base, systemid)
            log.debug("%s -> %s", systemid, result)

        yield result


def parse_ent_file(entityfile, args):
    """Parse entity file for other referenced entities

    :param str entityfile: filename to the referenced
                           entity file from XML
    :param args: parsed arguments from CLI parser
    :yield: a filename
    """
    # HINT: This reads the complete file.
    log.debug("Investigate entity file %r...", entityfile)
    base = os.path.dirname(entityfile)
    content = open(entityfile, "r").read()
    yield from investigate_identifiers(content, args, base)


def xmlcatalog(uri, catalog=MAINCATALOG, raise_on_error=False):
    """Call xmlcatalog and parse return

    :param uri: the URI to query for
    :param catalog: the catalog file to use
    :param raise_on_error: flag to raise an exception if URL couldn't be found (=True)
       or return None (=False)
    :return: the resolved string or None
    """
    result = None
    if catalog and not os.path.exists(catalog):
        raise XMLCatalogError("Cannot find catalog %r" % catalog)

    log.debug("Trying to find %r in catalog %r", uri, catalog)
    proc = subprocess.run(["xmlcatalog", catalog, uri], stdout=subprocess.PIPE)
    log.debug("subprocess of 'xmlcatalog': %s", proc)
    result = proc.stdout.decode("UTF-8")
    if proc.returncode:
        log.warning("URI %r not found in catalog %r", uri, catalog)
        if raise_on_error:
            raise XMLCatalogError("Problem with xmlcatalog: %s" % result)
        return None

    result = result.split("file://")[-1].strip()
    log.debug("Found %r -> %r", uri, result)

    return result


def preparelines(xmlfile, linenr, showlines=5):
    """Read lines from xmlfile but output only the first 6 lines by default.

    :param xmlfile: path to the XML filename
    :param int linenr: number of lines that should be investigated
    :param int showlines: show lines (couting from zero to showlines)
    :return: list of lines
    """
    lines = []
    with open(xmlfile, "r") as fh:
        for i in range(linenr):
            lines.append(fh.readline())

    if len(lines) > showlines:
        log.debug("First six lines of file %r:", xmlfile)
        for i in range(6):
            log.debug("  line %d: %s", i + 1, lines[i].strip())
    lines = "".join(lines)
    return lines


def getentities(args, linenr=50):
    """Read first 50 lines (default) and return any parameter entity names

    :param args: parsed arguments from CLI parser
    :param int linenr: number of lines that should be investigated
    :return: a list of all found entities
    """
    # Holds a dictionary of (relative) paths as keys and absolut paths as values:
    ents = {}
    seen = set()

    for xmlfile in args.xmlfiles:
        # Checks for well-formed XML
        # does nothing if XML is well-formed, otherwise raises a SAXParseException
        xmlsyntaxcheck(xmlfile)

        # Prepare the first N lines (linenr)
        lines = preparelines(xmlfile, linenr)

        # Try to find matches
        match = r_DOCTYPE.search(lines)
        if match:
            log.debug("Match: %r", match.string)
            log.debug("DOCTYPE and internal subset: %s", match.groupdict())
            internalsubset = match.group("IntSubset")
            if internalsubset is None:
                log.debug("No internal subset found in %r", xmlfile)
                # No internal subset, so continue with next file
                continue

            content = remove_xml_comments(internalsubset)
            base = os.path.dirname(xmlfile)

            log.debug("Looking for entities...")
            for entity in investigate_identifiers(content, args, base):
                # log.debug("Got %r as file", entity)
                if (entity is None) or entity in seen:
                    continue
                seen.add(entity)
                ents[entity] = entity
                log.debug("Found entity %r %s", entity, ents)

    resultdict = ents.copy()
    # Process ents to find other referenced PEs
    for absolute in ents.values():
        for entity in parse_ent_file(absolute, args):
            if entity not in seen:
                seen.add(entity)
                resultdict[entity] = os.path.join(os.path.dirname(absolute), entity)
    return resultdict


def parsecli(cliargs=None):
    """Parse CLI with :class:`argparse.ArgumentParser` and return parsed result

    :param list cliargs: Arguments to parse or None (=use sys.argv)
    :return: parsed CLI result
    :rtype: :class:`argparse.Namespace`
    """
    # Setup logging
    dictConfig(DEFAULT_LOGGING_DICT)

    parser = argparse.ArgumentParser(
        description=__doc__.strip(),
        formatter_class=argparse.RawDescriptionHelpFormatter,  # noqa: E501
        usage="%(prog)s [OPTIONS] XMLFILE...",
    )
    parser.add_argument("--version", action="version", version=__version__)

    parser.add_argument(
        "-v",
        "--verbose",
        action="count",
        help="Raise verbosity level",
    )
    parser.add_argument(
        "-A",
        "--absolute",
        default=False,
        action="store_true",
        help="Make paths absolute (default: %(default)s)",
    )
    parser.add_argument(
        "-P",
        "--skip-no-public",
        dest="skip_public",
        default=True,
        action="store_false",
        help=("Skip parameter entities with public reference (default: %(default)s)"),
    )
    parser.add_argument(
        "-s",
        "--separator",
        default=" ",
        help=(
            "Set the separator between consecutive "
            "filenames (default '%(default)s'). "
            "Use '\\n' and '\\t' to "
            "insert a CR and TAB character. "
        ),
    )
    parser.add_argument(
        "-c",
        "--catalog",
        default=MAINCATALOG,
        help="Use the catalog to query the input",
    )
    parser.add_argument(
        "xmlfiles", metavar="XMLFILES", nargs="+", help="One or more XML files"
    )

    args = parser.parse_args(cliargs)
    level = LOGLEVELS.get(args.verbose, logging.DEBUG)
    # log.setLevel(LOGLEVELS.get(args.verbose, logging.DEBUG))
    log.setLevel(level)
    log.info("CLI args: %s", args)
    log.debug("")
    # Save our parser instance:
    args.parser = parser

    # Fix separators
    if args.separator == "\\n":
        args.separator = "\n"
    elif args.separator == "\\t":
        args.separator = "\t"

    resultargs = []
    for fn in args.xmlfiles:
        if not os.path.exists(fn):
            raise FileNotFoundError(f"File {fn!r} not found")
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

    except (FileNotFoundError, IOError, SAXParseException, XMLCatalogError) as error:
        log.fatal(error)
    return 1


if __name__ == "__main__":
    sys.exit(main())
