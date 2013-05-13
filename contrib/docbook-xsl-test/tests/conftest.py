# -*- coding: UTF-8 -*-

from __future__ import print_function
import sys
import os


def pytest_runtest_setup(item):
   MYDIR=os.path.dirname(__file__)
   if MYDIR not in sys.path:
      sys.path.insert(0, MYDIR)
