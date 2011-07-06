# -*- coding: UTF-8 -*-

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
