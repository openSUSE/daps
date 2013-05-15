#!/usr/bin/python
# -*- coding: utf-8 -*-

from __future__ import print_function

import sys
import os.path

from lxml import etree
import pytest
import glob


@pytest.mark.incremental
class TestArticle:
   # @classmethod
   def setup_method(self, method):
      self.dirname = os.path.dirname(__file__)
      path = os.path.join(self.dirname, "*.xml")
      self.xmlfiles = glob.glob(path)
   
   def test_if_xmlfiles_exists(self):
      for i in self.xmlfiles:
         assert os.path.exists(i)
         
   def test_get_root(self):
      for i in self.xmlfiles:
         # print("Parsing {0}...".format(i))
         tree = etree.parse(i)
         root=tree.getroot()
         assert root.tag
         assert root.tag == "article"

   
# EOF