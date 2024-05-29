import pytest
from lxml import etree

from metadatavalidator.checks import (
    check_info, check_info_revhistory,
    check_info_revhistory_revision,
    check_info_revhistory_revision_date
)
from metadatavalidator.exceptions import InvalidValueError, MissingAttributeWarning


def test_check_info():
    xmlcontent = """<article xmlns="http://docbook.org/ns/docbook" version="5.2">
    <info>
        <title>Test</title>
    </info>
    <para/>
</article>"""
    tree = etree.ElementTree(
        etree.fromstring(xmlcontent,
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
    xmlcontent = """<article xmlns="http://docbook.org/ns/docbook" version="5.2">
    <info>
        <title>Test</title>
    </info>
    <para/>
</article>"""
    tree = etree.ElementTree(
        etree.fromstring(xmlcontent,
                         parser=etree.XMLParser(encoding="UTF-8"))
    )

    with pytest.raises(InvalidValueError,
                       match="Couldn't find a revhistory element"):
        check_info_revhistory(tree, {})


def test_check_info_revhistory():
    xmlcontent = """<article xmlns="http://docbook.org/ns/docbook" version="5.2">
    <info>
        <title>Test</title>
        <revhistory xml:id="rh"></revhistory>
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
    assert check_info_revhistory(tree, {}) is None


def test_check_info_revhistory_xmlid():
    xmlcontent = """<article xmlns="http://docbook.org/ns/docbook" version="5.2">
    <info>
        <title>Test</title>
        <revhistory xml:id="rh1"></revhistory>
    </info>
    <para/>
</article>"""
    tree = etree.ElementTree(
        etree.fromstring(xmlcontent,
                         parser=etree.XMLParser(encoding="UTF-8"))
    )

    assert check_info_revhistory(tree, {}) is None


def test_check_info_revhistory_missing_xmlid():
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

    with pytest.raises(InvalidValueError,
                       match="Couldn't find xml:id attribute"):
        check_info_revhistory(tree, {})


def test_check_info_revhistory_xmlid_with_wrong_value():
    xmlcontent = """<article xmlns="http://docbook.org/ns/docbook" version="5.2">
    <info>
        <title>Test</title>
        <revhistory xml:id="wrong_id"></revhistory>
    </info>
    <para/>
</article>"""
    tree = etree.ElementTree(
        etree.fromstring(xmlcontent,
                         parser=etree.XMLParser(encoding="UTF-8"))
    )

    with pytest.raises(InvalidValueError,
                       match="should start with 'rh'"):
        check_info_revhistory(tree, {})


def test_check_info_revhistory_revision():
    xmlcontent = """<article xmlns="http://docbook.org/ns/docbook" version="5.2">
    <info>
        <title>Test</title>
        <revhistory>
          <revision xml:id="rh">
            <date>2021-01-01</date>
          </revision>
        </revhistory>
    </info>
    <para/>
</article>"""
    tree = etree.ElementTree(
        etree.fromstring(xmlcontent,
                            parser=etree.XMLParser(encoding="UTF-8"))
    )
    assert check_info_revhistory_revision(tree, {}) is None


def test_check_info_revhistory_revision_missing_xmlid():
    xmlcontent = """<article xmlns="http://docbook.org/ns/docbook" version="5.2">
    <info>
        <title>Test</title>
        <revhistory>
          <revision>
            <date>2021-01-01</date>
          </revision>
        </revhistory>
    </info>
    <para/>
</article>"""
    tree = etree.ElementTree(
        etree.fromstring(xmlcontent,
                            parser=etree.XMLParser(encoding="UTF-8"))
    )

    with pytest.raises(MissingAttributeWarning,
                       match="Missing recommended attribute in"):
        check_info_revhistory_revision(
            tree,
            {"metadata": {"require_xmlid_on_revision": True}})



def test_check_info_revhistory_revision_missing():
    xmlcontent = """<article xmlns="http://docbook.org/ns/docbook" version="5.2">
    <info>
        <title>Test</title>
        <revhistory/>
    </info>
    <para/>
</article>"""
    tree = etree.ElementTree(
        etree.fromstring(xmlcontent,
                         parser=etree.XMLParser(encoding="UTF-8"))
    )

    with pytest.raises(InvalidValueError,
                       match="Couldn't find a revision element"):
        check_info_revhistory_revision(
            tree,
            {"metadata": {"require_xmlid_on_revision": True}}
        )


def test_check_info_revhistory_revision_date():
    xmlcontent = """<article xmlns="http://docbook.org/ns/docbook" version="5.2">
    <info>
        <title>Test</title>
        <revhistory>
          <revision>
            <date>2021-01-01</date>
          </revision>
        </revhistory>
    </info>
    <para/>
</article>"""
    tree = etree.ElementTree(
        etree.fromstring(xmlcontent,
                         parser=etree.XMLParser(encoding="UTF-8"))
    )

    assert check_info_revhistory_revision_date(tree, {}) is None


def test_check_info_revhistory_revision_date_missing():
    xmlcontent = """<article xmlns="http://docbook.org/ns/docbook" version="5.2">
    <info>
        <title>Test</title>
        <revhistory>
          <revision/>
        </revhistory>
    </info>
    <para/>
</article>"""
    tree = etree.ElementTree(
        etree.fromstring(xmlcontent,
                         parser=etree.XMLParser(encoding="UTF-8"))
    )
    with pytest.raises(InvalidValueError,
                       match="Couldn't find a date element"):
        check_info_revhistory_revision_date(tree, {})



def test_check_info_revhistory_revision_date_invalid_format():
    xmlcontent = """<article xmlns="http://docbook.org/ns/docbook" version="5.2">
    <info>
        <title>Test</title>
        <revhistory xml:id="rh">
          <revision>
            <date>January 2024</date>
          </revision>
        </revhistory>
    </info>
    <para/>
</article>"""
    tree = etree.ElementTree(
        etree.fromstring(xmlcontent,
                         parser=etree.XMLParser(encoding="UTF-8"))
    )

    with pytest.raises(InvalidValueError,
                       match="Invalid date format"):
        check_info_revhistory_revision_date(tree, {})


def test_check_info_revhistory_revision_date_invalid_value():
    xmlcontent = """<article xmlns="http://docbook.org/ns/docbook" version="5.2">
    <info>
        <title>Test</title>
        <revhistory xml:id="rh">
          <revision>
            <date>2024-13</date>
          </revision>
        </revhistory>
    </info>
    <para/>
</article>"""
    tree = etree.ElementTree(
        etree.fromstring(xmlcontent,
                         parser=etree.XMLParser(encoding="UTF-8"))
    )

    with pytest.raises(InvalidValueError,
                       match="Invalid value in metadata"
                       ):
        check_info_revhistory_revision_date(tree, {})
