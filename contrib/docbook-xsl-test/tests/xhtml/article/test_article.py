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
      assert len(res) == 0

   def test_div_toc_sect5(self):
      """Checks if sect5 is NOT available
      """
      res = self.result.xpath("/h:html/h:body//h:div[@class='toc']//h:span[@class='sect5']",
                              namespaces=self.ns)
      assert len(res) == 0
   

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
      """Checks if /html/body/div[1]/@class='article' is available 
      """
      res = self.result.xpath("/h:html/h:body/h:div[1]", 
                              namespaces=self.ns)[0].attrib.get("class")
      assert "article" == res

   def test_div_article_titlepage(self):
      """Checks for /html/body/div[@class='article']/div[@class] = 'titlepage'
      """
      res = self.result.xpath("/h:html/h:body/h:div[@class='article']/h:div[@class]", 
                              namespaces=self.ns)[0].attrib.get("class")
      assert "titlepage" == res

   def test_div_sect1(self):
      """Checks if a div[@class='sect1'] element is available
      """
      res = self.result.xpath("/h:html/h:body/h:div[@class='article']/h:div[@class='sect1']", 
                              namespaces=self.ns)
      assert len(res)
      res=res[0]
      
      child = res.getchildren()[0]
      # print("attrib:", child.attrib)
      assert child.attrib.get('class') == 'titlepage'
   
   def test_div_class_article(self):
      """
      Checks, if /html/body/div[@class="article"] is available
      """
      div = self.result.xpath("/h:html/h:body/h:div[@class='article']", 
                              namespaces=self.ns)
      assert len(div) 
      div=div[0]
      tp = div.xpath("h:div[@class='titlepage']", namespaces=self.ns)

      assert len(tp) 
   


   



class TestArticleToc():
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

   def test_div_class_toc(self):
      """
      Checks if /html/body/div/div[@class="toc"] is available
      """
      toc = self.result.xpath("/h:html/h:body/h:div/h:div[@class='toc']",
                              namespaces=self.ns)[0]

      assert len(toc) 

   def test_strong(self):
      """
      Checks if /html/body/div/div/p/strong is available
      """
      strong = self.result.xpath("/h:html/h:body/h:div/h:div/h:p/h:strong",
                                 namespaces=self.ns)
      assert len(strong) 

   def test_dl_class_toc(self):
      """
      Checks if /html/body/div/div/dl[@class="toc"] is available
      """
      toc = self.result.xpath("/h:html/h:body/h:div/h:div/h:dl[@class='toc']",
                              namespaces=self.ns)
      assert len(toc)

   def test_span_class_sect1(self):
      """
      Checks if /html/div/div/dl/dt/span[@class="sect1"] is available
      """
      span = self.result.xpath("/h:html/h:body/h:div/h:div/h:dl/h:dt/h:span[@class='sect1']",
                               namespaces=self.ns)
      assert len(span) 

   def test_a_href_mysect(self):
      """
      Checks if /html/div/div/dl/dt/span/a[@href="#mysect"] is available
      """
      sect1id = self.xf.xml.xpath("/article/sect1/@id")

      assert sect1id 
      content = sect1id[0]
      a = self.result.xpath("/h:html/h:body/h:div/h:div/h:dl/h:dt/h:span/h:a[@href='#{0}']".format(content),
                            namespaces=self.ns)
      assert len(a) 

   def test_span_class_sect2(self):
      """
      Checks if /html/body/div/div/dl/dd/dl/dt/span[@class="sect2"] is available
      """
      span = self.result.xpath("/h:html/h:body/h:div/h:div/h:dl/h:dd/h:dl/h:dt/h:span[@class='sect2']",
                               namespaces=self.ns)[0]
      assert len(span) 
   
   def test_a_href_sect2(self):
      """
      Checks if /html/body/div/div/dl/dd/dl/dt/span/a[@href="#mysect2"] is available
      """
      a = self.result.xpath("/h:html/h:body/h:div/h:div/h:dl/h:dd/h:dl/h:dt/h:span/h:a[@href='#mysect2']",
                            namespaces=self.ns)
      
      assert len(a) 

   def test_all_sect_title(self):
      """
      Checks if all sect titles are available:
      /html/body/div[@class='article']/div[@class='sect1']//*[@class='title']
      """
      
      restitles = self.result.xpath("/h:html/h:body/h:div[@class='article']/h:div[@class='sect1']//h:*[@class='title']",
                                    namespaces=self.ns)
      dbtitles = self.xf.xml.xpath("/article/sect1//title")

      #Checks, if length of both lists are the same
      assert len(dbtitles) == len(restitles)

      #Checks, if all the text nodes are the same
      restitles = [i.getchildren()[0].tail for i in restitles]
      dbtitles=[i.text for i in dbtitles]
      assert restitles == dbtitles
      
   def test_all_ids(self):
      """
      Checks, if all ids are available
      /html/body/div[@class='article']/div[@class='sect1']//*[@id]
      """
      resid = self.result.xpath("/h:html/h:body/h:div[@class='sect1']//h:*[@id]",
                                namespaces=self.ns)
      dbid = self.xf.xml.xpath("/article/sect1//id")
      assert len(dbid) == len(resid)
      
      resid = [i.getchildren()[0].tail for i in resid]
      dbid = [i.text for i in dbid]

      assert dbid == resid 

   def test_all_href(self):
      """
      Checks, if the hrefs are available
      """
      sectid = self.xf.xml.xpath("/article/sect1//@id")

      assert sectid
      content = sectid[0]
      
      href = self.result.xpath("/h:html/h:body/h:div[@class='article']/h:div[@class='toc']/h:dl[@class='toc']/h:dt/h:span/h:a[@href='#{0}']".format(content),
                               namespaces=self.ns)
      

      assert len(href) 

   def test_abstract(self):
      """
      Checks, if the abstract is available
      """
      abstract = self.result.xpath("/h:html/h:body/h:div[@class='article']/h:div[@class='abstract']",
                                   namespaces=self.ns)
      assert len(abstract)
   


#   def test_div_class_sect1(self):
#      """
#      Check if /html/body/div/div[@class="sect1"]a
#      """
#     div = self.result.xpath("/h:html/h:body/h:div/h:div",
#                            namespaces=self.ns)[0]
#

# EOF
