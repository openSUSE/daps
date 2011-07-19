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

__version__="$Revision: 43294 $"
__author__="Thomas Schraitle <thomas DOT schraitle AT suse DOT de>"
__depends__=["Python-2.4", "optcomplete"]

import os
import sys
import optcomplete
from optparse import OptionGroup, OptionValueError
from base     import SVNFile, SVNRepository, red, done
import svncmd

class CmdDocset(optcomplete.CmdComplete):
   """docset SETOPTION [options] [filename(s)]
Set characteristics and merge or copy into branch

Parameters:
   * SETOPTION let you choose the property that you want to set
   * option: Additional options
   * filenames: List filenames your interested filenames or leave it out.
     No filenames means search in the complete project file list
     (from make projectfiles)
    """
   __exampledoc__="""Examples:
   1. Set file a.xml to doc:status "edited":
      $ dm.py docset -E xml/a.xml

   2. Set maintainer foo for file xml/a.xml:
      $ dm.py docset --set-maintainer foouser  xml/a.xml

   3. Set maintainer foo *and* status editing for file xml/a.xml:
      $ dm.py docset -E -M foouser  xml/a.xml
    """

   names=["docset","ds"]

   def cb_checkdeadline(self, option, opt, value, parser):
       """Checks the deadline

       @param option:
       @param opt:
       @param value:
       @param parser: The parser context
       """
       import datetime
       import re
       if value!='': # Allow to "unset" dates by empty strings
           try:
               year, month, day = re.match(r"(2\d\d\d)[.-](\d\d)[.-](\d\d)",
                                            value).groups()
               datetime.date(int(year), int(month), int(day))
           except (ValueError, AttributeError), e:
               raise OptionValueError("Wrong date format. Got '%s', " \
                                      "expected 'year[.-]month[.-]day'. (%s)" % 
                                      (value, e))
       setattr(parser.values, option.dest, value)

   def cb_checkpriority(self, option, opt, value, parser):
       # value is integer type
       if not 0<= value <= 5:
           raise OptionValueError("Priority must be 0...5, got %s" % value)
       setattr(parser.values, option.dest, value)
   
   def cb_checkprelim(self, option, opt, value, parser):
       # print "** cb_checkprelim: opt='%s', parser.values.prelim='%s'" % ( opt, parser.values.prelim)
       # print "option.dest=", option.dest
       
       if opt in ("-Y", "--set-prelim"):
         v = "set"
       elif opt in ("-y", "--unset-prelim"):
         v = "unset"
       else:
         v = None

       if self.options["prelim"] == None:
         self.options["prelim"] = True
       else:
         raise OptionValueError("You can't use both, unset and set prelim. Choose one.")

       setattr(parser.values, option.dest, v)
       

   def cb_checktrans(self, option, opt, value, parser):
       #print "** cb_checktrans: opt='%s', parser.values.prelim='%s'" % ( opt, parser.values.prelim)
       #print "option.dest=", option.dest
       
       if opt in ("-T", "--set-trans"):
         v = "set"
       elif opt in ("-t", "--unset-trans"):
         v = "unset"
       else:
         v = None
       
       if self.options["trans"] == None:
         self.options["trans"] = True
       else:
         raise OptionValueError("You can't use both, unset and set trans. Choose one.")

       setattr(parser.values, option.dest, v)
     

   def addopts(self, parser):
     """addopts(parser) -> None
        Initialize the options for this class
     """
     self.parser = parser
     self.options={}
     self.options["prelim"] = None
     self.options["trans"] = None
     
     
     parser.add_option("", "--help-examples",
        dest="helpexamples",
        default=False,
        action="store_true",
        help="Show some example how to use this subcommand")
     parser.add_option("", "--from-project",
         dest="project",
         action="store_true",
         default=False,
         help="Covers only those project files, that are returned by 'make projectfiles'")
     parser.add_option("-o", "--output",
        dest="output",
        metavar="FILENAME",
        help="Save the output in a file")
     parser.set_defaults(skipformatting=False)
     parser.add_option("", "--skip-formatting",
        dest="skipformatting",
        action="store_true",
        help="Skip the XML formatting process",
     )
      
     group = OptionGroup(parser, "Set Options",
                    "These options are set properties for XML files. "\
                    "Choose one of the following:")
     group.add_option("-M", "--set-maintainer",
        dest="maintainer",
        #default=os.getenv("USER"),
        # metavar="[$LOGNAME]",
        help="Sets property doc:maintainer (default: %default)")
     group.add_option("-E", "--set-editing",
        dest="actionset",
        action="store_const",
        const="editing",
        # metavar="[$LOGNAME]",
        help="Sets property doc:status = editing")
     group.add_option("-C", "--set-comments",
        dest="actionset",
        action="store_const",
        const="comments",
        # metavar="[$LOGNAME]",
        help="Sets property doc:status = comments")
     group.add_option("-D", "--set-edited",
        dest="actionset",
        action="store_const",
        const="edited",
        # metavar="[$LOGNAME]",
        help="Sets property doc:status = edited")
     group.add_option("-P", "--set-proofing",
        dest="actionset",
        action="store_const",
        const="proofing",
        # metavar="[$LOGNAME]",
        help="Sets property doc:status = proofing")
     group.add_option("-R", "--set-proofed",
        dest="actionset",
        action="store_const",
        const="proofed",
        # metavar="[$LOGNAME]",
        help="Sets property doc:status = proofed")
     group.add_option("-L", "--set-locdrop",
        dest="actionset",
        action="store_const",
        const="locdrop",
        # metavar="[$LOGNAME]",
        help="Sets property doc:status = locdrop")
     group.add_option("-T", "--set-trans",
        dest="trans",
        callback=self.cb_checktrans,
        # default="set",
        action="callback",
        help="Sets property doc:trans = yes")
     group.add_option("-t", "--unset-trans",
        dest="trans",
        callback=self.cb_checktrans,
        #default="unset",
        action="callback",
        help="Unsets property doc:trans")
     # group.set_default("prelim", False)
     group.add_option("-Y", "--set-prelim",
        dest="prelim",
        callback=self.cb_checkprelim,
        #default="set",
        action="callback",
        help="Sets property doc:prelim = yes")
     # group.set_default("unprelim", False)
     group.add_option("-y", "--unset-prelim",
        dest="prelim",
        action="callback",
        #default="unset",
        callback=self.cb_checkprelim,
        help="Unsets property doc:prelim")
     group.add_option("-X", "--set-deadline",
        action="callback",
        dest="deadline",
        callback=self.cb_checkdeadline,
        type="string",
        help="Sets property doc:deadline (format is year[.-]month[.-]day). For example 2006-08-23."\
             "Delete it with an empty string.")
     group.add_option("-I", "--set-priority",
        dest="priority",
        action="callback",
        callback=self.cb_checkpriority,
        type=int,
        help="Sets property doc:priority (range is 0...5, "
             "with 1 the highest, 5 the lowest and 0 is tabu.")
     group.add_option("-G", "--set-maintainer-for-graphics",
        dest="incgraphics",
        action="store_true",
        help="""Set the maintainer of the current XML file to each corresponding graphic file.
If more than one XML files are given, then ...
You can force the maintainer by using -M|--set-maintainer.
**WORK IN PROGRESS**"""
     )
     parser.set_defaults(incgraphics=False)
     
     parser.add_option_group(group)
     group = OptionGroup(parser, "Options for INCLUDE/EXCLUDE filesets",
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
      # print "  CmdDocset.execute", self.gopts, self.opts
      if self.opts.helpexamples:
         print self.__exampledoc__
         sys.exit()

      if not args and not self.opts.project:
         # print dir(self.parser),
         self.parser.print_help()
         print "\n%s: error:  %s" % ( os.path.basename(sys.argv[0]),
                                      red("I need one or more files.\n") )
         sys.exit(10)

      # Build the dictionary
      dd={}
      if self.opts.actionset != None:
         dd["doc:status"] = self.opts.actionset
      if self.opts.maintainer!=None:
         dd["doc:maintainer"] = self.opts.maintainer
      if self.opts.trans == "set":
         dd["doc:trans"] = "yes"
      elif self.opts.trans == "unset":
         dd["doc:trans"] = "no"
      if self.opts.deadline != None:
         dd["doc:deadline"] = self.opts.deadline
      if self.opts.priority != None:
         dd["doc:priority"] = self.opts.priority
      if self.opts.prelim == "set":
         dd["doc:prelim"] = "yes"
      elif self.opts.prelim == "unset":
         dd["doc:prelim"] = "no"


      if self.opts.incgraphics and not self.opts.maintainer:
        self.parser.error(red("If you set option --%s, then you need to set option --%s too." % ("set-maintainer-for-graphics",
                      "set-maintainer")))
        

      if not len(dd):
         self.parser.error(red("I need a set option."))

      dd["incgraphics"] = self.opts.incgraphics

      print "Creating fileobjects..."
      # print >> sys.stderr, "Opts: %s, GOpts: %s" % (self.opts, self.gopts)
      svn = SVNRepository(args,
                          dryrun=self.gopts.dryrun,
                          envfile=self.gopts.envfile,
                          basedir=self.gopts.basedir,
                          force=self.gopts.force,
                          output=self.opts.output,
                          ##FIXME: Implement it later:
                          # sorting=self.opts.sortfiles,
                          includequery=self.opts.include,
                          excludequery=self.opts.exclude,
                          branching=self.gopts.branching
                         )
      svn.setProperties(**dd)
      print done()

if __name__ == "__main__":
   pass
