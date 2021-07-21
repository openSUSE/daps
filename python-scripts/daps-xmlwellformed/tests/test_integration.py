from pathlib import Path
import logging
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
    assert result == dxwf.ExitCode.file_not_found


def test_main_two():
    # Given
    xmlfiles = ["test-syntax-comments.xml",
                "test-syntax-err-undeclared-entity.xml"]
    files = [str(BADDIR / f) for f in xmlfiles]

    # When
    result = dxwf.main(["--xinclude", *files])

    # Then
    assert result != 0


def test_main_one_good_one_bad(caplog):
    # Given
    xmlfiles = [
        # the good
        "test-external-entity.xml",
        # the bad
        "test-syntax-comments.xml",
    ]
    messages = (
        "Comment not terminated",
        "Start tag expected, '<' not found",
    )
    dirs = [GOODDIR, BADDIR]
    files = [str(d / f) for d, f in zip(dirs, xmlfiles)]

    # When
    with caplog.at_level(logging.ERROR):
        result = dxwf.main(["--xinclude", *files])

    # Then
    assert result != 0
    assert len(caplog.records) == len(messages)
    for record, msg in zip(caplog.records, messages):
        assert record.msg == msg
