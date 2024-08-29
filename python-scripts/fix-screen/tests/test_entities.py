import pytest
import screen


def test_replace_entities_with_braces():
    text = "echo &gt; &hello;"
    result = screen.replace_entities_with_braces(text)
    assert result not in "&hello;"
    expected = f"echo &gt; {screen.START_DELIMITER}hello{screen.END_DELIMITER}"
    assert result == expected


@pytest.mark.parametrize("text", [
    "&lt;",
    "&gt;",
    "&apos;",
    "&quot;",
    "&amp;",
])
def test_replace_entities_standard(text):
    result = screen.replace_entities_with_braces(text)
    assert result == text


def test_restore_entities_from_braces():
    text = f"echo &gt; {screen.START_DELIMITER}hello{screen.END_DELIMITER}"
    result = screen.restore_entities_from_braces(text)
    assert result == "echo &gt; &hello;"
