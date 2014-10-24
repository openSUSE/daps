# -*- coding: UTF-8 -*-

import pytest

@pytest.fixture(scope="module")
def namespaces():
   """Pytest fixture: returns a dictionary of common namespaces
   """
   return {
             'h': 'http://www.w3.org/1999/xhtml',
            'fo': 'http://www.w3.org/1999/XSL/Format',
            'db': 'http://docbook.org/ns/docbook',
           'svg': 'http://www.w3.org/2000/svg',
           'mml': 'http://www.w3.org/1998/Math/MathML',
          }

