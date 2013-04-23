#!/usr/bin/python
# -*- coding: utf-8 -*-

from lxml import etree
import os.path

XML_FILE = 'article.xml'
DIRNAME = os.path.dirname(__file__)
XML_FILE = os.path.join(DIRNAME, XML_FILE)
DB2XHTML = '/usr/share/xml/docbook/stylesheet/nwalsh/current/xhtml/docbook.xsl'
XML_TREE = None
XML_ROOT = None
PARSER = None
XSLT_TREE = None
TRANSFORM = None
RESULT_TREE = None
XML_TITLE = None

def test_article_exists():
    ''' checks if XML file exists'''
    assert os.path.exists(XML_FILE), 'filename %s not found' % filename


def test_xml_parse():
    '''checks the root element from XML file'''
    global XML_TREE, XML_ROOT, PARSER
    PARSER = etree.XMLParser(ns_clean=True, 
                         dtd_validation=False, 
                         no_network=True, 
                         resolve_entities=False, 
                         load_dtd=False)
    XML_TREE = etree.parse(XML_FILE, PARSER)    
    XML_ROOT = XML_TREE.getroot()
    
    assert XML_ROOT.tag == 'article', 'mismatch of root-element %s' %XML_ROOT.tag


def test_xslt_parse():
    '''transform XML to HTML'''
    global XSLT_TREE, TRANSFORM, RESULT_TREE
    XSLT_TREE = etree.parse(DB2XHTML)
    TRANSFORM = etree.XSLT(XSLT_TREE)
    RESULT_TREE = TRANSFORM(XML_TREE)
    assert RESULT_TREE != '', 'expected html output'


def test_title_element():
    '''test if title element is given'''
    global XML_TREE, XML_TITLE
    XML_TREE.xpath('/article/title')
    XML_TITLE = XML_TREE.xpath('/article/title')[0]
    XML_TITLE = XML_TITLE.text
    assert XML_TITLE != '', 'no title in your xml file!'


def test_head_title():
    '''test if XML title element match with HTML title element'''
     global RESULT_TREE, XML_TITLE
     html_title = RESULT_TREE.xpath('/h:html/h:head/h:title',
                                    namespaces = {'h':'http://www.w3.org/1999/xhtml'})
     title_text = html_title[0].text
     assert title_text == XML_TITLE, 'titles dont match'
