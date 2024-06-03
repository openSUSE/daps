from lxml import etree
import pytest

from metadatavalidator.checks.check_meta import (
    check_meta_title,
    check_meta_description,
)
from metadatavalidator.exceptions import InvalidValueError


def test_check_meta_title(xmlparser):
    xmlcontent = """<article xmlns="http://docbook.org/ns/docbook" version="5.2">
    <info>
        <title>Test</title>
        <meta name="title">The SEO title</meta>
    </info>
    <para/>
</article>"""
    tree = etree.ElementTree(
        etree.fromstring(xmlcontent, parser=xmlparser)
    )

    assert check_meta_title(tree, {}) is None


def test_check_meta_title_wrong_length(xmlparser):
    xmlcontent = """<article xmlns="http://docbook.org/ns/docbook" version="5.2">
    <info>
        <title>Test</title>
        <meta name="title">The SEO title that is too long</meta>
    </info>
    <para/>
</article>"""
    tree = etree.ElementTree(
        etree.fromstring(xmlcontent, parser=xmlparser)
    )

    with pytest.raises(InvalidValueError, match=".*too long.*"):
        check_meta_title(tree, dict(metadata=dict(meta_title_length=10)))


def test_check_required_meta_title(xmlparser):
    xmlcontent = """<article xmlns="http://docbook.org/ns/docbook" version="5.2">
    <info>
        <title>Test</title>
    </info>
    <para/>
</article>"""
    tree = etree.ElementTree(
        etree.fromstring(xmlcontent, parser=xmlparser)
    )
    with pytest.raises(InvalidValueError, match=".*required.*"):
        check_meta_title(tree, dict(metadata=dict(meta_title_required=True)))


def test_check_optional_meta_title(xmlparser):
    xmlcontent = """<article xmlns="http://docbook.org/ns/docbook" version="5.2">
    <info>
        <title>Test</title>
    </info>
    <para/>
</article>"""
    tree = etree.ElementTree(
        etree.fromstring(xmlcontent, parser=xmlparser)
    )
    assert check_meta_title(tree,
                            dict(metadata=dict(meta_title_required=False))) is None


def test_check_meta_description(xmlparser):
    xmlcontent = """<article xmlns="http://docbook.org/ns/docbook" version="5.2">
    <info>
        <title>Test</title>
        <meta name="description">The SEO description</meta>
    </info>
    <para/>
</article>"""
    tree = etree.ElementTree(
        etree.fromstring(xmlcontent, parser=xmlparser)
    )

    assert check_meta_description(tree, {}) is None


def test_check_meta_description_wrong_length(xmlparser):
    xmlcontent = """<article xmlns="http://docbook.org/ns/docbook" version="5.2">
    <info>
        <title>Test</title>
        <meta name="description">The SEO description that is too long</meta>
    </info>
    <para/>
</article>"""
    tree = etree.ElementTree(
        etree.fromstring(xmlcontent, parser=xmlparser)
    )

    with pytest.raises(InvalidValueError, match=".*too long.*"):
        check_meta_description(tree, dict(metadata=dict(meta_description_length=10)))


def test_check_required_meta_description(xmlparser):
    xmlcontent = """<article xmlns="http://docbook.org/ns/docbook" version="5.2">
    <info>
        <title>Test</title>
    </info>
    <para/>
</article>"""
    tree = etree.ElementTree(
        etree.fromstring(xmlcontent, parser=xmlparser)
    )
    with pytest.raises(InvalidValueError, match=".*required.*"):
        check_meta_description(tree, dict(metadata=dict(meta_description_required=True)))


def test_check_optional_meta_description(xmlparser):
    xmlcontent = """<article xmlns="http://docbook.org/ns/docbook" version="5.2">
    <info>
        <title>Test</title>
    </info>
    <para/>
</article>"""
    tree = etree.ElementTree(
        etree.fromstring(xmlcontent, parser=xmlparser)
    )
    assert check_meta_description(tree,
                                  dict(metadata=dict(meta_description_required=False))) is None