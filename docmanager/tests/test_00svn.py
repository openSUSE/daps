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
  
from core import *

class TestSVNRepository(unittest.TestCase):
  
  def test_00svnrepo_exists(self):
    """Checks, if SVN repository exists"""
    self.assertTrue(path.exists(SVNREPO))
    
  def test_00svnworkdir_exists(self):
    """Checks, if SVN directory exists"""
    self.assertTrue(path.exists(WORKINGREPO))
  
  def test_dotsvn(self):
    """Checks, if the .svn directory is available"""
    self.assertTrue(path.exists(path.join(WORKINGREPO, '.svn')))
    
# EOF