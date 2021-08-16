import pytest
import py
import gen

ROOTDIR = py.path.local(__file__).parts()[-3]
TESTDIR = ROOTDIR / "tests"
DATADIR = TESTDIR / "data"
BINDIR = ROOTDIR / "bin"
SCRIPT = BINDIR / "getentityname.py"


@pytest.fixture(autouse=True)
def add_semver(doctest_namespace):
    # doctest_namespace["gen"] = getentityname
    pass

@pytest.fixture
def doctype():
    doctype, _ = gen.dtdmatcher()
    return doctype
