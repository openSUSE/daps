#!/usr/bin/python3
# -*- coding: UTF-8 -*-

import sys
import os, os.path
import glob

import pytest


def pytest_generate_tests(metafunc):
   """
   """
   idlist = []
   argvalues = []
   argnames = []

   # If we have a setup_class method, initalize our class:
   if hasattr(metafunc.cls, 'setup_class'):
      metafunc.cls.setup_class()

   # Fill our helper variables
   for scenario in metafunc.cls.scenarios:
      idlist.append((scenario[0], scenario[1]))
      items = scenario[2].items()
      argnames = [x[0] for x in items]
      argvalues.append(([x[1] for x in items]))

   metafunc.parametrize(argnames, argvalues, ids=idlist, scope="class")


class TestFO:
   """Test class for FO output
   """
   scenarios = []
   basedir=None
   
   # These are constants:
   src="src/"
   res="res/"

   @classmethod
   def setup_class(cls):
      cls.basedir=os.path.dirname(__file__)

      for f in glob.glob( os.path.join(cls.basedir, cls.src, "*.xml") ):
         basename = os.path.basename(f)
         base, _ = os.path.splitext(basename)
         fobase = base+".fo"
         fo = os.path.join(cls.basedir, cls.res, fobase)
         cls.scenarios.append( (basename, fobase,
                                {'sourcexml': os.path.join(cls.basedir, cls.src, basename),
                                 'resultxml': os.path.join(cls.basedir, cls.res, fobase)
                                }
                                )
                              )

   def test_files_exist(self, sourcexml, resultxml):
      """checks, if all files exist"""
      assert os.path.join(self.basedir, self.src, sourcexml)
      assert os.path.join(self.basedir, self.res, resultxml)
