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
__license__="GPL 3"
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

###
# Regular Expressions
SPACE = r'[ \t\r\n]'                   # whitespace
S = '%s+'  % SPACE                     # One or more whitespace
opS = '%s*'% SPACE                     # Zero or more  whitespace
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
DOCTYPE = ("""<!DOCTYPE{S}"""
           "(?P<Name>{NAME})"
           "("
             "({S}{EXTERNALID}{opS})?"
             r"(?:{S}\[(?P<IntSubset>.*)\])?"
           ")?"
           """{opS}>"""
          ).format(**locals())


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
COMMENTOPEN = re.compile('<!--')
COMMENTCLOSE = re.compile('-->')


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
    log.debug("Investigating %s", f)
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
  _space = r'[ \t\r\n]'                    # whitespace
  _S = '%s+'  % _space                    # One or more whitespace
  _opS = '%s*'% _space                    # Zero or more  whitespace
  _oS = '%s?' % _space                    # Optional whitespace
  _Name = '[a-zA-Z_:][-a-zA-Z0-9._:]*'    # Valid XML name
  _QStr = "(?:'[^']*'|\"[^\"]*\")"        # Quoted XML string
  _quotes = "(?:'[^']'|\"[^\"]\")"
  _SystemLiteral = '(?P<%s>'+_QStr+')'
#  _PublicLiteral = r'(?P<%s>"[-\'\(\)+,./:=?;!*#@$_%% \n\ra-zA-Z0-9]*"|' \
#                   r"'[-\(\)+,./:=?;!*#@$_%% \n\ra-zA-Z0-9]*')" % 'pubid'

  _PublicLiteral = r'(?P<%s>"[-\'\(\)+,./:=?;!*#@$_%% \n\ra-zA-Z0-9]*"|' \
                   r"'[-\(\)+,./:=?;!*#@$_%% \n\ra-zA-Z0-9]*')"
#  _ExternalId = 'SYSTEM' +_S+'('+_SystemLiteral % 'syslit'+')' \
#                '|' \
#                + 'PUBLIC'+_S+'('+_PublicLiteral % 'pubid' +_S+_SystemLiteral % 'psyslit'+')'
#  _ExternalId = '(?:SYSTEM|PUBLIC' + _S +_PublicLiteral % 'pubid'+ ')' \
#                + _S + _SystemLiteral % 'syslit'
  _ExternalId = """(?:SYSTEM|PUBLIC{_S}{pubid})
                   {_S}{syslit}
                """.format(syslit=_SystemLiteral % 'syslit',
                           pubid=_PublicLiteral % 'pubid',
                           psyslit=_SystemLiteral % 'psyslit',
                           **locals()
                           )

  # Normally, this is the EBNF from the XML Spec:
  # [74] PEDef     ::=      EntityValue | ExternalID
  # As we are only interested in ExternalIDs, we omit EntityValue
  _PEDef = _ExternalId

  # [72] PEDecl     ::=     '<!ENTITY' S '%' S Name S PEDef S? '>'
  #_PEDecl = '<!ENTITY' + _S + '%' + _S + '(?P<PEDecl>' + \
  #          _Name + ')' + _S + _PEDef + _oS + '>'
  _PEDecl = """<!ENTITY{_S}%{_S}
               (?P<PEDecl>{_Name}){_S}
               {_ExternalId}{_oS}>
             """.format(**locals())
             

#  __dtd = ("<!DOCTYPE"
#          "{s}+(?P<Name>{_Name})"
#          "{s}+(?:(?P<Type>PUBLIC|SYSTEM)"
#          "(?P<ExternalID>.*))?"
#          # r"{s}+{extid}"
#          r"""{s}+\[(?P<IntSubset>.*)\]{oS}>"""
#          ).format(
#              s=_space,
#              oS=_oS,
#              extid=_ExternalId,
#              _Name=_Name,
#              )
#
# (?:{_S}(?P<ExternalID>.*))?
  __dtd = r"""<!DOCTYPE{_S}(?P<Name>{_Name}){_S}
             (?:{_ExternalId}{_opS})?
             (?:\[(?P<IntSubset>.*)\])?
             {_oS}>
          """.format(**locals())
  doctype = re.compile(__dtd,  re.DOTALL|re.VERBOSE|re.MULTILINE)
  entities = re.compile(_PEDecl, re.DOTALL|re.VERBOSE|re.MULTILINE)

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


def remove_xml_comments(content):
    """Remove all XML comments (<!-- ... -->) in a string

    :param str content: the content with possible XML comments
    :return: a string without any XML comments
    :rtype: str

    >>> remove_xml_comments('<!-- hello -->World')
    'World'
    >>> remove_xml_comments('<!-- h -->World<!-- is it? -->')
    'World'
    >>> remove_xml_comments('<!--A-->Hi <!--B--> World.')
    'Hi  World.'
    """
    # Extract comment by using
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
                log.debug("  line {%d}: %s", i, lines[i].strip())
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
    parser.add_argument("--version",
                        action="version",
                        version=__version__)

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
