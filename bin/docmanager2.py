#!/usr/bin/env python
# -*- coding: utf-8 -*-

# FIXME: Better motto
"""%prog [GLOBAL_OPTS] command [CMD_OPT] [filename(s)]

   Docmanager's light and writer's fate (BRANCH Edition)
"""


__version__="$Revision: 43505 $"
__author__="Thomas Schraitle <thomas DOT schraitle AT suse DOT de>"
__depends__=["Python-2.4", "optparse"]
# BEWARE: Don't rename NAME to __name__!
NAME= "docmanager2"

import sys
import os
import os.path
import types
import re

# FIXME: Set variable PYTHONPATH
def addPythonPath(pypath):
   """Add the path in the list (pypath) in the path
   variable to allow searching for other modules"""
   assert isinstance(pypath, list), "addPythonPath: Expecting a list"

   try:
     dtdroot=os.environ["DTDROOT"]
     for p in pypath:
        sys.path.insert(0, os.path.join(dtdroot, p))

   except KeyError:
     print >> sys.stderr, "ERROR: Did you forget to source an ENV file? "\
                          "I can not find variable DTDROOT."
     sys.exit(100)

## Set an additional search path for Python modules
## Please note: These paths are relative to env variable $DTDROOT
addPythonPath([# "python",  # General modules
               "bin/dm",  # Docmanager modules
              ])


import optparse

import optcomplete

from docget import CmdDocget
from docset import CmdDocset
from tag    import CmdTag
from branch import CmdBranch
from propinit import CmdPropInit

import dmexceptions as dm


if not hasattr(sys, "version_info") or sys.version_info < (2, 4):
    print "%s requires Python 2.4 or newer" % NAME
    sys.exit(1)

#global prog
#prog=os.path.basename(sys.argv[0])

# ------------------------------------
class CmdHelp(optcomplete.CmdComplete):
   """help [subcommand]
     Get Help"""
   names=["help"]
   def __init__(self, cmds):
     self.cmds = cmds
   #def addopts(self, parser):
   #    pass

   def execute(self, args):
      if args:
        for i in self.cmds:
          if args[0] in i.names:
            print i.__doc__
            break
        else:
          print >> sys.stderr, "Unknown subcommand"
      else:
        # Print help of *all* subcommands
        for i in self.cmds:
            if id(i) != id(self): # Omit help
                print "  %s %s" % (
                ", ".join(i.names).ljust(15),
                i.__doc__.split("\n")[1].strip()
              )


def parse_subcommands(gparser, subcmds):
    """Parse given global arguments, find subcommand from given list of
    subcommand objects, parse local arguments and return a tuple of global
    options, selected command object, command options, and command arguments.
    Call execute() on the command object to run. The command object has members
    'gopts' and 'opts' set for global and command options respectively, you
    don't need to call execute with those but you could if you wanted to."""

    # import optparse
    # global subcmds_map # needed for help command only.

    # Build map of name -> command and docstring.
    subcmds_map = {}
    gparser.usage += '\n\nAvailable Subcommands\n\n'
    for sc in subcmds:
        doc=sc.__doc__.splitlines()
        # Check, if only one line is available
        if len(doc)==1:
            gparser.usage += '- %s %s\n' % (\
                ', '.join(sc.names).ljust(14),
                doc[0].strip()
                )
        else:
            gparser.usage += '- %s %s\n  %s\n' % (\
                ', '.join(sc.names).ljust(14),
                doc[0].strip(),
                ''.ljust(15)+doc[1].strip()
                )
        for n in sc.names:
            assert n not in subcmds_map
            subcmds_map[n] = sc

    # Declare and parse global options.
    gparser.disable_interspersed_args()

    gopts, args = gparser.parse_args()
    if not args:
        gparser.print_help()
        raise SystemExit("\nError: you must specify a command to use.\n")
    subcmdname, subargs = args[0], args[1:]

    # Parse command arguments and invoke command.
    try:
        sc = subcmds_map[subcmdname]
        lparser = optparse.OptionParser(sc.__doc__.strip())
        if hasattr(sc, 'addopts'):
            sc.addopts(lparser)
        sc.gopts = gopts
        sc.opts, subsubargs = lparser.parse_args(subargs)
    except KeyError:
        raise SystemExit("Error: invalid command '%s'" % subcmdname)

    return sc.gopts, sc, sc.opts, subsubargs

def main():

    # Create global options parser.
    #global gparser # only need for 'help' command (optional)
    #import optparse
    parser = optparse.OptionParser(__doc__.strip(), \
                                   version="Revision %s" % __version__[11:-2])
    parser.set_default("verbose", True)
    parser.add_option("-v", "--verbose",
        dest="verbose",
        #default=True,
        action="store_true",
        help="Be verbose")
    parser.add_option("-q", "--quiet",
        dest="verbose",
        action="store_false",
        help="Be quiet")
    parser.set_default("force", False)
    parser.add_option("-f", "--force",
        dest="force",
        #default=False,
        action="store_true",
        help="Never prompt")
    parser.set_default("dryrun", False)
    parser.add_option("-n", "--dry-run",
        dest="dryrun",
        #default=False,
        action="store_true",
        help="Don't actually run any commands; just print them.")
    parser.set_default("branching", False)
    parser.add_option("-B", "--branching",
        dest="branching",
        #default=False,
        action="store_true",
        help="Switch on branching (default: %default)")
    #parser.add_option("", "--working-dir",
        #dest="workingdir",
        #help="Set your working directory, if the current dir is different.")

    #
    # FIXME: Need option for redirecting error messages into a file?
    # FIXME: Need option for transcripting what docmanager did?
    #
    #optcomplete.autocomplete(parser, ['xml/.*\.xml', 'xml/.*\.ent'])

    # Declare subcommands.
    subcmds = [
        CmdDocget(),
        CmdDocset(),
        CmdTag(),
        CmdBranch(),
        CmdPropInit(),
    #    CmdLocdrop(), 
    ]
    subcmds.append(CmdHelp(subcmds))

    # subcommand completions
    scmap = {}
    for sc in subcmds:
        for n in sc.names:
            scmap[n] = sc

    listcter = optcomplete.ListCompleter(scmap.keys())
    subcter=None
    #subcter = optcomplete.ListCompleter(
    #    ['some', 'default', 'commands', 'completion'])
    #optcomplete.autocomplete(parser, listcter, None, subcter, subcommands=scmap)

    gopts, sc, opts, args = parse_subcommands(parser, subcmds)
    return sc.execute(args)



if __name__ == "__main__":
   try:
      # print "sys.argv=", sys.argv
      res = main()
      sys.exit(res)
   except RuntimeError, e:
      print e
   #except NameError, e:
      #print >> sys.stderr, e
      #checkcwd()
   except (dm.DocManagerException), e:
      print >> sys.stderr, "ERROR: %s" % e
      sys.exit(20)
   
   except KeyboardInterrupt:
      print "Interrupted by user"
   except optparse.OptionValueError, e:
      print >> sys.stderr, e
      sys.exit(10)


# EOF
