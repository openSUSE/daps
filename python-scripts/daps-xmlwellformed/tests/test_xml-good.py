from pathlib import Path
import sys

import pytest

# "dxwf" is the abbreviated name for daps-xmlwellformed
# We can't import a name with a "-" so we use a link here:
import dxwf


THISDIR = Path(__file__).parent
DATADIR = THISDIR / "data"
GOODDIR = DATADIR / "good"


def test_check_wellformedness_without_ents_and_without_xi():
    # Given
    xmlfile = str(GOODDIR / "test-wents-wxi.xml")

    # When
    result = dxwf.check_wellformedness(xmlfile)

    # Then
    assert result == 0
