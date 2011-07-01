# -*- coding: utf-8 -*-

import subprocess as subproc
import os

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

      ## print "   %s" % cmd
      #self.p = popen2.Popen4( cmd )
      #self.p.tochild.close()
      #self.pi=iter(self.p.fromchild)
      #ret = self.p.wait()

      env = os.environ.copy()
      env["LANG"]="en_EN.UTF-8"
      # ret = subproc.call(["svn", subcmd, options], env=env)
      
      self.cmd = ["svn", subcmd, options]
      self.p = subproc.Popen(self.cmd,
                             shell=True, close_fds=False,
                             #env=env,
                             stdin=subproc.PIPE, stdout=subproc.PIPE)
      ret = self.p.wait()
      if ret < 1:
         raise IOError, "SVNCmd.__init__: Unexpected error for »%s«: %s" % (" ".join(self.cmd), str(ret))
      self.pi = iter(self.p.stdout)

   def __repr__(self):
     return "<%s '%s' 0x%x>" % (self.__class__.__name__, " ".join(self.cmd),  id(self) )

   def __iter__(self):
      """__iter__() -> Iterator"""
      return self.pi

   def reopen(self):
      """reopen() -> None"""
      self.close()
      self.__init__(self.subcmd, self.options)

   def close(self):
      """close() -> None or (perhaps) an integer.
         Close the SVN command"""
      pass

   def read(self):
      """read() -> read at most size bytes, returned as a string."""
      return self.p.stdout.read()

   def readline(self):
      """readline() -> String
         next line from the file, as a string."""
      return self.p.stdout.readline()

   def readlines(self):
      """readlines() -> List
         list of strings, each a line from the file."""
      return self.p.stdout.readlines()

   def closed(self):
      """closed -> BOOL
         Checks, if a SVN stream is still accessible"""
      return self.stdout.closed

   def next(self):
      """next() -> String
         Returns the next line"""
      return self.pi.next()

if __name__=="__main__":
  svn = SVNCmd("ls", "https://svn.suse.de/svn/doc/trunk/")
  print svn
  print "Test start"
  for s in svn:
    print s
  print "Test end"
