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
import datetime
import svncmd
import commands

from lxml import etree as et

class CmdPropInit(optcomplete.CmdComplete):
  """propinit SETOPTION [options] [filename(s)]
Initialize all doc properties

Parameters:
   * option: Additional options
   * filenames: List filenames you are interested in.
     This argument is mandatory.
    """

  __exampledoc__="""Examples:
   1. Initialize file :
      $ dm.py propinit xml/a.xml
    """

  names=["propinit","pi"]
   
  def addopts(self, parser):
    """addopts(parser) -> None
         Initialize the options for this class
    """
    self.parser = parser
    
    nextweek = datetime.date.today() + datetime.timedelta(weeks=1)
    
    parser.set_defaults(deadline=nextweek.isoformat())
    parser.add_option("-d", "--deadline",
        dest="deadline",
        help="Set doc:deadline (default is one week from today: %default)")
    parser.set_defaults(maintainer=os.getenv("USER"))
    parser.add_option("-m", "--maintainer",
        dest="maintainer",
        help="Set doc:maintainer (default to %default)")
    parser.set_defaults(prelim="no")
    parser.add_option("-p", "--prelim",
        dest="prelim",
        help="Set doc:prelim (defaults to %default)")
    parser.set_defaults(priority="1")
    parser.add_option("-P", "--priority",
        dest="priority",
        help="Set doc:priority (defaults to %default)")
    parser.set_defaults(release="UNKNOWN")
    parser.add_option("-r", "--release",
        dest="release",
        help="Set doc:release (defaults to %default)")
    parser.set_defaults(status="editing")
    parser.add_option("-s", "--status",
        dest="status",
        help="Set doc:status (defaults to %default)")
    parser.set_defaults(trans="yes")
    parser.add_option("-t", "--trans",
        dest="trans",
        help="Set doc:trans (defaults to %default)")


  def execute(self, args):
    """ execute(args) -> None"""
    # print "  CmdDocget.execute:  -> (opts, args) ", self.opts, args

    # print(self.opts )
    # Create dictionary with valid doc properties and their default values
    docprops = {
      'doc:deadline':   self.opts.deadline,
      'doc:maintainer': self.opts.maintainer,
      'doc:prelim':     self.opts.prelim,
      'doc:priority':   self.opts.priority,
      'doc:release':    self.opts.release,
      'doc:status':     self.opts.status,
      'doc:trans':      self.opts.trans,
    }
    
    print(docprops)
    
    if not(args):
      print("ERROR: Need one or more filenames")
      print( self.__exampledoc__)
      sys.exit()
    
    for f in args:
      print(f)
      prop=commands.getstatusoutput("LANG=C svn pl -v --xml %s" % f)
      if prop[0] != 0:
         raise IOError("SVN proplist: %s" % prop[1])
       
      # print( prop[1] )
      # 'Convert' our properties into a string:
      XP=et.fromstring( prop[1].strip() )
      # We are only interested in doc properties:
      props = XP.xpath( "//property[starts-with(@name,'doc:')]")
      x = ""
      print(props)
      # Contains all properties of the file
      fileprops = [ p.attrib.get("name") for p in props ]
      
      # Contains all properties which are _not_ available in the file
      neededprops=[ p for p in docprops.keys() if p not in fileprops ]
      
      if not neededprops:
        print("All properties in '%s' found. Don't change anything." % f)
        continue
      
      # Set all properties:
      for p in neededprops:
        v = docprops.get(p)
        print("Set property %s to %s" % ( p, v) )
        print("LANG=C svn ps %s '%s' %s" % (p, v, f) )
        res=commands.getstatusoutput("LANG=C svn ps %s '%s' %s" % \
             (p, v, f) )
             
        # Error checking:
        if res[0] != 0:
          raise IOError("Problem with setting property: %s" % res[1])
      
      # Commit it:
      


#
