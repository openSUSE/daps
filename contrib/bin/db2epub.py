#!/usr/bin/python
"""
This program converts DocBook documents into .epub files
"""

__version__="0.1"
__author__="Thomas Schraitle <toms@opensuse.org>"

import sys
import os
import optparse

import logging

#IMPORTDIR=os.path.dirname(__file__)
#sys.path.insert(0, IMPORTDIR)
import docbook

log = logging.getLogger('db2epub')
fh=logging.FileHandler('/var/tmp/db2epub.log')
fh.setFormatter(logging.Formatter('%(asctime)s %(levelname)s %(message)s'))
log.addHandler(fh) 
log.setLevel(logging.INFO)
log.addHandler(logging.StreamHandler(sys.stdout))


def main():
  parser = optparse.OptionParser(version="%prog "+__version__, ) # epilog="See also "
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
  parser.add_option("-i", "--image-dir",
     dest="IMAGEDIR",
     help="Points to the image path")
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
     # IMAGEDIR=None,
     CUSTOMIZATIONLAYER=os.path.join(docbook.DBPATH, "epub/docbook.xsl"),
     OUTPUTFILE=None,
     )  
  (options, args)= parser.parse_args()
  # print "Parsed commandline: options=%s, args=%s" % (options, args)
  log.debug("Parsed commandline: options=%s, args=%s" % (options, args) )
  
  if not len(args):
    parser.print_help()
    sys.exit(1)
  
  verbosedict={ 0: logging.NOTSET,
                1: logging.DEBUG,
                2: logging.INFO,
                3: logging.WARN,
                4: logging.ERROR,
                5: logging.CRITICAL,
               }  

  
  log.setLevel( verbosedict.get(options.VERBOSE, logging.DEBUG) ) 

  return (options, args, parser)

  
def opt2dict(options):
  """FUTURE: Converts the result from OptionParser into a dictionary"""
  # Convert options into a string representation
  dictstring = str(options)[1:-1].split(":")
  key = re.compile("'(?P<name>\w+)'" )
  # Extracts all keys which matches to a 'KEY' reg expr
  opts=[ key.search(i).groupdict()["name"] for i in dictlist if key.search(i) ]
  d={}
  for k in opts:
    d[k.lower()] = getattr(options, k)
  return d
  # Only for Python 2.7:
  # return { k: getattr(options,k)  for k in opts  }
  
  
if __name__=="__main__":
  options, args, parser = main()
  
  try:
    for f in args:
      d = docbook.EPUB2(f, options) # **opt2dict(options)
      epubfile = options.OUTPUTFILE if options.OUTPUTFILE else os.path.splitext(f)[0]+".epub"
      d.render(epubfile)      
      if options.VERBOSE > 1: log.warn("Rendered DocBook file %s to %s" % (f, os.path.abspath(epubfile)))
  
  # except etree.XIncludeError, e
  except IOError, e:
    log.critical(e)
    sys.exit(10)
  except docbook.FileNotFoundError, e:
     log.critical(e)
     sys.exit(10)
  except KeyboardInterrupt:
    log.error("Canceled by user.")
    sys.exit(2)
    
# EOF