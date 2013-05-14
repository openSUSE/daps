#!/usr/bin/python
# -*- coding: utf-8 -*-

from lxml import etree
import os.path
from docbook.xslt import STYLESHEETS, LOCALDBXSLPATH, xmlparser, namespaces

XML_FILE = 'article.xml'
DIRNAME = os.path.dirname(__file__)
XML_FILE = os.path.join(DIRNAME, XML_FILE)
DB2XHTML = os.path.join(LOCALDBXSLPATH, STYLESHEETS['xhtml-single'])

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


def test_xml_parse(xmlparser):
    '''checks the root element of the XML file'''
    global XML_TREE, XML_ROOT
    XML_TREE = etree.parse(XML_FILE, xmlparser)    
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


def test_head_title(namespaces):
     '''test if XML title element match with HTML title element'''
     global RESULT_TREE, XML_TITLE
     html_title = RESULT_TREE.xpath('/h:html/h:head/h:title',
                                    namespaces=namespaces)
     title_text = html_title[0].text
     assert title_text == XML_TITLE, 'titles dont match'


