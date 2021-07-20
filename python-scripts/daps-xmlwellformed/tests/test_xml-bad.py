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
    xmlfile = "test-syntax-err-tag-name-mismatch.xml"
    file = str(BADDIR / xmlfile)

    # When
    dxwf.check_wellformedness(file)
    captured = capsys.readouterr()

    # Then
    assert xmlfile in captured.err
    assert "ERROR" in captured.err


def test_unknown_entity_stderr(capsys):
    # Given
    xmlfile = "test-syntax-err-undeclared-entity.xml"
    file = str(BADDIR / xmlfile)

    # When
    result = dxwf.check_wellformedness(file)
    captured = capsys.readouterr()

    # Then
    assert result == dxwf.ExitCode.syntax
    assert xmlfile in captured.err
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


@pytest.mark.parametrize("xmlfile,errormsg", [
    ("test-xinclude-file-not-found.xml", "File not found"),
    ("test-xinclude-undeclared-entity.xml", "Cannot resolve URI"),
])
def test_xinclude_errors(xmlfile, errormsg, capsys):
    # Given
    xmlfile = str(BADDIR / xmlfile)

    # When
    result = dxwf.check_wellformedness(xmlfile, xinclude=True)
    captured = capsys.readouterr()

    # Then
    assert errormsg in captured.err
    assert result == dxwf.ExitCode.xinclude
