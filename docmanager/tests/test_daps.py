#!/usr/bin/env python
# -*- coding: utf-8 -*-

__version__="$Revision: $"
__author__="Thomas Schraitle <toms AT opensuse DOT org>"

import sys
import os
from os import path
  
from core import *

class DapsTestcase(unittest.TestCase):
  """TestCase for daps"""
  
  def test_00WhereIsDaps(self):
    """Checks, if daps is available"""
    daps = whereis("daps")
    self.assertTrue(daps)
    
  def test_validate(self):
    """Checks output of daps validate"""
    cmd="daps --basedir %s --envfile %s validate" % \
      (WORKINGREPO, "ENV-daps" )    
    proc=subprocess.Popen(cmd, stdout=subprocess.PIPE, stderr=subprocess.PIPE, shell=True)
    out, err = proc.communicate()
    
    self.assertEqual(proc.returncode, 0, "Got return code != 0")
    self.assertFalse(err, msg="Got error code")
    
  def test_projectfiles(self):
    """Checks output of daps projectfiles"""
    cmd="daps --basedir %s --envfile %s projectfiles" % \
      (WORKINGREPO, "ENV-daps")
    proc=subprocess.Popen(cmd, stdout=subprocess.PIPE, stderr=subprocess.PIPE, shell=True)
    out, err = proc.communicate()
    
    self.assertEqual(proc.returncode, 0, "Got return code != 0")
    self.assertEqual(len(out.strip().split()), 2, msg="Expected two files")
    
  def test_projectgraphics(self):
    """Checks output of daps projectgraphics"""
    cmd="daps --basedir %s --envfile %s projectgraphics" % \
      (WORKINGREPO, "ENV-daps")
    proc=subprocess.Popen(cmd, stdout=subprocess.PIPE, stderr=subprocess.PIPE, shell=True)
    out, err = proc.communicate()
    
    self.assertEqual(proc.returncode, 0, "Got return code != 0")
    self.assertEqual(len(out.strip().split()), 0, msg="Expected two files")
    
  def test_make_text(self): 
    """Checks, if daps text is executed without errors"""
    cmd="daps --basedir %s --envfile %s text" % \
      (WORKINGREPO, "ENV-daps")
    proc=subprocess.Popen(cmd, stdout=subprocess.PIPE, stderr=subprocess.PIPE, shell=True)
    out, err = proc.communicate()
    
    self.assertEqual(proc.returncode, 0, "Got return code != 0")
  
  def test_projectfilesWithDAPS_ENV_NAME(self):
    """Checks, if daps is also satisfied with DAPS_ENV_NAME environment variable"""
    os.environ['DAPS_ENV_NAME']="ENV-daps"
    cmd="daps --basedir %s projectfiles" % (WORKINGREPO)
    proc=subprocess.Popen(cmd, stdout=subprocess.PIPE, stderr=subprocess.PIPE, shell=True)
    out, err = proc.communicate()
    self.assertEqual(proc.returncode, 0, "Got return code != 0")
    
    out=out.strip().split()
    
    # Checks if all files exists
    out=[f for f in out if os.path.exists(f) ]
    self.assertTrue(out, msg="daps projectfiles failed")
    
    
  
if __name__ == "__main__":
  unittest.main()

# EOF