# -*- coding: UTF-8 -*-

__version__="$Revision: 10939 $"
__author__="Thomas Schraitle <thomas DOT schraitle AT suse DOT de>"
__depends__=["Python-2.4", "optcomplete"]

import optcomplete

class CmdBranch(optcomplete.CmdComplete):
   """branch [option] [filename(s)]
     Set a branch (UNIMPLEMENTED)"""
   names=["branch", "br"]

   #def addopts(self, parser):
   #   """addopts(parser) -> None
   #      Initialize the options for this class
   #   """

   def execute(self, args):
      print "Do branching", self.gopts, self.opts

if __name__ == "__main__":
   pass
