#!/usr/bin/env python
# -*- coding: utf-8 -*-

import sys
import os, os.path

try:
  import unittest2 as unittest
except ImportError:
  import unittest

__all__=["discover", "setUpModule", "tearDownModule"]

def discover(globaldict, prefix="Test_", module=__file__):
  """Discovers all classes in a module, which name starts with 'prefix' and are
     derived from unittest.TestCase
  """
  suite = unittest.TestSuite()
  
  testcls = [ k for i, k in globaldict.items() \
              if i.startswith(prefix) and issubclass(k, unittest.TestCase) ]
  print("-- %s: Found %s testcases" % ( os.path.basename(module), len(testcls) ))
  
  for u in testcls:
    case = unittest.TestLoader().loadTestsFromTestCase(u)
    suite.addTests(case)
  
  return suite
  
  
def setUpModule():
  """Create SVN repository and working directory"""
  print "   Setup Module called"

def tearDownModule():
  print "  TearDownModule called"

# EOF