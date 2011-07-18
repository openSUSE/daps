#!/usr/bin/env python
# -*- coding: utf-8 -*-

__version__="$Revision$"
__author__="Thomas Schraitle <toms AT opensuse DOT org>"

import sys
import os
from os import path

from core import *

from dm.base import SVNFile


class SVNProperties(unittest.TestCase):
  """Checks Properties """
  @classmethod
  def setUpClass(cls):
    """Setups the class, used for all testcases"""
    cls.filename = "test_01.xml"
    cls.fullfilename = path.join(WORKINGREPO, "xml", cls.filename)
    cls.svn = SVNFile(cls.fullfilename)
    cls.output=subprocess.check_output("svn pl -v --xml %s" % cls.fullfilename, shell=True)
    cls.doc = etree.parse(StringIO(cls.output))
    
  def setUp(self):
    self.c = self.__class__
    self.svn = self.c.svn

  def test_InstanceOfSVNFile(self):
    """Checks instance of class xml variable"""
    self.assertTrue(isinstance(self.__class__.svn, SVNFile))

  @unittest.skip("FIXME")
  def test_ComparesLengthOfProperties(self):
    """Compares length of properties from SVNFile and length from svn pl -v --xml"""
    props = self.svn.getprops()
    root = self.c.doc.getroot()
    # Iterate through the props dictionary but include only those starting with "doc:"
    propdict = dict([ (k, i) for k, i in props.items() if k.startswith("doc:") ])
    # Get the children from XPath /properties/target
    propertylist = root.getchildren()[0].getchildren()
        
    # Although both are different types (dict vs. list), nevertheless they should
    # contain the same amount of items
    self.assertEqual( len(propertylist), len(propdict), msg="%s != %s" % ( [i.attrib['name'] for i in propertylist], 
    propdict.keys()) )
    



if __name__ == "__main__":
  unittest.main()
