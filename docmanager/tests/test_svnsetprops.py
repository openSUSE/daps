#!/usr/bin/env python
# -*- coding: utf-8 -*-

__version__="$Revision$"
__author__="Thomas Schraitle <toms AT opensuse DOT org>"

import sys
import os
from os import path

from core import *

from dm.base import SVNFile


class SVNSetProperties(unittest.TestCase):
  """Checks set properties """
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


if __name__ == "__main__":
  unittest.main()
