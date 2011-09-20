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

from xml.sax.handler import ContentHandler

""" Each SVN XML entry file has the following content:

  <entry
    committed-rev="10844"
    name="svncmd.py"
    text-time="2006-08-01T06:58:37.000000Z"
    committed-date="2006-07-26T14:54:49.460095Z"
    checksum="cb9709292562c7b374147a01330eadab"
    last-author="toms"
    kind="file"/>

  This works only til 10.1. 
  In 10.2 Subversion has changed the internal format.
"""

class SVNEntriesHandler(ContentHandler):
    def __init__(self):
        self.entrylist=[]
        
    def startElement(self, name, attrs):
        if name=="entry":
            if attrs["kind"] == "file":
                self.entrylist.append(attrs["name"])

if __name__=="__main__":
    pass
