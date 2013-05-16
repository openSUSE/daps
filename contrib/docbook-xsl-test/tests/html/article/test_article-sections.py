#!/usr/bin/python
# -*- coding: utf-8 -*-
from __future__ import print_function

import os.path
from lxml import etree
import pytest


import conftest as conf

DIR=os.path.dirname(__file__)


class TestArticle():
   """
   """
   @classmethod
   def setup_class(cls):
      """ setup class (only once) and transform XML file
      """
      cls.xf = conf.XMLFile( os.path.join(DIR, "article.xml") )
      cls.xf.parse( conf.STYLESHEETS["html-single"] )
      cls.result = cls.xf.transform()

   def test_head_title(self):
      """Compare /html/head/title with /*/title
      """
      restitle = self.result.xpath("/html/head/title")[0].text
      dbtitle = self.xf.xml.xpath("/*/title")[0].text
      assert restitle == dbtitle
   
   def test_head_generator(self):
      """Checks if meta[@name='generator'] contains DocBook string
      """
      resmeta = self.result.xpath("/html/head/meta[@name='generator']")[0].attrib.get("content")
      assert "DocBook XSL Stylesheets" in resmeta

   def test_div_article(self):
      """Checks if /html/body/div[1]/@class='article'
      """
      res = self.result.xpath("/html/body/div[1]")[0].attrib.get("class")
      assert "article" in res

   div test_div_titlepage(self):
      """
      """
      res = self.result.xpath("/html/body/div[@class='article']/div[@class]")[0].attrib.get("class")
      assert "titlepage" in res

   def test_div_toc(self):
      """Checks if TOC is written in /html/body[1]/div[1]/div[2]/@class='toc'
      """
      res = self.result.xpath("/html/body/div[1]/div[2]")[0].attrib.get("class")
      assert "toc" in res

# EOF