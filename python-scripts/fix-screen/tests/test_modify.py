import pytest
import screen
from lxml import etree


def test_modify_screen_with_text_only():
    content = "<screen>\n    This is a screen\nblock  \n</screen>"
    xml = etree.fromstring(content, parser=screen.xmlparser())
    screen.modify_screen_with_text_only(xml)
    assert xml.text == "    This is a screen\nblock  \n"


def test_modify_screen_with_prompt():
    content = "<screen>\n<prompt>&lt;</prompt>\ncommand\n</screen>"
    xml = etree.fromstring(content, parser=screen.xmlparser())
    screen.modify_screen_with_prompt(xml)
    assert etree.tostring(xml, encoding="unicode") == "<screen><prompt>&lt;</prompt>\ncommand\n</screen>"