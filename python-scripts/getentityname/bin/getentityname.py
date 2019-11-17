#!/usr/bin/python3
# -*- coding: utf-8 -*-
# $Id: getentityname.py 33777 2008-08-08 09:20:06Z toms $
#
# Copyright (C) 2012-2015 SUSE Linux GmbH
#
# Author:
# Thomas Schraitle <toms at opensuse dot org>
#

import os.path
import sys
import optparse

__proc__ = os.path.basename(sys.argv[0])
__version__ = "$Revision: 33777 $"[11:-2]
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


def getAllEntities(options, filenames):
  """Collects *all* entities in XML files"""
  ents=[]
  for f in filenames:
    if not os.path.exists(f):
      print("ERROR: File »%s« not found!" % sys.argv[1], file=sys.stderr)
      sys.exit(10)
    parser = make_parser()# ["drv_expat"]
    cwd=os.getcwd()
    os.chdir(os.path.dirname(f)) 
    parser.setEntityResolver(MyEntityResolver(f, ents))
    parser.parse(f)
    os.chdir(cwd)

  print(joinEnts(options.unique, options.separator, ents))


def getFirstEntity(options, filenames):
  import re
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

  for f in filenames:
    # print >> sys.stderr, "Analyzing %s" % f
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

  print(joinEnts(options.unique, options.separator, ents))


def main(cliargs=None):
    """ """
    # Create global options parser.
    #global gparser # only need for 'help' command (optional)
    #import optparse
    parser = optparse.OptionParser(__doc__.strip(), \
                                   version="Revision %s" % __version__[11:-2])
    parser.add_option("-f", "--only-first",
        dest="first",
        action="store_true",
        help="Never prompt (default %default)")
    parser.add_option("-u", "--unique",
        dest="unique",
        action="store_false",
        help="Make entity filenames unique (default %default)")
    parser.add_option("-s", "--separator",
        dest="separator",
        help="Set the separator between consecutive filenames (default '%default'). Use '\\n' and '\\t' to insert a CR and TAB character.")

    parser.set_defaults( \
        first=False,
        unique=True,
        separator=' ',
      )
    options, args = parser.parse_args(cliargs)
    if options.separator == '\\n':
      options.separator = '\n'
    elif options.separator == '\\t':
      options.separator = '\t'
 
    resultargs = []
    for fn in args:
        if not os.path.isabs(fn):
            fn = os.path.abspath(fn)
        resultargs.append(fn)

    return parser, options, resultargs


if __name__=="__main__":
  try:
    p, options, args = main()

    if not args:
      p.print_usage()
      sys.exit(1)
      
    if options.first:
      getFirstEntity(options, args)
    else:
      getAllEntities(options, args)
  except SAXParseException as e:
      print(e, file=sys.stderr)
      print(" ".join(resultEntities))
  except IOError as e:
      print(e, file=sys.stderr)

