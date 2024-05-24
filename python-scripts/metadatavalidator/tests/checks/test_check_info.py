from metadatavalidator.checks import check_info
from lxml import etree


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