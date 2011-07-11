#!/usr/bin/env python
# -*- coding: utf-8 -*-

import sys
try:
  import unittest2 as unittest
except ImportError:
  import unittest


print("****** Test Suite for DocManager ******")
print(sys.argv)

def suite():
  """Returns a test suite for DocManager"""
  from tests import test_dm
  suite = unittest.TestSuite()
  
  suite.addTests(test_dm.suite())
  return suite

#if __name__=="__main__":
  #unittest.main()