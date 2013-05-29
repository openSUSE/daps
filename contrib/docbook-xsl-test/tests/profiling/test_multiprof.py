#!/usr/bin/python
# -*- coding: utf-8 -*-
from __future__ import print_function

import os.path
from lxml import etree
import pytest

import conftest as conf


DIR=os.path.dirname(__file__)


class TestMultiProfiling():
   """
   """
   
   partid = "multiprof-arch-and-os"
   xmlfile = "profiling-book-multiple.xml"
   
   @classmethod
   def setup_class(cls):
      """ setup class (only once) and transform XML file
      """
      cls.profattr = {'profile.arch': "'foo'",
                      'profile.os':   "'osuse'",
                     }
      cls.xf = conf.XMLFile( 
                  os.path.join(DIR, cls.xmlfile),
                  xmlparser=conf.xmlparser(dtd_validation=True,load_dtd=True)
               )
      cls.xf.parse( conf.STYLESHEETS["profile"] )
      cls.result = cls.xf.transform( **cls.profattr )
      cls.ns = conf.namespaces()

   def test_roots_thesame(self):
      """Checks, if root element before and after profiling are the same
      """
      src = self.xf.xml.getroot()
      dest = self.result.getroot()
      assert src.tag == dest.tag
   
   def test_arch_and_os(self):
      """Checks, if the correct amount of chapters are seen
      """
      dest = self.result.xpath("/book/part[@id='{0}']/chapter".format(self.partid))
      assert len(dest) == 2

   def test_arch_and_os_ids(self):
      """Checks if available chapter id's are the same
      """
      dest = self.result.xpath("/book/part[@id='{0}']/chapter/@id".format(self.partid))
      src= self.xf.xml.xpath("/book/part[@id='{0}']/chapter[not(@arch!='foo')]/@id".format(self.partid))
      assert src == dest

   def test_(self):
      """
      """
      dest = self.result.xpath("/book/part[@id='{0}']/chapter".format(self.partid))
      # print(">>> dest", dest)
      attrs = [ i.attrib  for i in dest ]
      # print(">>> attrs", attrs )
      
      path = "//chapter[@id='cha.arch.foo']/sect1"
      dest = self.result.xpath(path)
      # print("»»» dest", dest )
      
      res = self.xf.xml.xpath(path)
      # print("»»» res", res )

      profattr = tuple( (a.split(".")[1], self.profattr[a].replace("'", "") ) 
                        for a in self.profattr )
      # Remove the "profile." part
      validattr = tuple( a.split(".")[1]  for a in self.profattr )

      # print("»»» profattr", profattr)
      A=[]
      for i in res:
         dd = tuple( (a, i.attrib[a]) for a in i.attrib if a in validattr )
         # print("   dd=", dd)
         if dd == profattr or not dd:
            A.append(i)

      # print("»»» A",    [i.attrib.get('id') for i in A] )
      # print("»»» dest", [i.attrib.get('id') for i in dest] )
      assert len(A) == len(dest)      
      assert [i.attrib.get('id') for i in A] == [i.attrib.get('id') for i in dest]
      
# EOF