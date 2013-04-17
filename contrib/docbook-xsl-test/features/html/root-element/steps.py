# -*- coding: utf-8 -*-

from lettuce import step, world
from lxml import etree
import os.path

@step('Given I have the file ["\'](.*)["\']')
def given_i_have_the_file_group1(step, group1):
    dirname=os.path.dirname(__file__)
    world.filename=os.path.join(dirname, group1)
    print group1, os.getcwd()
    assert os.path.exists(world.filename), 'filename %s not found' % world.filename

@step('When I parse this file')
def when_i_parse_group1(step):
    parser = etree.XMLParser(ns_clean=True, 
                         dtd_validation=False, 
                         no_network=True, 
                         resolve_entities=False, 
                         load_dtd=False)
    world.tree = etree.parse(world.filename)    
    world.root = world.tree.getroot()

@step('Then I see the root element ["\'](\w+)["\']')
def then_i_see_the_root_element_group1(step, tag):
#prüfen ob root tag dem übergebenen element entspricht - mit assert & world     
    print world.root, tag
    assert world.root != tag, 'root element: %s ' % world.root.tag
