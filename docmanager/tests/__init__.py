#!/usr/bin/env python
# -*- coding: utf-8 -*-

import sys
import os
from os import path

from core import *
import subprocess


def setUpPackage():
  # Create SVN repository
  if not path.exists(SVNREPO) or not path.exists(WORKINGREPO):
    log.error("SVN repository '%s' does not exists!" % SVNREPO)
    d=path.relpath(path.abspath(path.dirname(__file__)))
    # "svnadmin create %s" % SVNREPO
    # "svn export %s %s.tmp" % (TESTROOT, WORKINGREPO)
    # "svn import %s.tmp file://%s -m'Initial import'" % (WORKINGREPO, SVNREPO)
    # shutil.rmtree("%s.tmp" %  WORKINGREPO)
    # "svn checkout file://%s %s" % (SVNREPO, WORKINGREPO)
    
    res = os.system(path.join(d, "init-svn.sh --svnrepo %s " \
      "--workingrepo %s "\
      "--testroot %s" % (SVNREPO, WORKINGREPO, TESTROOT)))
    log.error("Result of system: %s" % res)
