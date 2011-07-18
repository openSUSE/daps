# -*- coding: UTF-8 -*-
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

__version__="$Revision: 11859 $"
__author__="Thomas Schraitle <thomas DOT schraitle AT suse DOT de>"
__depends__=["Python-2.4", "optcomplete"]

import optcomplete
from optparse import OptionGroup, OptionValueError
import os
import sys
from base     import SVNFile, SVNRepository, green, red

class CmdTag(optcomplete.CmdComplete):
   """tag [option] TAG
     Set a tag from a branch point"""
   __exampledoc__="""Examples:
   TO BE DEFINIED (ask toms)
   """

   names=["tag"]

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
      parser.add_option("-P", "--from-project",
         dest="project",
         action="store_true",
         # default=False,
         help="Lists only those project files, that are covered by 'make projectfiles'")
      parser.set_defaults(listtag=False)
      parser.add_option("-l", "--list-tags",
        dest="listtag",
        action="store_true",
        help="Show some example how to use this subcommand")
      group = OptionGroup(parser, "Options for Query group",
                    "These options query your file set. "\
                    "Choose one ore more in arbitrary order:" )
      group.add_option('', '--exclude',
        action="append",
        dest="exclude",
        metavar="STRING",
        help="Query request to exclude files from file list. Format: PROPERTY=VALUE")
      group.add_option('', '--include',
        action="append",
        dest="include",
        metavar="STRING",
        help="Query request to include files from file list.  Format: PROPERTY=VALUE")
      parser.add_option_group(group) 

   def execute(self, args):
      print "Do tagging", self.gopts, self.opts, os.getenv("BOOK"), len(args)
      
      if not len(args):
        self.parser.print_help()
        print "\n%s: error:  %s" % ( os.path.basename(sys.argv[0]),
                                      red("I need a tag.") )
        sys.exit(10)
        
      # Create a filelist with exactly one file to speed up things
      if os.getenv("MAIN"):
         filename=[os.path.join("xml", os.getenv("MAIN"))]
      else:
         filename=[]

      svn = SVNRepository(filename, tag=args[0])
      svn.tagging()


if __name__ == "__main__":
   pass
