#!/usr/bin/python
# -*- coding: utf-8 -*-

from __future__ import print_function

from lxml import etree
import os.path
import pytest


def test_article_exists(xmlfile):
    '''checks if XML file exists'''
    for x in xmlfile:
      assert os.path.exists(x), 'filename %s not found' % filename

@pytest.skip(msg="Needs fixing (XML_FILE)")
def test_xml_parse(xmlparser):
    '''checks the root element from XML file'''
    tree = etree.parse(XML_FILE, xmlparser)
    root = tree.getroot()

    assert root.tag == 'article', 'mismatch of root-element %s' %root.tag


#def test_module():
#    '''Checks, if DBXSLT variable is not empty '''
#    assert LOCALDBXSLPATH != ''
