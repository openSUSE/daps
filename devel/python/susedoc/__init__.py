# print "SUSEDOC __init__.py loaded"

# __all__ allows us to say 
#   from susedoc import *
#   ctx = SUSEDOC()
#
__all__ = [ 'SUSEDOC', 'copy_in' ]

import os, sys
import perl


class SUSEDOC():
  """
  Python wrapper for perl-SUSEDOC, see 'perldoc SUSEDOC'
  for details.
  """
  def __init__(self, **opt):
    # Use opt as dictionary
    # print "SUSEDOC __init__() called"
    self.hello = "Hello World"
    bindir = os.path.abspath(os.path.dirname(sys.argv[0]))
    inc = perl.get_ref("@INC")
    inc.insert(0, bindir + "/../lib/perl")
    # perl.eval('print "@INC\n"') 
    perl.require("SUSEDOC")
    self.perl = perl.callm("new", "SUSEDOC", opt)

  def project_files(self):
    """
    This is ugly: no idea how to merge the perl object into the python-object.
    Unless we can merge, we have to write stubs for everything.
    """
    return self.perl.project_files()
     
def ref(o):
  return o.__class__ or o.__type__

def copy_in(o):
  """
  copy_in(<perl object>) is a python helper, that creates a deep copy 
  of a perl object in python. Usefull for pprint.pprint(copy_in(o)) .
  """
  if (ref(o) == 'HASH'):
    r = {}
    for k in o.keys(): r[k] = copy_in(o[k])
    return r
  if (ref(o) == 'ARRAY'):
    r = []
    for x in o: r.append(copy_in(x))
    return r
  if (ref(o) == 'SCALAR'):
    return o.__value__
  return o



