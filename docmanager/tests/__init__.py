#!/usr/bin/env python
# -*- coding: utf-8 -*-

import os
import sys
try:
  import unittest2 as unittest
except ImportError:
  import unittest
import logging

print("----- Test Suite for DocManager -----")


log = logging.getLogger("dm")

def get_name_from_path(path):
  # Taken from unittest2.loader
  path = os.path.splitext(os.path.normpath(path))[0]
  _relpath = os.path.relpath(path, os.getcwd())
  assert not os.path.isabs(_relpath), "Path must be within the project"
  assert not _relpath.startswith('..'), "Path must be within the project"
  name = _relpath.replace(os.path.sep, '.')
  return name


def suite():
  """Returns a test suite for DocManager"""
  # from tests import test_dm
  import glob
  suite = unittest.TestSuite()  
  # Our defaults:
  args={'svnrepo':    "/var/tmp/docmanagersvn",
        'workingdir': "/var/tmp/docmanager",
       }
  
  # Use pattern:
  testpy=glob.glob("tests/test_*.py")

  # Iterate through all our found test cases and load them into our suite:
  for path in testpy:
    name = get_name_from_path(path)
    print "> Loading %s" % name
    case = unittest.TestLoader().loadTestsFromName(name)
    suite.addTests(case)
  
  return suite

#if __name__=="__main__":
  #unittest.main()