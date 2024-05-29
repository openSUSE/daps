import pytest
from lxml import etree

from metadatavalidator.util import getfullxpath

xmlcontent = """<article>
    <title/>
    <para/>
    <section>
       <title/>
       <para/>
       <para/>
    </section>
    </article>
"""


def test_getfullpath():
    root = etree.fromstring(xmlcontent)
    tree = root.getroottree()
    section = tree.find("./section")
    assert getfullxpath(section) == "/article/section"

    para = tree.find("./section/para[1]")
    assert getfullxpath(para) == "/article/section/para[1]"

    para = tree.find("./section/para[2]")
    assert getfullxpath(para) == "/article/section/para[2]"