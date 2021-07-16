from pathlib import Path
import sys

import pytest

# "dxwf" is the abbreviated name for daps-xmlwellformed
# We can't import a name with a "-" so we use a link here:
import dxwf


THISDIR = Path(__file__).parent
DATADIR = THISDIR / "data"
GOODDIR = DATADIR / "good"


@pytest.mark.parametrize("xmlfile", [
    "test-wents-wxi.xml",
    "test-defined-entity.xml",
    "test-external-entity.xml",
    "test-defined-entity-with-xinclude.xml",
])
def test_check_wellformedness(xmlfile):
    # Given
    xmlfile = str(GOODDIR / xmlfile)

    # When
    result = dxwf.check_wellformedness(xmlfile)

    # Then
    assert result == 0
