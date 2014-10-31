#!/usr/bin/python3
# -*- coding: UTF-8 -*-

import sys
import os, os.path
import glob

import py, pytest
from lxml import etree

# Our base directory
BASEDIR=os.path.dirname(__file__)

# source and result directories:
SRC="src/"
RES="res/"

# Our test namespace:
TESTURN="urn:x-suse:toms:ns:testcases"

# Collect all XML files in a list:
XML=glob.glob(os.path.join(BASEDIR, SRC, "*.xml"))

# -----------------------------------------------------------------------
#  Fixtures
#
@pytest.fixture(params=XML)
def xmlsource(request):
   """Fixture to create an XMLFile object of source XML"""
   return py.path.local(request.param)


@pytest.fixture
def fosource(request, xmlsource):
   """Fixture to create an XMLFile object of result FO"""
   fobase = xmlsource.new(ext=".fo",dirname=os.path.join(BASEDIR, RES))
   return fobase


@pytest.fixture
def xmltestcases(request, xmlsource, defaultxmlparser):
   """Fixture to select all testcases from a file """
   # print("xmltestcases:", request, xmlsource, defaultxmlparser)
   root = etree.parse(str(xmlsource), defaultxmlparser)
   return root.xpath("//t:scenarios/t:try", namespaces={"t": TESTURN}, )


@pytest.fixture
def xmltree(request, xmlsource, defaultxmlparser):
   """Fixture to create XML tree from XML source"""
   root = etree.parse(str(xmlsource), defaultxmlparser)
   #return root.xpath("/t:testcases/t:scenario[1]/t:context[1]/node()[not(self::text())]",
   #                  namespaces={"t": TESTURN}, )
   return root


@pytest.fixture
def fotree(request, fosource, defaultxmlparser):
   """Fixture to create XML tree from FO result file"""
   return etree.parse(str(fosource), defaultxmlparser)


@pytest.fixture
def stylesheet(request, defaultxmlparser):
   """ """
   styledir="../../../../suse/suse2013"
   stylepath=py.path.local(BASEDIR).join(styledir)
   return stylepath


# -----------------------------------------------------------------------
#  Test Functions
#
def test_file_exists(xmlsource, fosource):
   """Checks, if both source and result files are available"""
   # print("source: {!s}, fo: {!s}".format(xmlsource, fosource))
   assert xmlsource.exists()
   assert fosource.exists()


def test_testcases_exists(xmlsource, xmltestcases):
   """Checks, if a testcase exists inside the file"""
   assert xmltestcases


def test_cmp_with_result(xmltree, fotree, xmltestcases, namespaces):
   """Checks """
   print()
   for i, t in enumerate(xmltestcases, 1):
      xp = t.attrib.get("xpath")
      exp=t.attrib.get("expect")
      expect = eval(exp)
      res = fotree.xpath(xp, namespaces=namespaces)
      
      print(" case {}: {} -> {!r} => {!r}".format(i, xp, expect, res))
      print("   xmltestcases:", xmltestcases)
      print("   fotree:", fotree, fotree.getroot().tag )
      print("   xpath:", exp, type(exp) )
      print("   expect:", expect, type(expect) )
      
      if isinstance(res, list):
         assert res
         assert str(res[0]) == expect
      elif isinstance(res, str):
         assert res == expect
      elif isinstance(res, float):
         assert res == float(expect)
      else:
         assert False, "Shouldn't happen!"
# EOF