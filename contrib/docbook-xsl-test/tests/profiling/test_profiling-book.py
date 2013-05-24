#!/usr/bin/python
# -*- coding: utf-8 -*-
from __future__ import print_function

import os.path
from lxml import etree
import pytest

import conftest as conf


DIR=os.path.dirname(__file__)


class TestSingleProfilingBook():
   """Tests book profiling with one profiling parameter"""
   @classmethod
   def setup_class(cls):
      """ setup class (only once) and transform XML file
      """
      cls.profattr = {'profile.os': "'foo'"}
      cls.xf = conf.XMLFile( os.path.join(DIR, "profiling-book.xml") )
      cls.xf.parse( conf.STYLESHEETS["profile"] )
      cls.result = cls.xf.transform( **cls.profattr )
      cls.ns = conf.namespaces()

   def test_roots_thesame(self):
      """Checks, if root element before and after profiling is the same
      """
      src = self.xf.xml.getroot()
      dest = self.result.getroot()
      assert src.tag == dest.tag

   def test_chapter(self):
      """
      """
      src = self.result.xpath("/book/part[@id='singleprof']/chapter")
      
      assert len(src) == 2

# EOF