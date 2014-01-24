#!/usr/bin/python
# -*- coding: utf-8 -*-
from __future__ import print_function

import os.path
from lxml import etree
import pytest


import conftest as conf

DIR=os.path.dirname(__file__)


class TestBook():
   """Tests Book """
   @classmethod
   def setup_class(cls):
       """ setup class (only once) and transform XML file
       """
       cls.xf = conf.XMLFile( os.path.join(DIR, "book.xml") )
       cls.xf.parse( conf.STYLESHEETS["xhtml-single"] )
       cls.result = cls.xf.transform()
       cls.ns = conf.namespaces()

   def test_div_class(self):
        """
        Checks if /html/body/div[@class="book"] is available
        """
        res = self.result.xpath("/h:html/h:body/h:div[@class='book']",
                                namespaces=self.ns)[0]
        assert res is not None

   def test_div_titlepage(self):
       """
       Checks if /html/body/div[@class='book']/div[@class='titlepage'] is available
       """
        
       tp = self.result.xpath("/h:html/h:body/h:div[@class='book']/h:div[@class='titlepage']",
                              namespaces=self.ns)[0]
       assert tp is not None


