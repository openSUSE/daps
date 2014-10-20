#!/usr/bin/python3
# -*- coding: UTF-8 -*-

import pytest
import sys

#sys.path.insert(0, "tests")

class MyPlugin:
    def pytest_sessionfinish(self):
        print("\n*** test run reporting finishing")


# Empty statement here needed so minversion reports no error
pytest

pytest.main(plugins=[MyPlugin()] )


