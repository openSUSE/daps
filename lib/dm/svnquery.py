# -*- coding: UTF-8 -*-

__version__="$Revision: $"
__author__="Thomas Schraitle <thomas DOT schraitle AT suse DOT de>"
__depends__=["Python-2.4", "optcomplete"]
__all__=["SVNQuery"]

import re
import sys
from optparse import OptionValueError

class SVNQuery:
   """ """
   propvalue=r"(?P<prop>[\w\d:_]+)\s*[=]\s*(?P<value>[!]?\w+)"
	 
   def __init__(self, fileobj, inquery, exquery):
       self._fileobj = fileobj
       self._inquery = inquery
       self._exquery = exquery
       self.propsdict={}

   def __repr__(self):
      return "<SVNQuery: inquery='%s' exquery='%s'>" % \
			                    (self._inquery, self._exquery)
   
   def __str__(self):
      return "<SVNQuery: %s>" % self.propsdict 
	
   def checkfilter(self, value):
      """checkfilter(value) -> STRING """
      r=re.match(self.propvalue, value)
      if r==None:
         raise OptionValueError("Wrong format. "\
				                        "Expecting »PROPERTY=VALUE« but got »%s«" % value)
      return r.groupdict()

   def PropsDict(self):
       return self.propsdict

   def process(self):
       self.propsdict = self._fileobj.getprops()
       return self.filtering()

   def filtering(self):
       """filtering() -> BOOL   Depending on the users' filter, the file is fullfilled
                                by the filter (True) or not (False)
       """
       if self._inquery==None and self._exquery==None:
           return True

       filename = self._fileobj.getorigfilename()
       # Rebuild the self._inquery list and collect double entries into a list
       includedict={}
       excludedict={}
       # Default values:
       includeresult=True
       excluderesult=True
       # Check includes first
       if self._inquery != None:
         for f in self._inquery:
            d=self.checkfilter(f)
            if includedict.has_key(d["prop"]):
               includedict[d["prop"]].append(d["value"])
            else:
               includedict[d["prop"]]=[d["value"]]

         #
         for i in includedict.keys():
            if not self.propsdict.has_key(i):
               #print >> sys.stderr, \
               #         "  WARNING: attribute »%s« not found in %s!" % \
				#								(i, filename)
               includeresult &= False
               continue
            if self.propsdict[i] in includedict[i]:
               includeresult &=True
            else:
               includeresult &=False

			 # Check excludes
       if self._exquery != None:
         for f in self._exquery:
            d=self.checkfilter(f)
            if excludedict.has_key(d["prop"]):
               excludedict[d["prop"]].append(d["value"])
            else:
               excludedict[d["prop"]]=[d["value"]]
         #
         for i in excludedict.keys():
            if not self.propsdict.has_key(i):
              #print >> sys.stderr, \
              #          "  WARNING: attribute »%s« not found in %s!" % \
				#								(i, filename)
               excluderesult &= False
               continue
            if self.propsdict[i] in excludedict[i]:
               excluderesult &= False
            else:
               excluderesult &= True
       return includeresult and excluderesult

					 
if __name__ == "__main__":
   pass
