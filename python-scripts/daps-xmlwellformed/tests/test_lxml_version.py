import pytest


def test_required_lxml(monkeypatch):
    # Given
    from lxml import etree
    import sys

    module = "dxwf"
    if module in sys.modules:
        # Force deleting them if it is already loaded from
        # other tests
        del sys.modules[module]

    with monkeypatch.context() as m:
        # simulate a very low version of lxml
        m.setattr(etree, "LXML_VERSION", (1, 42, 42, 0))
        with pytest.raises(SystemExit):
            import dxwf
