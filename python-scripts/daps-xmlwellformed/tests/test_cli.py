from pathlib import Path
import sys

import pytest

# "dxwf" is the abbreviated name for daps-xmlwellformed
# We can't import a name with a "-" so we use a link here:
import dxwf


ROOTDIR = Path(__file__).parent.parent
BINDIR = ROOTDIR / "bin"
PROG = [p for p in BINDIR.glob("daps*") if p.suffix != '.xsl'][0]



def test_help(capsys):
    # given
    # n/a

    # when
    with pytest.raises(SystemExit):
        dxwf.main(["prog", "--help"])

    # then
    assert capsys.readouterr()


def test_invalid(capsys):
    # given
    # n/a

    # when
    with pytest.raises(SystemExit):
        dxwf.main(["prog", "--asdf"])

    # then
    assert capsys.readouterr()