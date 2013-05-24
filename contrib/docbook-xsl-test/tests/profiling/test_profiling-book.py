#!/usr/bin/python
# -*- coding: utf-8 -*-
from __future__ import print_function

import os.path
from lxml import etree
import pytest

import conftest as conf


DIR=os.path.dirname(__file__)


class TestProfilingBook():
   """Tests book profiling """
   @classmethod
   def setup_class(cls):
      """ setup class (only once) and transform XML file
      """
      cls.xf = conf.XMLFile( os.path.join(DIR, "profiling-book.xml") )
      cls.xf.parse( conf.STYLESHEETS["profile"] )
      cls.result = cls.xf.transform()
      cls.ns = conf.namespaces()

   def test_root(self):
      """
      """
      src = self.xf.xml.xpath("/*", namespaces=self.ns)[0]
      dest = self.result.xpath("/*", namespaces=self.ns)[0]
      assert src.tag == dest.tag


# EOF