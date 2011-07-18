# -*- coding: utf-8 -*-
#
# This file is part of the docmanager distribution.
#
# docmanager is free software: you can redistribute it and/or modify it
# under the terms of the GNU General Public License as published by the Free
# Software Foundation, either version 2 of the License, or (at your option) any
# later version.
#
# docmanager is distributed in the hope that it will be useful, but
# WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or
# FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License for
# more details.
#
# You should have received a copy of the GNU General Public License along with
# this program.  If not, see <http://www.gnu.org/licenses/>.

"""
    Contains functions for calling Subversion
    Ideas from from http://svn.collab.net/repos/svn/trunk/contrib/client-side/svnmerge.py
    (function launch)
"""
__version__="$Id: svncmd.py 1 2006-07-14 08:52:25Z tom $"
__author__="Thomas Schraitle <thomas DOT schraitle AT suse DOT de>"

#import os
import popen2

class SVNCmd(object):
   """SVN base class for all subcommands"""
   def __init__(self, subcmd, options="", dryrun=False):
      """__init__(subcmd, options='')
      subcmd  = Subcommand of svn (string)
      options = The options of the subcommand (string)
      """
      assert subcmd!="", "SVNCmd.__init__: Empty subcommand"
      self.subcmd = subcmd
      self.options = options
      cmd = "LANG=C svn %s %s" % (subcmd, options)
      # print "   %s" % cmd
      self.p = popen2.Popen4( cmd )
      self.p.tochild.close()
      self.pi=iter(self.p.fromchild)
      ret = self.p.wait()
      if ret != 0:
         raise IOError, "SVNCmd.__init__: Unexpected error for »%s«: %s" % (cmd, str(ret))

   def __iter__(self):
      """__iter__() -> Iterator"""
      return self.pi

   def reopen(self):
      """reopen() -> None"""
      self.close()
      self.__init__(self.subcmd, options)

   def close(self):
      """close() -> None or (perhaps) an integer.
         Close the SVN command"""
      self.p.fromchild.close()

   def read(self):
      """read() -> read at most size bytes, returned as a string."""
      return self.p.fromchild.read()

   def readline(self):
      """readline() -> String
         next line from the file, as a string."""
      return self.p.fromchild.readline()

   def readlines(self):
      """readlines() -> List
         list of strings, each a line from the file."""
      return self.p.fromchild.readlines()

   def closed(self):
      """closed -> BOOL
         Checks, if a SVN stream is still accessible"""
      return self.p.fromchild.closed

   def next(self):
      """next() -> String
         Returns the next line"""
      return self.pi.next()


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

