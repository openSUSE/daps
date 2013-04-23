#!/usr/bin/python
# -*- coding: utf-8 -*-

from lxml import etree
import os.path

XML_FILE = 'article.xml'
DIRNAME = os.path.dirname(__file__)
XML_FILE = os.path.join(DIRNAME, XML_FILE)

def test_article_exists():
    ''' checks if XML file exists'''
    assert os.path.exists(XML_FILE), 'filename %s not found' % filename


def test_xml_parse():
    '''checks the root element from XML file'''
    parser = etree.XMLParser(ns_clean=True, 
                         dtd_validation=False, 
                         no_network=True, 
                         resolve_entities=False, 
                         load_dtd=False)
    tree = etree.parse(XML_FILE, parser)    
    root = tree.getroot()
    
    assert root.tag == 'article', 'mismatch of root-element %s' %root.tag
