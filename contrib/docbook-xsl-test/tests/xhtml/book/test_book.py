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

   def test_div_book_titlepage(self):
       """
       Checks if /html/body/div[@class='book']/div[@class='titlepage'] is available
       """
        
       tp = self.result.xpath("/h:html/h:body/h:div[@class='book']/h:div[@class='titlepage']",
                              namespaces=self.ns)[0]
       assert tp is not None
   

   def test_booktitle(self):
      """
      Checks, if book title is available 
      """
      btitle = self.result.xpath("/h:html/h:head/h:title",
                                 namespaces=self.ns)
      assert btitle is not None

   
   def test_head_generator(self):
      """
      Checks if meta[@name='generator'] contains DocBook string
      """
      resmeta = self.result.xpath("/h:html/h:head/h:meta[@name='generator']", 
                                  namespaces=self.ns)[0].attrib.get("content")

      assert "DocBook XSL Stylesheets" in resmeta



class TestBookSections():
   """Tests Sections """
   @classmethod
   def setup_class(cls):
       """ setup class (only once) and transform XML file
       """
       cls.xf = conf.XMLFile( os.path.join(DIR, "book.xml") )
       cls.xf.parse( conf.STYLESHEETS["xhtml-single"] )
       cls.result = cls.xf.transform()
       cls.ns = conf.namespaces()

   def test_all_sect_title(self):
      """
      Checks, if all sect titles are available:
      /html/body/div[@class='book']/div[@class='chapter']/div[@class='sect1']//*[@class='title']
      """
      restitles = self.result.xpath("/h:html/h:body/h:div[@class='book']/h:div[@class='chapter']/h:div[@class='sect1']//h:*[@class='title']",
                                namespaces=self.ns)
      dbtitles = self.xf.xml.xpath("/book/chapter/sect1//title")

      # Checks, if length of both lists are the same
      assert len(dbtitles) == len(restitles)

      # Checks, if all text nodes are the same
      restitles=[ i.getchildren()[0].tail  for i in restitles ]
      dbtitles =[ i.text for i in dbtitles ]
      assert restitles == dbtitles
   
   def test_abstract(self):
      """
      Checks, if abstract is available
      """
      abstract = self.result.xpath("/h:html/h:body/h:div/h:div/h:div/h:p/h:strong",
                                   namespaces=self.ns)[0]
      assert abstract is not None

   









class TestBookTOC():
   """Tests the Table of Contents """
   @classmethod
   def setup_class(cls):
       """ setup class (only once) and transform XML file
       """
       cls.xf = conf.XMLFile( os.path.join(DIR, "book.xml") )
       cls.xf.parse( conf.STYLESHEETS["xhtml-single"] )
       cls.result = cls.xf.transform()
       cls.ns = conf.namespaces()

   def test_strong_toc(self):
      """
      Checks, if the Table of contents is available.
      """
      toc = self.result.xpath("/h:html/h:body/h:div[@class='book']/h:div[@class='toc']/h:dl[@class='toc']",
                              namespaces=self.ns)[0]
      assert toc is not None

      
   def test_href_chapter(self):
      """
      Checks, if href is available
      """

      chapterid = self.xf.xml.xpath("/book/chapter/@id")

      assert chapterid 
      content = chapterid[0]

      href = self.result.xpath("/h:html/h:body/h:div[@class='book']/h:div[@class='toc']/h:dl[@class='toc']/h:dt/h:span[@class='chapter']/h:a[@href='#{0}']".format(content),
                               namespaces=self.ns)[0]
      assert href is not None

   def test_href_sects(self):
      """
      Checks, if the hrefs are available
      """
      sectid = self.xf.xml.xpath("/book/chapter/sect1//@id")

      assert sectid
      content = sectid[0]
      
      href = self.result.xpath("/h:html/h:body/h:div[@class='book']/h:div[@class='toc']/h:dl[@class='toc']/h:dd/h:dl/h:dt/h:span/h:a[@href='#{0}']".format(content),
                               namespaces=self.ns)
      

      assert href is not None

      
   def test_div_toc_dl(self):
      """
      Checks if TOC contains dl 
      """
      res = self.result.xpath("/h:html/h:body//h:div[@class='toc']/h:dl", 
                              namespaces=self.ns)[0].attrib.get("class")
      assert "toc" == res
      res = self.result.xpath("/h:html/h:body//h:div[@class='toc']/h:dl/h:dt", 
                              namespaces=self.ns)[0]
      assert "{{{0}}}dt".format(self.ns["h"]) == res.tag



   def test_div_toc_sect1(self):
      """
      Checks if sect1 is available in toc, both @id and text
      """
      res = self.result.xpath("/h:html/h:body/h:div[1]/h:div[@class='toc']//h:span[@class='sect1']",
                              namespaces=self.ns)[0]
      assert "sect1" == res.attrib.get("class")
      
      dbid = self.xf.xml.xpath("/*/chapter/sect1[1]/@id", 
                               namespaces=self.ns)[0]

      htmlid = res.xpath("substring-after(h:a/@href, '#')", 
                         namespaces=self.ns)
      assert dbid == htmlid
      
      dbtitle = self.xf.xml.xpath("/*/chapter/sect1[1]/title", 
                                  namespaces=self.ns)[0]
      htmltitle = res.xpath("/h:html/h:body//h:div[@class='toc']//h:span[@class='sect1']/h:a", 
                            namespaces=self.ns)[0]
      
      assert dbtitle.text == htmltitle.text



   def test_div_toc_sect2(self):
      """
      Checks if sect2 is available in toc, both @id and text
      """
      res = self.result.xpath("/h:html/h:body//h:div[@class='toc']//h:span[@class='sect2']", 
                              namespaces=self.ns)[0]
      assert "sect2" == res.attrib.get("class")
      
      dbid = self.xf.xml.xpath("/*/chapter/sect1[1]/sect2[1]/@id", 
                               namespaces=self.ns)[0]
      htmlid = res.xpath("substring-after(h:a/@href, '#')", 
                         namespaces=self.ns)
      assert dbid == htmlid
      
      dbtitle = self.xf.xml.xpath("/*/chapter/sect1[1]/sect2[1]/title", 
                                  namespaces=self.ns)[0]
      htmltitle = res.xpath("/h:html/h:body//h:div[@class='toc']//h:span[@class='sect2']/h:a", 
                            namespaces=self.ns)[0]

   

   def test_div_toc_sect6(self):
      """
      Checks if sect6 is NOT available
      """
      res = self.result.xpath("/h:html/h:body//h:div[@class='toc']//h:span[@class='sect6']",
                              namespaces=self.ns)
      assert len(res) == 0
   









     
