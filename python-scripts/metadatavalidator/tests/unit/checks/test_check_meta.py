from lxml import etree
import pytest

from metadatavalidator.checks.check_meta import (
    check_meta_title,
    check_meta_description,
    check_meta_series,
    check_meta_techpartner,
    check_meta_platform,
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
    config = dict(metadata=dict(meta_title_required=False))
    assert check_meta_title(tree, config) is None


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


def test_check_meta_series(xmlparser):
    xmlcontent = """<article xmlns="http://docbook.org/ns/docbook" version="5.2">
    <info>
        <title>Test</title>
        <meta name="series">Products &amp; Solutions</meta>
    </info>
    <para/>
</article>"""
    tree = etree.ElementTree(
        etree.fromstring(xmlcontent, parser=xmlparser)
    )

    config = dict(metadata=dict(require_meta_series=True,
                                valid_meta_series=["Products & Solutions",
                                                   "Best Practices",
                                                   "Technical References"]))
    assert check_meta_series(tree, config) is None


def test_check_missing_meta_series(xmlparser):
    xmlcontent = """<article xmlns="http://docbook.org/ns/docbook" version="5.2">
    <info>
        <title>Test</title>
    </info>
    <para/>
</article>"""
    tree = etree.ElementTree(
        etree.fromstring(xmlcontent, parser=xmlparser)
    )

    config = dict(metadata=dict(require_meta_series=False))
    assert check_meta_series(tree, config) is None


def test_check_wrong_meta_series(xmlparser):
    xmlcontent = """<article xmlns="http://docbook.org/ns/docbook" version="5.2">
    <info>
        <title>Test</title>
        <meta name="series">Foo</meta>
    </info>
    <para/>
</article>"""
    tree = etree.ElementTree(
        etree.fromstring(xmlcontent, parser=xmlparser)
    )

    config = dict(metadata=dict(require_meta_series=True,
                                valid_meta_series=["Best Practices",
                                                   "Technical References"]))
    with pytest.raises(InvalidValueError, match="Meta series is invalid"):
        check_meta_series(tree, config)


def test_check_meta_techpartner(xmlparser):
    xmlcontent = """<article xmlns="http://docbook.org/ns/docbook" version="5.2">
    <info>
        <title>Test</title>
        <meta name="techpartner">
            <phrase>Acme Inc.</phrase>
            <phrase>Foo Corp.</phrase>
        </meta>
    </info>
    <para/>
</article>"""
    tree = etree.ElementTree(
        etree.fromstring(xmlcontent, parser=xmlparser)
    )

    assert check_meta_techpartner(tree, {}) is None


def test_check_missing_meta_techpartner(xmlparser):
    xmlcontent = """<article xmlns="http://docbook.org/ns/docbook" version="5.2">
    <info>
        <title>Test</title>
    </info>
    <para/>
</article>"""
    tree = etree.ElementTree(
        etree.fromstring(xmlcontent, parser=xmlparser)
    )

    config = dict(metadata=dict(require_meta_techpartner=True))
    with pytest.raises(InvalidValueError, match=".*required.*"):
        check_meta_techpartner(tree, config)


def test_check_missing_children_in_meta_techpartner(xmlparser):
    xmlcontent = """<article xmlns="http://docbook.org/ns/docbook" version="5.2">
    <info>
        <title>Test</title>
        <meta name="techpartner"/>
    </info>
    <para/>
</article>"""
    tree = etree.ElementTree(
        etree.fromstring(xmlcontent, parser=xmlparser)
    )

    config = dict(metadata=dict(require_meta_techpartner=True))
    with pytest.raises(InvalidValueError, match=".*Couldn't find any tech partners.*"):
        check_meta_techpartner(tree, config)


def test_check_meta_techpartner_with_nonunique_children(xmlparser):
    xmlcontent = """<article xmlns="http://docbook.org/ns/docbook" version="5.2">
    <info>
        <title>Test</title>
        <meta name="techpartner">
            <phrase>Acme Inc.</phrase>
            <phrase>Acme Inc.</phrase>
        </meta>
    </info>
    <para/>
</article>"""
    tree = etree.ElementTree(
        etree.fromstring(xmlcontent, parser=xmlparser)
    )

    config = dict(metadata=dict(require_meta_techpartner=True))
    with pytest.raises(InvalidValueError, match=".*Duplicate tech partners.*"):
        check_meta_techpartner(tree, config)


def test_check_meta_platform(xmlparser):
    xmlcontent = """<article xmlns="http://docbook.org/ns/docbook" version="5.2">
    <info>
        <title>Test</title>
        <meta name="platform">Foo</meta>
    </info>
    <para/>
</article>"""
    tree = etree.ElementTree(
        etree.fromstring(xmlcontent, parser=xmlparser)
    )
    config = dict(metadata=dict(require_meta_platform=True))
    assert check_meta_platform(tree, config) is None


def test_check_missing_meta_platform(xmlparser):
    xmlcontent = """<article xmlns="http://docbook.org/ns/docbook" version="5.2">
    <info>
        <title>Test</title>
    </info>
    <para/>
</article>"""
    tree = etree.ElementTree(etree.fromstring(xmlcontent, parser=xmlparser))
    config = dict(metadata=dict(require_meta_platform=True))
    with pytest.raises(InvalidValueError,
                       match=r".*Couldn't find required meta.*"):
        check_meta_platform(tree, config)


def test_check_empty_meta_platform(xmlparser):
    xmlcontent = """<article xmlns="http://docbook.org/ns/docbook" version="5.2">
    <info>
        <title>Test</title>
        <meta name="platform"/>
    </info>
    <para/>
</article>"""
    tree = etree.ElementTree(etree.fromstring(xmlcontent, parser=xmlparser))
    config = dict(metadata=dict(require_meta_platform=True))
    with pytest.raises(InvalidValueError, match=r".*Empty meta.*"):
        check_meta_platform(tree, config)
