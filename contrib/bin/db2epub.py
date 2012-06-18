#!/usr/bin/python
"""
This program converts DocBook documents into .epub files
"""

__version__="0.1"
__author__="Thomas Schraitle <toms@opensuse.org>"

import sys
import os
import optparse

#IMPORTDIR=os.path.dirname(__file__)
#sys.path.insert(0, IMPORTDIR)
import docbook


def main():
  parser = optparse.OptionParser(version="%prog "+__version__, epilog="See also ")
  parser.add_option("-c", "--css",
     dest="CSSFILE",
     help="Use CSSFILE for CSS on generated XHTML")
  parser.add_option("-d", "--debug",
     dest="DEBUG",
     help="Show debugging output")
  parser.add_option("-f", "--font",
     dest="OTFFILES",
     action="append",
     # type="str",
     help="Embed OTF FILE in .epub")
  parser.add_option("-o", "--output",
     dest="OUTPUTFILE",
     help="Output ePub file as OUTPUT FILE")
  parser.add_option("-s", "--stylesheet",
     dest="CUSTOMIZATIONLAYER",
     help="Use XSL FILE as a customization layer (imports epub/docbook.xsl)")
  parser.add_option("-v", "--verbose", 
     dest="VERBOSE",
     #action="store_true",
     action="count",
     help="Make output verbose")
  parser.set_defaults(VERBOSE=False,
     DEBUG=False,
     CSSFILE=None,
     # OTFFILES=[],
     CUSTOMIZATION_LAYER=None,
     OUTPUTFILE=None,
     )  
  (options, args)= parser.parse_args()
  print options, args
  if not len(args):
    parser.print_help()
    sys.exit(1)
  return (options, args, parser)

  
if __name__=="__main__":
  options, args, parser = main()
  
  try:
    for f in args:
      if options.VERBOSE > 0: print >> sys.stderr, "File: %s" % f
      d = DocBook.EPUB2(f, options)
      epubfile = options.OUTPUTFILE if options.OUTPUTFILE else os.path.splitext(f)[0]+".epub"
      if options.VERBOSE > 0: print >> sys.stderr, "Rendering DocBook file %s to %s" % (f, epubfile)
      d.render(epubfile)
      
  except IOError, e:
    print >> sys.stderr, e
    sys.exit(10)
  except KeyboardInterrupt:
    sys.exit(2)
    
# EOF