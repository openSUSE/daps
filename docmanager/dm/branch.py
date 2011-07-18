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
