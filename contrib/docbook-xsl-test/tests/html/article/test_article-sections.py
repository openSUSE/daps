#!/usr/bin/python
# -*- coding: utf-8 -*-
from __future__ import print_function

import os.path
from lxml import etree
import pytest
import glob



@pytest.mark.incremental
class TestArticleSections:
    
   def test_transform(self, xmltestfile, stylesheets):
      xmltestfile.parse(stylesheets["html-single"])
      result = xmltestfile.transform()
      assert result
   
   def test_head(self, xmltestfile, stylesheets):
      """Checks content of <head> tag (mainly title and meta)
      """
      xmltestfile.parse(stylesheets["html-single"])
      result = xmltestfile.transform()
      # ns = xmltestfile.ns
      #
      dbtitle = xmltestfile.xml.xpath("/*/title")[0].text
      restitle=  result.xpath("/html/head/title")[0].text
      assert restitle == dbtitle
      #
      resmeta = result.xpath("/html/head/meta[@name='generator']")[0].attrib.get("content")
      assert "DocBook XSL Stylesheets" in resmeta
      

   def test_div_article(self, xmltestfile, stylesheets):
      xmltestfile.parse(stylesheets["html-single"])
      result = xmltestfile.transform()
      
      res = result.xpath("/html/body/div[1]")[0].attrib.get("class")
      assert "article" in res
      
      res = result.xpath("/html/body/div[@class='article']/div")[0].attrib.get("class")
      assert "titlepage" in res

      
      