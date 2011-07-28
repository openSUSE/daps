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

__version__="$Revision: 30109 $"
__author__="Thomas Schraitle <thomas DOT schraitle AT suse DOT de>"
__depends__=["Python-2.4", "optcomplete"]

import optcomplete
import commands
from optparse import OptionGroup, OptionValueError
from base     import SVNFile, SVNRepository, green, red
import dmexceptions as dmexpect
import svncmd
import formatter

import os.path
import sys
import re


def getenvfile():
  """Returns BASEDIR and ENVFILE"""
  cmd = "daps showenv"
  res=commands.getstatusoutput( cmd )
  if res[0] != 0:
    raise dmexpect.DocManagerEnvironment(res[1])
  
  # BASEDIR, ENVFILE
  return tuple( i.split("=")[1] for i in res[1].split(";") )


class CmdDocget(optcomplete.CmdComplete):
   """docget [option] [filename(s)]
   Lists characteristics of XML files, like SVN properties, URL, etc.
"""
   __exampledoc__="""Examples:
   1. Returns a formatted list of all project files:
      $ dm.py docget  xml/a.xml

   2. Returns a formatted list, searched in all project files. Include only those where
      the current maintainer is set:
      $ dm.py docget -P --include="doc:maintainer=$USER"

   3. Returns a formatted list, searched in all project files. Include only files with
      doc:maintainer=a and doc:maintainer=b, and with doc:status=edited:
      $ dm.py docget -P --include="doc:maintainer=a" --include="doc:maintainer=b" --status=edited

   4. Specify a user definied query string for two XML files:
      $ dm.py dg -q 'File=%{name}\\tRevision=%{rev}\\t%{maintainer}\\tStatus=%{status}' xml/a.xml xml/b.xml
   """
   names=["docget","dg"]


   def addopts(self, parser):
      """addopts(parser) -> None
         Initialize the options for this class
      """
      self.parser = parser
      parser.set_defaults(helpexamples=False)
      parser.add_option("", "--help-examples",
        dest="helpexamples",
        action="store_true",
        help="Show some example how to use this subcommand")
      parser.add_option("", "--help-keywords",
        dest="helpkeywords",
        action="store_true",
        help="Show available keywords used in --queryformat")
      parser.add_option('-q', '--queryformat',
        dest="query",
        metavar="QUERYSTRING",
        help="Format of a query request. See --help-keywords for more information.")
      parser.add_option("-o", "--output",
        dest="output",
        metavar="FILENAME",
        help="Save the output in a file")
      #parser.set_defaults(sortfiles=False)
      #parser.add_option('-s', '--sortfiles',
         #dest="sortfiles",
         #action="store_true",
         ## default=False,
         #help="Sort the filenames alphabetically")
      parser.add_option('-A', '--no-align',
         dest="aligning",
         action="store_false",
         help="Do not align the querystring in columns")
      parser.set_defaults(aligning=True)
      parser.add_option('-a', '--align',
         dest="aligning",
         action="store_true",
         # default=True,
         help="Align the querystring in columns (default)")
      parser.add_option('-s', '--statistic',
         dest="statistic",
         action="store_true",
         # default=True,
         help="Print statistics (default)")
      parser.set_defaults(statistic=False)
      parser.add_option('-S', '--no-statistic',
         dest="statistic",
         action="store_false",
         # default=True,
         help="Suppress the output of statistics")
      parser.set_defaults(header=True)
      parser.add_option('-H', '--no-header',
         dest="header",
         action="store_false",
         # default=True,
         help="Print the header of the output")
      parser.set_defaults(project=False)
      parser.add_option("-P", "--from-project",
         dest="project",
         action="store_true",
         # default=False,
         help="Lists only those project files, that are covered by 'make projectfiles'")
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
      # optcomplete.autocomplete(parser, ['.*\.xml', 'xml/.*\.xml', 'xml/.*\.ent'])


   def execute(self, args):
      """ execute(args) -> None"""
      # print "  CmdDocget.execute:  -> (opts, args) ", self.opts, args

      if self.opts.helpexamples:
         print self.__exampledoc__
         sys.exit()
         
      if self.opts.helpkeywords:
        # Sort the keys first
        kspace=formatter.Formatter(fileobj=sys.stdout).getspaces()
        keys=kspace.keys()
        keys.sort()
        print "%s %s %s" % \
            ( "Keyword".ljust(15),
              "Type".ljust(12),
              "Description"
            )
        print "-"*50
        for k in keys:
          print k.ljust(15), kspace[k]["type"].ljust(12), kspace[k]["help"]
        sys.exit()

      if not args and not self.opts.project:
         # print dir(self)
         self.parser.print_help()
         print "\n%s: error:  %s" % ( os.path.basename(sys.argv[0]),
                                      red("I need an option. Probably -P?\n") )
         sys.exit(10)
         # self.parser.error("I need an option.")
     
      # Handle ENVFILE and BASEDIR by getenvfile (which uses daps showenv internally)
      # 
      envfile = self.gopts.envfile
      basedir = self.gopts.basedir
      if not envfile:
        res = getenvfile()
        envfile = res[1]
        if not basedir:
          basedir=res[0]

      

      try:
        svn = SVNRepository(args,
                          querystring=self.opts.query,
                          opts=self.opts,
                          envfile=envfile,
                          basedir=basedir,
                          dryrun=self.gopts.dryrun,
                          aligning=self.opts.aligning,
                          statistics=self.opts.statistic,
                          allowmodified=True,
                          output=self.opts.output,
                          header=self.opts.header,
                          # sorting=self.opts.sortfiles,
                          includequery=self.opts.include,
                          excludequery=self.opts.exclude
                         )
        svn.query()
      except dmexpect.SVNException, e:
        print >> sys.stderr, e
        exit(1000)


if __name__ == "__main__":
   pass
