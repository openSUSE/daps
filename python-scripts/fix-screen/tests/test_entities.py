import pytest
import screen


@pytest.mark.parametrize("text", [
    "&ticket1;",
    "&prompt.root;",
    "&ABC;",
    "&prompt;",
    "&repo-url;",
    "&s390;",
    "&s4h;",
    "&crm.live.host;",
    "&geo-vip-site1;",
    "&subnetImask;",
])
def test_replace_entities_with_braces(text):
    result = screen.replace_entities_with_braces(text)
    name = screen.ENTITIES.search(text).group(2)
    expected = f"{screen.START_DELIMITER}{name}{screen.END_DELIMITER}"
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


@pytest.mark.parametrize("text", [
    "&ticket1;",
    "&prompt.root;",
    "&ABC;",
    "&prompt;",
    "&repo-url;",
    "&s390;",
    "&s4h;",
    "&crm.live.host;",
    "&geo-vip-site1;",
    "&subnetImask;",
])
def test_restore_entities_from_braces(text):
    name = screen.ENTITIES.search(text).group(2)
    result = screen.restore_entities_from_braces(
        f"{screen.START_DELIMITER}{name}{screen.END_DELIMITER}"
    )
    assert result == text
