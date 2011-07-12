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

class SVNProperties(unittest.TestCase):
  """
  """
  pass


