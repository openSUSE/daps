#!/usr/bin/env python
# -*- coding: utf-8 -*-

__version__="$Revision$"
__author__="Thomas Schraitle <toms AT opensuse DOT org>"

import sys
import os
from os import path

try:
  import unittest2 as unittest
except ImportError:
  import unittest

import subprocess
from core import *

from dm.base   import SVNRepository, SVNFile
from dm.docget import CmdDocget
from dm.docset import CmdDocset
from dm.tag    import CmdTag
from dm.branch import CmdBranch
#from locdrop import CmdLocdrop
import dm.dmexceptions as dmexcept

from lxml import etree
from StringIO import StringIO


class SVNProperties(unittest.TestCase):
  """
  """
  @classmethod
  def setUpClass(cls):
    """Setups the class, used for all testcases"""
    cls.filename = "xml/test_01.xml"
    cls.fullfilename = path.join(WORKINGREPO, cls.filename)
    cls.svn = SVNFile(cls.fullfilename)
    cls.output=subprocess.check_output("svn pl -v --xml %s" % cls.fullfilename, shell=True)
    cls.doc = etree.parse(StringIO(cls.output))
    
  def setUp(self):
    self.c = self.__class__

  def test_InstanceOfSVNFile(self):
    """Checks instance of class xml variable"""
    self.assertTrue(isinstance(self.__class__.svn, SVNFile))

  def test_ComparesLengthOfProperties(self):
    """Compares length of properties from SVNFile and length from svn pl -v --xml"""
    props = self.c.svn.getprops()
    root = self.c.doc.getroot()
    # Iterate through the props dictionary but include only those with "doc:"
    propdict = dict([ (k, i) for k, i in props.items() if k.startswith("doc:") ])
    # Get the children from /properties/target
    propertylist = root.getchildren()[0].getchildren()
    # Although both are different types (dict vs. list), nevertheless they should
    # contain the same amount of items
    self.assertEqual( len(propertylist), len(propdict) )
    



if __name__ == "__main__":
  unittest.main()
