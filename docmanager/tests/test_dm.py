#!/usr/bin/env python
# -*- coding: utf-8 -*-
#
""" Unittests for DocManager

NOTES:
* The test methods are executed alphabetically (that's a design issue from
  the unittest module), so be careful to add new testcases that are dependend
  on others (this is hint for bad written test cases)
* The tests have to be written that before and after the test the SVN
  working directory is the same.  A test shouldn't leave the SVN in a
  uncertain state (e.g. modified files, deleted files, new files, ...).
  This has the advantage that this script can be executed multiple times.
* There is the base class BaseDM which is used by all testcase classes. 
  Insert code (variables or methods) here that are useful for all derived classes.

TODO:
* Maybe modularize it into a test directory?
"""

__version__="$Revision: 43291 $"
__author__="Thomas Schraitle <toms AT opensuse DOT org>"

import sys
import os, os.path
import logging
try:
  import unittest2 as unittest
except ImportError:
  import unittest
  
from core import discover


log = logging.getLogger("dm")
log.setLevel(logging.DEBUG)

class BaseDM(unittest.TestCase):
  def setUp(self):
    log.info("Setting up class %s" % self.__class__.__name__)
    

class Test_dm(BaseDM):
  """ Only a small test case"""
  def test00(self):
    self.assertTrue( 0 != 1 )

class Test_Foo(unittest.TestCase):
  def testBasic(self):
    self.assertTrue( 5 < 10 )

# -----------
def suite(args=None):
  # TODO: How do we delegate the args argument?
  return discover(globals(), module=__file__)

if __name__=="__main__":
  unittest.main(defaultTest='suite')
