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

"""Formatter class to format output query strings

The formatter expects a querystring, containing several keywords, and
a fileobject.
"""

__version__="$Revision: $"
__author__="Thomas Schraitle <thomas DOT schraitle AT suse DOT de>"
__depends__=["Python-2.4", "optcomplete"]

__all__=["Formatter"]


#import os
import os.path
#import sys
#import types
import re
import commands

class Formatter(object):
    """Class to format filenames for output"""
    standardquery=r"%{name} '%{modified}' %{maintainer} %{trans} %{status} %{priority} %{deadline}\n"
    # propvalue=r"(?P<prop>[\w\d:_]+)\s*[=]\s*(?P<value>[!]?\w+)"

    # Mapping from alignings to string functions
    tokendict = { "l": str.ljust,
                  "r": str.rjust,
                  "c": str.center}

    def __init__(self, **args):
       # Keyword dictionary that contains everything a Formatter class needs.
       self.keywords = {
          "absname":   { "width": args.get("maxfilename", 28)+2,
                         "align": "l",
                         "map":   "name",
                         "type":  "string",
                         "help":  "The absolute filename",
                         "func":  self.cb_absfilename,
                       },
          "checksum":  { "width": 34,                      # Width of this entry
                         "align": "l",                     # Alignment, l=left, r=right, c=center
                         "map":   "Checksum",              # Maps to another output, svn info or others
                         "type":  "MD5",                   # Data type of this entry
                         "help":  "Checksum of this file", # Help text
                         "func":  None,
                       },
          "deadline":  { "width": 12,
                         "align": "l",
                         "map":   "doc:deadline",
                         "type":  "date",
                         "help":  "Deadline when this file must be finished",
                         "func":  None,
                       },
          "lastrev":   { "width": 8,
                         "align": "r",
                         "map":   "Last Changed Rev",
                         "type":  "int",
                         "help":  "Last revision",
                         "func":  None,
                       },
          "lastdate":  { "width": 20,
                         "align":  "l",
                         "map":   "Last Changed Date",
                         "type":  "date",
                         "help":  "Last changed date",
                         "func":  self.cb_lastdate,
                       },
          "maintainer": {
                         "width": 14,
                         "align": "l",
                         "map":   "doc:maintainer",
                         "type":  "string",
                         "help":  "Maintainer of this file",
                         "func":  None,
                       },
          "modified":  { "width": 2,# Use only two: content and property
                         "align": "l",
                         "map":   "svn:status",
                         "type":  "string",
                         "help":  "Are the content or properties of this file modified?",
                         "func":  None,
                       },
          "name":      { "width": args.get("maxfilename", 28)+2,
                         "align": "l",
                         "map":   "name",
                         "type":  "string",
                         "help":  "Filename relative to BASE_DIR",
                         "func":  self.cb_relfilename,
                       },
          
          "prelim":    { "width": 6,
                         "align": "l",
                         "map":   "doc:prelim",
                         "type":  "int",
                         "help":  "Is this file preliminary?" ,
                         "func":  None,
                       },
          "priority":  { "width": 3,
                         "align": "r",
                         "map":   "doc:priority",
                         "type":  "int",
                         "help":  "How important is this file?" ,
                         "func":  None,
                       },
          "proplastdate": {
                         "width": 20,
                         "align": "l",
                         "map":   "Properties Last Updated",
                         "type":  "date",
                         "help":  "When have the properties changed?",
                         "func":  self.cb_proplastdate,
                       },
          "release":   { "width": 10,
                         "align": "l",
                         "map":   "doc:release",
                         "type":  "string",
                         "help":  "Current project where this file belongs to",
                         "func":  None,
                       },
          "rev":       { "width": 8,
                         "align": "r",
                         "map":   "Revision",
                         "type":  "int",
                         "help":  "Current revision of this file",
                         "func":  None,
                       },
          "revprop":   { "width": 5,
                         "align": "r",
                         "map":   None,
                         "type":  "bool",
                         "help":  "Is the revision property different from doc:status?",
                         "func":  self.cb_revprop,
                       },
          "status":    { "width": 15,
                         "align": "l",
                         "map":   "doc:status",
                         "type":  "string",
                         "help":  "The current status of this file (editing, proofed, ...)",
                         "func":  None,
                       },
          "trans":     { "width": 6,
                         "align": "l",
                         "map":   "doc:trans",
                         "type":  "bool",
                         "help":  "Does this file need to be translated?",
                         "func":  None,
                       },
          "url":       { "width": 70,
                         "align": "l",
                         "map":   "URL",
                         "type":  "string",
                         "help":  "The URL of this file",
                         "func":  None,
                       },
        }         
       
       self.querystring = self.standardquery
       self.d = {}
       # Read from args (object, default value)
       for a, default in [("fileobj", None), 
                          ("querystring",self.standardquery), 
                          ("d", {}),
                          ("headerflag", True )]:
          if args.get(a):
              setattr(self, a, args.get(a, default))
       # Special handling for self.aligning, 
       # because value should always be True or False
       self.aligning = args.get("aligning")
       # We need a SVNFile object
       if self.fileobj is None:
          raise IOError("Formatter: Expected a SVNFile object")
              
       # print self.fileobj, self.fileobj.getprops()
       # Replace \n and \t
       self.querystring= re.sub(r"\\t", "\t", self.querystring)
       self.querystring= re.sub(r"\\n", "\n", self.querystring)

    def __repr__(self):
       return "<Formatter '%s'>" % self.fileobj.getfilename()

    def __str__(self):
       return self.expand()

    def getspaces(self):
      return self.keywords

    def cb_relfilename(self, value):
      """Prints relative filename"""
      return self.fileobj.relfilename

    def cb_absfilename(self, value):
      return os.path.abspath(self.fileobj.getfilename())

    def cb_revprop(self, value):
      props = self.fileobj.getprops()
      lastchangedrev = props["Last Changed Rev"]
      filename = self.fileobj.getfilename()
      cmd="LANG=C svn pg -r %s --revprop doc:status" % ( lastchangedrev )
      res=commands.getstatusoutput(cmd)
      
      # print ".... revprop .... %s '%s'" % (filename, props["doc:status"])
      if props["doc:status"]==res[1]:
          return "Ok"
      else:
          return "Check"
    
    def cb_proplastdate(self, value):
        # print "cb_proplastdate: '%s'" % value
        return " ".join(value.split(" ")[0:2])
    
    def cb_lastdate(self, value):
      return self.cb_proplastdate(value)
    
    def expand(self):
      self.props = self.fileobj.getprops()
      result=self.querystring
      for k in self.keywords:
            if self.querystring.count("%%{%s}" % k):
               result=re.sub("%%{%s}" % k,
                    "%s"     % self.replace(k),
                    result,
                    re.IGNORECASE)
      return result


    def replace(self, key):
       """replace(key) -> string  
        Replaces keywords"""
       try:
         search=self.keywords[key]["map"]
         #if key == "revprop":
         #  return self.align(key, self.revprop())
         if self.keywords[key]["func"]==None:
            if self.props.has_key(search):
                return self.align(key, self.props[search])
            else:
                return self.align(key, "--")
         else:
            if self.props.has_key(search):
                return self.align(key, self.keywords[key]["func"](self.props[search]))
            else:
                return self.align(key, self.keywords[key]["func"](search))
            
       except KeyError:
         raise RuntimeError, "Formatter.replace: Unknown property '%s'" % key

    def align(self, key, value):
       """align(key, value) -> string  Aligns a given keyword (key) with a value"""
       if self.aligning:
          sp, align = self.keywords[key]["width"], self.keywords[key]["align"]
          return self.tokendict[align](value, sp)
       else:
          return value

if __name__ == "__main__":
   pass
