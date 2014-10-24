# -*- coding: UTF-8 -*-

import os
import glob
from collections import OrderedDict

import pytest
from lxml import etree

BASEDIR=os.path.dirname(__file__)
SRC="src/"
RES="res/"

def pytest_report_header(config):
   print("config:", config)
   return dir(config)


@pytest.fixture
def defaultxmlparser(encoding=None,
              attribute_defaults=False,
              dtd_validation=False,
              load_dtd=False,
              no_network=True,
              ns_clean=True,
              recover=False,
              # XMLSchema schema=None,
              remove_blank_text=False,
              resolve_entities=False,
              remove_comments=False,
              remove_pis=False,
              strip_cdata=True,
              target=None,
              compact=True):
   """Pytest fixture: returns a XMLParser object
   """
   return etree.XMLParser(encoding="UTF-8",
                  attribute_defaults=attribute_defaults,
                  dtd_validation=dtd_validation,
                  load_dtd=load_dtd,
                  no_network=no_network,
                  ns_clean=ns_clean,
                  recover=recover,
                  remove_blank_text=remove_blank_text,
                  resolve_entities=resolve_entities,
                  remove_comments=remove_comments,
                  remove_pis=remove_pis,
                  strip_cdata=strip_cdata,
                  target=target,
                  compact=compact
                  )
