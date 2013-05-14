#!/usr/bin/python
# -*- coding: utf-8 -*-

from lxml import etree
import os.path

from docbook.xslt import xmlparser, LOCALDBXSLPATH

XML_FILE = 'article.xml'
DIRNAME = os.path.dirname(__file__)
XML_FILE = os.path.join(DIRNAME, XML_FILE)

def test_article_exists():
    '''checks if XML file exists'''
    assert os.path.exists(XML_FILE), 'filename %s not found' % filename


def test_xml_parse(xmlparser):
    '''checks the root element from XML file'''
    tree = etree.parse(XML_FILE, xmlparser)
    root = tree.getroot()

    assert root.tag == 'article', 'mismatch of root-element %s' %root.tag


def test_module():
    '''Checks, if DBXSLT variable is not empty '''
    assert LOCALDBXSLPATH != ''
