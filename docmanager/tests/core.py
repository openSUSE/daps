#!/usr/bin/env python
# -*- coding: utf-8 -*-

__version__="$Revision$"
__author__="Thomas Schraitle <toms AT opensuse DOT org>"
# Which modules are exported, after from core import * is executed:
__all__=[
         # Our variables:
         "SVNREPO", "WORKINGREPO", "TESTROOT", 
         # Own functions
         "discover","log",
         # Modules we want to export:
         "subprocess", "unittest", ]


import sys
import os
from os import path

try:
  import unittest2 as unittest
except ImportError:
  import unittest

import logging, logging.handlers
import subprocess


SVNREPO="/var/tmp/docmanagersvn"
WORKINGREPO="/var/tmp/docmanager"
TESTROOT=path.join(path.dirname(__file__),"ROOT")

LOG_FILENAME="/var/tmp/docmanager-test.log"
logging.basicConfig(filename=LOG_FILENAME,
                    level=logging.DEBUG
                   )

log = logging.getLogger("dm")
log.setLevel(logging.DEBUG)
handler=logging.handlers.RotatingFileHandler(LOG_FILENAME, backupCount=3)
log.addHandler(handler)



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


# EOF