# -*- coding: utf-8 -*-

"""
    Contains functions for calling Subversion
    Ideas from from http://svn.collab.net/repos/svn/trunk/contrib/client-side/svnmerge.py
    (function launch)
"""
__version__="$Id: svncmd.py 1 2006-07-14 08:52:25Z tom $"
__author__="Thomas Schraitle <thomas DOT schraitle AT suse DOT de>"

#import os
import sys
if sys.version_info[:2] < ( 2,6):
  from svncmd25 import SVNCmd
else:
  from svncmd26 import SVNCmd


class SVNinfo(SVNCmd):
   """SVN class for svn info"""
   def __init__(self, options, dryrun=False):
      SVNCmd.__init__(self, "info", options)


class SVNstatus(SVNCmd):
   """SVN class for svn status"""
   def __init__(self, options, dryrun=False):
      assert options!="", "SVNstatus.__init__: Empty options"
      SVNCmd.__init__(self, "status", options)


class SVNpropget(SVNCmd):
   """SVN class for svn propget"""
   def __init__(self, options, dryrun=False):
      assert options!="", "SVNpropget.__init__: Empty options"
      if dryrun == False:
         SVNCmd.__init__(self, "propget", options)
      else:
         print "dryrun: svn propget %s" % options


class SVNpropset(SVNCmd):
   """SVN class for svn propset"""
   def __init__(self, options, revprop=False, dryrun=False):
      assert options!="", "SVNpropset.__init__: Empty options"
      # FIXME: Insert check for setting revision property
      print "SVNpropset:", options
      if dryrun == False:
         SVNCmd.__init__(self, "propset", options)
      else:
         print "dryrun: svn propset %s" % options


class SVNproplist(SVNCmd):
   """SVN class for svn propset"""
   def __init__(self, options, dryrun=False):
      assert options!="", "SVNproplist.__init__: Empty options"
      if dryrun == False:
         SVNCmd.__init__(self, "proplist", options)
      else:
         print "dryrun: svn proplist %s" % options


class SVNcommit(SVNCmd):
   """SVN class for svn commit"""
   def __init__(self, options, dryrun=False):
      assert options!="", "SVNcommit.__init__: Empty options"

      if dryrun == False:
         # print "  SVNCmd.__init__", options
         SVNCmd.__init__(self, "commit", options)
      else:
         print "dryrun: svn commit %s" % options


class SVNmerge(SVNCmd):
   """SVN class for svn merge"""
   def __init__(self, options, dryrun=False):
      assert options!="", "SVNmerge.__init__: Empty options"
      if dryrun == False:
         SVNCmd.__init__(self, "merge", options)
      else:
          print "dryrun: svn merge %s" % options


class SVNcopy(SVNCmd):
   """SVN class for svn copy"""
   def __init__(self, options, dryrun=False):
      assert options!="", "SVNcopy.__init__: Empty options"
      if dryrun == False:
         SVNCmd.__init__(self, "copy", options)
      else:
          print "dryrun: svn copy %s" % options

