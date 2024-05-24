import pytest
from lxml import etree

from metadatavalidator.checks import check_info, check_info_revhistory
from metadatavalidator.exceptions import InvalidValueError


basic_xmlcontent = """<article xmlns="http://docbook.org/ns/docbook" version="5.2">
    <info>
        <title>Test</title>
    </info>
    <para/>
</article>"""


def test_check_info():
    tree = etree.ElementTree(
        etree.fromstring(basic_xmlcontent,
                         parser=etree.XMLParser(encoding="UTF-8"))
    )

    assert check_info(tree, {}) is None


def test_check_info_missing():
    xmlcontent = """<article xmlns="http://docbook.org/ns/docbook" version="5.2">
    <para/>
</article>"""
    tree = etree.ElementTree(
        etree.fromstring(xmlcontent,
                         parser=etree.XMLParser(encoding="UTF-8"))
    )
    with pytest.raises(InvalidValueError,
                          match="Couldn't find info element"):
          check_info(tree, {})


def test_check_info_revhistory_missing():
    tree = etree.ElementTree(
        etree.fromstring(basic_xmlcontent,
                         parser=etree.XMLParser(encoding="UTF-8"))
    )

    with pytest.raises(InvalidValueError,
                       match="Couldn't find a revhistory element"):
        check_info_revhistory(tree, {})


def test_check_info_revhistory():
    xmlcontent = """<article xmlns="http://docbook.org/ns/docbook" version="5.2">
    <info>
        <title>Test</title>
        <revhistory></revhistory>
    </info>
    <para/>
</article>"""
    tree = etree.ElementTree(
        etree.fromstring(xmlcontent,
                         parser=etree.XMLParser(encoding="UTF-8"))
    )

    assert check_info_revhistory(tree, {}) is None


def test_check_info_revhistory_without_info():
    xmlcontent = """<article xmlns="http://docbook.org/ns/docbook" version="5.2">
    <para/>
</article>"""
    tree = etree.ElementTree(
        etree.fromstring(xmlcontent,
                         parser=etree.XMLParser(encoding="UTF-8"))
    )

    assert check_info_revhistory(tree, {}) is None

