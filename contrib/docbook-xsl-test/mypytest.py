#!/usr/bin/python
# -*- coding: UTF-8 -*-

# content of myinvoke.py
import pytest
import sys

sys.path.insert(0, "tests")

class MyPlugin:
    def pytest_sessionfinish(self):
        print("\n*** test run reporting finishing")

pytest.main(plugins=[MyPlugin()] )

