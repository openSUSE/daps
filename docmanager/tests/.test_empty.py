#!/usr/bin/env python
# -*- coding: utf-8 -*-

__version__="$Revision: $"
__author__="Thomas Schraitle <toms AT opensuse DOT org>"

import sys
import os
from os import path
  
from core import *

class TestEmpty(unittest.TestCase):
  """Simple TestCase"""
  
  def test_empty(self):
    """Checks, if 1 is True"""
    self.assertTrue(1)
  
  
if __name__ == "__main__":
  unittest.main()

# EOF