"""

>>> import docbook
>>> db = DocBook.EPUB2(f, options)

"""

__all__=["EPUB2", "DBPATH", "DBURI"]
__version__="0.1"
__author__="Thomas Schraitle <toms@opensuse.org>"

import sys
import os
import os.path
import tempfile
import shutil
from lxml import etree
import zipfile
import logging
import errno

# Prepare the logger
log = logging.getLogger('db2epub')


# HACK: This path should be retrieved in a platform independant way 
DBPATH="/usr/share/xml/docbook/stylesheet/nwalsh/current/"
# The official DocBook URI for the stylesheet
DBURI="http://docbook.sourceforge.net/release/xsl/current/"


def mkdir_p(path):
  """Make parent directories as needed"""
  try:
    os.makedirs(path)
  except OSError as err: # Python >2.5
    if err.errno != errno.EEXIST:
       raise


class EPUB2(object):
  """Transforms a DocBook 4 file into a EPUB file, version 2
  """
  CALLOUT_EXT = ".png"
  CALLOUT_PATH = os.path.join("images", "callouts")
  CALLOUT_FULL_PATH= os.path.join(DBPATH, CALLOUT_PATH)
  #
  ADMON_EXT = ".png"
  ADMON_PATH = "images"
  ADMON_FULL_PATH = os.path.join(DBPATH, ADMON_PATH)
  #
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
    self.tmpdir = tempfile.mkdtemp(prefix="db2epub-")
    self.xmlparser = etree.XMLParser(remove_blank_text=True, no_network=True)
    self.xmltree = etree.parse(self.xmlfile, self.xmlparser)
    self.xmltree.xinclude()
    
    # Calculated values for properties
    self._has_callouts = int(self.xmltree.xpath("count(//co)"))
    self._has_admons = int(self.xmltree.xpath("count(//note | //caution | //tip | //warning | //important)"))
    
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
    log.info("Use epubfile=%s" % self.epubfile )
    self.createstructure()
    self.bundle_epub()
    self.render_to_epub()
    #self.cleanup()
  
  def createstructure(self):
    """Create directory structure in temp directory"""
    log.info("createstructure")
    mkdir_p(os.path.join(self.tmpdir, self.OEBPS_DIR))
    mkdir_p(os.path.join(self.tmpdir, self.META_DIR))
    
    if self.has_callouts:
      mkdir_p(os.path.join(self.tmpdir, self.OEBPS_DIR, self.CALLOUT_PATH))
      
    if self.has_admons:
      mkdir_p(os.path.join(self.tmpdir, self.OEBPS_DIR, self.ADMON_PATH))  
    
  
  def render_to_epub(self):
    """Transforms DocBook XML file into HTML chunk files"""
    log.info("render_to_epub")
    # 
    # Create stylesheet parameters:
    # Watch out for correct string quotation
    params= { 
       "chunk.quietly":              self.stringparam("%s" % int(bool(self.verbose)) if self.verbose else 0),
       #"callout.graphics.path":      CALLOUT_PATH,
       #"callout.graphics.number.limit": CALLOUT_EXT,
       "callout.graphics.extension": self.stringparam('1'),
       # Make sure, all the directories contain a trailing slash (IMPORTANT!):
       "base.dir":                   self.stringparam("%s/" % os.path.join(self.tmpdir, self.OEBPS_DIR)),
       "epub.metainf.dir":           self.stringparam("%s/" % os.path.join(self.tmpdir, self.META_DIR)),
       "epub.oebps.dir":             self.stringparam("%s/" % os.path.join(self.tmpdir, self.OEBPS_DIR)),
    }
    if self.cssfile:
      params["html.stylesheet"] = self.stringparam(self.cssfile)
      # log.info("Found css file: %s, %s" % (self.cssfile, params["html.stylesheet"]) )
    if self.otffiles:
      params["epub.embedded.fonts"] =  self.stringparam(" ".join(self.otffiles))
   
    # Prepare for transformation
    self.xslttree = etree.parse(self.myxslt)
    log.debug("Preparing transformation with params: %s\n " \
              "xml: %s: xslt: %s" % ( params, self.xmltree, self.xslttree) )

    transform = etree.XSLT(self.xslttree)    
    result = transform(self.xmltree, **params)
    log.debug("Result of transformation: %s" % result)
    
  def bundle_epub(self):
    """ """
    log.info("bundle_epub")
    self.write_mimetype()
    # self.copy_images()
    self.copy_cssfiles()
    self.copy_admons()
    self.copy_fonts()
    self.copy_callouts()
    # 
    
    return
    # ------------- FIXME
    with zipfile.ZipFile(self.epubfile, mode="w", ) as myzip: # 
      myzip.write(os.path.join(self.tmpdir, "mimetype"), compression=zipfile.ZIP_DEFLATED)
      d=[ i for i in os.listdir(self.tmpdir) if os.path.isdir(os.path.join(self.tmpdir,i)) ]
      for i in d:
        #myzip.write(os.path.join(self.tmpdir, i), zipfile.ZIP_STORED)
        log.info("Directory %s" % i)
        for root, dirs, files in os.walk(os.path.join(self.tmpdir, i)):
           # myzip.write()
           log.info("  root %s" % root)
           for ff in dirs:
              log.info("  dir %s" % ff)
              myzip.write(ff)
           for ff in files:
              log.info("  file %s" % ff)
              myzip.write(ff, zipfile.ZIP_STORED)
           
    
  def copy_cssfiles(self):
    """Copy CSS file into OEBPS directory
       raises IOError if CSS file is not found
    """
    log.info("copy_cssfiles")
    if not self.cssfile:
      return
    log.info("  tmpdir=%s, oebps=%s, css=%s" % (self.tmpdir, self.OEBPS_DIR, self.cssfile))
    # FUTURE: If cssfile will be a list, remove [...]
    for css in [self.cssfile]:
      if not os.path.exists(css):
        raise IOError("CSS file %s not found" % css)
      newcss=os.path.join(self.tmpdir, self.OEBPS_DIR, os.path.basename(css))
      log.info("  From %s to %s" % (css, newcss) )
      shutil.copyfile(css, newcss)
  
  def copy_admons(self):
    """Copy admonition files into OEBPS/admons directory
    """
    log.info("copy_admons")
    if not self.has_admons:
       return
    #
    admons=[ "%s%s" % (os.path.join(self.ADMON_FULL_PATH, a), self.ADMON_EXT)  for a in ('important', 'warning', 'tip', 'caution', 'note')]
    
    # callouts.sort()
    for img in admons:
      newimg=os.path.join(self.tmpdir, self.OEBPS_DIR, self.ADMON_PATH, os.path.basename(img))
      log.info("  From %s to %s" % (img, newimg) )
      shutil.copyfile(img, newimg)

     
  def copy_fonts(self):
    # FIXME
    pass
  
  def copy_callouts(self):
    """Copy callout files"""
    log.info("copy_callouts")
    if not self.has_callouts:
      return

    # add only those callouts which ends with CALLOUT_EXT
    callouts=[ os.path.join(self.CALLOUT_FULL_PATH,c) for c in os.listdir(self.CALLOUT_FULL_PATH) if c.endswith(self.CALLOUT_EXT) ]
    # callouts.sort()
    for img in callouts:
      newimg=os.path.join(self.tmpdir, self.OEBPS_DIR, self.CALLOUT_PATH, os.path.basename(img))
      log.info("  From %s to %s" % (img, newimg) )
      shutil.copyfile(img, newimg)
    
  
  def get_image_refs(self):
    """Returns a list of image filenames"""
    imagedata = self.xmltree.findall("//imagedata")
    return [ i.attrib["fileref"] for i in imagedata if i.attrib.get("fileref") ]
  
  @property
  def has_callouts(self):
    """Checks, if the document contains any co elements in screen or programlisting (property)"""
    return bool(self._has_callouts)
 
  @property
  def has_admons(self):
    """Checks, if the document contains any admonition elements (property)"""
    return bool(self._has_admons)
 
  def write_mimetype(self):
    """Write the mimetype file and returns the absolute path of the file 'mimetype'"""
    log.info("write_mimetype")
    filename = os.path.join(self.tmpdir, "mimetype")
    file(filename, "w").write(self.MIMETYPE)
    return filename
  
  def cleanup(self):
    """Cleanup temporary directory"""
    shutil.rmtree(self.tmpdir) # ignore_errors=
    
# EOF