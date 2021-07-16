from pathlib import Path
import re
import sys

import pytest

# "dxwf" is the abbreviated name for daps-xmlwellformed
# We can't import a name with a "-" so we use a link here:
import dxwf


THISDIR = Path(__file__).parent
DATADIR = THISDIR / "data"
BADDIR = DATADIR / "bad"


def test_syntax_error():
    # Given
    xmlfile = str(BADDIR / "test-with-syntax-error.xml")

    # When
    result = dxwf.check_wellformedness(xmlfile)

    # Then
    assert result != 0


def test_syntax_error_stderr(capsys):
    # Given
    xmlfile = str(BADDIR / "test-with-syntax-error.xml")

    # When
    dxwf.check_wellformedness(xmlfile)
    captured = capsys.readouterr()

    # Then
    assert captured.err.startswith("ERROR")


def test_unknown_entity_stderr(capsys):
    # Given
    xmlfile = str(BADDIR / "test-undef-entity.xml")

    # When
    result = dxwf.check_wellformedness(xmlfile)
    captured = capsys.readouterr()

    # Then
    assert result !=0
    assert "ERR_UNDECLARED_ENTITY" in captured.err
    # assert "Entity 'unknown' not defined" in captured.err
    assert re.search(r"[eE]ntity\s'([a-zA-Z\d]+)'\snot\sdefined",
                     captured.err,
                     )
