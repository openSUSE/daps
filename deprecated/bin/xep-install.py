#!/usr/bin/python
# -*- coding: UTF-8 -*-

"""Python script for installing a new XEP version
"""

import sys
import os
import commands

destdir="/tmp/xep-install"
licensefile=""

def copyfile(filename):
   """Copy filename"""
   print "Copying file »%s« ..." % filename,
   if not os.path.exists(destdir):
      os.mkdir(destdir)
   res=commands.getstatusoutput("cp -vi %s %s" % (filename, destdir ))
   if res[0] != 0:
      print >> sys.stderr, "\nERROR: %s" % res[1]
      cleanup()
      sys.exit(100)
   print "done"
   print "  ", res[1]
   return os.path.basename(filename)


def unpack(filename):
   """ """
   print "Unpacking »%s« ..." % filename,
   currentdir=os.getcwd()
   os.chdir(destdir)
   res=commands.getstatusoutput("unzip %s" % os.path.join(destdir, filename) )
   os.chdir(currentdir)
   if res[0] != 0:
      print >> sys.stderr, "\nERROR: %s" % res[1]
      cleanup()
      sys.exit(200)
   print "done"


def searchXEPPath():
   """ """
   print "Searching for XEP installation path ...",
   path=os.getenv("PATH")
   for p in path.split(":"):
      if "XEP" in p:
         print '"%s"' % p
         return p
   print >> sys.stderr, "\nERROR: XEP installation path not found."
   sys.exit(300)


def copylicensefile(xepdir):
   """ """
   print "Copying license file ...",
   res=commands.getstatusoutput("cp -vi %s %s" % (os.path.join(xepdir,licensefile), destdir ))
   #print res
   if res[0] != 0:
      print >> sys.stderr, "\nERROR: %s" % res[1]
      cleanup()
      sys.exit(200)
   print "done"


def startsetup(filename):
   """ """
   setupfile = "setup-*.jar"
   #currentdir=os.chdir(destdir)
   res=commands.getstatusoutput("(cd %s; java -jar %s)" % (destdir, os.path.join(destdir, setupfile)) )
   #os.chdir(currentdir)
   if res[0] != 0:
      print >> sys.stderr, "ERROR: %s" % res[1]
   # print res


def renameXEPDir(xepdir):
   """ """
   print "Trying to rename old XEP installation directory ... ",
   res=commands.getstatusoutput("xep -version" )
   if res[0] != 0:
      import datetime
      d=datetime.date.today()
      version = "%s%s%s" % (d.year, d.month, d.day)
   else:
      version = res[1].split(" ")[-1]

   os.rename(xepdir, xepdir+"-"+version)
   print "%s -> %s" % (xepdir, xepdir+"-"+version)
   return (xepdir, xepdir+"-"+version)


def createNewXEPDir(xepdir):
   """ """
   print "Creating new directory »%s« ..." % xepdir,
   if not os.path.exists(xepdir):
      os.mkdir(xepdir)
   else:
      print >> sys.stderr, "\nWARNING: Directory »%s« already exists." % xepdir

   print "done"


def main(filename):
   """ """
   filename=copyfile(filename)
   xepdir=searchXEPPath()
   oldxepdir=renameXEPDir(xepdir)[0]
   createNewXEPDir(xepdir)
   copylicensefile(oldxepdir)
   unpack(filename)
   startsetup(filename)
   cleanup()
   print "XEP successfully installed."


def cleanup():
   print "Cleaning up... ",
   if os.path.exists(destdir):
      for i in os.listdir(destdir):
         os.remove(os.path.join(destdir, i))
      os.rmdir(destdir)
   print "done"


if __name__ == "__main__":

   if len(sys.argv)!=2:
      print >> sys.stderr, "ERROR: I need the XEP package."
   if not os.path.exists(sys.argv[1]):
      print >> sys.stderr, "ERROR: File not found: »%s«" % sys.argv[1]
   try:
      main(sys.argv[1])
   except RuntimeError, e:
      cleanup()
   #except OSError, e:
      #print >> sys.stderr, e
      #cleanup()
   except KeyboardInterrupt:
      print "Interrupted"
