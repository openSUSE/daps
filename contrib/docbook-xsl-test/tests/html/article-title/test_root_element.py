#!/usr/bin/python
# -*- coding: utf-8 -*-

from lxml import etree
import os.path

import docbook.xslt as db

XML_FILE = 'article.xml'
DIRNAME = os.path.dirname(__file__)
XML_FILE = os.path.join(DIRNAME, XML_FILE)

def test_article_exists():
    '''checks if XML file exists'''
    assert os.path.exists(XML_FILE), 'filename %s not found' % filename


def test_xml_parse():
    '''checks the root element from XML file'''
    tree = etree.parse(XML_FILE, db.xmlparser)
    root = tree.getroot()

    assert root.tag == 'article', 'mismatch of root-element %s' %root.tag


def test_module():
    '''Checks, if DBXSLT variable is not empty '''
    assert db.LOCALDBXSLPATH != ''
