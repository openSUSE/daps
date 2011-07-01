#!/usr/bin/python
# -*- coding: UTF-8 -*-

"""
  Manages the diffing between a file in a specific branch and
  a file in a specific trunk, returns statistical information
  for translators

"""

__version__="$Id: $"
__author__="Thomas Schraitle <thomas.schraitle@suse.de>"


import sys
import re
import os
import os.path
import commands
from optparse import Option, OptionParser, OptionGroup, OptionValueError
from shutil   import copyfile

class SVNException(Exception):
     pass



def svncmd(command, filename):
   """ """
   return commands.getstatusoutput("%s %s" % (command, filename) )


def svncommand(command, filename, msg=None):
   """ """
   result = svncmd(command, filename)
   if result[0]!=0:
      if msg==None:
         raise SVNException(result[1])
      else:
         raise SVNException("%s: %s" % (msg, result[1]))
   return result[1]


def svninfo(filename):
   """ """
   return svncommand("LANG=C svn info", filename)


def svnpropget(property, filename):
   """ """
   return svncommand("svn propget %s" % property, filename)


def svnstatus(filename):
   """Return the SVN flags of a given file"""
   result = svncmd("svn status", filename)
   if result[0]!=0:
      raise SVNException("svn status failed on »%s« with »%s«" % (filename, result))

   # Check, if file was modified
   if result[1]=="":
      return "      "# Not modified files return a constant string of spaces
   else:
      svnflags=result[1][:7]# Get all flags; SVN has 6 flags
      return svnflags


def svnupdate(filename):
   """ """
   return svncommand("svn update", filename, "Could not update")


#
#
#
class SVNEnvironment:
   """ """

   def __init__(self, tag, filenames):
      self.filenames = filenames
      self.tag       = tag

      # print gettrunandbranchdir()
      self.svnroot=self.getsvnroot()
      self.remotetagsdir=self.gettagsdir(self.svnroot, "branches/")
      try:
         self.dtdroot = os.environ["DTDROOT"]
      except KeyError, e:
         raise DocManager("Environment variable DTDROOT not set.")

      #
      self.resultdict = {} # Define it empty
      # print "svnroot", self.svnroot
      # print "remotetagsdir", self.remotetagsdir


   def diff(self):
      """ """
      #
      for f in self.filenames:
         self.resultdict[f] = None
         svnfile = SVNFile(f)
         dr = svnfile.docrelease()
         print "Investigating file »%s« (%s) ..." % (f, dr)
         _tmpremotetagsdir=os.path.join(self.remotetagsdir, dr, self.tag)
         print _tmpremotetagsdir

         # Create a temporary directory for each file in tags dir
         # Use the one in your working copy
         tmpdir = os.path.join("tmp", self.tag)
         try:
            os.mkdir(tmpdir)
         except OSError, e:
            if e.errno!=17: # File exists
               raise OSError(e)
            # If e.errno==17 it's ok

         # Get the remaining directories after the docrelease
         cdir=os.getcwd()
         try:
            endir=cdir.split(dr)[1][1:] # We want the second and from that cut off the remaining /
         except IndexError:
            raise SVNException("You are not in branch")

         path2file = os.path.join(_tmpremotetagsdir, endir, f)
         # print "***", dr, _tmpremotetagsdir, path2file
         result = svninfo(f)
         # print result

         tmpfile = os.path.join(tmpdir, os.path.basename(f))# Put it in the local tmp directory

         svncommand("svn cat %s >" % path2file, tmpfile)
         result = svnstatus(f)
         # print "Status: »%s«" % result
         if result[0]=="M":
            raise SVNException("File »%s« is modified. Please check in your changes or revert it first, before you start this tool." % f)

         result=svnupdate(f)

         _splitedf=os.path.splitext(tmpfile)
         branchfile=_splitedf[0]+"_branch"+_splitedf[1]
         copyfile(f, branchfile)

         for _f in tmpfile, branchfile:
            __basename = os.path.splitext(_f)[0]
            tmptxtfile = __basename +".txt"
            sorttxtfile = __basename + "_wl.txt"# wl = wordlist

            xsltstylesheet = os.path.join(self.dtdroot, "xslt/misc/get-textonly.xsl")
            cmd = "xsltproc --output %s %s %s" % (tmptxtfile, xsltstylesheet, _f)
            result = commands.getstatusoutput(cmd)
            # if result[0]!=0:
            #   raise DocManager("Could not copy: %s" % result)
            # print "Befehl: ", cmd

         # Now run wdiff
         cmd = "wdiff --statistics %s %s >/dev/null" % (branchfile, tmpfile)
         result = commands.getstatusoutput(cmd)
         # print cmd
         self.resultdict[f]=result[1]

         # ------------
#          for _f in tmpfile, branchfile:
#             __basename = os.path.splitext(_f)[0]
#             tmptxtfile = __basename +".txt"
#             sorttxtfile = __basename + "_wl.txt"# wl = wordlist
#             cmd = r"cat %s | sed \"s/ /\\n/g\" | sort | uniq > %s" % (tmptxtfile, sorttxtfile)
#             print cmd
#             result = commands.getstatusoutput(cmd)
#
#
#          cmd = "wdiff --statistics %s %s >/dev/null" % ( \
#                 os.path.splitext(branchfile)[0]+"_wl.txt",
#                 os.path.splitext(tmpfile)[0]+"_wl.txt"
#                 )
#          print cmd

      # print self.resultdict
      print


   def out(self):
      """ """
      i=iter(self.resultdict)

      try:
         while 1:
            x = i.next()
            # print x
            print self.resultdict[x]
            print "-"*40

      except StopIteration:
         pass


   def getsvnroot(self):
      """Returns the remote SVN root URL"""
      result = commands.getstatusoutput("svn info | grep URL")

      if result[0]!=0:
         raise SVNException("svn info failed. Got: %s" % result[1])
      return result[1].split("URL: ")[1]

   def gettagsdir(self, directory=None, part="/trunk/"):
      """Returns the tags directory"""
      if directory==None:
         currentdir = os.getcwd()
      else:
         currentdir = directory

      m = re.split(part, currentdir)

      return os.path.join(m[0], "tags")




class SVNFile:
   """ """
   def __init__(self, filename):
      self.filename = filename

      if not self.filename or self.filename==None:
         raise SVNException("Empty filename")
      if not(os.path.exists(self.filename)):
         raise IOError("File »%s« not found!" % self.filename)


   def docrelease(self):
      self.docrelease=svnpropget("doc:release", self.filename)
      return self.docrelease



def diffing(tag, filenames):
   """ """
   if len(filenames)==0:
      raise OptionValueError("I need a filename.")

   svnenv = SVNEnvironment(tag, filenames)
   svnenv.diff()
   svnenv.out()



if __name__=="__main__":
   try:
      parser = OptionParser(usage="%prog TAGNAME FILENAME(S)...",
                           version="%prog " + __version__[3:-1],
                           description="Diffs a filename in branch and tag." \
                           "For example TAGNAME can be LOCDROP_1 and filename " \
                           "can be xml/foo.xml")


      (options, args) = parser.parse_args()

      if len(args)==0:
         parser.print_help()
         sys.exit(0)
      elif len(args)<2:
         raise OptionValueError("I need a tag and one ore more filenames")

      print args
      diffing(args[0], args[1:])


   except OptionValueError, e:
      print e

   except SVNException, e:
      print e

#    except Exception, e:
#       print e
