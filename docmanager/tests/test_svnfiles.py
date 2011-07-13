#!/usr/bin/env python
# -*- coding: utf-8 -*-

__version__="$Revision$"
__author__="Thomas Schraitle <toms AT opensuse DOT org>"

import sys
import os
from os import path

from core import *

from dm.base   import SVNFile

class SVNFiles(unittest.TestCase):
  """ Testcase for SVNFile class """
  @classmethod
  def setUpClass(cls):
    """Setups the class, used for all testcases"""
    cls.filename = "test_01.xml"
    cls.fullfilename = path.join(WORKINGREPO, "xml", cls.filename)
    cls.svn = SVNFile(cls.fullfilename)
    
  def setUp(self):
    self.c = self.__class__
    self.svn = self.c.svn
    self.filename = self.c.filename
  
  def test_compareRootAndWorkingXMLFiles(self):
    """Create two lists and compare them: original from ROOT dir and from SVN working dir"""
    xmldir = path.join(WORKINGREPO, 'xml')
    xml = [ f for f in os.listdir(xmldir) if path.isfile(path.join(xmldir,f)) and f.endswith(".xml") ]
    
    roottestdir = path.join(TESTROOT, "xml")
    roottestxml = [ f for f in os.listdir(roottestdir) if path.isfile(path.join(roottestdir,f)) and f.endswith(".xml")]
    
    self.assertListEqual(roottestxml, xml)
  
  def test_SVNFile_getinfo(self):
    """Checks if SVNFile.getinfo() return != '' """
    info = self.svn.getinfo()
    self.failUnless( info != '', "Could not get svn info for '%s'" % self.filename)
   
  def test_SVNFile_getstatus(self):
    """Checks if SVNFile.getstatus() return != None"""
    status = self.svn.getstatus()
    self.failUnless( status != None, "Unexpected status: '%s'" % status)
  
  def test_SVNFile_getfilename(self):
    """Checks SVNFile.getfilename()"""
    self.assertEqual(self.svn.getfilename(), self.filename)
  
  def foo(self):
    for x in xml:
      output=subprocess.check_output("svn pl -v --xml %s" % x, shell=True)
      d=path.dirname(x)
      f="%s.log" % path.splitext(x)[0]
      open(f, "w").writelines(output)


if __name__ == "__main__":
  unittest.main()

# EOF