#!/usr/bin/python
# -*- coding: UTF-8 -*-
"""
  pxsltproc.py Python "replacement" for xsltproc, but with the needed
  extension function for DocBook compatibility.

  depends on the packages:
    - python-lxml (see http://software.opensuse.org/download/home:/thomas-schraitle/)
    - python-imaging
    - python-elementtree
"""

import sys

try:
    from lxml import etree
except ImportError:
    print >> sys.stderr, \
    "ERROR: I need the Python lxml module.\n"\
    ""\
    "       See http://codespeak.net/lxml for more information."
    sys.exit(100)
try:
    import Image
except ImportError:
    print >> sys.stderr, \
    "ERROR: I need the Python Imaging Library.\n"\
    "       See http://effbot.org/zone/pil-index.htm"
    sys.exit(100)

import os
import os.path
from StringIO import StringIO
from optparse import OptionParser


VERSION=" ".join("$Id: pxsltproc.py 11457 2006-08-22 06:58:52Z toms $".split()[2:-3])

# These are some namespaces that are useful for DocBook documents
# (Some could be deleted)
namespaces = {'xverb': "com.nwalsh.xalan.Verbatim",
              'sverb': "http://nwalsh.com/xslt/ext/com.nwalsh.saxon.Verbatim",
              'lxslt': "http://xml.apache.org/xslt",
              'xtext': "com.nwalsh.xalan.Text",
              'db':    "http://docbook.org/ns/docbook",
              'xlink': "http://www.w3.org/1999/xlink",
              'i':     "urn:cz-kosek:functions:index",
              'k':     "java:com.isogen.saxoni18n.Saxoni18nService"}

class MyExtension:
    """See http://codespeak.net/lxml/extensions.html"""
    def numberLines(self, _, arg):
        print >> sys.stderr, arg
        return "numberLines", "numberLines: %s" % args
    def insertCallouts(self, _, arg):
        print >> sys.stderr, "insertCallouts: %s" % arg
        return "insertCallouts", args


def main():
    parser = OptionParser(usage="%prog [options] stylesheet file",
                          version="%s: %s" % \
                                  ("%prog", VERSION )
                         )

    parser.set_defaults(xinclude=False)
    parser.add_option("", "--xinclude",
           dest="xinclude",
           action="store_true",
           # default=False,
           help="do XInclude processing on document intput")
    # parser.set_defaults(output=sys.stdout)
    parser.add_option("-o", "--output",
           dest="output",
           help="save to a given file")
    parser.add_option("", "--stringparam",
           action="append",
           dest="stringparam",
           nargs=2,
           help="pass a (parameter, UTF8 string value) pair")
    (options, args) = parser.parse_args()

    if len(args) != 2:
        parser.error("Need stylesheet and XML file.")

    print >> sys.stderr, options, args
    checkIfFileExists(parser, args)
    Transform(parser, options, args)

def checkIfFileExists(p, args):
    # args[0] = stylesheet
    # args[1:n] = XML File(s)
    if not os.path.exists(args[0]):
        p.error("Stylesheet '%s' not found." % args[0])
    for f in args[1:]:
        if not os.path.exists(f):
            p.error("XML file '%s' not found." % f)

def Transform(p, options, args):
    xsltfilename = args[0]
    xmlfilename = args[1]

    # Install our parser
    parser = etree.XMLParser(ns_clean=True, no_network=True)

    # Propagate the XSLT stylesheet
    xslt_tree = etree.parse(open(xsltfilename), parser)

    # Propagate the XML document
    doc = etree.parse(open(xmlfilename), parser)
    if options.xinclude:
        doc.xinclude()

    ac = etree.XSLTAccessControl(read_network=False)
    extensions = etree.Extension( MyExtension(),
                                  ("numberLines", "insertCallouts"),
                                  namespaces["sverb"] )
    transform = etree.XSLT(xslt_tree,
                           access_control=ac,
                           # namespaces=namespaces,
                           extensions=extensions)
    result = transform.apply(doc)

    if options.output != None:
       output = open(options.output, "w")
    else:
       output = sys.stdout

    result.write(output)


if __name__=="__main__":
    main()
