import sys
import os, os.path

from lxml import etree

import pytest

os.environ.setdefault("PYTHONPATH",
                      os.path.normpath(os.path.join(os.path.dirname(__file__), "..")))


@pytest.fixture
def xmlparser():
    return etree.XMLParser(encoding="UTF-8")