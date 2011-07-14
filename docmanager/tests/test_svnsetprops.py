#!/usr/bin/env python
# -*- coding: utf-8 -*-

__version__="$Revision$"
__author__="Thomas Schraitle <toms AT opensuse DOT org>"

import sys
import os
from os import path

from core import *
from dm.commandline import main, climain
from dm.base import SVNFile


class SVNSetProperties(unittest.TestCase):
  """Checks set properties """
  @classmethod
  def setUpClass(cls):
    """Setups the class, used for all testcases"""
    cls.filename = "test_01.xml"
    cls.fullfilename = path.join(WORKINGREPO, "xml", cls.filename)
    cls.svn = SVNFile(cls.fullfilename)
    cls.output=subprocess.check_output("svn pl -v --xml %s" % cls.fullfilename, shell=True)
    cls.doc = etree.parse(StringIO(cls.output))
    
  def setUp(self):
    self.c = self.__class__
    self.svn = self.c.svn
    self.filename = self.c.filename

  def test_setMaintainer(self):
    """Change maintainer to 'tux'"""
    user = "tux"
    
    pwd = os.getcwd()
    os.chdir( WORKINGREPO )# 
    sys.argv=["testy.py", "--force",
                "ds", "-o", "/tmp/.dm-test.log",
                "--set-maintainer", user,
                "xml/%s" % self.filename ]
    res = main()
    cmd="svn pg doc:maintainer xml/%s" % self.filename
    proc=subprocess.Popen(cmd, stdout=subprocess.PIPE, stderr=subprocess.PIPE, shell=True)
    out, err = proc.communicate()
    
    self.assertEqual( out.strip(), user, "Unexpected maintainer")
    os.chdir(pwd)
    
    

if __name__ == "__main__":
  unittest.main()
