#!/usr/bin/python3
# -*- coding: utf-8 -*-
#
# Copyright (C) 2012-2019 SUSE Linux GmbH
#
# Author:
# Thomas Schraitle <toms at opensuse dot org>
#

import argparse
import os.path
import re
import sys

import logging
from logging.config import dictConfig

__proc__ = os.path.basename(sys.argv[0])
__version__ = "1.0.0"
__author__="Thomas Schraitle <thomas DOT schraitle AT suse DOT de>"
__license__="GPL"
__doc__= """
This script finds every external entity in the internal subset
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


from xml.sax import make_parser, handler, SAXParseException
import tempfile

# Contains the filenames found of every external entities:
resultEntities=[]

class  MyEntityResolver(handler.EntityResolver):
   """Prints the system identifier of an external entity"""
   def __init__(self, filename, ents=[]):
      """Constructor of this class
      filename - XML file to be investigated """
      # Create a temporary file object
      self.tmpfile=tempfile.NamedTemporaryFile()
      self.filename=os.path.abspath(filename)
      self.ents = ents
      # log.debug("Created %s", type(self).__name__)

   def getEntityList(self):
      log.debug("Return found entities: %s", self.ents)
      return self.ents

   def resolveEntity(self, publicId, systemId):
      """Print the system identifier only, ignoring the public"""
      # log.debug("resolving entitiy publicID=%r, systemID=%r", publicId, systemId)
      if publicId==None:
        dirname = os.path.dirname(self.filename)

        print("dirname:", dirname)

        if not systemId in resultEntities:
            # Remove # to enable absolute paths in self.ents list:
            #self.ents.append( os.path.abspath(os.path.join( dirname, systemId)) ) 
            self.ents.append(systemId)
        return os.path.abspath(os.path.join( dirname, systemId))

      elif publicId.startswith("-//OASIS//") or \
           publicId.startswith("-//Novell//DTD"):
        # Return a temporary filename without meaningful content
        return self.tmpfile.name 

      # ---------------------------------------------------
      #elif publicId.startswith("-//OASIS//DTD DocBook") or \
      #     publicId.startswith("-//OASIS//ENTITIES"):
      #  dtdversion=publicId.split("//")[2][-3:]
      #  filename = os.path.basename(systemId)
      #  return "/usr/share/xml/docbook/schema/dtd/%s/%s" % (dtdversion ,filename)
      #elif publicId.startswith("ISO 8879:1986//"):
      #  dtdversion=publicId.split("//")[2][-3:]
      #  filename = os.path.basename(systemId)
      #  print >> sys.stderr, "dtdversion=%s, filename=%s, file=%s" % \
      #   (dtdversion, filename, "/usr/share/xml/entities/xmlcharent/0.3/%s" % filename)
      #  return "/usr/share/xml/entities/xmlcharent/0.3/%s" % filename

      else:
        # Should not happen...
        return ""


def joinEnts(unique, sep, ents):
  """Returns a string of names, separated by 'sep'."""
  if unique:
    return sep.join(list(set(ents)))
  else:
    return sep.join(ents)


def getAllEntities(args):
  """Collects *all* entities in XML files"""
  ents=[]
  for f in args.xmlfiles:
    log.debug(f"Investigating {f!r}")
    if not os.path.exists(f):
      log.fatal("ERROR: File »%s« not found!", f)
      sys.exit(10)

    parser = make_parser()# ["drv_expat"]
    cwd=os.getcwd()
    os.chdir(os.path.dirname(f))
    log.debug("Parser: %s for %r", parser, os.path.basename(f))
    parser.setEntityResolver(MyEntityResolver(f, ents))
    parser.parse(f)
    os.chdir(cwd)

  print(joinEnts(args.unique, args.separator, ents))


def dtdmatcher():
  # Mostly taken from xmllib.py
  # Regular expressions
  _space = '[ \t\r\n]'                    # whitespace
  _S = '%s+'  % _space                    # One or more whitespace
  _opS = '%s*'% _space                    # Zero or more  whitespace
  _oS = '%s?' % _space                    # Optional whitespace
  _Name = '[a-zA-Z_:][-a-zA-Z0-9._:]*'    # Valid XML name
  _QStr = "(?:'[^']*'|\"[^\"]*\")"        # Quoted XML string
  _quotes = "(?:'[^']'|\"[^\"]\")"
  _SystemLiteral = '(?P<%s>'+_QStr+')'
  _PublicLiteral = '(?P<%s>"[-\'\(\)+,./:=?;!*#@$_%% \n\ra-zA-Z0-9]*"|' \
                          "'[-\(\)+,./:=?;!*#@$_%% \n\ra-zA-Z0-9]*')" % 'pubid'
  _ExternalId = 'SYSTEM' +_S+'('+_SystemLiteral % 'syslit'+')' \
                '|' + \
                'PUBLIC'+_S+'('+_PublicLiteral+_S+_SystemLiteral % 'psyslit'+')'
  # Normally, this is the EBNF from the XML Spec:
  # [74] PEDef     ::=      EntityValue | ExternalID
  # As we are only interested in ExternalIDs, we omit EntityValue
  _PEDef = _ExternalId

  # [72] PEDecl     ::=     '<!ENTITY' S '%' S Name S PEDef S? '>'
  #_PEDecl = '<!ENTITY' + _S + '%' + _S + '(?P<PEDecl>' + \
  #          _Name + ')' + _S + _PEDef + _oS + '>'
  _PEDecl = f"""!ENTITY{_S}%{_S}(?P<PEDecl>{_Name}){_S}{_PEDef}{_oS}>"""

  # r"""%(spc)s+(?:(?P<Type>PUBLIC|SYSTEM)""" \
  # r"""%(spc)s+(?P<ExternalID>.*))?"""  \
  __dtd = ("<!DOCTYPE"
          f"{_space}+(?P<Name>{_Name})"
          fr"""{_space}+\[(?P<IntSubset>.*)\]{_space}?>"""
          )

  doctype = re.compile(__dtd,  re.DOTALL)
  entities = re.compile(_PEDecl)

  return doctype, entities


def getFirstEntity(args):
  doctype, entities = dtdmatcher()
  ents=[]

  for f in args.xmlfiles:
    # print >> sys.stderr, "Analyzing %s" % f
    lines = []
    with open(f, 'r') as fh:
        for i in range(50):
            lines.append(fh.readline())
    log.debug("First two lines: %s%s", lines[0], lines[1])
    lines = "".join(lines)

    match_obj = re.search(__dtd, lines,  re.DOTALL)
    log.debug("")
    log.debug("Match obj: %s", match_obj)
    if match_obj:
      # Only process, when the internal subset has been found:
      Content = match_obj.group('IntSubset')
      #Name = match_obj.group('Name')
      #Type = match_obj.group('Type')
      #ExternalID = match_obj.group('ExternalID')

      #print >> sys.stderr, "Name:    %s" % Name
      #print >> sys.stderr,"Type:    %s" % Type
      #print >> sys.stderr,"ExtId:   %s" % ExternalID
      #print >> sys.stderr,"Content: %s" % Content

      if Content:
        # Only process, when there is an internal subset
        # Find comments without reg expressions:
        cs = Content.find("<!--")
        ce = Content.find("-->")

        if (cs < 0 and ce >= 0) or (cs >=0 and ce <0):
          log.fatal("ERROR: Wrong XML comment found!")
          sys.exit(100)
        elif cs >= 0 and ce >= 0:
          # If XML comment found, remove the substring (cs,ce)
          assert cs < ce, "ERROR: Internal error. " \
                "Start index of XML comment must be smaller than end index!"
          Content = Content[1:cs] +  Content[ce+3:]

        # Now it's easy. Search for all entity declarations in the internal subset:
        x=entities.findall(Content)
        for j in x:
          if j[1][0] in  ('"', "'"):
            # Chop quotes
            ents.append( j[1][1:-1] )
          else:
            ents.append(j[1])

  print(joinEnts(args.unique, args.separator, ents))


def remove_xml_comment(content):
    """Remove first XML comments (<!-- ... -->) in a string

    :param str content: the content with possible XML comments
    :return: a string without any XML comments
    :rtype: str

    >>> remove_xml_comment('<!-- hello -->World')
    'World'
    >>> remove_xml_comment('<!-- h -->World<!-- is it? -->')
    'World<!-- is it? -->'
    >>> remove_xml_comment('<!-- hello')
    Traceback (most recent call last)
    ...
    ValueError: ERROR: Wrong XML comment found!
    """
    # Only process, when there is an internal subset
    # Find comments without reg expressions:
    cs = content.find("<!--")
    ce = content.find("-->")
    if (cs < 0 and ce >= 0) or (cs >=0 and ce <0):
        raise ValueError("ERROR: Wrong XML comment found!")
          # log.fatal("ERROR: Wrong XML comment found!")
          # sys.exit(100)
    elif cs >= 0 and ce >= 0:
        # If XML comment found, remove the substring (cs,ce)
        assert cs < ce, "ERROR: Internal error. " \
            "Start index of XML comment must be smaller than end index!"
        content = content[1:cs] +  content[ce+3:]
    return content


def getEntities(args, linenr=50):
    """Read first 50 lines (default) and return any parameter entity names

    :param args:
    :param int linenr: number of lines that should be investigated
    :return: a list of all found entities
    """
    ents = []
    seen = set()
    doctype, entities = dtdmatcher()

    for file in args.xmlfiles:
        # Prepare the lines:
        lines = []
        with open(file, 'r') as fh:
            for i in range(linenr):
                lines.append(fh.readline())
        if len(lines) > 5:
            log.debug("First five lines:")
            for i in range(5):
                log.debug(f"  line {i}: %s", lines[i].strip())
        # log.debug("  line 1: %s", lines[0].strip())
        # log.debug("  line 2: %s", lines[1].strip())
        lines = "".join(lines)

        # Try to find matches
        match = doctype.search(lines)
        log.debug("Match: %s", match)
        if match:
            content = match['IntSubset']
            content = remove_xml_comment(content)

            log.debug("Looking for entities...")
            for match in entities.finditer(content):
                # Remove quotes:
                entity = match['syslit'][1:-1]
                log.debug("Found entity %r", entity)
                if entity in seen:
                    continue
                seen.add(entity)
                if entity.startswith("/"):
                    ents.append(entity)
                elif entity.startswith("http"):
                    ents.append(entity)
                else:
                    dirname = os.path.dirname(file)
                    ents.append(os.path.join(dirname, entity))
                log.debug("ents: %s", ents)
    # FIXME: Process ents to find other referenced PEs
    return ents


def parsecli(cliargs=None):
    """Parse CLI with :class:`argparse.ArgumentParser` and return parsed result

    :param list cliargs: Arguments to parse or None (=use sys.argv)
    :return: parsed CLI result
    :rtype: :class:`argparse.Namespace`
    """
    # Setup logging
    dictConfig(DEFAULT_LOGGING_DICT)

    parser = argparse.ArgumentParser(description=__doc__.strip(), \
                                     formatter_class=argparse.RawDescriptionHelpFormatter,
                                     usage='%(prog)s [OPTIONS] XMLFILE...')
    parser.add_argument('-v', '--verbose',
                        action="count",
                        help="Raise verbosity level",
                        )
    parser.add_argument("-f", "--only-first",
                        dest="first",
                        default=False,
                        action="store_true",
                        help="Never prompt (default %(default)s)")
    parser.add_argument("-u", "--unique",
                        default=True,
                        action="store_false",
                        help="Make entity filenames unique (default %(default)s)")
    parser.add_argument("-s", "--separator",
                        default=' ',
                        help=("Set the separator between consecutive filenames "
                              "(default '%(default)s'). Use '\\n' and '\\t' to "
                              "insert a CR and TAB character.")
                        )
    parser.add_argument("-t", "--test",
                        default=False,
                        action="store_true",
                        help="Just testing"
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


def test():
    xml = """<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE chapter
[
  <!-- comment -->
  <!ENTITY % entities SYSTEM "entity-decl.ent">
   %entities;
  <!ENTITY % general SYSTEM "general-decl.ent"
  %general;
  %
]>"""
    doctype, entities = dtdmatcher()
    # print(">>> doctype:", doctype)
    match = doctype.search(xml)
    print(">>> doctype?", match)
    if match is not None:
        print("  >>> pos match:", match.groupdict())
    match = entities.findall(xml, re.DOTALL)
    print(">>> entities?")
    if match is not None:
        print("  >>> pos match:", match)
    import doctest
    doctest.testmod(optionflags=doctest.REPORT_NDIFF
                                |doctest.IGNORE_EXCEPTION_DETAIL
                                |doctest.NORMALIZE_WHITESPACE)


def main():
  """Entry point for the application script

    :param list cliargs: Arguments to parse or None (=use :class:`sys.argv`)
    :return: error code; 0 => everything was succesfull, !=0 => error
    :rtype: int
  """
  try:
    args = parsecli()

    if args.test:
        test()
        sys.exit(1)

    if not args:
      args.parser.print_usage()
      sys.exit(1)

    ents = getEntities(args)
    print(joinEnts(args.unique, args.separator, ents))
    print("-"*40)
    if args.first:
      getFirstEntity(args)
    else:
      getAllEntities(args)
    return 0

  except SAXParseException as error:
      log.fatal(error)
      print(" ".join(resultEntities))
  except IOError as error:
      log.fatal(error)

  return 1


if __name__=="__main__":
    sys.exit(main())
