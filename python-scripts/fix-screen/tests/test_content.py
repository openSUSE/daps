import pytest
import screen


def test_extract_screen_block():
    content = """
    <para>Hello World</para>
    <screen>
    This is a screen
    block
    </screen>
    <para>Goodbye World</para>
    """
    result = screen.extract_screen_blocks(content)
    assert len(result)
    assert result[0] == '    <screen>\n    This is a screen\n    block\n    </screen>\n'


def test_extract_screen_block_with_entity():
    content = """
    <para>Hello World</para>
    <screen>
    This is a screen with an entity &lt;
    block
    </screen>
    <para>Goodbye World</para>
    """
    result = screen.extract_screen_blocks(content)
    assert len(result)
    assert result[0] == (
        '    <screen>\n'
        '    This is a screen with an entity &lt;\n'
        '    block\n'
        '    </screen>\n'
    )
    assert "&lt;" in result[0]


def test_extract_screen_block_with_non_std_entity():
    content = """
    <para>Hello World</para>
    <screen>
    This is a screen with an entity &hello;
    block
    </screen>
    <para>Goodbye World</para>
    """
    result = screen.extract_screen_blocks(content)
    assert len(result)
    assert result[0] == (
        '    <screen>\n    '
        'This is a screen with an entity '
        f'{screen.START_DELIMITER}hello{screen.END_DELIMITER}\n'
        '    block\n    </screen>\n')


def test_extract_screen_block_with_childelements():
    content = """
    <para>Hello World</para>
    <screen>
    <prompt>&lt;</prompt>
    <command>ls</command>
    </screen>
    <para>Goodbye World</para>
    """
    result = screen.extract_screen_blocks(content)
    assert len(result)
    assert result[0] == (
        '    <screen>\n'
        '    <prompt>&lt;</prompt>\n'
        '    <command>ls</command>\n'
        '    </screen>\n')