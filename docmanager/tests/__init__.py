#!/usr/bin/env python
# -*- coding: utf-8 -*-

__version__="$Revision$"
__author__="Thomas Schraitle <toms AT opensuse DOT org>"

import sys
import os
from os import path

from core import *
import subprocess


def setUpPackage():
  # Check if SVN repositories are already there:
  if not path.exists(SVNREPO) or not path.exists(WORKINGREPO):
    log.error("SVN repository '%s' does not exists!" % SVNREPO)
    d=path.relpath(path.abspath(path.dirname(__file__)))
    
    res = os.system(path.join(d, "init-svn.sh --svnrepo %s " \
      "--workingrepo %s "\
      "--testroot %s" % (SVNREPO, WORKINGREPO, TESTROOT)))
    log.error("Result of system: %s" % res)
  
  # Check if daps is installed:
  if not whereis("daps"):
    raise IOError("I couldn't find daps. Have you installed the daps package?")
