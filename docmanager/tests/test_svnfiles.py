#!/usr/bin/env python
# -*- coding: utf-8 -*-

__version__="$Revision$"
__author__="Thomas Schraitle <toms AT opensuse DOT org>"

import sys
import os
from os import path

from core import *


class SVNFiles(unittest.TestCase):
  """ Testcase for SVNFile class """
  def test_compareRootAndWorkingXMLFiles(self):
    """Create two lists and compare them: original from ROOT dir and from SVN working dir"""
    xmldir = path.join(WORKINGREPO, 'xml')
    xml = [ f for f in os.listdir(xmldir) if path.isfile(path.join(xmldir,f)) and f.endswith(".xml") ]
    
    roottestdir = path.join(TESTROOT, "xml")
    roottestxml = [ f for f in os.listdir(roottestdir) if path.isfile(path.join(roottestdir,f)) and f.endswith(".xml")]
    
    self.assertListEqual(roottestxml, xml)
    
  def foo(self):
    for x in xml:
      output=subprocess.check_output("svn pl -v --xml %s" % x, shell=True)
      d=path.dirname(x)
      f="%s.log" % path.splitext(x)[0]
      open(f, "w").writelines(output)


if __name__ == "__main__":
  unittest.main()

# EOF