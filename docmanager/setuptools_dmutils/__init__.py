#!/usr/bin/env python
# -*- coding: utf-8 -*-

import sys
import os

from setuptools import Command
from setuptools.command.test import test  as _test

__all__=["CleanCommand", "TestCommand"]


class CleanCommand(Command):
   """Command to clean the directory"""
   description = "custom clean command that forcefully removes dist/build directories"
   user_options = []
   def initialize_options(self):
      self.cwd = None
   def finalize_options(self):
      self.cwd = os.getcwd()
   def run(self):
      assert os.getcwd() == self.cwd, 'Must be in package root: %s' % self.cwd
      os.system('rm -rf ./build ./dist')

class TestCommand(_test):
   """Command to run unit tests after in-place build"""
   description = "Run unittests"

   user_options = _test.user_options + [
      # Merge with our own:
      ('svnrepo=',     None, "SVN root repository"),
      ('workingrepo=', None, "Working directory"),
   ]
      
   def initialize_options(self):
      _test.initialize_options(self)      
      self.svnrepo = None
      self.workingrepo = None
      
   def finalize_options(self):
      _test.finalize_options(self)
      self.test_args.extend(["--svnrepo", self.svnrepo])
      print "finalize_options", self, self.__dict__, sys.path
      
   #def run(self):
   #   _test.run(self)
   #   print "Running mytest..."

