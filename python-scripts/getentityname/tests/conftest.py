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


#@pytest.fixture(scope="session")
#def xmlgoodcase():
#


## ---------------------------------------------------------------------
class XMLException(Exception):
    """Custom exception for error reporting."""


class XMLFileItem(pytest.Item):
    def __init__(self, name, parent, failed, error=None):
        super().__init__(name, parent)
        self.failed = failed
        self.error = error

    def runtest(self):
        if self.failed:
            raise XMLException(self, self.fspath)
        return # ok

    def repr_failure(self, excinfo):
        if isinstance(excinfo.value, XMLException):
            return "\n".join(
                ["XML usecase {!r} failed".format(self.fspath.relto(ROOTDIR)),
                 "  error={}".format(self.error),
                 "  location={}".format(self.location),
                 # "  name={}".format(self.name),
                 "  nodeid={}".format(self.nodeid),
                 "  reportinfo={}".format(self.reportinfo),
                 "  failed={}".format(self.failed),
                 "  parent={}".format(self.parent),
                 "  fspath={}".format(self.fspath),
                 "{}".format(dir(self)),
                 "  {!r}".format(*excinfo.value.args),
                ]
            )


class XMLFileCollector(pytest.File):
    def collect(self):
        failed=False
        excinfo=None
        try:
            output = SCRIPT.sysexec(str(self.fspath), shell=True).strip()
            # failed=True
            print(">>>", output)
        except py.process.cmdexec.Error as error:
            failed=True
            excinfo = error
        yield XMLFileItem("entities", parent=self, failed=failed, error=excinfo)


"""
def pytest_collect_file(path, parent):
    if path.ext == ".xml" and path.dirname.endswith("tests/data"):
        print(">>>", path, parent)
        return XMLFileCollector(path, parent=parent)
"""

