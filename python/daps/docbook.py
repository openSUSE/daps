"""
Library 

Example:
>>> import docbook
>>> db = docbook.EPUB2(f, options)
>>> db.render()

"""

__all__=["EPUB2", "DBPATH", "DBURI", "FileNotFoundError"]
__version__="1.0"
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

from StringIO import StringIO

# Prepare the logger
log = logging.getLogger('db2epub')


# HACK: This path should be retrieved in a platform independant way 
DBPATH="/usr/share/xml/docbook/stylesheet/nwalsh/current/"
# The official DocBook URI for the stylesheet
DBURI="http://docbook.sourceforge.net/release/xsl/current/"
# Namespace for DocBook5
DB5NS="http://docbook.org/ns/docbook"

def mkdir_p(path):
  """Make parent directories as needed"""
  try:
    os.makedirs(path)
  except OSError as err: # Python >2.5
    if err.errno != errno.EEXIST:
       raise

       
class FileNotFoundError(Exception):
   pass

class EPUB2(object):
  """Transforms a DocBook 4 file into a EPUB file, version 2
  """
  # The image path *inside* the EPUB temporary directory
  IMG_SRC_PATH="images"
  #
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
    # We introduce our own variables to make it independant from options
    # self.options = options
    self.verbose = options.VERBOSE
    self.cssfile = options.CSSFILE
    self.otffiles = options.OTFFILES
    self.keeptemp = options.KEEP_TEMP
    self.dtd = options.DTD
    self.xslparams = options.XSLTPARAMS if options.XSLTPARAMS else {}
    self.imgsrcpath = os.path.abspath(options.IMAGEDIR) if options.IMAGEDIR else os.path.abspath(os.path.dirname(self.xmlfile))
    self.myxslt  = options.CUSTOMIZATIONLAYER if options.CUSTOMIZATIONLAYER else self.STYLESHEET
    self.epubfile = options.OUTPUTFILE if options.OUTPUTFILE else os.path.splitext(self.xmlfile)[0]+".epub"
    
    # Set IMG_SRC_PATH only, when --image-dir is NOT set
    # self.IMG_SRC_PATH = "images" if not options.IMAGEDIR else options.IMAGEDIR
    
    self.xmlparser = etree.XMLParser(remove_blank_text=True, no_network=True, dtd_validation=bool(self.dtd))
    self.xmltree = etree.parse(self.xmlfile, self.xmlparser)
    self.xmltree.xinclude()
    
    # Calculated values for properties
    self._has_callouts = int(self.xmltree.xpath("count(//co)"))
    self._has_admons = int(self.xmltree.xpath("count(//note | //caution | //tip | //warning | //important)"))
    self._has_imagobjects = int(self.xmltree.xpath("count(imageobject)"))
  
  
  def getxsltparam(self, param):
    """HACK: Returns the value of the parameter 'param' from the given
       stylesheet.
       
       This may be an expensive call, if there is no catalog resolution
       available. It just creates a stylesheet in memory and applies a
       dummy document to it. The stylesheet just returns the value of
       the parameter as text output.
    """
    
    xslt="""<xsl:stylesheet version="1.0"
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
  <xsl:import href="file://%s"/>
  <xsl:output method="text"/>  
  <xsl:template match="/">
    <xsl:value-of select="$%s"/>
  </xsl:template>  
</xsl:stylesheet>
     """ % ( os.path.abspath(self.myxslt), param)
     
    try:
      # We recycle our xmlparser object and apply our stylesheet
      # to the dummy doc "<x/>". The result is text, so we can
      # use the str() function
      transform = etree.XSLT( etree.XML(xslt, self.xmlparser) )
      result=transform( etree.parse(StringIO("<x/>")))
      return str(result)
    except etree.XSLTApplyError, e:
      # We return None, if parameter 'param' doesn't exist
      return None

  
  
  def stringparam(self, string):
    """Wrap string values in single quotes before passing it to XSLT"""
    return "'%s'" % string

  def render(self, epubfile=None):
    """Render DocBook file to EPUB"""
    if epubfile:
      self.epubfile = epubfile
    log.debug("Use epubfile=%s" % self.epubfile )
    self.createstructure()
    self.render_to_epub()
    self.bundle_epub()
    self.cleanup()
    return True
  
  def createstructure(self):
    """Create directory structure in temp directory"""
    log.debug("createstructure")
    mkdir_p(os.path.join(self.tmpdir, self.OEBPS_DIR))
    mkdir_p(os.path.join(self.tmpdir, self.META_DIR))
    
    if self.has_callouts:
      mkdir_p(os.path.join(self.tmpdir, self.OEBPS_DIR, self.CALLOUT_PATH))
      
    if self.has_admons:
      mkdir_p(os.path.join(self.tmpdir, self.OEBPS_DIR, self.ADMON_PATH))  
    
    mkdir_p(os.path.join(self.tmpdir, self.OEBPS_DIR, self.ADMON_PATH, "admons"))
  
  def render_to_epub(self):
    """Transforms DocBook XML file into HTML chunk files"""
    log.debug("render_to_epub")
    # 
    # Create stylesheet parameters:
    # Watch out for correct string quotation
    params= {
       "chunk.quietly":              self.stringparam("%s" % int(bool(self.verbose)) if self.verbose else 0),
       #"callout.graphics.path":      CALLOUT_PATH,
       #"callout.graphics.number.limit": CALLOUT_EXT,
       #"callout.graphics.extension": self.stringparam('.png'),
       #'admon.graphics.path':        self.stringparam("%s/" % os.path.join(self.ADMON_PATH, "admons")),
       #'img.src.path':               self.stringparam("%s/" % self.IMG_SRC_PATH),
       # Make sure, all the directories contain a trailing slash (IMPORTANT!):
       "base.dir":                   self.stringparam("%s/" % os.path.join(self.tmpdir, self.OEBPS_DIR)),
       #"epub.metainf.dir":           self.stringparam("%s/" % self.META_DIR),
       # "epub.oebps.dir":             self.stringparam("%s/" % self.OEBPS_DIR),
    }
    if self.cssfile:
      params["html.stylesheet"] = self.stringparam(os.path.basename(self.cssfile))
      # log.info("Found css file: %s, %s" % (self.cssfile, params["html.stylesheet"]) )
    if self.otffiles:
      params["epub.embedded.fonts"] =  self.stringparam(",".join([os.path.basename(font) for font in self.otffiles]))
   
    # Update our dict and possibly overwrite any key/values:
    params.update(self.xslparams)
    # Prepare for transformation
    self.xslttree = etree.parse(self.myxslt)
    log.debug("  Preparing transformation with params: %s" %  params )

    pwd=os.getcwd()
    try:
      os.chdir(self.tmpdir)
      transform = etree.XSLT(self.xslttree)
      result = transform(self.xmltree, **params)
      log.debug("  Results from XSLT transformation: %s" % result )
    except etree.XSLTApplyError, e:
      for msg in e.error_log.filter_from_warnings():
         log.debug(msg.message)
         # a xslt tree does not need to come from a file
         #if not '<string>' in msg.filename:
         #   log.error(msg.filename)
         #   log.error(msg.line)
    finally:
      os.chdir(pwd)
   
    if self.verbose > 3:
      for error in transform.error_log:
         log.error(error.message)
    
  def bundle_epub(self):
    """Copies all relevant files and pack it """
    log.debug("bundle_epub")
    self.write_mimetype()
    self.copy_images()
    self.copy_cssfiles()
    self.copy_callouts()
    self.copy_admons()
    self.copy_fonts()
    self.packepub()

  def packepub(self):
    """Create a ZIP archive with all the needed files """
    # Create two lists of all files and directories
    log.debug("packepub")
    epubfiles = [os.path.join(root,f) for root, dirs, files in \
                  os.walk(os.path.join(self.tmpdir, self.OEBPS_DIR)) for f in files ]
    epubdirs = [os.path.join(root,d) for root, dirs, files in os.walk(self.tmpdir) for d in dirs ]
   
    myzip=zipfile.ZipFile(self.epubfile, mode="w" )
    # Handle mimetype separately
    log.debug("  Writing mimetype file")
    myzip.write(os.path.join(self.tmpdir, "mimetype"), "mimetype", 
                compress_type=zipfile.ZIP_STORED)
    # Handle container.xml separately
    container=os.path.join(self.tmpdir, self.META_DIR, "container.xml")
    myzip.write(container,
                os.path.relpath(container, self.tmpdir),
                compress_type=zipfile.ZIP_DEFLATED)

    ## Handle directories first
    #for d in epubdirs:
    #  archive = os.path.relpath(d, self.tmpdir)
    #  log.debug("  Storing %s directory as %s" % (d, archive))
    #  myzip.write(d,archive, compress_type=zipfile.ZIP_STORED)
    # Handle files
    for f in epubfiles:
      archive = os.path.relpath(f, self.tmpdir)
      log.info("  Compressing %s file as %s" % (f, archive))
      myzip.write(f, archive, compress_type=zipfile.ZIP_DEFLATED)

    myzip.close()
  
  def copy_images(self):
    """Copy all image files into OEBPS directory"""
    log.debug("copy_images")
    images=self.get_image_refs()
    log.debug("  found %i images" % len(images))
    
    #if not self.IMG_SRC_PATH:
    #   fragment=os.path.join(self.tmpdir, self.OEBPS_DIR)
    #else:
    fragment=os.path.join(self.tmpdir, self.OEBPS_DIR, self.IMG_SRC_PATH)
    log.debug("  fragment=%s" % fragment )
    
    for img in images:
       newimg = os.path.join(fragment, os.path.basename(img.attrib["fileref"]))
       fullimg = os.path.join(self.imgsrcpath, img.attrib["fileref"])
       log.debug("  copying image from %s to %s" % (fullimg, newimg))
       shutil.copyfile(fullimg, newimg)
  
  def copy_cssfiles(self):
    """Copy CSS file into OEBPS directory
       raises IOError if CSS file is not found
    """
    log.debug("copy_cssfiles")
    if not self.cssfile:
      return
    # FUTURE: If cssfile will be a list, remove [...]
    for css in [self.cssfile]:
      if not os.path.exists(css):
        raise IOError("CSS file %s not found" % css)
      newcss=os.path.join(self.tmpdir, self.OEBPS_DIR, os.path.basename(css))
      log.debug("  From %s to %s" % (css, newcss) )
      shutil.copyfile(css, newcss)
  
  def copy_admons(self):
    """Copy admonition files into OEBPS/admons directory
    """
    log.debug("copy_admons")
    # Set admonparam to True/False, regardless of None return value
    admonparam = self.getxsltparam("admon.graphics")
    admonparam = True if admonparam != None and int(admonparam) else False
    
    if not self.has_admons and admonparam:
       return
    #
    admons=[ "%s%s" % (os.path.join(self.ADMON_FULL_PATH, a), self.ADMON_EXT)  for a in ('important', 'warning', 'tip', 'caution', 'note')]
    
    for img in admons:
      newimg=os.path.join(self.tmpdir, self.OEBPS_DIR, self.ADMON_PATH, "admons", os.path.basename(img))
      log.debug("  From %s to %s" % (img, newimg) )
      shutil.copyfile(img, newimg)

     
  def copy_fonts(self):
    """Copy font files into OEBPS/ directory """
    log.debug("copy_fonts")
    if not self.otffiles:
       return
    
    for font in self.otffiles:
       newfont=os.path.join(self.tmpdir, self.OEBPS_DIR, os.path.basename(font))
       log.info("   Copying from %s to %s" % (font, newfont) )
       shutil.copyfile(font, newfont)
  
  def copy_callouts(self):
    """Copy callout files"""
    log.debug("copy_callouts")
    if not self.has_callouts:
      return

    # add only those callouts which ends with CALLOUT_EXT
    callouts=[ os.path.join(self.CALLOUT_FULL_PATH,c) for c in os.listdir(self.CALLOUT_FULL_PATH) if c.endswith(self.CALLOUT_EXT) ]
    # callouts.sort()
    for img in callouts:
      newimg=os.path.join(self.tmpdir, self.OEBPS_DIR, self.CALLOUT_PATH, os.path.basename(img))
      log.debug("  From %s to %s" % (img, newimg) )
      shutil.copyfile(img, newimg)
    
  
  def get_image_refs(self):
    """Returns a list of image filenames"""
    log.debug("get_image_refs")
    # Allowed image file extensions:
    imgext = (".svg", ".png", ".gif", ".jpg", ".jpeg", ".xml", ".eps", ".pdf")
    # Allowed values in <imageobject role="...">
    rolevalues = ("epub", "html", "xhtml")
    imagedata = self.xmltree.findall("//imagedata")
    
    # Only return an imagedata element, when
    #  (1) imagedata has a fileref attribute, and
    #  (2) its parent element contains a role
    #  (3) that role attribute contains a value with either html, xhtml or epub, and
    #  (4) the filename of the fileref attribute is one of the extensions in the imgext tuple
    imagedata=[ img for img in imagedata if \
              img.attrib.get("fileref") and \
              img.getparent().attrib.get("role") and \
              img.getparent().attrib.get("role") in rolevalues and \
              os.path.splitext(img.attrib.get("fileref", ""))[1] in imgext 
              ]
    return imagedata
  
  @property
  def has_callouts(self):
    """Checks, if the document contains any co elements in screen or programlisting (property)"""
    return bool(self._has_callouts)
 
  @property
  def has_admons(self):
    """Checks, if the document contains any admonition elements (property)"""
    return bool(self._has_admons)
 
  @property
  def has_imagesobjects(self):
     """Checks, if the document contains any imageobject elements (property)"""
     return bool(self._has_imagobjects)
 
  def write_mimetype(self):
    """Write the mimetype file and returns the absolute path of the file 'mimetype'"""
    log.debug("write_mimetype")
    filename = os.path.join(self.tmpdir, "mimetype")
    file(filename, "w").write(self.MIMETYPE)
    return filename
  
  def cleanup(self):
    """Cleanup temporary directory"""
    log.debug("cleanup")
    if not self.keeptemp:
      log.debug("  Temporary directory tree deleted")
      shutil.rmtree(self.tmpdir) # ignore_errors=
    
# EOF