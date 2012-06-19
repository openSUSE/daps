"""

>>> import docbook
>>> db = DocBook.EPUB2(f, options)

"""

__all__=["EPUB2", "DBPATH"]
__version__="0.1"
__author__="Thomas Schraitle <toms@opensuse.org>"

import sys
import os
import os.path
import tempfile
import shutil
from lxml import etree
import zipfile

# HACK: This path should be retrieved in a platform independant way 
DBPATH="/usr/share/xml/docbook/stylesheet/nwalsh/current/"

class EPUB2(object):
  """Transforms a DocBook 4 file into a EPUB file, version 2
  """
  CALLOUT_EXT = ".png"
  CALLOUT_PATH = os.path.join("images", "callouts")
  # CALLOUT_ABSPATH=
  MIMETYPE = "application/epub+zip"
  META_DIR = "META-INF"
  OEBPS_DIR = "OEBPS"
  STYLESHEET=unicode(os.path.join(DBPATH, "epub", "docbook.xsl"))
  
  def __init__(self, xmlfile, options):
    """Initalizes the EPUB class
       
       xmlfile: DocBook file to render (will be make absolute)
       options: Option parser result from optparse
    """
    self.xmlfile = os.path.abspath(xmlfile)
    self.tmpdir = tempfile.mkdtemp(suffix="-epub")
    self.xmlparser = etree.XMLParser(remove_blank_text=True, no_network=True)
    self.xmltree = etree.parse(self.xmlfile, self.xmlparser)
    self.xmltree.xinclude()
    
    # We introduce our own variables to make it independant from options
    # self.options = options
    self.verbose = options.VERBOSE
    self.cssfile = options.CSSFILE
    self.otffiles = options.OTFFILES
    self.myxslt  = options.CUSTOMIZATIONLAYER if options.CUSTOMIZATIONLAYER else self.STYLESHEET
    self.epubfile = options.OUTPUTFILE if options.OUTPUTFILE else os.path.splitext(self.xmlfile)[0]+".epub"
  
  def stringparam(self, string):
    """Wrap string values in single quotes before passing it to XSLT"""
    return "'%s'" % string

  def render(self, epubfile=None):
    """Render DocBook file to EPUB"""
    if epubfile:
      self.epubfile = epubfile
    if self.verbose: print >> sys.stderr, self.epubfile
    self.render_to_epub()
    #self.bundle_epub()
    #self.cleanup()
  
  def render_to_epub(self):
    """ """
    # Create directory structure:
    os.mkdir(os.path.join(self.tmpdir, self.OEBPS_DIR))
    os.mkdir(os.path.join(self.tmpdir, self.META_DIR))
    # 
    # Create stylesheet parameters:
    # Watch out for correct string quotation
    params= { 
       "chunk.quietly":              "%s" % int(bool(self.verbose)) if self.verbose else 0,
       #"callout.graphics.path":      CALLOUT_PATH,
       #"callout.graphics.number.limit": CALLOUT_EXT,
       "callout.graphics.extension": self.stringparam('1'),
       # Make sure, all the directories contain a trailing slash (IMPORTANT!):
       "base.dir":                   self.stringparam("%s/" % os.path.join(self.tmpdir, self.OEBPS_DIR)),
       "epub.metainf.dir":           self.stringparam("%s/" % os.path.join(self.tmpdir, self.META_DIR)),
       "epub.oebps.dir":             self.stringparam("%s/" % os.path.join(self.tmpdir, self.OEBPS_DIR)),
    }
    if self.cssfile:
      params["html.stylesheet"] = self.strparam(self.cssfile)
    if self.otffiles:
      params["epub.embedded.fonts"] =  self.strparam(" ".join(self.otffiles))
   
    
    # Prepare for transformation
    self.xslttree = etree.parse(self.myxslt)
    if self.verbose: print >> sys.stderr, \
      "Preparing transformation with params: %s\n " \
      "xml: %s: xslt: %s" % ( params, self.xmltree, self.xslttree )

    transform = etree.XSLT(self.xslttree)    
    result = self.xmltree, **params)
    if self.verbose: print >> sys.stderr, "Result: %s" % result
    
  def bundle_epub(self):
    """ """
    self.write_mimetype()
    # self.copy_images()
    # self.copy_cssfiles()
    # self.copy_fonts()
    # self.copy_callouts()
    # 
    
    # with zipfile.ZipFile(self.epubfile, mode="w", compression=zipfile.ZIP_DEFLATED ) as myzip:
    
  
  def get_image_refs(self):
    """Returns a list of image filenames"""
    imagedata = self.xmltree.findall("//imagedata")
    return [ i.attrib["fileref"] for i in imagedata if i.attrib.get("fileref") ]
  
  def has_callouts(self):
    """Checks, if the document contains any co elements in screen or programlisting"""
    # bool(len(xmltree.findall("//co")))
    return bool(xmltree.xpath("count(//co)"))
  
  def write_mimetype(self):
    """Write the mimetype file and returns the absolute path of the file 'mimetype'"""
    filename = os.path.join(self.tmpdir, "mimetype")
    file(filename, "w").write(self.MIMETYPE)
    return filename
  
  def cleanup(self):
    """Cleanup temporary directory"""
    shutil.rmtree(self.tmpdir) # ignore_errors=
    
# EOF