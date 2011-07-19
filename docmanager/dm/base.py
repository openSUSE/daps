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

__version__="$Id: base.py 45614 2009-11-17 20:15:17Z jw $"
__author__="Thomas Schraitle <thomas.schraitle@suse.de>"

import os
import os.path
import sys
import types
import re
import svncmd
import commands
import shutil
import glob

import dm.dmexceptions as dmexcept
import itertools

from lxml import etree as et


# Remove DeprecationWarning for Python V<2.6
# Sets are in Python 2.6 are a builtin feature
if sys.version_info[:2] < ( 2,6):
  from sets import Set

from optparse import OptionValueError
from formatter import Formatter
from svnquery import SVNQuery

"""Base classes and functions for DocManager

"""

PROCDIR=os.path.join(os.path.split(sys.argv[0])[0], "dm")
DAPSPATH="/usr/share/daps/"

__all__=["userinput",
         "OptParseWarning",
         "SVNFile",
         "SVNRepository",
         "dryrun",
         "green",
         "red",
         "done",
         "failed"]


# 2009-11-17, jw:
# Stolen from /usr/lib/python2.6/commands.py,
# but we need a version which does not capture stderr.
# E.g. make projectfiles shall not be vulnerable to
#      make: Warning: File `xml/webyast_packages.xml' has modification time 3.1e+02 s in the future
#
def noerr_getstatusoutput(cmd):
    """Return (status, output) of executing cmd in a shell."""
    import os
    pipe = os.popen('{ ' + cmd + '; } ', 'r')
    text = pipe.read()
    sts = pipe.close()
    if sts is None: sts = 0
    if text[-1:] == '\n': text = text[:-1]
    return sts, text


def userinput(msg, force=False):
   """Prompts the user with the message msg"""
   if not force:
      res=raw_input("\033[31m%s\033[m\017 (\033[31my\033[m\017|\033[32mN\033[m\017)?" % msg)
      res=res.lower()
      if res not in ["yes", "y"]:
         print "Nothing changed."
         sys.exit(0)

def dryrun(msg):
   """Prints text to stderr"""
   print >> sys.stderr, "Dry run mode: %s" % msg

def getsttycolumnwidth():
   """Get the screen width of your current terminal"""
   out = os.popen("stty -a").read()
   m = re.search(r"columns (\d+);", out)
   return m.group(1)

def normal(text):
  return text

def green(text):
  return "\033[32m%s\033[m\017" % text

def red(text):
  return "\033[31m%s\033[m\017" % text

def done():
  return green("done.")

def failed():
  return red("failed!")


def extractURL(infolist):
    """extractURL: Returns the URL from the line URL: http://bla.bla...
       given by svn info
    """
    for l in infolist:
        if l.startswith("URL: "):
            return l.split(": ")[1]
    return "UNKNOWN" # This case should not happen


# Just a try:
def runsvn(filename, svncmd, svnopt, exceptmsg, exception=dmexcept.DocManagerException):
    """Run a svn command with appropriate options and filename(s).
       Arguments:
       - filename:  The filename(s) as string or list
       - svncmd:    The respective SVN command
       - svnopt:    The option(s) as string or list
       - exception: None or a pointer to a exception class
       - exceptmsg: The exception message
    """
    if isinstance(filename, list):
        f = " ".join(filename)
    else:
        f = filename
    if isinstance(svnopt, list):
        opt = " ".join(svnopt)
    else:
        opt = svnopt
    cmd = "LANG=C %s %s %s" % (svncmd, opt, f)
    res = commands.getstatusoutput(cmd)
    if res[0] != 0:
        if exception is None:
            return None
        else:
            raise exception("%s\nReason: %s" % (exceptmsg, res[1]) )
    return res[1]

    
    
############################################
class SVNFile(object):
   """Base class for all files in a repository"""

   class Props:
      """Class for collection properties"""
      def __init__(self, propstring):
         assert isinstance(propstring, types.StringType), \
            "ERROR: Props.__init__: Expected string type, got %s" % type(propstring)
         self.props = {}
         self.propstring=propstring.strip().split("\n")
         if propstring.startswith("Properties on"):
            self.propstring.pop(0) # Remove the first item
         # Eliminate empty entries
         self.propstring = ( i for i in self.propstring if i != '')

      def __iter__(self):
         return self

      def getprops(self):
         self.props = {}
         try:
            for p in self.propstring:
               # print "p='%s'" % p
               ss = p.strip().split(" : ")
               if len(ss)==1:
                 # Occurs only, when there is a property but with empty value
                 ss=p.strip().split(" :")
               self.props[ss[0]] = ss[1]
            return self.props
         except IndexError, e:
              # This should not happen:
              print >> sys.stderr, "IndexError: %s" % (e)
         #   pass

      def next(self):
         try:
            ss = self.propstring.pop(0).strip().split(" : ")
            self.props[ss[0]] = ss[1]
            return {ss[0]: ss[1]}
         except IndexError:
            raise StopIteration

   # Class SVNFile:
   def __init__(self, filename, basedir=None):
      self._docrelease=None
      self.origfilename = filename
      self.basedir = basedir or ""
      self.dir, self.filename=os.path.split(filename)
      self._abspath=self.abspath()
      self._trunkpath=self.trunkpath()
      self._branchpath=self.branchpath()
     
   def getbranchpath(self):
      return self._branchpath

   def getfilename(self):
      return self.filename

   def getorigfilename(self):
      return self.origfilename

   def getfilenamewithdir(self):
      return os.path.join(self.dir, self.filename)
      
   @property
   def filenamewithdir(self):
      return os.path.join(self.dir, self.filename)
   
   @property
   def relfilename(self):
     """Returns the relative filename in regards to basedir"""
     return os.path.split(self.filename)[-1]

   def __repr__(self):
      return "<SVNFile from '%s'>" % self._abspath

   def abspath(self):
      return os.path.abspath(self.getfilenamewithdir())

   def trunkpath(self):
      return self.abspath()

   def branchpath(self):
      apath=self.abspath()
      release = self.getdocrelease()
      xx=apath.split("/trunk/")
      # Check, if we are in trunk or branches:
      if len(xx)==2:
          # release==None should not happen
          try:
            assert release!=None, \
                  "ERROR: File '%s' does not have a release property" \
                  " Is it really available in SVN?" % apath
            return os.path.join(xx[0], "branches", release, xx[1])
          except AssertionError, e:
            raise dmexcept.SVNException(e)

      elif len(apath.split("/branches/")) == 2:
         return None
      else:
         return None
   #def existsbranchfile(self):
      #return os.path.exists(self._branchpath)
   #def existstrunkfile(self):
      #return os.path.exists(self._trunkpath)

   def iterprops(self):
      return iter(self.getprops() )

   def getstatus(self):
      """Returns the status of a file in a repository by svn status"""
      status = commands.getstatusoutput("LANG=C svn st %s" %
                                         self.getfilenamewithdir() )
      if status[0] != 0:
         raise IOError("SVN status: %s" % status[1])
      if status[1]=='':
         return " "*2
      else:
         return status[1]

   def getinfo(self):
      """Returns some information of a file or directory by svn info"""
      info=commands.getstatusoutput("LANG=C svn info %s" % self.getfilenamewithdir() )
      if info[0] != 0:
         raise IOError("SVN info: %s" % info[1])
      return info[1]

   def getdocrelease(self):
      """ """
      if self._docrelease==None:
        res = commands.getstatusoutput("svn pg doc:release %s" %
                                       self.getfilenamewithdir())
        if res[0] == 0:
           self._docrelease=res[1]

      return self._docrelease

   def getpropertylist(self):
      """Returns a list of properties from svn proplist"""
      prop=commands.getstatusoutput("LANG=C svn pl -v --xml %s" %
                                           self.getfilenamewithdir() )
      if prop[0] != 0:
         raise IOError("SVN proplist: %s" % prop[1])
       
      # print( prop[1] )
      XP=et.fromstring( prop[1].strip() )
      props = XP.xpath( "//property")
      x = ""
      for i in props:
        # x[i.attrib.get("name")] = i.text
        x += "%s : %s\n" % ( i.attrib.get("name"), i.text )
      return x

   def __getprops(self):
      prop=self.getpropertylist()
      info=self.getinfo()
      info=" : ".join(info.split(": ")).strip()
      status="svn:status : %s." % self.getstatus()[:3]# The dot after %s is essential!
      # print("*** info:", info )
      # print("*** prop:", prop )
      #print("\n*** STATUS »%s«, INFO: »%s«" % (status, info) )
      # _properties[1].strip()+"\n"+info+"\n"+status
      return self.Props( "\n".join([prop, info, status]) )

   def getprops(self):
      p = self.__getprops().getprops()
      # print("getprops:", p, self.__getprops() )
      p["name"] = self.origfilename # Extend dictionary
      # Correct svn:status: We are only interested in content and properties:
      p["svn:status"] = p["svn:status"][:2]
      return p
#

   def setsinglerevprop(self, propname, propvalue):
     """Set a revision property.
     
     If you get the following error, proceed with NOTE:
       svn: Repository has not been enabled to accept revision propchanges;
       ask the administrator to create a pre-revprop-change hook
     
     NOTE: The SVN repository needs the following prerequisists:
     * There must be a pre-revprop-change script
     * It must be executable (chmod 755 pre-revprop-change)
     * It must contain the following lines:
       -------------------
       #!/bin/sh
       # We need
       exit 0
       -------------------
     * Don't use the original pre-revprop-change.tmpl! It rejects
       every property name that is *not* "svn:log"!
     """
     print "Setting a revprop"
     cmd="LANG=C svn ps --revprop -r HEAD %s %s %s" % \
          ( propname, propvalue, self.getfilenamewithdir() )
     res=commands.getstatusoutput(cmd)
     if res[0] != 0:
       print res[1]

   def setsingleprop(self, propname, propvalue):
        cmd="LANG=C svn ps %s %s %s" % \
          ( propname, propvalue, self.getfilenamewithdir() )
        res=commands.getstatusoutput(cmd)
        if res[0] != 0:
            raise IOError("singleprop: Could not set %s=%s to file %s.\n"
                          "Command was %s\n"\
                          "Reason: %s" %
                          (propname, propvalue, self.getfilenamewithdir(), cmd, res[1]) )


   def setprops(self, **args):# message,
      assert isinstance(args, dict), \
             "setprops: Expected a dictionary."

      for k in args.iterkeys():
        print >> sys.stdout, "INFO: Setting %s" % k
        self.setsingleprop(k, args[k])
      
      # self.commit(message)
      # After the normal properties, set the revision property
      #if args.get("doc:status") in ("proofed", "locdrop"):
      #   self.setsinglerevprop("doc:status", args["doc:status"])

   def commit(self, msg=''):
      print "Committing '%s'... " % self.getorigfilename(),
      res=commands.getstatusoutput("LANG=C svn ci -m'%s' %s" % \
               ( "docmanager2: %s" % msg, self.getfilenamewithdir()) )
      if res[0] != 0:
        print failed()
        raise dmexcept.DocManagerCommitException(
            "\nCommitting for file '%s' failed.\n"\
            "       Reason: %s" % (self.getfilenamewithdir(), res[1]) )
      print done()




############################################
class SVNRepository(object):
   """Represents our SVN repository"""

   def __init__(self, filenames, **args):
      # self.filenames = filenames
      self._filenames = []  # List of filenames
      self._fileobjects=[]  # List of file objects
      self.formatter=None
      self.args = args
      self._props = None
      self.maxfilename = 0 # Length of the longest filename
      self.svnentrylist=[]  #
      self.docstatus = (
                "editing",  # Someone starts to edit a file
                "edited",   # Someone has finished editing; file is ready for proofing
                "proofing", # Proofreader starts proofing file
                "proofed",  # Proofreader has finished proofing
                "comments", # Proofreader has some comments for proofed file
                "locdrop",  # File is sent to translators
               )

      #
      # self._gopts = self.args.get("gopts")
      self.basedir = self.args.get("basedir", "")
      self.envfile = self.args.get("envfile")
      # Avoids None in self.basedir:
      self.basedir=self.basedir or ""
      
      # FIXME: Check if we are in the correct directory
      # Old:
      #if not self.svnentrylist:
      #    self.initsvnentrylist()
      if not os.path.exists(os.path.join(self.basedir, "xml/")):
          raise dmexcept.DocManagerEnvironment(dmexcept.DIR_XML_NOT_FOUND)
      if not os.path.exists(os.path.join(self.basedir, "xml/.svn")):
          raise dmexcept.DocManagerEnvironment(dmexcept.DIR_SVN_NOT_FOUND)
      
      # Just in case, there is no force attribute set...
      self.args["force"] = self.args.get("force", False)
      
      
      # print " SVNRepository: filenames=%s" % len(filenames)
      # If file list is empty, use "make projectfiles"
      if not len(filenames):
        filenames=self.makeprojectfiles()
        
      # print "<%s>: " % (self.__class__.__name__,), self.args

      # Allow only those files that fit certain criterias
      for f in filenames:
            # print "Filename %s" % f
            if not os.path.exists(f):
                print >> sys.stderr, dmexcept.FILE_NOT_FOUND_ERROR % f
                continue
            elif f[-1]=='~':
                # We don't want backup files
                # (they are not under version control)
                continue
            elif not self.issvnfile(f):
                # We don't want files, that are not under version control
                # print >> sys.stderr, f
                #continue
                # raise dmexcept.SVNException(red(dmexcept.NOT_IN_SVN_ERROR % f))
                print red(dmexcept.NOT_IN_SVN_ERROR % f)
            #elif not(self.checkstatus(f)) and self.allowmodified==False:
            #   raise  RuntimeError("ERROR: File »%s« is modified. " \
            #            "Please commit your changes first." % f )
            else:
                self._filenames.append(f)
                # print "Filename %s" % f

      if not len(self._filenames):
         print >> sys.stderr, dmexcept.EMPTY_FILELIST
         sys.exit(40)

      # Calculate the longest length of our filename
      self.maxfilename = max([ len(os.path.split(f)[-1]) for f in self._filenames])

      # Create a new generator, only with existing filenames
      # Any exceptions are propagated to the caller
      self._fileobjects = ( SVNFile(f, self.basedir) for f in self._filenames )


   def __repr__(self):
      return "<%s '%s'>" % (self.__class__.__name__, self._fileobjects)

   def checkenvfile(self, env):
     """Checks for new style env file"""
     envfile = os.path.join(self.basedir, env)
     data=open(envfile, 'r').read()
     # Apply simple heuristic:
     # If any "export " string is found, we assume it's old style
     if ".env-profile" in data:
       raise dmexcept.DocManagerEnvironment(dmexcept.OLDSTYLE_ENV_FILE)

   def makeprojectfiles(self):
      """Call daps and create a list of projectfiles"""
      
      # First we want to check for commandline option
      env=self.envfile
      
      if not env:
        # Use ENV name from envirionment variable, otherwise
        # use glob ENV-*
        if os.environ.get("DAPS_ENV_NAME"):
            env=os.environ.get("DAPS_ENV_NAME")
        else:
          env=glob.glob("ENV-*")
          if len(env)==1:
            env=env[0]
          else:
            raise dmexcept.DocManagerEnvironment(dmexcept.TOO_MANY_ENV_FILES)
          
      self.checkenvfile(env)
        

      if self.args.get("header"):
         print "Collecting filenames...",

      # Use --basedir when available, otherwise assign empty string
      if self.basedir:
        basedir = "--basedir %s" % self.basedir
      else:
        basedir = ""
      cmd="LANG=C daps -e %s %s --color=0 projectfiles" % (env , basedir)
      
      res=noerr_getstatusoutput(cmd)
      if res[0] != 0:
         print failed()
         print >> sys.stderr, \
              red("\nReason: %s\n" \
                  "Solution: Check the result."
                  % ( res[1]) )

      if self.args.get("header"):
          print done()
      
      filelist = res[1].split()
      if self.args.get("header"):
        print "Checking if files are available in SVN... ",
      
      for f in filelist:
         if not self.issvnfile(f):
           #raise dmexcept.SVNException(dmexcept.NOT_IN_SVN_ERROR % f)
           print red(dmexcept.NOT_IN_SVN_ERROR % f)
      
      if self.args.get("header"):
          print done()

      return filelist


   def initsvnentrylist(self):
        # Old code used xml/.svn/entries to collect filenames, but
        # that doesn't work anymore. ;-(
        pass
        

   def issvnfile(self, filename):
      """issvnfile(filename) -> BOOL
         Checks if a file is under version control"""
      # We have to convert our filename to Unicode, because entries 
      # in svnentrylist are in Unicode too.
      #if unicode(os.path.basename(filename)) in self.svnentrylist
      # Old code:
      # Finally find a SVN command that gives back reasonably return codes
      res=commands.getstatusoutput("LANG=C svn info %s" % filename)
      #print >> sys.stderr, res
      if res[0] == 256:
        return False
      else:
        return True

   def iterfilenames(self):
      return iter(self._filenames)

   def iterfileobj(self):
      return iter(self._fileobjects)
   
   def isinbranches(self):
      """Checks if the current path belongs into a branch directory"""
      return len(os.getcwd().split("/branches/")) == 2

   def isintrunk(self):
      """Checks if the current path belongs into a trunk directory"""
      return len(os.getcwd().split("/trunk/")) == 2

   def setIncludeQuery(self, query):
        """Set the query filter for include(s) """
        self._inquery = query

   def setExcludeQuery(self, query):
        """Set the query filter for exclude(s) """
        self._exquery = query

   def setHeader(self, header=True):
        """Set the header flag"""
        self.headerflag = header

   def header(self):
     """header() -> String.  Print the header"""
     
     if not self.args.get("header", True):
        return ''

     if self.args.get("querystring") is None:
       result=Formatter.standardquery
     else:
       result=self.args.get("querystring")
     line=len(result)*"-"
     return "%s\n%s\n%s\n" % (line, result, line)

   def query(self):
      """query(querystring) -> void  Runs a query of the given repository"""
      if self.formatter is None:
         self.formatter = Formatter

      on = self.args.get("output")
      if on == None:
        output = sys.stdout
      else:
        output = open(on, "w")

      print >> output, self.header()
      # Using strange names to omit name clashes
      #self.args['***MAINTAINER***'] = 0# Addional
      self.args["***TRANS***"] = 0
      self.args["***filecount***"] = 0
      self.args["maxfilename"] = self.maxfilename
      for k in self.docstatus:
        self.args['***%s***' % k] = 0

      for f in self._fileobjects:
        self.args["fileobj"] = f
        self.args["***filecount***"] += 1
        # f = self.splitfrombasedir(f)
        svnq = SVNQuery(f, self.args.get("includequery"), self.args.get("excludequery"))
        
        if svnq.process():
            # print >> sys.stderr, f, svnq.PropsDict()
            print >> output, "%s" % self.formatter(**self.args), # Don't remove the comma here!
        self.collectstatistics(svnq.PropsDict(), f)

      if self.args["statistics"]:
          self.printstatistics(output)
      output.close()

   def printstatistics(self, stream):
      _fwidth=40
      _mwidth=15
      _rwidth=10
      _swidth=15
      _twidth=6  #

      # Print statistics:
      print >> stream, "\n*** Statistics ***"
      # print " %s%s\n" % ("Files".ljust(_swidth), str(len(Properties.xmlfiles)).rjust(4))
      print >> stream, " %s%s" % ("#files".ljust(_swidth), str(self.args["***filecount***"]).rjust(4))
      for k in self.docstatus:
        print >> stream, " %s%s" % ( k.ljust(_swidth), str(self.args['***%s***' % k]).rjust(4) )
      print >> stream, " %s%s" % ( "trans".ljust(_swidth), str(self.args["***TRANS***"]).rjust(4) )
      #print >> stream, " No maintainer".ljust(_swidth), str(self.args['***MAINTAINER***']).rjust(4)
     

   def collectstatistics(self, queryobj, fileobj):
      """Count all properties"""
      try:
        if queryobj["doc:status"]=="editing":
            self.args['***editing***'] += 1
        elif queryobj["doc:status"]=="edited":
            self.args['***edited***'] += 1
        elif queryobj["doc:status"]=="proofing":
            self.args['***proofing***'] += 1
        elif queryobj["doc:status"]=="proofed":
            self.args['***proofed***'] += 1
        elif queryobj["doc:status"]=="comments":
            self.args['***comments***'] += 1
        elif queryobj["doc:status"]=="locdrop":
            self.args['***locdrop***'] += 1

        if queryobj["doc:trans"]=="yes":
            self.args["***TRANS***"] += 1

      except KeyError, e:
        print >> sys.stderr, \
        dmexcept.DocManagerEnvironment(dmexcept.NO_PROPERTY_ERROR % (e, fileobj.getfilename() ) )

   def setProperties(self, **properties):
     """Set properties from a dictionary"""
     # 
     # print "**** Inside setProperties", properties
     def nothing(f, debug, **properties): 
        print "  nothing:() properties:", properties
        pass
     def xx(f, debug, **properties):
       if debug: print "Props:", properties; dryrun(properties)
        
       #if properties.has_key('doc:status') and properties["doc:status"] == 'edi':
       # and properties.has_key('doc:maintainer'):
       # Need to set the owner of the XML file?
       # If yes, set the respective graphics too
       gf = self.getgraphics(f)
       return self.branchgraphics(gf, properties, debug=debug)
       #else:
       #   print "fooo"

     # return self._setProps(self._fileobjects, ask=self.args["force"], func=xx, **properties)
     #
     # From here: new code:
     self._props = properties
     func = xx
     logmsg = ""
     assert isinstance(properties, dict), dmexcept.EXPECTED_DICTIONARY_ERROR
     # Creates the string "KEY=VALUE[, KEY=VALUE]*"
     xx=", ".join(["%s=%s" % \
           _i for _i in itertools.izip(properties.keys(),
                                       properties.values()) ])

     # Output reminder, when doc:status="edited":
     if properties.get('doc:status') == 'edited':
           print """
Your friendly "DocManager Reminder". :-) Did you:
  1. Checked the file(s) for validation?
  2. Checked all the image files, if any?
  3. Checked all the remarks, if any?
  4. Checked the profiling attributes, if any?
  5. Checked all the links (<ulink/>) with "make chklink"?
           """
     # Any security question before?
     if not self.args["force"]:
        userinput("Should I set the properties: %s?" % xx)

     for f in self._fileobjects:
       # Check first for modification of the file and return an error
       status=f.getstatus()
       # print " ## setProperties: '%s'" % status

       if status[0]=='M':
         raise dmexcept.DocManagerPropertyException(dmexcept.MODIFIED_FILE % f.getorigfilename())
       if status[1]=='M':
         raise dmexcept.DocManagerPropertyException(dmexcept.MODIFIED_PROPS % f.getorigfilename())

       # FIXME: Add missing option for skipping the XML format process
       #        Format the xml file, if not deactivated
       if properties.get("skipformatting" , True):
         logmsg = "Formatted with xmlformat."
         try:
           self.xmlformat(f)
         except dmexcept.DocManagerFileError, e:
           print red(e)
           sys.exit(30)
       
       #
       # Set the properties
       #
       #
       if os.path.exists(".svn"):
        try:
            logmsg = "\n".join([logmsg, "Set properties %s" % xx])
            if not properties.get("dryrun", False):
              f.setprops(**properties)
              f.commit(logmsg)
              if properties.get("doc:status") in ("proofed", "locdrop"):
                f.setsinglerevprop("doc:status", properties["doc:status"])
              if properties.get("incgraphics", False):
                res = func(f, debug=False, **properties)
                
            else:
                res = func(f, debug=True, **properties)
            
            print "    %s.\n" % green("Successful")
    
        except (dmexcept.DocManagerPropertyException,
                dmexcept.DocManagerCommitException), e:
            print red(e)
            sys.exit(30)
    
        except (dmexcept.DocManagerPropertyException,
                dmexcept.DocManagerCommitException), e:
            print red(e)
            sys.exit(30)

       # Neither in branch nor in trunk
       else:
         raise dmexcept.DocManagerEnvironment(dmexcept.WRONG_DIRECTORY_ERROR)

       # Commit any changes
       # f.commit(logmsg)
       # After the normal properties, set the revision property
       # if properties.get("doc:status") in ("proofed", "locdrop"):
       #   f.setsinglerevprop("doc:status", args["doc:status"])


   def xmlformat(self, fileobj):
    """Run daps-xmlformat"""
    # print "*** Inside xmlformat(%s)" % fileobj

    res = commands.getstatusoutput("%s -i %s" % (
         "daps-xmlformat",
         fileobj.getorigfilename()) )
    if res[0] != 0:
      print >> sys.stderr, "ERROR: XML formatting has failed.\n"\
                           "       Reason: %s" % (res[1], )
    elif res[0] == 100:
      raise dmexcept.DocManagerFileError("ERROR: %s" % res[1])
    else:
      return False
      
    return True


   def _setProps(self, fileobjects, ask=False, func=None, **properties):
      """Set properties on a fileobject from a dictionary (obsolete)"""
      def nothing(f, debug, **properties): 
        print "  nothing:() properties:", properties
        pass
      
      assert isinstance(properties, dict), dmexcept.EXPECTED_DIRECTORY_ERROR
      # print self, self.args, self.args["dryrun"] #properties
      # Creates a string with format:
      # PROPERTY=VALUE[, PROPERTY=VALUE]*
      xx=", ".join(["%s=%s" % \
           _i for _i in itertools.izip(properties.keys(),
                                       properties.values()) ])

      if not ask:
        userinput("Should I set the properties: %s?" % xx)
      if not func:
        func = nothing

      if self.isintrunk():
        #branchroot = os.path.abspath(os.path.join(os.getcwd(),
        #                             "../../../branches/"))
        #assert os.path.exists(branchroot), ERROR_BRANCH_DIRECTORY_NOT_EXISTS % branchroot

        try:
            for f in fileobjects:
                # print "***", f, properties
                propstr = "Set properties %s" % xx
                if not self.args["dryrun"]:
                    f.setprops(propstr, **properties)
                    # f.commit(propstr)
                    self.branching(f)# Merge or copy to branch
                    if self._props["incgraphics"]:
                      res = func(f, debug=False, **properties)
                else:
                    res = func(f, debug=True, **properties)
    
            print "    %s.\n" % green("Successful")
    
        except (dmexcept.DocManagerPropertyException,
                dmexcept.DocManagerCommitException), e:
            print red(e)
            sys.exit(30)
      
      # Not in trunk, but in branches
      elif self.isinbranches() == True:
        try:
            for f in fileobjects:
                #print "***", f, properties
                propstr = "Set properties %s" % xx
                if not self.args["dryrun"]:
                    f.setprops(propstr, **properties)
                    # f.commit(propstr)
                    ## No merge or copy to branch
                else:
                    #dryrun(propstr)
                    pass
    
            print "    %s.\n" % green("Successful")
    
        except (dmexcept.DocManagerPropertyException,
                dmexcept.DocManagerCommitException), e:
            print red(e)
            sys.exit(30)

      # Neither in branch nor in trunk
      else:
        raise dmexcept.DocManagerEnvironment(dmexcept.WRONG_DIRECTORY_ERROR)


   def getgraphics(self, fileobj):
     """ """
     # General procedure:
     # 1. Get all graphics in the current file
     # 2. Iterate through all files
     #  2a. Check, if the file is available in SVN
     #  2b. If not, iterate through all the available formats
     #  2c.  
     # 3. Return the list
     
     fn = fileobj.getorigfilename()
     
     GFX_STYLESHEET=os.path.join(PROCDIR, "get-graphics.xsl")
     # Empty parameter preferred.mediaobject.role is needed here to return
     # *all* graphic files:
     cmd="xsltproc --stringparam preferred.mediaobject.role '' %s %s"
     res=commands.getstatusoutput(cmd % (GFX_STYLESHEET, fn) )
     if res[0] != 0:
       print >> sys.stderr, "ERROR: Something is not correct with the XML file '%s'\n"\
             "       Reason: %s" % (fn, res[1])
     
     gfx = set(res[1].strip().split()) # needed to remove any duplicate entries
     return self.getgraphformat(gfx)


   def getgraphformat(self, gfx):
     """Checks, which format for each graphic file is available in SVN"""
     GRAPHPATH="images/src/"
     dirs = os.listdir(GRAPHPATH)
     # Remove any ".svn" directory
     if ".svn" in dirs:
        dirs.remove(".svn")
     resstr=[]
     
       
     for d in dirs:
       dd = os.path.join(GRAPHPATH, d)
       
       if not os.path.isdir(dd):
         continue
       
       for g in gfx:
         basefile = "%s.%s" % (os.path.splitext(g)[0], d)
         gg = os.path.join(dd, basefile )
         
         cmd = "LANG=C svn ls %s"
         res=commands.getstatusoutput(cmd % gg )
         # print "%s " % gg,
         if res[0] != 0:
           continue
         else:
           resstr.append(gg)
       
     resstr = set(resstr) # Remove any duplicates
     # print "Graphics:", resstr
     return resstr

   def branchgraphics(self, gfx, props, debug=False):
      """Merge or copy a graphic file into branch"""
      if not self.args.get("branching", False):
         # Skip branching when variable is False
         return 0

      ask=self.args["force"]
      assert type(gfx) == type(set()), "branchgraphics: Type for gfx ist not a set"
      assert type(props)  == types.DictType, "branchgraphics: Type for props is not a dict"
      
      if len(gfx): 
        print "Found graphics:", ", ".join(gfx)
        if ask:
          userinput("Should I set the property for these graphics: %s?" % ", ".join(gfx) )
      else:  
        print >> sys.stderr, "-- No graphics found for this XML file."
        return 0


      #gfxfiles = []
      for g in gfx:
        try:
          svn = SVNFile(g)
          # gfxfiles.append(svn)
          branchpath = svn.branchpath()
          trunkpath = svn.trunkpath()
        except dmexcept.SVNException, e:
          # In case of a problem occurs, skip it
          print >> sys.stderr, e
          continue
        
        # Set the doc:maintainer
        assert props.has_key('doc:maintainer'), \
           "branchgraphics: No doc:maintainer found. This should not happen!"
        
        #d={}
        #d['doc:maintainer']=props.get('doc:maintainer')
        #self._setProps([svn], ask=False, **d)
        
        ## FIXME: Maybe test here the status of the respective graphic file?
        
        cmd="LANG=C svn ps doc:maintainer '%s' %s" % (props.get('doc:maintainer'),trunkpath)
        res=commands.getstatusoutput(cmd)
        print "Setting maintainer for '%s'" % trunkpath
        
        if res[0] != 0:
          raise dmexcept.DocManagerCommitException("ERROR: Problem with setting doc:maintainer property\n%s" % res[1])
        
        if os.path.exists(branchpath):
          print "Copying over existing file..."
          res = shutil.copy(trunkpath, branchpath)
          
          cmd="LANG=C svn ci -m'%s' %s %s" % (
             "docmanager2: Copying graphic into branch.", 
             trunkpath, branchpath)
          
        else:
          print "Copying..."
          cmd="LANG=C svn copy %s %s && "\
          "LANG=C svn ci -m'%s' %s" % \
            (svn.abspath(), os.path.dirname(branchpath),
             "docmanager2: Copying into branch.", branchpath)

        if debug:
          print >> sys.stderr, cmd
          res=(0, "")
        else:
          res=commands.getstatusoutput(cmd)
          if res[1] !='': print res[1]
        
        if res[0] != 0:
          print failed()
          raise dmexcept.DocManagerCommitException("ERROR: Something went wrong with the graphics:\n%s" % res[1] )
        



   def copytrunk2branch(self, fileobj):
      """Copy a file into a branch"""
      info = fileobj.getinfo()
      remoteurl = extractURL(info.split("\n"))
      branchdir = fileobj.branchpath()

      cmd="LANG=C svn copy %s %s && "\
          "LANG=C svn ci -m'%s' %s" % \
            (fileobj.abspath(), branchdir,
             "docmanager2: Copying into branch.", 
             branchdir)
      if not self.args["dryrun"]:
        print "Copying to branch '%s'..." % branchdir,
        res=commands.getstatusoutput(cmd)
      else:
        dryrun(cmd)
        res=(0,cmd)

      if res[0] != 0:
          print failed()
          raise dmexcept.DocManagerCommitException("\nCopying into branch failed.\n"\
                                          "Reason: %s" % res[1])
      print "%s\n%s %s" % (done(), res[1], "-"*10)


   def mergetrunk2branch(self, fileobj):
      """Merge a file into branch"""
      trunkpath = fileobj.abspath()
      branchpath = fileobj.branchpath()
      info = fileobj.getinfo()
      remotetrunkurl = extractURL(info.split("\n"))

      cmd="LANG=C svn info %s" % branchpath
      res=commands.getstatusoutput(cmd)

      if res[0] != 0:
         raise dmexcept.DocManagerEnvironment("Could not get remote URL from '%s'\n"\
                                        "Reason: %s" %
                                        (branchpath, res[1])
                                       )
      remotebranchurl=extractURL(res[1].split("\n"))

      print "Merging\n"\
            "  '%s'\n"\
            "  '%s'\n"\
            "  '%s'..." % \
            (remotebranchurl, remotetrunkurl, branchpath),

      # print "  svn merge %s %s %s" % (remotebranchurl, remotetrunkurl, branchpath)
      cmd="LANG=C svn merge %s %s %s && LANG=C svn ci -m'%s' %s" % \
           (remotebranchurl, remotetrunkurl, branchpath,
           "docmanager2: Merging file", branchpath)
      if not self.args["dryrun"]:
        res=commands.getstatusoutput(cmd)
      else:
        dryrun(cmd)
        res=(0, cmd)

      if res[0] != 0:
          print failed()
          raise dmexcept.DocManagerCommitException("\nMerging into branch failed.\n"\
                                          "Reason: %s" % res[1])
      print "%s\n%s\n%s" % (done(), res[1], "-"*10 )

   def updateinbranch(self, fileobj):
      """Update the branch directory"""
      res=commands.getstatusoutput("LANG=C svn up %s" % fileobj.branchpath())
      # FIXME: Is there a need to check the result?
      # If the update was successful, it's ok.
      # If the update was not successful, we have to copy it anyway.

   def tagging(self):
     """ """
     print "Tagging", self.args
     allowed_tags = ("TOPRINT", "TOTRANS", "LOCDROP")
     # These are the allowed prefixes that are used to build the
     # branch names (not used at the moment)
     allowed_release_prefixes = (
        "SLE",  # SUSE Linux Enterprise (Server and NLD)
        "SL",   # SUSE Linux Box
        "OS"    # openSUSE 
        )
     tagname = self.args['tag']
      
     c=r"(%s)_\d{3}" % "|".join(allowed_tags)
     if re.match(c, tagname)==None:
          raise dmexcept.DocManagerException("Tag name is not valid. "\
                                       "Expected one of %s, but got '%s'." %
                    ( ", ".join(allowed_tags), tagname) )

     cwd = os.getcwd()
     try:
       dirname=cwd.split("/trunk/")[1].split("/")[0]
       lang=cwd.split("/trunk/")[1].split("/")[1]
     except IndexError:
       raise DocManagerEnvironment("You are in the wrong directory. Expected 'trunk' in directory.")

     # Now we are in the correct dir
     tagsrootdir = os.path.abspath("../../../tags/")
     
     if not os.path.exists(tagsrootdir):
       # Hmn, can we switch to server side tagging here? 
       raise DocManagerEnvironment("You do not have a tags directory. "\
                                   "I expected it at '%s'" % tagsrootdir )
     
     itemroot=os.path.join(tagsrootdir, dirname)
     
     # (1) Check, if tags exists on server
     #  -> no:  raise exception
     # (2) Check if tags/$dirname exists on server
     #  -> no:  Create directory
     #  -> yes: Choose another name and repeat
     # (3) Check if tags/$dirname/$lang exists on server
     #  -> no:  Create directory
     #  -> yes: Hmn, ...
     # (4) Tag the branch
     #   Copy $SVNROOT/branches/$release/$dirname/$lang to
     #        $SVNROOT/tags/$dirname/$lang
     # 
     # Need to be implemented...

     print "Tagging ..."

   def branching(self, fileobj):
      """Merge or copy a file into branch"""
      if not self.args.get("branching", False):
         # Skip branching when variable is False
         return

      branchpath = fileobj.branchpath()
      trunkpath = fileobj.abspath()
      #print fileobj
      #print " getfilenamewithdir:", fileobj.getfilenamewithdir()
      #print "            abspath:", fileobj.abspath()
      #print "          trunkpath:", trunkpath
      #print "         branchpath:", branchpath
      if branchpath == None:
         raise dmexcept.DocManagerEnvironment("Path to branch not found for file '%s'"% trunkpath)
      # Make sure we have the latest version in branch
      self.updateinbranch(fileobj)

      if os.path.exists(branchpath):
        self.mergetrunk2branch(fileobj)
      else:
        self.copytrunk2branch(fileobj)


#
if __name__ == "__main__":
    print __name__
