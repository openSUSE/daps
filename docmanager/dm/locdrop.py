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
