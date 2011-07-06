# -*- coding: UTF-8 -*-

__version__="$Revision: $"
__author__="Thomas Schraitle <thomas DOT schraitle AT suse DOT de>"
__depends__=["Python-2.4", "optcomplete"]

import optcomplete
from optparse import OptionGroup, OptionValueError
import os
import sys
from base     import SVNFile, SVNRepository, green, red

class CmdLocdrop(optcomplete.CmdComplete):
   """locdrop [option] TAG
     Set a tag from a branch point (UNIMPLEMENTED)"""
   __exampledoc__="""Examples:
   TO BE DEFINIED (ask toms)
   """

   names=["locdrop", "ld", "loc"]

   def addopts(self, parser):
      """addopts(parser) -> None
         Initialize the options for this class
      """
      self.parser = parser
      parser.set_defaults(helpexamples=False)
      parser.add_option("", "--help-examples",
        dest="helpexamples",
        default=False,
        action="store_true",
        help="Show some example how to use this subcommand") 

   def execute(self, args):
      print "Do locdropping", self.gopts, self.opts, os.getenv("BOOK"), len(args)

      if not len(args):
        self.parser.print_help()
        print "\n%s: error:  %s" % ( os.path.basename(sys.argv[0]),
                                      red("I need a tag.") )

      svn = SVNRepository(filename, tag=args[0])
      svn.locdrop()


if __name__ == "__main__":
   pass
