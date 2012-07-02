#!/usr/bin/python
"""
Transforms a DocBook4 XML file into EPUB2 file

EPUB is defined by the IDPF at www.idpf.org and is made up of 3 standards:
* Open Publication Structure (OPS)
* Open Packaging Format (OPF) 
* Open Container Format (OCF)
"""

__version__="1.0"
__author__="Thomas Schraitle <toms@opensuse.org>"

import sys
import os
import optparse

import logging
import textwrap

#IMPORTDIR=os.path.dirname(__file__)
#sys.path.insert(0, IMPORTDIR)
import docbook
from lxml import etree

log = logging.getLogger('db2epub')
fh=logging.FileHandler('/var/tmp/db2epub.log')
fh.setFormatter(logging.Formatter('%(asctime)s %(levelname)s %(message)s'))
fh.setLevel(logging.DEBUG)
log.addHandler(fh) 
log.setLevel(logging.INFO)
log.addHandler(logging.StreamHandler(sys.stdout))

class IndentedHelpFormatterWithNL(optparse.IndentedHelpFormatter):
  # Source
  # http://groups.google.com/group/comp.lang.python/browse_frm/thread/6df6e6b541a15bc2/09f28e26af0699b1
  def format_description(self, description):
    if not description: return ""
    desc_width = self.width - self.current_indent
    indent = " "*self.current_indent
# the above is still the same
    bits = description.split('\n')
    formatted_bits = [
      textwrap.fill(bit,
        desc_width,
        initial_indent=indent,
        subsequent_indent=indent)
      for bit in bits]
    result = "\n".join(formatted_bits) + "\n"
    return result

  def format_option(self, option):
    # The help for each option consists of two parts:
    #   * the opt strings and metavars
    #   eg. ("-x", or "-fFILENAME, --file=FILENAME")
    #   * the user-supplied help string
    #   eg. ("turn on expert mode", "read data from FILENAME")
    #
    # If possible, we write both of these on the same line:
    #   -x    turn on expert mode
    #
    # But if the opt string list is too long, we put the help
    # string on a second line, indented to the same column it would
    # start in if it fit on the first line.
    #   -fFILENAME, --file=FILENAME
    #       read data from FILENAME
    result = []
    opts = self.option_strings[option]
    opt_width = self.help_position - self.current_indent - 2
    if len(opts) > opt_width:
      opts = "%*s%s\n" % (self.current_indent, "", opts)
      indent_first = self.help_position
    else: # start help on same line as opts
      opts = "%*s%-*s  " % (self.current_indent, "", opt_width, opts)
      indent_first = 0
    result.append(opts)
    if option.help:
      help_text = self.expand_default(option)
# Everything is the same up through here
      help_lines = []
      for para in help_text.split("\n"):
        help_lines.extend(textwrap.wrap(para, self.help_width))
# Everything is the same after here
      result.append("%*s%s\n" % (
        indent_first, "", help_lines[0]))
      result.extend(["%*s%s\n" % (self.help_position, "", line)
        for line in help_lines[1:]])
    elif opts[-1] != "\n":
      result.append("\n")
    return "".join(result) 

def main():
  parser = optparse.OptionParser(version="%prog "+__version__, 
               usage="%prog [options] XMLFILE [XMLFILE...]",
               # version="",
               formatter=IndentedHelpFormatterWithNL(),
               description=__doc__.strip()) # epilog="See also "
  parser.add_option("-c", "--css",
     dest="CSSFILE",
     help="Use CSSFILE for CSS on generated XHTML")
  #parser.add_option("-d", "--debug",
  #   dest="DEBUG",
  #   help="Show debugging output")
  parser.add_option("-f", "--font",
     dest="OTFFILES",
     action="append",
     # type="str",
     help="Embed OTF FILE in .epub")
  parser.add_option("-i", "--image-dir",
     dest="IMAGEDIR",
     help="Points to the image path")
  parser.add_option("-d", "--dtd",
     dest="DTD",
     help="Validate with respective DTD")
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
  parser.add_option("-k", "--keep-temp",
     dest="KEEP_TEMP",
     action="store_true",
     help="Keep temporary directory for debugging reason (default: %default)")
  parser.set_defaults(VERBOSE=False,
     # DEBUG=False,
     CSSFILE=None,
     KEEP_TEMP=False,
     DTD=None,
     # OTFFILES=[],
     # IMAGEDIR=None,
     CUSTOMIZATIONLAYER=os.path.join(docbook.DBPATH, "epub/docbook.xsl"),
     OUTPUTFILE=None,
     )  
  (options, args)= parser.parse_args()
  log.debug("Parsed commandline: options=%s, args=%s" % (options, args) )
  
  if not len(args):
    parser.print_help()
    sys.exit(1)
  
  verbosedict={ 0: logging.NOTSET,
                1: logging.DEBUG,    # logging.ERROR
                2: logging.INFO,     # logging.WARN
                3: logging.WARN,     # logging.INFO
                4: logging.ERROR,    # logging.DEBUG
                5: logging.CRITICAL, # 
               }  

  
  log.setLevel( verbosedict.get(options.VERBOSE, logging.WARN) ) 

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
  
  except (etree.XIncludeError, etree.XMLSyntaxError), e:
     log.critical("ERROR in file '%s': %s " % (f, e))
     sys.exit(10)
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