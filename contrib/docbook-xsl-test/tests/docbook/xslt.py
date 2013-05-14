# -*- coding: utf-8 -*-

"""
Common module for all test cases

Contains the following variables:

* CANONICALURL
  The official URL which is used to access the DocBook XSL stylesheets online

* MAINXMLCATALOG
  The main XML catalog file (usually /etc/xml/catalog on Linux systems).
  Undefinied for Windows systems, user need to set it manually

* LOCALDBXSLPATH
  The path to the DocBook XSL stylesheets

"""


import platform
import os
import commands


__all__ = [ 'CANONICALURL', 'MAINXMLCATALOG', 'LOCALDBXSLPATH', 'SYSTEM', 'DIST' ]
__author__="Thomas Schraitle <tom_schr (AT) web (DOT) de>"


CANONICALURL='http://docbook.sourceforge.net/release/xsl/current/'
MAINXMLCATALOG={
   'Linux':    "/etc/xml/catalog",
   'Mac':      "/etc/xml/catalog",
   'Windows':  None,
   }

def getlocalpath(catalog, url):
   """Returns the local path from url found in file catalog
   """
   cmd="xmlcatalog {0} {1}".format(catalog, url)
   result=commands.getstatusoutput(cmd)
   if result[0]:
      raise OSError("Problem with xmlcatalog: {0}".format(result[1]))
   
   # Small trick which works in both cases, with and without file:// suffix
   return result[1].split("file://")[-1]
   
   
SYSTEM=platform.system()
DIST=platform.linux_distribution()[0].strip()

if SYSTEM=="Linux":
   # Overwrite it
   MAINXMLCATALOG=MAINXMLCATALOG[SYSTEM]
   LOCALDBXSLPATH=getlocalpath(MAINXMLCATALOG, CANONICALURL)

else:
   raise OSError("Variable LOCALPATH in {0} for system '{1}' is unknown. " \
                 "Please set the correct path.".format(__file__, system))


