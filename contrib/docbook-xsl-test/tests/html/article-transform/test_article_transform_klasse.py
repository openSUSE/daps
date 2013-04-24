#!/usr/bin/python
# -*- coding: utf-8 -*-

import os.path
from lxml import etree

class TestClass:
    def test_one(self):
        x = "this"
        assert 'h' in x


class TestArticle_Transform:
    XML_FILE = 'article.xml'
    DB2XHTML = '/usr/share/xml/docbook/stylesheet/nwalsh/current/xhtml/docbook.xsl'
    XML_TREE = None
    XML_ROOT = None
    PARSER = None
    XSLT_TREE = None
    TRANSFORM = None
    RESULT_TREE = None
    XML_TITLE = None
    
    def setup_class(cls):
        '''creates path to files
           parses XML file
           parses XML file and creates HTML output'''
        cls.DIRNAME = os.path.dirname(__file__)
        cls.XML_FILE = os.path.join(cls.DIRNAME, cls.XML_FILE)
        cls.PARSER = etree.XMLParser(ns_clean=True, 
                         dtd_validation=False, 
                         no_network=True, 
                         resolve_entities=False, 
                         load_dtd=False)
        cls.XML_TREE = etree.parse(cls.XML_FILE, cls.PARSER)    
        cls.XML_ROOT = cls.XML_TREE.getroot()
        cls.XSLT_TREE = etree.parse(cls.DB2XHTML)
        cls.TRANSFORM = etree.XSLT(cls.XSLT_TREE)

    def article_title(self):
        '''creates path to article/title'''
        return self.XML_TREE.xpath('/article/title')[0]
    
    def transform(self):
        '''creates HTML output'''
        return self.TRANSFORM(self.XML_TREE)

    # testing functions

    def test_article_exists(self):
        ''' checks if XML file exists'''
        assert os.path.exists(self.XML_FILE), 'filename %s not found' % self.XML_FILE
        
    def test_xml_parse(self):
        '''checks if root tag is article'''
        assert self.XML_ROOT.tag == 'article', 'mismatch of root-element %s' %self.XML_ROOT.tag

    def test_xslt_parse(self):
        '''transform XML to HTML'''
        RESULT_TREE = self.transform()
        assert RESULT_TREE != '', 'expected html output'

    def test_title_element(self):
        '''checks if title element is given'''
        TITLE = self.article_title()
        assert TITLE.text != '', 'no title in your xml file!'

    def test_head_title(self):
        '''checks if XML title element match with HTML title element'''
        TITLE = self.article_title()
        RESULT_TREE = self.transform()
        HTML_TITLE = RESULT_TREE.xpath('/h:html/h:head/h:title',
                                       namespaces = {'h':'http://www.w3.org/1999/xhtml'})
        assert TITLE.text == HTML_TITLE[0].text, 'titles dont match'
