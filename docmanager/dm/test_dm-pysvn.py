#!/usr/bin/env python
# -*- coding: utf-8 -*-
#
""" Unittests for DocManager

Coordinate any changes with init-testsvn.sh

NOTES:
* The test methods are executed alphabetically (that's a design issue from
  the unittest module), so be careful to add new testcases that are dependend
  on others
* The tests have to be written that before and after the test the SVN
  working directory is the same.  A test shouldn't leave the SVN in a
  uncertain state (e.g. modified files, deleted files, new files, ...).
  This has the advantage that this script can be executed multiple times.
* There is the base class BaseDM which is used by all testcase classes. 
  Insert code (variables or methods) here that are useful for all derived classes.

TODO:
* Maybe modularize it into a test directory?
"""

__version__="$Revision: 46056 $"
__author__="Thomas Schraitle <thomas DOT schraitle AT suse DOT de>"

import sys
import os
import os.path
try:
  import pysvn
except ImportError, e:
  print("%s\n" \
  "Solution: Install RPM package python-pysvn from obs://devel:/languages:/python/" % e )
  sys.exit(10)


def whoami():
    """Determins current function name
    Source: http://aspn.activestate.com/ASPN/Cookbook/Python/Recipe/66062
    """
    return sys._getframe(1).f_code.co_name


def AddSysPath(new_path):
  """AddSysPath(new_path): adds a "directory" to Python's sys.path
  Does not add the directory if it does not exist or if it's already
  on sys.path. Returns 1 if Ok, -1 if new_path does not exist, 0 if it
  was already on sys.path
  """
  # Avoid adding nonexistent paths
  if not os.path.exists(new_path): return -1
  # Standardize the path.
  new_path = os.path.abspath(new_path)
  # Check against all currently available paths
  for x in sys.path:
    x = os.path.abspath(x)
    if new_path in (x, x+os.sep):
      return 0
  # sys.path.append(new_path)
  sys.path.insert(0, new_path)
  print "--- Added to search path: '%s'" % new_path
  return 1


def extendpath4initscript(script):
  curdir=os.getcwd()
  if "novdoc" not in curdir:
    print >> sys.stderr, "Where is the novdoc directory?\n"\
             "Run the script from the novdoc directory."
    sys.exit(42)
  
  return os.path.join(curdir.split("/novdoc/")[0], "novdoc", "bin", script)


# Extend the Python search path:
SYSPATH = [ "../", "../../python", 
          "./", "../python" ]
for i in SYSPATH:
  AddSysPath(i)
print "==> Search path:", sys.path
print



LOG_FILENAME = '/tmp/dm-test.out'
INITSCRIPT=extendpath4initscript("init-testsvn.sh")
DOCRELEASE="OS_110"
DAPSPATH="/usr/share/daps/"
FORMATSTRING='%(asctime)s %(levelname)s (%(funcName)s):  %(message)s'


import commands
import unittest
import logging # as log

# Import all docmanager relevant modules:
from base   import SVNRepository, SVNFile
from docget import CmdDocget
from docset import CmdDocset
from tag    import CmdTag
from branch import CmdBranch
#from locdrop import CmdLocdrop
import dmexceptions as dm


logger = logging.getLogger('DMLog')

def logs(function):
    return Logs(function)

class Logs(object):
   # """Decorator class"""
   def __init__(self, function, level=logging.DEBUG):
      self.func = function
      self.level = level

   def __get__(self, instance, cls=None):
        self.instance = instance
        return self

   def __call__(self, *args):
      kwargs=vars(self.func)
      # print >> sys.stderr, "<%s>" % self.func.__name__, args, kwargs
      logger.log(self.level, msg="START %s: args=%s vars=%s" % \
              ( self.func.__name__, args, kwargs) )
      try:
        return self.func(self.instance, *args)
      
      finally:
        # print >> sys.stderr, "</%s>" % self.func.__name__
        logger.log(self.level, msg=" END %s" % ( self.func.__name__, ) )



def touch(filename):
  """Simulate the 'touch' command"""
  open(filename, "w").close()


class BaseDM(unittest.TestCase):
  """Base class for all DocManager related things"""
  initscript = INITSCRIPT
  tmpsvnpath = None
  mainfile = "MAIN.opensuse.xml"
  mainpath = None
  branchmainpath = None
  booksenpath = None
  branching = None
  thisscript = os.path.basename(sys.argv[0])
  
  
  def setUp(self):
    """Setup the base class and fill the variables"""
    res = commands.getstatusoutput("sh %s --absworkingrepo" % self.initscript)
    self.assertEqual(res[0], 0, "Could not start script '%s'" % self.initscript )
    self.tmpsvnpath = res[1]
    self.branching = False
    
    if not os.path.exists(self.tmpsvnpath):
      res = commands.getstatusoutput("sh %s " % self.initscript)
      self.assertEqual(res[0], 0, "Script '%s' failed." % self.initscript)
    
    self.mainpath = os.path.join(self.tmpsvnpath, 
                                 "trunk/books/en/xml",
                                 self.mainfile
                                 )
    
    self.branchmainpath = os.path.join(self.tmpsvnpath,
                                 "branches/%s/books/en" % DOCRELEASE )
    self.branchmainfile = os.path.join(self.tmpsvnpath,
                                 "branches/%s/books/en/xml" % DOCRELEASE,
                                 self.mainfile
                                 )
                                 
    self.booksenpath = os.path.abspath(os.path.join(os.path.split(self.mainpath)[0], ".."))


class SVNTestCase(BaseDM):
  """Unittest for testing, if certain directories and files exist"""

  @logs
  def test0SVN(self):
    """test0SVN: Test for dummy SVN"""
    classname = self.__class__.__name__
    self.assertTrue( os.path.exists(self.tmpsvnpath) )
    logger.debug("<%s>%s: Ok" % (self.__class__.__name__, whoami() ) )
    return True

  @logs
  def test0branch(self):
    """test0branch: Test for branches"""
    self.assertTrue( os.path.exists(os.path.join(self.tmpsvnpath, "branches")))
    logger.debug("<%s>%s: Ok" % (self.__class__.__name__, whoami() ) )
    return True

  @logs
  def test0branchos110(self):
    """test0branchos110: Test for branches/OS_110"""
    self.assertTrue( os.path.exists(os.path.join(self.tmpsvnpath, "branches/OS_110")))
    logger.debug("<%s>%s: Ok" % (self.__class__.__name__, whoami()) )
    return True

  @logs
  def test0trunk(self):
    """test0trunk: Test for trunk"""
    self.assertTrue( os.path.exists(os.path.join(self.tmpsvnpath, "trunk")))
    logger.debug("<%s>%s: Ok" % (self.__class__.__name__, whoami()) )
    return True

  @logs
  def test0trunkbooks(self):
    """test0trunkbooks: Test for trunk/books"""
    self.assertTrue( os.path.exists(os.path.join(self.tmpsvnpath, "trunk/books")))
    logger.debug("<%s>%s: Ok" % (self.__class__.__name__, whoami()) )
    return True

  @logs
  def test0trunkbooksen(self):
    """test0trunkbooksen: Test for trunk/books/en"""
    self.assertTrue( os.path.exists(os.path.join(self.tmpsvnpath, "trunk/books/en")))
    logger.debug("<%s>%s: Ok" % (self.__class__.__name__, whoami()) )
    return True

  @logs
  def test0trunkbooksenxml(self):
    """test0trunkbooksenxml: Test for trunk/books/en/xml"""
    self.assertTrue( os.path.exists(os.path.join(self.tmpsvnpath, "trunk/books/en/xml")))
    logger.debug("<%s>%s: Ok" % (self.__class__.__name__, whoami()) )
    return True


  @logs
  def test_0_MAINfile(self):
    """test_0_MAINfile: Test if MAIN.opensuse.xml file exists"""
    self.assertTrue( os.path.exists(self.mainpath),
                    "File 'MAIN.opensuse.xml' not found" )
    logger.debug("<%s>%s: Ok" % (self.__class__.__name__, whoami()) )
    return True


  @logs
  def test_1_MAINProperties(self):
    """test_1_MAINProperties: Test doc:maintainer property of MAIN.opensuse.xml"""
    cmd="svn pg doc:maintainer %s" % self.mainpath
    logger.debug("Executing %s" % cmd)
    res = commands.getstatusoutput(cmd)
    self.assertEqual(res[0], 0, msg="svn could not get properties from MAIN.opensuse.xml")
    self.failUnless(res[1] != '', "It seems no property is set.")
    logger.debug("<%s>%s: Ok" % (self.__class__.__name__, whoami()) )
    return True


  @logs
  def test_2_validate(self):
    """test_2_validate: Runs make validate"""
    pwd=os.getcwd()
    if pwd != self.booksenpath:
      os.chdir(self.booksenpath)
    
    cmd = ". ENV-opensuse-startup && make validate"
    res = commands.getstatusoutput( cmd )
    logger.debug("Executing %s, result: %s" % (cmd, res) )
    os.chdir(pwd)
    self.assertEqual(res[0], 0, msg="Error from 'make validate': %s" % res[1])
    logger.debug("<%s>%s: Ok" % (self.__class__.__name__, whoami()) )
    return True
    

  @logs
  def test_3_makeprojectfiles(self):
    """test_3_makeprojectfiles: Runs make projectfiles"""
    pwd=os.getcwd()
    if pwd != self.booksenpath:
      os.chdir(self.booksenpath)
    cmd = ". ENV-opensuse-startup >& /dev/null && make projectfiles"
    res = commands.getstatusoutput( cmd )
    logger.debug("Executing %s, result: %s" % (cmd, res) )
    os.chdir(pwd)
    self.assertEqual(res[0], 0, msg="Error from 'make projectfiles': %s" % res[1])
    x=res[1].split()
    print res[1]
    self.assertEqual(len(x), 5, msg="make projectfiles returns a different number of project files: %s" % res[1])
    logger.debug("<%s>%s: Ok" % (self.__class__.__name__, whoami()) )
    return True


class SVNFileTestCase(BaseDM):
  """Unittest for testing, if certain conditions for SVNFile are correct"""
  
  @logs
  def setUp(self):
    super(self.__class__, self).setUp()
    self.svn = SVNFile(self.mainpath)
    logger.debug("<%s>%s: Ok" % (self.__class__.__name__, whoami()) )
    return True

  @logs
  def test_SVNFile(self):
    """test_SVNFile: Get SVNFile.getinfo()"""
    info = self.svn.getinfo()
    self.failUnless( info != '', "Could not get svn info for '%s'" % self.mainfile)
    logger.debug("<%s>%s: Ok" % (self.__class__.__name__, whoami()) )
    return True
    
  @logs
  def test_SVNFile_branchpath(self):
    """test_SVNFile_branchpath: Test SVN branch path"""
    bp = self.svn.getbranchpath()
    x = os.path.join(self.tmpsvnpath, "branches/OS_110/books/en/xml", self.mainfile)
    self.assertEqual(bp, x)
    logger.debug("<%s>%s: Ok" % (self.__class__.__name__, whoami()) )
    return True
  
  @logs
  def test_SVNFile_getstatus(self):
    """test_SVNFile_getstatus: Test SVN status"""
    status = self.svn.getstatus()
    self.failUnless( status != None, "Unexpected status: '%s'" % status)
    logger.debug("<%s>%s: Ok" % (self.__class__.__name__, whoami()) )
    return True

  @logs
  def test_SVNFile_getpropertylist(self):
    """test_SVNFile_getpropertylist: Test SVN doc properties"""
    pl = self.svn.getpropertylist()
    self.assertTrue( "doc:maintainer" in pl, "No doc:maintainer status found")
    self.assertTrue( "doc:status" in pl, "No doc:status status found")
    self.assertTrue( "doc:deadline" in pl, "No doc:deadline status found")
    self.assertTrue( "doc:release" in pl, "No doc:release status found")
    self.assertTrue( "doc:trans" in pl, "No doc:trans status found")
    logger.debug("<%s>%s: Ok" % (self.__class__.__name__, whoami()) )
    return True

  @logs
  def test_SVNFile_getfilename(self):
    """test_SVNFile_getfilename: Test SVN filename"""
    self.assertEqual(self.svn.getfilename(), self.mainfile)
    logger.debug("<%s>%s: Ok" % (self.__class__.__name__, whoami()) )
    return True


  @logs
  def test_SVNFile_getprops(self):
    """test_SVNFile_getprops: Test for special doc properties"""
    import types
    props=self.svn.getprops()
    ty_props= type(props)
    
    self.failUnlessEqual( ty_props, types.DictType, "I got wrong types: '%s'" % ty_props)
    self.failUnless( len(props.items()) > 0, "No props found!" )
    self.assertTrue( "doc:release" in props, "No doc:release in props found")
    self.assertTrue( "doc:status" in props, "No doc:status in props found")
    self.assertTrue( "doc:maintainer" in props, "No doc:maintainer in props found")
    logger.debug("<%s>%s: Ok" % (self.__class__.__name__, whoami()) )
    return True


  @logs
  def test_SVNFile_trunkpath(self):
    """test_SVNFile_trunkpath: Test trunk path"""
    tp = self.svn.trunkpath()
    self.assertEqual(tp, self.mainpath)
    logger.debug("<%s>%s: Ok" % (self.__class__.__name__, whoami()) )
    return True



class DMGetTestCase(BaseDM):
  """Unittest for testing, if certain SVN properties are correct"""

  @logs
  def setUp(self):
    super(self.__class__, self).setUp()
    #
    os.environ["DTDROOT"]="/usr/share/daps/"
    logger.debug("<%s>%s: Ok" % (self.__class__.__name__, whoami()) ) 

  @logs
  def test_dg(self):
    """test_dg: Test DocManager's dg command"""
    import docmanager2
    
    pwd = os.getcwd()
    try:
      os.chdir( self.booksenpath )# os.path.join(self.tmpsvnpath, "trunk/books/en/"
      sys.argv=[self.thisscript, "dg", "-o", "/tmp/.dm-test.log",  "-H", "xml/%s" % self.mainfile ]
      logger.debug("Executing %s" % ( " ".join(sys.argv), ) )
      docmanager2.main()
    finally:
      os.chdir(pwd)

    # The following line is stripped, any apostrophs replaced and split
    # The result is a list with 6 entries, for example:
    #   ['xml/MAIN.opensuse.xml', 'toms', 'OS_110', 'yes', 'editing', '--']
    # If the file is modified, you get 7 entries:
    #   ['xml/MAIN.opensuse.xml', 'M', 'toms', 'OS_110', 'yes', 'editing', '--']
    line=open("/tmp/.dm-test.log", 'r').read().strip().replace("'", "").split()
    self.failUnless(len(line) == 6, "After getting the properties, it seems the file is modifed:\n%s" % " ".join(line) )
    self.failUnless(line[0] == "xml/%s" % self.mainfile, "Mainfile not found!")
    self.failUnless(line[1] == os.getlogin(), "Login user different than what I expected (doc:maintainer='%s'" % line[1])
    self.failUnless(line[2] == DOCRELEASE, "doc:release is not correct, got '%s'" % line[2] )
    self.failUnless(line[3] == 'yes', "doc:trans is not correct, got '%s'" % line[2] )
    
    cmd="svn pg doc:status %s" % self.mainpath
    res=commands.getstatusoutput( cmd )
    logger.debug("Executing %s, result %s" % ( cmd, res) )
    self.assertEqual(res[0], 0, msg="svn could not get properties from MAIN.opensuse.xml. Got %s" % res[1])
    self.failUnless(line[4] == res[1].strip(), "doc:status is not correct, expected 'editing' got '%s'" % line[2] )
    # Testing for line[5] omitted
    logger.debug("<%s>%s: Ok" % (self.__class__.__name__, whoami()) ) 
    return True

  @logs
  def test_dg_query_maintainer(self):
    """test_dg_query_maintainer: Test DocManager's queryformat %{maintainer}"""
    import docmanager2
    
    pwd = os.getcwd()
    try:
      os.chdir( self.booksenpath )# os.path.join(self.tmpsvnpath, "trunk/books/en/" )
      sys.argv=[self.thisscript, "dg", "-o", "/tmp/.dm-test.log",  "-H",
                "-q", "%{maintainer}",
                "xml/%s" % self.mainfile ]
      logger.debug("Executing %s" % ( " ".join(sys.argv), ) )
      docmanager2.main()
    finally:
      os.chdir(pwd)
    line=open("/tmp/.dm-test.log", 'r').read().strip().replace("'", "")
    user=os.getlogin()
    self.failUnless(line == user, 
         "doc:maintainer is not correct. Expected '%s' got '%s'" % (user, line) )
    logger.debug("<%s>%s: Ok" % (self.__class__.__name__, whoami()) )
    return True
  
  
  @logs
  def test_dg_query_name(self):
    """test_dg_query_name: Test DocManager's queryformat %{name}"""
    import docmanager2
    
    pwd = os.getcwd()
    try:
      os.chdir( self.booksenpath )# os.path.join(self.tmpsvnpath, "trunk/books/en/" )
      sys.argv=[self.thisscript, "dg", "-o", "/tmp/.dm-test.log",  "-H",
                "-q", "%{name}",
                "xml/%s" % self.mainfile ]
      logger.debug("Executing %s" % ( " ".join(sys.argv), ) )
      docmanager2.main()
    finally:
      os.chdir(pwd)
    line=open("/tmp/.dm-test.log", 'r').read().strip().replace("'", "")
    self.failUnless(line == "xml/%s" % self.mainfile, "Seems querystring was not correct.")
    logger.debug("<%s>%s: Ok" % (self.__class__.__name__, whoami()) )
    return True
  
  
  @logs
  def test_dg_query_status(self):
    """test_dg_query_status: Test DocManager's querformat with %{status}"""
    import docmanager2
    
    pwd = os.getcwd()
    try:
      os.chdir( self.booksenpath )# os.path.join(self.tmpsvnpath, "trunk/books/en/" )
      sys.argv=[self.thisscript, "dg", "-o", "/tmp/.dm-test.log",  "-H",
                "-q", "%{status}",
                "xml/%s" % self.mainfile ]
      logger.debug("Executing %s" % ( " ".join(sys.argv), ) )
      docmanager2.main()
    finally:
      os.chdir(pwd)
      
    cmd="svn pg doc:status %s" % self.mainpath
    res = commands.getstatusoutput(cmd)
    logger.debug("Executing %s, result %s" % (cmd, res) )
    
    self.failUnless(res[0] == 0, "Return of '%s' got: %s" % (cmd,  res[1]))
    status=res[1].strip()

    line=open("/tmp/.dm-test.log", 'r').read().strip().replace("'", "")
    self.failUnless(line == status, "doc:status is not correct. Expected 'editing' got '%s'" % line)
    logger.debug("<%s>%s: Ok" % (self.__class__.__name__, whoami()) )
    return True


class DMSetTestCase(BaseDM):
  """Unittest for setting certain properties and test if they are correct"""

  @logs
  def setUp(self):
    super(self.__class__, self).setUp()
    #
    os.environ["DTDROOT"]="/usr/share/daps/"
 
  @logs
  def test_ds_0init(self):
    """test_init: Test several paths"""
    self.failIfEqual(self.tmpsvnpath, None, "tmpsvnpath should not be empty" )
    self.failIfEqual(self.mainfile, None,   "mainfile should not be empty" )
    self.failIfEqual(self.mainpath, None,   "mainpath should not be empty" )
    # print self.tmpsvnpath, self.mainfile, self.mainpath
    logger.debug("<%s>%s: Ok" % (self.__class__.__name__, whoami()) )
    return True


  @logs
  def test_ds_maintainer_1(self):
    """test_ds_maintainer_1: Tests DocManager's ds with --set-maintainer"""
    import docmanager2
    user = "tux"
    logger.debug("%s Start of setting maintainer" % whoami() )
    
    pwd = os.getcwd()
    try:
      os.chdir( self.booksenpath )# os.path.join(self.tmpsvnpath, "trunk/books/en/" ) 
      sys.argv=[self.thisscript, "--force",
                "ds", "-o", "/tmp/.dm-test.log",
                "--set-maintainer", user,
                "xml/%s" % self.mainfile ]
      logger.debug("Executing %s" % ( " ".join(sys.argv), ) )
      res = docmanager2.main()
    finally:
      os.chdir(pwd)

    cmd="svn pg doc:maintainer %s" % self.mainpath
    res=commands.getstatusoutput( cmd )
    logger.debug("Executing %s, result %s" % (cmd, res) )
    
    # print "test_ds_status: '%s'" % str(res)
    if self.branching:
      self.assertEqual(res[0], 0, msg="svn could not get doc:maintainer properties from MAIN.opensuse.xml. Got %s" % res[1])
      self.assertEqual(res[1].strip(), user, msg="File 'MAIN.opensuse.xml' does not have the doc:maintainer property '%s'. Got %s'" % (user, res[1]) )
      logger.debug("<%s>%s: Ok" % (self.__class__.__name__, whoami()) )
      return True
    else:
      logger.debug("<%s>%s: Skipped branching test" % (self.__class__.__name__, whoami()) )


  @logs
  def test_ds_maintainer_1a(self):
    """test_ds_maintainer_1a: Tests branched file from test test_ds_maintainer_1"""
    if self.branching:
      user="tux"
      self.assertEqual( os.path.exists(self.branchmainfile), True, 
                      msg="File in branch seems not be avilable." )
      res=commands.getstatusoutput("svn pg doc:maintainer %s" % self.branchmainfile )
      self.assertEqual(res[0], 0, msg="svn could not get doc:maintainer properties. Got %s" % res[1])
      self.assertEqual(res[1].strip(), user, msg="File 'MAIN.opensuse.xml' in branch does not have the doc:maintainer property '%s'. Got %s'" % (user, res[1]) )
      logger.debug("<%s>%s: Ok" % (self.__class__.__name__, whoami()) )
      return True
    else:
      logger.debug("<%s>%s: Skipped branching test" % (self.__class__.__name__, whoami()) )
      return True


  @logs
  def test_ds_maintainer_2(self):
    """test_ds_maintainer_2: Tests DocManager's ds with --set-maintainer (sets back)"""
    import docmanager2
    user = os.getlogin()
    
    pwd = os.getcwd()
    try:
      os.chdir( self.booksenpath )# os.path.join(self.tmpsvnpath, "trunk/books/en/" ) 
      sys.argv=[self.thisscript,  "--force",
                "ds", "-o", "/tmp/.dm-test.log",
                "--set-maintainer", user,
                "xml/%s" % self.mainfile ]
      logger.debug("Executing %s" % ( " ".join(sys.argv), ) )
      res = docmanager2.main()
    finally:
      os.chdir(pwd)

    cmd="svn pg doc:maintainer %s" % self.mainpath
    res=commands.getstatusoutput(cmd)
    logger.debug("Executing %s, result %s" % (cmd, res) )
    # print "test_ds_status: '%s'" % str(res)
    
    self.assertEqual(res[0], 0, msg="svn could not get doc:maintainer properties from MAIN.opensuse.xml. Got %s" % res[1])
    self.assertEqual(res[1].strip(), user, msg="File 'MAIN.opensuse.xml' does not have the doc:maintainer property '%s'. Got %s'" % (user, res[1]) )
    logger.debug("<%s>%s: Ok" % (self.__class__.__name__, whoami()) )
    return True


  @logs
  def test_ds_maintainer_2a(self):
    """test_ds_maintainer_2a: Tests branched file from test test_ds_maintainer_2"""
    if self.branching:
      user = os.getlogin()
      self.assertEqual( os.path.exists(self.branchmainfile), True, 
                        msg="File in branch seems not be avilable." )
      res=commands.getstatusoutput("svn pg doc:maintainer %s" % self.branchmainfile )
      self.assertEqual(res[0], 0, msg="svn could not get doc:maintainer properties. Got %s" % res[1])
      self.assertEqual(res[1].strip(), user, msg="File 'MAIN.opensuse.xml' in branch does not have the doc:maintainer property '%s'. Got %s'" % (user, res[1]) )
      logger.debug("<%s>%s: Ok" % (self.__class__.__name__, whoami()) )
      return True
    else:
      logger.debug("<%s>%s: Skipped branching test" % (self.__class__.__name__, whoami()) )


  @logs
  def test_ds_status(self):
    """test_ds_status: Tests DocManager's ds --set-edited """
    import docmanager2
    
    pwd = os.getcwd()
    try:
      os.chdir( self.booksenpath )# os.path.join(self.tmpsvnpath, "trunk/books/en/" )
      sys.argv=[self.thisscript, "--force",
                "ds", "-o", "/tmp/.dm-test.log",
                "--set-edited",
                "xml/%s" % self.mainfile ]
      logger.debug("Executing %s" % ( " ".join(sys.argv), ) )
      res = docmanager2.main()
    finally:
      os.chdir(pwd)
    
    cmd="svn pg doc:status %s" % self.mainpath
    res=commands.getstatusoutput(cmd)
    logger.debug("Executing %s, result %s" % (cmd, res) )
    
    # print "test_ds_status: '%s'" % str(res)
    self.assertEqual(res[0], 0, msg="svn could not get doc:status properties from MAIN.opensuse.xml. Got %s" % res[1])
    self.failUnless(res[1].strip() == 'edited', "File 'MAIN.opensuse.xml' does not have the doc:status property 'edited'. Got %s" % res[1])
    
    # Check the branch file:
    self.failUnless(os.path.exists(self.branchmainpath), "Branch file '%s' not found!" % self.branchmainpath )
    
    cmd="svn pg doc:status %s" % self.branchmainfile
    res=commands.getstatusoutput(cmd)
    logger.debug("Executing %s, result %s" % (cmd, res) )
    
    if self.branching:
      self.assertEqual(res[0], 0, msg="svn could not get properties from branch MAIN.opensuse.xml. Got %s" % res[1])
      self.failUnless(res[1].strip() == 'edited', msg="Branch file 'MAIN.opensuse.xml' does not have the doc:status property 'edited'. Got from %s: %s" % (self.branchmainfile, str(res) ) )

      # self.failUnless(res == 0, "ds --set-edited returned != 0: %s" % res)
      logger.debug("<%s>%s: Ok" % (self.__class__.__name__, whoami()) )
      return True
    else:
       logger.debug("<%s>%s: Skipped test" % (self.__class__.__name__, whoami()) )
       return True



  @logs
  def test_ds_unknownFile(self):
    """test_ds_unknownFile: Test for unknown files (MUST fail)"""
    import docmanager2
    pwd = os.getcwd()
    os.chdir( self.booksenpath )
    sys.argv=[self.thisscript, "--force",
                "ds", "-o", "/tmp/.dm-test.log",
                "--set-edited",
                "xml/unknown.xml" ]
    logger.debug("Executing %s" % ( " ".join(sys.argv), ) )
    self.assertRaises(SystemExit,  docmanager2.main )
    os.chdir(pwd)
    logger.debug("<%s>%s: Ok" % (self.__class__.__name__, whoami()) )
    return True


  @logs
  def test_ds_modifiedFile(self):
    """test_ds_modifiedFile: Test if an error is thrown after some property modifications (MUST fail)"""
    # Works with a "fresh" repository only.
    import docmanager2
    pwd = os.getcwd()
    main = "xml/%s" % self.mainfile
    os.chdir( self.booksenpath )
    
    cmd = "svn ps A foo %s" % main 
    res=commands.getstatusoutput(cmd)
    logger.debug("Executing %s, result %s" % (cmd, res) )
    
    self.assertEqual(res[0], 0, msg="svn ps returned an error: %s" % res[1] )
    # print "\n cmd=%s  == svn st: %s" % (cmd, res)
    
    # The file must be modified, otherwise something is fishy...
    cmd="svn st %s" % main
    res=commands.getstatusoutput(cmd)
    logger.debug("Executing %s, result %s" % (cmd, res) )
    #print "\n         == svn st: %s" % (res, )
    
    self.assertEqual(res[0], 0, msg="svn st returned an error: %s" % res[1] )
    self.assertEqual(bool(len(res[1])), True, msg="Result of svn st is a null string (expected something with ' M') %s" % repr(res) )
    self.assertEqual(res[1][1], 'M', msg="File is not modified: %s" % res[1] )
    
    
    # print "Returned from svn ps %s => '%s'" % (main, res[1] )
    
    try:
      sys.argv=[self.thisscript, "--force",
                "ds", "-o", "/tmp/.dm-test.log",
                "--set-proofed",
                main ]
      logger.debug("Executing %s" % ( " ".join(sys.argv), ) )
      res = self.assertRaises(dm.DocManagerPropertyException,  docmanager2.main )
      #res = docmanager2.main()
      
      # Clean up and remove the property:
      cmd="svn pd A %s" % main
      res=commands.getstatusoutput(cmd)
      logger.debug("Executing %s, result %s" % (cmd, res) )
      self.assertEqual(res[0], 0, msg="svn pd returned an error: %s" % res[1] )
      
      cmd="svn ci -m'Removing property A' %s" % main 
      res=commands.getstatusoutput(cmd)
      logger.debug("Executing %s, result %s" % (cmd, res) )
      self.assertEqual(res[0], 0, msg="svn ci returned an error: %s" % res[1] )
    finally:
      os.chdir(pwd)

    # We don't need to check the result for revert:
    commands.getstatusoutput("svn revert %s" % main )
    logger.debug("<%s>%s: Ok" % (self.__class__.__name__, whoami()) )
    return True

  @logs
  def test_ds_modifybranches_0(self):
    """Initialize some files that go into the branch"""
    import docmanager2
    pwd = os.getcwd()
    
    self.assertEqual(os.path.exists(self.booksenpath), True, 
                     msg="Path not found: '%s'" % self.booksenpath)
    os.chdir( self.booksenpath )

    try:
      sys.argv=[self.thisscript, "--force",
                "ds", "-o", "/tmp/.dm-test.log",
                "--set-edited",
                "Makefile",
                "xml/quickstart.xml",
                "ENV-opensuse-startup",
                ".env-profile" ]
      logger.debug("Executing %s" % ( " ".join(sys.argv), ) )
      res = docmanager2.main()
      
    finally:
      os.chdir(pwd)
    
    return True

  @logs
  def test_ds_modifybranches_1(self):
    """Change path to branches and set Makefile to proofing"""
    if not self.branching:
       logger.debug("<%s>%s: Skipped test" % (self.__class__.__name__, whoami()) )
       return True

    import docmanager2
    pwd = os.getcwd()
    testfile="Makefile"
    
    self.assertEqual(os.path.exists(self.booksenpath), True, 
                     msg="Path not found: '%s'" % self.branchmainpath )
    os.chdir( self.branchmainpath )
    
    try:
      sys.argv=[self.thisscript, "--force",
                "ds", "-o", "/tmp/.dm-test.log",
                "--set-proofing",
                testfile ]
      logger.debug("Executing %s" % ( " ".join(sys.argv), ) )
      res = docmanager2.main()
      
      cmd="svn pg doc:status %s" % testfile
      res=commands.getstatusoutput(cmd)
      logger.debug("Executing %s, result %s" % (cmd, res) )
      self.assertEqual(res[0], 0, msg="svn pg returned an error: %s" % res[1] )
      self.assertEqual(res[1].strip(), 'proofing', msg="svn pg returned an error: %s" % res[1] )
      
      # Set doc:status property back:
      sys.argv=[self.thisscript, "--force",
                "ds", "-o", "/tmp/.dm-test.log",
                "--set-edited",
                testfile ]
      logger.debug("Executing %s" % ( " ".join(sys.argv), ) )
      res = docmanager2.main()
      
    finally:
      os.chdir(pwd)

    return True


  @logs
  def __test_ds_graphic_1(self):
    """__test_ds_graphic: Tests for graphics"""
    import docmanager2
    
    pwd = os.getcwd()
    try:
      rest, main = os.path.split(self.mainpath)
      self.assertEqual(main, self.mainfile, "Main file not correct. Got %s" % main)
      
      
      os.chdir( self.booksenpath )#  os.path.join(self.tmpsvnpath, "trunk/books/en/" ) 
      
      sys.argv=[self.thisscript, "--force",
                "ds", "-o", "/tmp/.dm-test.log",
                "--set-edited",
                "xml/%s" % self.mainfile ]
      logger.debug("Executing %s" % ( " ".join(sys.argv), ) )
      res = docmanager2.main()
      logger.debug("Results %s" % ( res, ) )
      
    finally:
      os.chdir(pwd)
    
    logger.debug("<%s>%s: Ok" % (self.__class__.__name__, whoami()) )
    return True

  @logs
  def __test_ds_graphic_1a(self):
    """__test_ds_graphic: Tests for graphics"""
    import docmanager2
    
  @logs
  def test_ds_graphic_2(self):
    """ """
    pass


class DMFormatTestCase(BaseDM):
  """Unittest for setting certain properties and test if they are correct"""

  @logs
  def setUp(self):
    super(self.__class__, self).setUp()
    #
    os.environ["DTDROOT"]="/usr/share/daps/"

  @logs
  def test_fm_init(self):
    import docmanager2
    import dmexceptions as dm
    
    pwd=os.getcwd()
    main = "xml/%s" % self.mainfile
    if pwd != self.booksenpath:
      os.chdir(self.booksenpath)

    res = commands.getstatusoutput(". ENV-opensuse-startup" )
    self.assertEqual(res[0], 0, msg="Error from '. ENV-opensuse-startup': %s" % res[1])

    # Set up the directory for daps-xmlformat:
    curdir = os.getcwd()
    lastdir = os.path.split(curdir)[-1]
    if lastdir == "bin":
      sxdir = "."
    elif lastdir == "dm":
      sxdir = ".."
    else:
      # Fallback to the system directory of daps
      sxdir = os.path.join(DAPSPATH, "bin")
    
    cmd="%s -i %s" % (os.path.join(sxdir, "daps-xmlformat"),main)
    res = commands.getstatusoutput(cmd)
    logger.debug("Executing %s, result %s" % (cmd, res) )
    self.assertEqual(res[0], 0, msg="daps-xmlformat returned an error: %s" % res[1])
    
    cmd="svn st %s" % main 
    res = commands.getstatusoutput(cmd)
    logger.debug("Executing %s, result %s" % (cmd, res) )
    self.assertEqual(res[0], 0, msg="svn st returned an error: %s" % res[1])
    
    # Only commit changes, if file is modified
    if res[1] != '':
      msg = "DocManager unittest: Reformatted with daps-xmlformat"
      cmd="svn ci -m '%s' %s" % (msg, main)
      res = commands.getstatusoutput(cmd)
      logger.debug("Executing %s, result %s" % (cmd, res) )
      self.assertEqual(res[0], 0, msg="svn ci returned an error: %s" % res[1])
    try:
      sys.argv=["test_dm.py", "--force",
                "ds", "-o", "/tmp/.dm-test.log",
                "--set-edited",
                main ]
      logger.debug("Executing %s" % ( " ".join(sys.argv), ) )
      res = docmanager2.main()
    
    finally:
      os.chdir(pwd)
      
    logger.debug("<%s>%s: Ok" % (self.__class__.__name__, whoami()) )
    return True

  @logs
  def test_fm_setedited(self):
    """test_fm_setedited: Set to edited and diff it with the branched file """
    import docmanager2
    
    pwd=os.getcwd()
    main = "xml/%s" % self.mainfile
    if pwd != self.booksenpath:
      os.chdir(self.booksenpath)

    res = commands.getstatusoutput(". ENV-opensuse-startup" )
    self.assertEqual(res[0], 0, msg="Error from '. ENV-opensuse-startup': %s" % res[1])
    
    try:
      sys.argv=["test_dm.py", "--force",
                "ds", "-o", "/tmp/.dm-test.log",
                "--set-edited",
                main ]
      logger.debug("Executing %s" % ( " ".join(sys.argv), ) )
      res = docmanager2.main()
      
      if self.branching:
        cmd="diff -u %s %s" % (main, self.branchmainfile)
        res = commands.getstatusoutput(cmd)
        logger.debug("Executing %s, result %s" % (cmd, res) )
        self.assertEqual(res[0], 0, msg="diff returned an error: %s" % res[1])
      else:
        logger.debug("<%s>%s: Skipped diff test" % (self.__class__.__name__, whoami()))
    
      # Revert the doc:status:
      sys.argv=["test_dm.py", "--force",
                "ds", "-o", "/tmp/.dm-test.log",
                "--set-editing",
                main ]
      logger.debug("Executing %s" % ( " ".join(sys.argv), ) )
      res = docmanager2.main()
    finally:
      os.chdir(pwd)

    
    logger.debug("<%s>%s: Ok" % (self.__class__.__name__, whoami()) )
    return True
#
#
#
def suite():
  """Assembles the test suite"""

  suite = unittest.TestSuite()
  # If you have any test, fill it into the list:
  # (If you need to disable a test, just insert a '#' before the name)
  testsuites = [ SVNTestCase, 
                 SVNFileTestCase,
                 DMGetTestCase,
                 DMSetTestCase,
                 DMFormatTestCase,
               ]

  # No need to change anything below:
  suite.addTests( [ unittest.makeSuite(i) for i in testsuites ] )
  return suite


def checkdaps():
  """Checks daps specific parameters (RPM, version and daps-xmlformat)"""
  res = commands.getstatusoutput("rpm -q daps" )
  assert res[0] == 0, "ERROR: rpm -q daps returned an error: %s" % res[1]
  # Get only the version:
  version = int(res[1].strip().split("-")[1].split("_")[1])
  assert version >= 20080529, """ERROR: daps has the wrong version number.
Expected 20080529, got %s""" % version
  
  xmlformatpath = os.path.join(DAPSPATH, "bin", "daps-xmlformat")
  assert os.path.exists( xmlformatpath ), \
    "ERROR: Can not find path to daps-xmlformat"


def removeSVNTrees(*paths):
  """Clean up all the given paths"""
  import shutil
  for p in paths:
    if os.path.exists(p):
      shutil.rmtree(p)


def cleanup():
  res = commands.getstatusoutput("sh %s --absworkingrepo" % INITSCRIPT)
  assert res[0]==0, "Something is going wrong: %s" % repr(res)
  wcpath = res[1].strip()
  assert os.path.exists(wcpath), "The path '%s' does not exist" % wcpath
  
  res = commands.getstatusoutput("sh %s --abssvnrepo" % INITSCRIPT)
  assert res[0]==0, "Something is going wrong: %s" % repr(res)
  svnpath = res[1].strip()
  assert os.path.exists(svnpath), "The path '%s' does not exist" % svnpath
  
  try:
    print "Following directories will be deleted:"
    print " * SVN repository on '%s'" % svnpath
    print " * Working directory on '%s'" % wcpath
    try:
      while True:
        res = raw_input("Should I remove them? (y|yes|n|no)")
        res=res.lower()
        if res not in ("y", "yes", "n", "no"):
          continue
        if res in ("y", "yes"):
          print "Removing it... ",
          removeSVNTrees(wcpath, svnpath)
          print "Done"
        else:
          print "Nothing deleted."
        break
    except KeyboardInterrupt:
        # Silently pass
        print "Removing stale paths..."
        removeSVNTrees(wcpath, svnpath)
        print

  except OSError, e:
    print >> sys.stderr, e


def main():
    import optparse
    parser = optparse.OptionParser(__doc__.split("\n")[0], \
                                   version="Revision %s" % __version__[11:-2])
    parser.set_defaults(verbosity=3)
    parser.add_option("-v", "--verbosity",
        dest="verbosity",
        type="int",
        help="Set the verbosity level (default %default)")
    parser.set_defaults(deldirs=False)
    parser.add_option("", "--delete-after-testing",
        dest="deldirs",
        action="store_true",
        help="Delete the SVN and working directories after testing")
    parser.set_defaults(logfile=LOG_FILENAME)
    parser.add_option("-l", "--logfile",
        dest="logfile",
        metavar="LOGFILE",
        action="store",
        help="Saves the test in LOGFILE (default \"%default\")")
    parser.set_defaults(formatstring=FORMATSTRING)
    parser.add_option("-f", "--format-string",
        dest="formatstring",
        metavar="STRING",
        action="store",
        help="Uses a different format string for logging.Formatter (default \"%default\"; see http://docs.python.org/lib/node421.html)")
    
    return parser.parse_args()


if __name__=="__main__":
  # Checks, if daps is installed
  checkdaps()
  options, args = main()
  print options, args
  
  # sys.exit(10)
  handler = logging.FileHandler(filename=options.logfile,
                                encoding="UTF-8")
  formatter = logging.Formatter(options.formatstring)
  handler.setFormatter(formatter)
  logger.addHandler(handler)
  logger.setLevel(logging.DEBUG)

  # logger.basicConfig(filename=LOG_FILENAME, level=logging.DEBUG )
  logger.debug("============================" )
  logger.debug("Starting DocManager's Unittest Session")
  unittest.TextTestRunner(descriptions=3,
                          verbosity=options.verbosity
                          ).run( suite() )
  logger.debug("Finished test")
  logger.debug("============================\n")

  cleanup()
  
  print "Logging file can be found at: %s" % options.logfile
