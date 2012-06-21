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
    self.imgsrcpath = os.path.abspath(options.IMAGEDIR) if options.IMAGEDIR else os.path.abspath(os.path.dirname(self.xmlfile))
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
    
    mkdir_p(os.path.join(self.tmpdir, self.OEBPS_DIR, self.ADMON_PATH, "admons"))
  
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
       'admon.graphics.path':        self.stringparam("%s/" % os.path.join(self.ADMON_PATH, "admons")),
       'img.src.path':               self.stringparam("%s/" % self.IMG_SRC_PATH),
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

    try:
      transform = etree.XSLT(self.xslttree)
      result = transform(self.xmltree, **params)
    except etree.XSLTApplyError, e:
      for msg in e.error_log.filter_from_warnings():
         log.error("<Domain %s Level: %s Name: %s> %s " % (msg.domain_name, msg.level_name, msg.type_name, msg.message))
         # a xslt tree does not need to come from a file
         if not '<string>' in msg.filename:
            log.error(msg.filename)
            log.errno(msg.line)
    if self.verbose > 3:
      for error in transform.error_log:
         log.error(error.message)

    log.debug("Result of transformation: %s" % result)
    log.info("Temporary directory for EPUB: %s" % self.tmpdir)
    
  def bundle_epub(self):
    """ """
    log.info("bundle_epub")
    self.write_mimetype()
    self.copy_images()
    self.copy_cssfiles()
    self.copy_callouts()
    self.copy_admons()
    self.copy_fonts()
    self.packepub()
    log.info("Packing directory %s into EPUB file %s" % (self.tmpdir, self.epubfile) )

  def packepub(self):
   # ------------- FIXME
    with zipfile.ZipFile(self.epubfile, mode="w" ) as myzip:
      # Handle mimetype separately
      log.info("Writing mimetype file")
      myzip.write(os.path.join(self.tmpdir, "mimetype"), compress_type=zipfile.ZIP_STORED)
      rootdirs=[ i for i in os.listdir(self.tmpdir) if os.path.isdir(os.path.join(self.tmpdir,i)) ]
      
      log.info("rootdirs=%s" % rootdirs)
      for d in rootdirs:
         log.info("Investigating %s dir..." % d)
         myzip.write(os.path.join(self.tmpdir, d), compress_type=zipfile.ZIP_STORED)
         
         for root, dirs, files in os.walk(os.path.join(self.tmpdir, d)):
            log.info("  root %s" % root)
            log.info("  dirs %s" % dirs)
            log.info("  files %s" % files)
            # myzip.write( ,compress_type=zipfile.ZIP_DEFLATED)
            for _d in dirs:
               log.info("    adding dir %s" % _d)
               myzip.write(os.path.join(root, _d))
            for _f in files:
               log.info("    adding file %s" % _f)
               myzip.write(os.path.join(root, _f), compress_type=zipfile.ZIP_DEFLATED)
    
    log.info("Wrote EPUB file %s" % self.epubfile)
  
  def copy_images(self):
    """Copy all image files into OEBPS directory"""
    log.info("copy_images")
    for img in self.get_image_refs():
       newimg = os.path.join(self.tmpdir, self.OEBPS_DIR, self.IMG_SRC_PATH, img.attrib["fileref"])
       fullimg = os.path.join(self.imgsrcpath, img.attrib["fileref"])
       log.info("  copying image from %s to %s" % (fullimg, newimg))
       shutil.copyfile(fullimg, newimg)
  
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
      newimg=os.path.join(self.tmpdir, self.OEBPS_DIR, self.ADMON_PATH, "admons", os.path.basename(img))
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
    log.info("get_image_refs")
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
    log.info("  images:%s" % imagedata )
    return imagedata
  
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