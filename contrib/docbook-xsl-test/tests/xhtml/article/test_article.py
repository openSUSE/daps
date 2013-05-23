#!/usr/bin/python
# -*- coding: utf-8 -*-
from __future__ import print_function

import os.path
from lxml import etree
import pytest


import conftest as conf

DIR=os.path.dirname(__file__)


class TestArticleToc():
   """Tests toc """
   @classmethod
   def setup_class(cls):
      """ setup class (only once) and transform XML file
      """
      cls.xf = conf.XMLFile( os.path.join(DIR, "article.xml") )
      cls.xf.parse( conf.STYLESHEETS["xhtml-single"] )
      cls.result = cls.xf.transform()
      cls.ns = conf.namespaces()
   
   def test_div_toc(self):
      """Checks if TOC is written in /html/body[1]/div[1]/div[2]/@class='toc'
      """
      res = self.result.xpath("/h:html/h:body/h:div[1]/h:div[2]", 
                              namespaces=self.ns)[0].attrib.get("class")
      assert "toc" == res

   def test_div_toc_dl(self):
      """Checks if TOC contains dl 
      """
      res = self.result.xpath("/h:html/h:body//h:div[@class='toc']/h:dl", 
                              namespaces=self.ns)[0].attrib.get("class")
      assert "toc" == res
      res = self.result.xpath("/h:html/h:body//h:div[@class='toc']/h:dl/h:dt", 
                              namespaces=self.ns)[0]
      assert "{{{0}}}dt".format(self.ns["h"]) == res.tag

   def test_div_toc_sect1(self):
      """Checks if sect1 is available in toc, both @id and text
      """
      res = self.result.xpath("/h:html/h:body/h:div[1]/h:div[@class='toc']//h:span[@class='sect1']",
                              namespaces=self.ns)[0]
      assert "sect1" == res.attrib.get("class")
      
      dbid = self.xf.xml.xpath("/*/sect1[1]/@id", 
                               namespaces=self.ns)[0]
      htmlid = res.xpath("substring-after(h:a/@href, '#')", 
                         namespaces=self.ns)
      assert dbid == htmlid
      
      dbtitle = self.xf.xml.xpath("/*/sect1[1]/title", 
                                  namespaces=self.ns)[0]
      htmltitle = res.xpath("/h:html/h:body//h:div[@class='toc']//h:span[@class='sect1']/h:a", 
                            namespaces=self.ns)[0]
      
      assert dbtitle.text == htmltitle.text
     
   def test_div_toc_sect2(self):
      """Checks if sect2 is available in toc, both @id and text
      """
      res = self.result.xpath("/h:html/h:body//h:div[@class='toc']//h:span[@class='sect2']", 
                              namespaces=self.ns)[0]
      assert "sect2" == res.attrib.get("class")
      
      dbid = self.xf.xml.xpath("/*/sect1[1]/sect2[1]/@id", 
                               namespaces=self.ns)[0]
      htmlid = res.xpath("substring-after(h:a/@href, '#')", 
                         namespaces=self.ns)
      assert dbid == htmlid
      
      dbtitle = self.xf.xml.xpath("/*/sect1[1]/sect2[1]/title", 
                                  namespaces=self.ns)[0]
      htmltitle = res.xpath("/h:html/h:body//h:div[@class='toc']//h:span[@class='sect2']/h:a", 
                            namespaces=self.ns)[0]
      
      assert dbtitle.text == htmltitle.text
     
   def test_div_toc_sect3(self):
      """Checks if sect3 is NOT available
      """
      res = self.result.xpath("/h:html/h:body//h:div[@class='toc']//h:span[@class='sect3']",
                              namespaces=self.ns)
      assert res == []

   def test_div_toc_sect4(self):
      """Checks if sect4 is NOT available
      """
      res = self.result.xpath("/h:html/h:body//h:div[@class='toc']//h:span[@class='sect4']",
                              namespaces=self.ns)
      assert res == []

   def test_div_toc_sect5(self):
      """Checks if sect5 is NOT available
      """
      res = self.result.xpath("/h:html/h:body//h:div[@class='toc']//h:span[@class='sect5']",
                              namespaces=self.ns)
      assert res == []
   

class TestArticle():
   """
   """
   @classmethod
   def setup_class(cls):
      """ setup class (only once) and transform XML file
      """
      cls.xf = conf.XMLFile( os.path.join(DIR, "article.xml") )
      cls.xf.parse( conf.STYLESHEETS["xhtml-single"] )
      cls.result = cls.xf.transform()
      cls.ns = conf.namespaces()

   def test_head_title(self):
      """Compare /html/head/title with /*/title
      """
      restitle = self.result.xpath("/h:html/h:head/h:title", 
                                   namespaces=self.ns)[0].text
      dbtitle = self.xf.xml.xpath("/*/title")[0].text
      assert restitle == dbtitle
   
   def test_head_generator(self):
      """Checks if meta[@name='generator'] contains DocBook string
      """
      resmeta = self.result.xpath("/h:html/h:head/h:meta[@name='generator']", 
                                  namespaces=self.ns)[0].attrib.get("content")
      assert "DocBook XSL Stylesheets" in resmeta

   def test_div_article(self):
      """Checks if /html/body/div[1]/@class='article'
      """
      res = self.result.xpath("/h:html/h:body/h:div[1]", 
                              namespaces=self.ns)[0].attrib.get("class")
      assert "article" == res

   def test_div_titlepage(self):
      """Checks for /html/body/div[@class='article']/div[@class] = 'titlepage'
      """
      res = self.result.xpath("/h:html/h:body/h:div[@class='article']/h:div[@class]", 
                              namespaces=self.ns)[0].attrib.get("class")
      assert "titlepage" == res

   
      
   
# EOF