import pytest

# import getentityname

@pytest.fixture(autouse=True)
def add_semver(doctest_namespace):
    # doctest_namespace["gen"] = getentityname
    pass


class XMLException(Exception):
    """Custom exception for error reporting."""


class XMLFileItem(pytest.Item):
    def __init__(self, name, parent):
        super().__init__(name, parent)

    def runtest(self):
        print(">>>", self.fspath, self.name, self.listnames)
              #dir(self))
        # raise XMLException(self, "Hello")
        return # ok

    def repr_failure(self, excinfo):
        if isinstance(excinfo.value, XMLException):
            return "\n".join(
                ["XML usecase failed",
                 "  {!r}".format(*excinfo.value.args),
                ]
            )


class XMLFileCollector(pytest.File):
    def collect(self):
        yield XMLFileItem(str(self.fspath), parent=self)


"""
def pytest_collect_file(path, parent):
    print(">>>", path, parent)
    if path.ext == ".xml" and path.basename.endswith("tests/data"):
        return XMLFileCollector("tests/data", parent=parent)
"""

