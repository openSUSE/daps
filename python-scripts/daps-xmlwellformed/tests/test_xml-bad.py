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
    xmlfile = str(BADDIR / "test-syntax-err-tag-name-mismatch.xml")

    # When
    result = dxwf.check_wellformedness(xmlfile)

    # Then
    assert result != 0


def test_syntax_error_stderr(capsys):
    # Given
    xmlfile = str(BADDIR / "test-syntax-err-tag-name-mismatch.xml")

    # When
    dxwf.check_wellformedness(xmlfile)
    captured = capsys.readouterr()

    # Then
    assert captured.err.startswith("ERROR")


def test_unknown_entity_stderr(capsys):
    # Given
    xmlfile = str(BADDIR / "test-syntax-err-undeclared-entity.xml")

    # When
    result = dxwf.check_wellformedness(xmlfile)
    captured = capsys.readouterr()

    # Then
    assert result != 0
    assert "ERR_UNDECLARED_ENTITY" in captured.err
    # assert "Entity 'unknown' not defined" in captured.err
    assert re.search(r"[eE]ntity\s'([a-zA-Z\d]+)'\snot\sdefined",
                     captured.err,
                     )


@pytest.mark.parametrize("xmlfile", [
    "test-syntax-err-hyphen-in-comment.xml",
    "test-syntax-err-name-required.xml",
    "test-syntax-err-ltslash-required.xml",
])
def test_syntax_errors(xmlfile):
    # Given
    xmlfile = str(BADDIR / xmlfile)

    # When
    result = dxwf.check_wellformedness(xmlfile)

    # Then
    assert result == dxwf.ExitCode.syntax


def test_file_not_found():
    # Given
    xmlfile = str(BADDIR / "unknown.xml")

    # When
    result = dxwf.check_wellformedness(xmlfile)

    # Then
    assert result == dxwf.ExitCode.file_not_found


@pytest.mark.parametrize("xmlfile", [
    "test-xinclude-file-not-found.xml",
])
def test_xinclude_errors(xmlfile):
    # Given
    xmlfile = str(BADDIR / xmlfile)

    # When
    result = dxwf.check_wellformedness(xmlfile)

    # Then
    assert result == dxwf.ExitCode.xinclude
