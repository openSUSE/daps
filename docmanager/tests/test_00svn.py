#!/usr/bin/env python
# -*- coding: utf-8 -*-

__version__="$Revision$"
__author__="Thomas Schraitle <toms AT opensuse DOT org>"

import sys
import os
from os import path
  
from core import *

class TestSVNRepository(unittest.TestCase):
  """Checks structure of SVN repository"""
  
  def test_00svnrepo_exists(self):
    """Checks, if SVN repository exists"""
    self.assertTrue(path.exists(SVNREPO))
  
  def test_00svnrepo_isdir(self):
    """Checks, if SVN repository is a directory"""
    self.assertTrue(path.isdir(SVNREPO))
    
  def test_00svnworkdir_exists(self):
    """Checks, if SVN working directory exists"""
    self.assertTrue(path.exists(WORKINGREPO))
    
  def test_00svnworkdir_isdir(self):
    """Checks, if SVN working directory is a directory"""
    self.assertTrue(path.isdir(WORKINGREPO))
    
  def test_00svnrepo_containsxmldir(self):
    """Checks, if SVN working directory contains a subdirectory 'xml'"""
    self.assertTrue(path.exists(path.join(WORKINGREPO, 'xml')))
    
  def test_00svnrepo_xmlisdir(self):
    """Checks, if SVN working directory contains a subdirectory 'xml' and is a directory"""
    self.assertTrue(path.isdir(path.join(WORKINGREPO, 'xml')))
  
  def test_dotsvn(self):
    """Checks, if the .svn directory is available"""
    self.assertTrue(path.exists(path.join(WORKINGREPO, '.svn')))

if __name__ == "__main__":
  unittest.main()

# EOF