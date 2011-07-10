#!/usr/bin/env python
# -*- coding: utf-8 -*-

from setuptools import Command
from setuptools.command.test import test  as _test


class CleanCommand(Command):
    description = "custom clean command that forcefully removes dist/build directories"
    user_options = []
    def initialize_options(self):
        self.cwd = None
    def finalize_options(self):
        self.cwd = os.getcwd()
    def run(self):
        assert os.getcwd() == self.cwd, 'Must be in package root: %s' % self.cwd
        os.system('rm -rf ./build ./dist')

class mytest(_test):
   """Command to run unit tests after in-place build"""
   description = "Run unittests"

   user_options = [
      ('test-module=','m', "Run 'test_suite' in specified module"),
      ('test-suite=','s',  "Test suite to run (e.g. 'some_module.test_suite')"),
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
      print "finalize_options", self, self.__dict__
      
   def run(self):
      _test.run(self)
      print "Running mytest..."
