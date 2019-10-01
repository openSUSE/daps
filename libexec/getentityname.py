#!/usr/bin/python3
# -*- coding: utf-8 -*-
#
# Copyright (C) 2012-2019 SUSE Linux GmbH
#
# Author:
# Thomas Schraitle <toms at opensuse dot org>
#

import os.path
import re
import sys
import argparse


__proc__ = os.path.basename(sys.argv[0])
__version__ = "0.9.0"
__author__="Thomas Schraitle <thomas DOT schraitle AT suse DOT de>"
__license__="GPL"
__doc__= """%(cmd)s [OPTIONS] XMLFILE(S)

This script finds every external entity in the internal subset
of the DTD, for example:

 <!DOCTYPE book PUBLIC 
      "-//OASIS//DTD DocBook XML V4.4//EN"
      "http://www.docbook.org/xml/4.4/docbookx.dtd"
 [
   <!-- The external subset -->
   <!ENTITY %% entities SYSTEM "entity-decl.ent">
   %%entities;
   <!ENTITY %% entities SYSTEM "foo.ent">
   %%foo.ent;
 ]>

The output will be:
entity-decl.ent foo.ent

The script detects XML comments inside the internal subset and removes them.
""".format(cmd=__proc__)

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

   def getEntityList(self):
      return self.ents

   def resolveEntity(self, publicId, systemId):
      """Print the system identifier only, ignoring the public"""
      if publicId==None:
        dirname = os.path.dirname(self.filename)

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
    f = os.path.abspath(f)
    if not os.path.exists(f):
      print("ERROR: File »%s« not found!" % sys.argv[1], file=sys.stderr)
      sys.exit(10)
    parser = make_parser()# ["drv_expat"]
    cwd=os.getcwd()
    os.chdir(os.path.dirname(f))
    parser.setEntityResolver(MyEntityResolver(f, ents))
    parser.parse(f)
    os.chdir(cwd)

  return ents


def getFirstEntity(args):
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
  _PEDecl = '<!ENTITY' + _S + '%' + _S + '(?P<PEDecl>' + \
            _Name + ')' + _S + _PEDef + _oS + '>'
  
  __dtd = r"""<!DOCTYPE""" \
          r"""%(spc)s+(?P<Name>%(_Name)s)""" \
          r"""%(spc)s+(?P<Type>PUBLIC|SYSTEM)""" \
          r"""%(spc)s+(?P<ExternalID>.*)"""  \
          r"""%(spc)s+\[(?P<IntSubset>.*)\]%(spc)s?>""" % { 
                   'spc':   _space,
                   '_Name':    _Name}

  doctype = re.compile(__dtd)
  entities = re.compile(_PEDecl)
  ents=[]

  for f in args.xmlfiles:
    name = open(f, 'r')
    lines=[]
    for i in range(50):
      lines.append( name.readline() )
    lines = "".join(lines)

    match_obj = re.search(__dtd, lines,  re.DOTALL)
    if match_obj:
      # Only process, when the internal subset has been found:
      Content = match_obj.group('IntSubset')
      #Name = match_obj.group('Name')
      #Type = match_obj.group('Type')
      #ExternalID = match_obj.group('ExternalID')
      # print("Name:    %s" % Name, file=sys.stderr)
      # print("Type:    %s" % Type, file=sys.stderr)
      # print("ExtId:   %s" % ExternalID, file=sys.stderr)
      # print("Content: %s" % Content, file=sys.stderr)

      if Content:
        # Only process, when there is an internal subset
        # Find comments without reg expressions:
        cs = Content.find("<!--")
        ce = Content.find("-->")

        if (cs < 0 and ce >= 0) or (cs >=0 and ce <0):
          print("ERROR: Wrong XML comment found!", file=sys.stderr)
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

  return ents


def main():
    """ """
    # Create global options parser.
    #global gparser # only need for 'help' command (optional)
    #import optparse
    parser = argparse.ArgumentParser(description=__doc__.strip())
    parser.add_argument("--version",
                        action="version",
                        version="%%(prog)s %s" % __version__[11:-2])
    parser.add_argument("-f", "--only-first",
        dest="first",
        default=False,
        action="store_true",
        help="Never prompt (default %(default)s)")
    parser.add_argument("-u", "--unique",
        dest="unique",
        default=True,
        action="store_false",
        help="Make entity filenames unique (default %(default)s")
    parser.add_argument("-s", "--separator",
        dest="separator",

        default=" ",
        help="Set the separator between consecutive filenames (default '%(default)s'). Use '\\n' and '\\t' to insert a CR and TAB character.")
    parser.add_argument("xmlfiles",
                        metavar="XMLFILES",
                        nargs="+",
                        help="One ore more XML files to search for entities")

    args = parser.parse_args()
    if args.separator == '\\n':
      args.separator = '\n'
    elif args.separator == '\\t':
      args.separator = '\t'

    return parser, args


if __name__=="__main__":
  try:
    p, args = main()

    if not args:
      p.print_usage()
      sys.exit(1)

    if args.first:
      ents = getFirstEntity(args)
    else:
      ents = getAllEntities(args)
    print(joinEnts(args.unique, args.separator, ents))

  except SAXParseException as e:
      print(e, file=sys.stderr)
      print(" ".join(resultEntities))
  except IOError as e:
      print(e, file=sys.stderr)

