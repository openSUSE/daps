#!/usr/bin/env python
# -*- coding: utf-8 -*-

import sys
import os, os.path

from setuptools import Command
from setuptools.command.test import test  as _test
from setuptools.command.build_py import build_py

__all__=["CleanCommand", "TestCommand", "ManpageCommand"]




class CleanCommand(Command):
   """clean build and dist directory"""
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
   """run unit tests after in-place build"""
   description = __doc__

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

class ManpageCommand(Command):
   """creates manpage from DocBook source"""
   description = __doc__

   user_options = [
      ('xml=',  None, "XML file in DocBook format"),
      ('xslt=', None, "XSLT stylesheet"),
      #('workingrepo=', None, "Working directory"),
   ]
   
   def initialize_options(self):
      self.xml=None
      self.xslt=None
      
   def finalize_options(self):
      if not self.xml:
         self.xml = "doc/docmanager.xml"
      if not self.xslt:
         self.xslt="/usr/share/xml/docbook/stylesheet/nwalsh/current/manpages/docbook.xsl"

      if not self.verbose:
         print dir(self)
         self.dump_options()
      self.ensure_filename('xml')
   
   def run(self):
      cmd="xsltproc --stringparam man.output.base.dir '%s/' " \
          "--stringparam man.output.subdirs.enabled 0 " \
          "--stringparam man.output.in.separate.dir 1 " \
          "%s %s" % (os.path.dirname(self.xml), self.xslt, self.xml)
      res=os.system(cmd)
      if not self.verbose:
         print "  %s -> %s" % (cmd, res)
   