import pytest
import screen
from lxml import etree


def test_modify_screen_with_text_only():
    content = "<screen>\n    This is a screen\nblock  \n</screen>"
    xml = etree.fromstring(content, parser=screen.xmlparser())
    screen.modify_screen_with_text_only(xml)
    assert xml.text == "    This is a screen\nblock  \n"


def test_modify_screen_with_prompt():
    content = "<screen>\n  <prompt>&lt;</prompt>\ncommand\n</screen>"
    xml = etree.fromstring(content, parser=screen.xmlparser())
    screen.modify_screen_with_prompt(xml)
    assert etree.tostring(xml, encoding="unicode") == (
        "<screen>"
        "<prompt>&lt;</prompt>\n"
        "command\n"
        "</screen>"
    )


def test_modify_screen_with_prompt_and_command():
    content = "<screen>\n<prompt>&lt;</prompt>\n  <command>sudo</command>\n</screen>"
    xml = etree.fromstring(content, parser=screen.xmlparser())
    screen.modify_screen_with_prompt(xml)
    assert etree.tostring(xml, encoding="unicode") == (
        "<screen>"
        "<prompt>&lt;</prompt>"
        "<command>sudo</command>\n"
        "</screen>"
    )

def test_modify_screen_with_prompt_entity():
    content = "<screen>        &prompt.root;\n    </screen>"
    xml = etree.fromstring(screen.replace_entities_with_braces(content),
                           parser=screen.xmlparser())
    screen.modify_screen_with_prompt(xml)
    assert etree.tostring(xml, encoding="unicode") == (
        "<screen>"
        f"{screen.START_DELIMITER}prompt.root{screen.END_DELIMITER}\n"
        "    </screen>"
    )


def test_modify_screen_with_prompt_and_replaceable():
    content = "<screen>\n<prompt>&lt;</prompt>\n  <replaceable>PATH</replaceable>\n</screen>"
    xml = etree.fromstring(content, parser=screen.xmlparser())
    screen.modify_screen_with_prompt(xml)
    assert etree.tostring(xml, encoding="unicode") == (
        "<screen>"
        "<prompt>&lt;</prompt>"
        "<replaceable>PATH</replaceable>\n"
        "</screen>"
    )


def test_modify_screen_with_prompt_and_command_text():
    content = "<screen>\n<prompt>&lt;</prompt>\n  <command>sudo</command>\nHello World</screen>"
    xml = etree.fromstring(content, parser=screen.xmlparser())
    screen.modify_screen_with_prompt(xml)
    assert etree.tostring(xml, encoding="unicode") == (
        "<screen>"
        "<prompt>&lt;</prompt>"
        "<command>sudo</command>\n"
        "Hello World"
        "</screen>"
    )


def test_replace_screen_blocks():
    content = (
        "<para>Some text</para>\n"
        "<screen>\n"
        "<prompt>&lt;</prompt>\n"
        "  <command>sudo</command>\n"
        "Hello World</screen>\n"
        "<para>Other text</para>"
    )
    screen_blocks = screen.extract_screen_blocks(content)
    modified_blocks = [(block, screen.modify_screen_content(block))
                       for block in screen_blocks]
    modified_content = screen.replace_screen_blocks(content, modified_blocks)

    assert modified_content == (
        "<para>Some text</para>\n"
        "<screen>"
        "<prompt>&lt;</prompt>"
        "<command>sudo</command>\n"
        "Hello World"
        "</screen>\n"
        "<para>Other text</para>"
    )


def test_replace_screen_blocks_with_prompt_entity():
    content = (
        "<para>Some text</para>\n"
        "<screen>\n"
        "        &prompt.root;\n"
        "    </screen>\n"
        "<para>Other text</para>"
    )
    content = screen.replace_entities_with_braces(content)
    screen_blocks = screen.extract_screen_blocks(content)
    modified_blocks = [(block, screen.modify_screen_content(block))
                       for block in screen_blocks]
    modified_content = screen.replace_screen_blocks(content, modified_blocks)
    #print(">>> screen_blocks:", screen_blocks)
    #print(">>> modified_blocks:", modified_blocks)

    assert modified_content == (
        "<para>Some text</para>\n"
        "<screen>"
        "&prompt.root;\n"
        "    </screen>\n"
        "<para>Other text</para>"
    )