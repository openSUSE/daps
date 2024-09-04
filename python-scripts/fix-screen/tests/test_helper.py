import pytest
import screen
from lxml import etree


def test_is_screen_content_text_only():
    content = "<screen>\nThis is a screen\nblock\n</screen>"
    xml = etree.fromstring(content, parser=screen.xmlparser())
    result = screen.is_screen_content_text_only(xml)
    assert result


def test_is_screen_content_text_only_with_prompt():
    content = "<screen>\n<prompt>echo</prompt>\ncommand\n</screen>"
    xml = etree.fromstring(content, parser=screen.xmlparser())
    result = screen.is_screen_content_text_only(xml)
    assert not result