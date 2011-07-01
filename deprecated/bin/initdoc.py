#!/usr/bin/python
# -*- coding: UTF-8 -*-

import commands
import os
import os.path
import sys
from optparse import Option, OptionParser


usage="Help:\n %s directory"

__author__="Thomas Schraitle <thomas DOT schraitle AT suse DOT de>"
__doc__="Creates directory structure for SUSE books."
__version__="$Id$"

# Possible repository URLs
SVN="svn+ssh://forgesvn1.novell.com/svn/novdoc/"
HTTPS="https://forgesvn1.novell.com/svn/novdoc/"

class SVNException(Exception):
    pass

class LaunchError(Exception):
    """Signal a failure in execution of an external command. Parameters are the
    exit code of the process, the original command line, and the output of the
    command."""
    pass

def getLang():
   """Returns the language from environment variable LANG"""
   try:
      lang=os.environ["LANG"]
      if lang.startswith("zh"):
         return lang
      else:
         return lang.split("_")[0]

   except KeyError:
      return "en"


def mkdirs(rootdir, lang=None):
   """ """
   ox=os.path.join(rootdir, "books" )

   # Our structure
   dirlist=["images", "tmp", "profiled", "html", "xml",
            "images/src", "images/print", "images/online",
            "images/src/fig", "images/src/png", "images/src/svg"]


   if not os.path.exists(ox):
      print "Creating %s..." % ox
      os.mkdir(ox)

   if lang==None:
      lang=getLang()

   print "Using language %s" % lang

   ox=os.path.join(ox, lang )
   if not os.path.exists(ox):
      print "Creating %s..." % ox
      os.mkdir(ox)

   for j in dirlist:
      x = os.path.join(ox, j)

      if not os.path.exists(x):
         print "Creating %s..." % x
         os.mkdir(x)
   #
   print


def launchsvn(cmd):
   """ """

   try:
      for line in os.popen(cmd).readlines():
         print line[:-1]
   except IOError:
      raise SVNException("Checking out created an error")



def checkout(rootdir, scheme):
   """Checks out the hole directory"""
   if scheme=="svn":
      trunk=os.path.join(SVN, "trunk")
   elif scheme=="https":
      trunk=os.path.join(HTTPS, "trunk")
   else:
      print "Unknown Scheme »%s«!\n" \
            "I do not know how to check out."  % scheme
      sys.exit(100)

   if os.path.exists(os.path.join(rootdir, "novdoc")):
      print "Hint: Directory %s already exists." % os.path.join(rootdir, "novdoc")
      return

   print "Using URL »%s«" % trunk

   if scheme=="svn":
      print "** Subversion (respectivly SSH) needs a password two times"
      print "** Enter the password \"anonymous\" (without the quotes.)"

   novdoc=os.path.join(rootdir, "novdoc")
   cmd = "svn co --username anonymous %s %s" % (trunk, novdoc)
   #result = commands.getstatusoutput(cmd)
   result = launchsvn(cmd)



def InstallOptionParser():
   """ """
   parser = OptionParser(usage="%prog [options] DIRECTORY",
         version="%prog " + __version__[3:-1],
         description="Creates the structure for SUSE books and checks out the Novdoc DTD and build mechanics")
   parser.add_option("-l", "--language",
      dest="lang",
      choices=("cz", "de", "en", "es", "fr", "hu", "it", "ja", "pt_BR", "zh_CN", "zh_TW"),
      # default=True,
      help="Set the language")
   parser.add_option("-a", "--accessing-method",
      dest="scheme",
      default="https",
      choices=("ssh", "https"),
      help="Selects the accessing method (SVN or HTTPS). Default is HTTPS")

   (options, args) = parser.parse_args()

   if len(args)==0:
      parser.print_help()
      print "\nI need a directory where I can create the structure"
      sys.exit(0)

   return (options, args)


def main():
   # print sys.argv

   options, args = InstallOptionParser()
#    print options, args
#    sys.exit(0)

   _rootdir= args[0]
   if not os.path.exists(_rootdir):
      print "WARNING: Directory \"%s\" does not exists." % _rootdir
      print "       Creating directory \"%s\"." % _rootdir
      try:
         os.mkdir(_rootdir)
      except OSError, e:
         print e
         sys.exit(10)

   _rootdir=os.path.join(_rootdir, "SUSEDOC")
   try:
      os.mkdir(_rootdir)
   except OSError, e:
      # print dir(e), e.errno, e.filename
      if e.errno!=17: # File exists
         raise OSError(e)

   mkdirs(_rootdir, options.lang)
   checkout(_rootdir, options.scheme)

   print
   print "All documents are saved at %s" % _rootdir
   print "   Your books directory is %s" % os.path.join(_rootdir, "books", getLang())


if __name__=="__main__":
   try:
      main()
   except OSError, e:
      print e

   except SVNException, e:
      print e
      sys.exit(100)
   except KeyboardInterrupt:
      print "Interrupted by user"
