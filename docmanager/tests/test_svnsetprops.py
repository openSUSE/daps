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
    
  def setUp(self):
    self.c = self.__class__
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
    
  def test_setEditing(self):
    """Change doc:status to 'editing'"""
    
    pwd = os.getcwd()
    os.chdir( WORKINGREPO )# 
    sys.argv=["testy.py", "--force",
                "ds", "-o", "/tmp/.dm-test.log",
                "--set-editing",
                "xml/%s" % self.filename ]
    res = main()
    cmd="svn pg doc:status xml/%s" % self.filename
    proc=subprocess.Popen(cmd, stdout=subprocess.PIPE, stderr=subprocess.PIPE, shell=True)
    out, err = proc.communicate()
    
    self.assertEqual( out.strip(), "editing", "Unexpected doc:status")
    os.chdir(pwd)
    
  def test_setEdited(self):
    """Change doc:status to 'edited'"""
    
    pwd = os.getcwd()
    os.chdir( WORKINGREPO )# 
    sys.argv=["testy.py", "--force",
                "ds", "-o", "/tmp/.dm-test.log",
                "--set-edited",
                "xml/%s" % self.filename ]
    res = main()
    cmd="svn pg doc:status xml/%s" % self.filename
    proc=subprocess.Popen(cmd, stdout=subprocess.PIPE, stderr=subprocess.PIPE, shell=True)
    out, err = proc.communicate()
    
    self.assertEqual( out.strip(), "edited", "Unexpected doc:status")
    os.chdir(pwd)
    
  def test_setProofing(self):
    """Change doc:status to 'proofing'"""
    
    pwd = os.getcwd()
    os.chdir( WORKINGREPO )# 
    sys.argv=["testy.py", "--force",
                "ds", "-o", "/tmp/.dm-test.log",
                "--set-proofing",
                "xml/%s" % self.filename ]
    res = main()
    cmd="svn pg doc:status xml/%s" % self.filename
    proc=subprocess.Popen(cmd, stdout=subprocess.PIPE, stderr=subprocess.PIPE, shell=True)
    out, err = proc.communicate()
    
    self.assertEqual( out.strip(), "proofing", "Unexpected doc:status")
    os.chdir(pwd)
    
  def test_setProofed(self):
    """Change doc:status to 'proofed'"""
    
    pwd = os.getcwd()
    os.chdir( WORKINGREPO )# 
    sys.argv=["testy.py", "--force",
                "ds", "-o", "/tmp/.dm-test.log",
                "--set-proofed",
                "xml/%s" % self.filename ]
    res = main()
    cmd="svn pg doc:status xml/%s" % self.filename
    proc=subprocess.Popen(cmd, stdout=subprocess.PIPE, stderr=subprocess.PIPE, shell=True)
    out, err = proc.communicate()
    
    self.assertEqual( out.strip(), "proofed", "Unexpected doc:status")
    os.chdir(pwd)
    
  def test_setLocdrop(self):
    """Change doc:status to 'locdrop'"""
    
    pwd = os.getcwd()
    os.chdir( WORKINGREPO )# 
    sys.argv=["testy.py", "--force",
                "ds", "-o", "/tmp/.dm-test.log",
                "--set-locdrop",
                "xml/%s" % self.filename ]
    res = main()
    cmd="svn pg doc:status xml/%s" % self.filename
    proc=subprocess.Popen(cmd, stdout=subprocess.PIPE, stderr=subprocess.PIPE, shell=True)
    out, err = proc.communicate()
    
    self.assertEqual( out.strip(), "locdrop", "Unexpected doc:status")
    os.chdir(pwd)

  def test_setComments(self):
    """Change doc:status to 'comments'"""
    
    pwd = os.getcwd()
    os.chdir( WORKINGREPO )# 
    sys.argv=["testy.py", "--force",
                "ds", "-o", "/tmp/.dm-test.log",
                "--set-comments",
                "xml/%s" % self.filename ]
    res = main()
    cmd="svn pg doc:status xml/%s" % self.filename
    proc=subprocess.Popen(cmd, stdout=subprocess.PIPE, stderr=subprocess.PIPE, shell=True)
    out, err = proc.communicate()
    
    self.assertEqual( out.strip(), "comments", "Unexpected doc:status")
    os.chdir(pwd)

  

if __name__ == "__main__":
  unittest.main()
