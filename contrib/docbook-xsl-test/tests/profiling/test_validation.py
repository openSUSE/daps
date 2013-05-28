#!/usr/bin/python
# -*- coding: utf-8 -*-
from __future__ import print_function

import os.path
from lxml import etree
import subprocess

import conftest as conf


DIR=os.path.dirname(__file__)


class TestValidation():
   """Tests validation with xmllint"""

   def test_validate(self):
      cmd = "xmllint --valid --noout {0}".format( os.path.join(DIR, "profiling-book.xml") )
      res = subprocess.call( cmd, shell=True )
      assert not res