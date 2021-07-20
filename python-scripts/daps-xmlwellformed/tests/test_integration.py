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
GOODDIR = DATADIR / "good"


def test_main_single_unknown():
    # Given
    xmlfile = "unknown"
    file = str(BADDIR / xmlfile)

    # When
    result = dxwf.main(["--xinclude", file])

    # Then
    assert result != 0


def test_main_two():
    # Given
    xmlfiles = ["test-syntax-comments.xml",
                "test-syntax-err-undeclared-entity.xml"]
    files = [str(BADDIR / f) for f in xmlfiles]

    # When
    result = dxwf.main(["--xinclude", *files])

    # Then
    assert result != 0


def test_main_one_good_one_bad(capsys):
    # Given
    xmlfiles = [
        # the good
        "test-external-entity.xml",
        # the bad
        "test-syntax-comments.xml",
    ]
    dirs = [GOODDIR, BADDIR]
    files = [str(d / f) for d, f in zip(dirs, xmlfiles)]

    # When
    result = dxwf.main(["--xinclude", *files])
    captured = capsys.readouterr()

    # Then
    assert result != 0
    assert xmlfiles[0] not in captured.err
    assert xmlfiles[1] in captured.err
