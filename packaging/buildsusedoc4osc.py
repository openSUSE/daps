#!/usr/bin/python
# -*- coding: utf-8 -*-

import os
import os.path
import sys
import subprocess
import optparse
import pprint
import tempfile
import shutil
import glob
import readline
import logging, logging.handlers

__version__ = "$Revision$"[1:-2]
__author__="Thomas Schraitle <thomas DOT schraitle AT suse DOT de>"
__license__="GPL"
__doc__= """Usage: %(proc)s [OPTIONS...]

OBS = OpenSUSE Build Server, %(version)s

This script creates a RPM package from the BerliOS SVN and builds it in OBS.
"""

readline.parse_and_bind('set editing-mode vi')
basename=os.path.splitext( os.path.basename( sys.argv[0] ) )[0]
username=os.environ.get('LOGNAME') or os.environ.get('USER') or 'unknown'

#
project="home:%s:branches:unittest"
parentproject="Documentation:Tools"

##
## Create logger with multiple destinations
## log with higher severity in file, but with lower severity on console
## The default levels are (in this order):
## NOTSET, DEBUG, INFO, WARNING, ERROR and CRITICAL
LOG_FILENAME="/tmp/%s.%s.log" % (basename,username)
log = logging.getLogger( 'susedoc4osc' )
log.setLevel(logging.DEBUG)

# Create file handler which logs even info messages
fh=logging.handlers.RotatingFileHandler(LOG_FILENAME, mode="w")
fh.setLevel(logging.DEBUG)
# Create console handler with a higher log level
ch=logging.StreamHandler()
ch.setLevel(logging.WARN)
# Create formatter and add it to the handlers
ch.setFormatter(logging.Formatter('[%(levelname)-8s]: %(message)s'))
fh.setFormatter(logging.Formatter('[%(levelname)-6s][%(name)s][%(funcName)s]: %(asctime)s %(message)s'))
# Add the handlers to logger
log.addHandler(ch)
log.addHandler(fh)



def excepthook(*args):
  """Catch and log any exception
     This function needs to be set to sys.excepthook
     
     Source: http://code.activestate.com/recipes/577074-logging-asserts/
  """
  log.error('Uncaught exception:', exc_info=args)

# Set the excepthook 
# sys.excepthook = excepthook



# Source:
# http://wordaligned.org/articles/echo
def name(item):
    " Return an item's name. "
    return item.__name__

def format_arg_value(arg_val):
    """ Return a string representing a (name, value) pair.
    
    >>> format_arg_value(('x', (1, 2, 3)))
    'x=(1, 2, 3)'
    """
    arg, val = arg_val
    return "%s=%r" % (arg, val)
    
def echo(fn, write=log.debug):# write=sys.stdout.write
    """ Echo calls to a function.
    
    Returns a decorated version of the input function which "echoes" calls
    made to it by writing out the function's name and the arguments it was
    called with.
    """
    import functools
    # Unpack function's arg count, arg names, arg defaults
    code = fn.func_code
    argcount = code.co_argcount
    argnames = code.co_varnames[:argcount]
    fn_defaults = fn.func_defaults or list()
    argdefs = dict(zip(argnames[-len(fn_defaults):], fn_defaults))
    
    @functools.wraps(fn)
    def wrapped(*v, **k):
        # Collect function arguments by chaining together positional,
        # defaulted, extra positional and keyword arguments.
        positional = map(format_arg_value, zip(argnames, v))
        defaulted = [format_arg_value((a, argdefs[a]))
                     for a in argnames[len(v):] if a not in k]
        nameless = map(repr, v[argcount:])
        keyword = map(format_arg_value, k.items())
        args = positional + defaulted + nameless + keyword
        msg="%s(%s)\n" % (name(fn), ", ".join(args))
        write(msg)
        return fn(*v, **k)
    return wrapped


def getoutput(process):
  """Print output from command ()"""
  while True:
    out= process.stdout.read(1)
    if out == '' and process.poll() != None:
      break
    if out != '':
      sys.stdout.write(out)
      sys.stdout.flush()
  return process.returncode


def get_input(prompt1, prompt2):
  """Input line with the help of readline module (if imported)"""
  L = list()
  prompt = prompt1
  while True:
      L.append(raw_input(prompt))
      if L[-1] == '' and L[-2] == '':
          s="\n".join(L)
          return s.rstrip().rstrip()
      prompt = prompt2


##
##
##
class OBSException(Exception):
  pass

class OBS(object):
  """Data for openSUSE Build Server"""
  # Development project:
  __project=project  #"home:%s:branches:unittest"
  # Where stable packages should live:
  parentprj=parentproject  #"Documentation:Tools"
  # The package name itself:
  package="susedoc"
  user="thomas-schraitle"
  arch=os.uname()[-1] # $(uname -m)
  os=""
  version=""
  pkgversion=""
  configfile="~/.oscrc"
  oscpath=None
  message=None

  def debug(self, msg, info=None):
    """Prints message, if debug is enabled"""
    if self.options.debug:
      log.info(msg)
    
  def dryrun(self, cmd):
    """Prints command, if dryrun is enabled"""
    if self.options.dryrun:
      log.info(cmd)

  def __str__(self):
     return """<%s 0x%0x>
 Project: %s %s
 Package: %s %s
 user:    %s
 arch:    %s
 os:      %s
 config:  %s
 oscpath: %s
 message: %s
 colon:   %s
 options: %s
""" % (self.__class__.__name__,
         id(self),
         self.project, self.version,
         self.package, self.pkgversion,
         self.user,
         self.arch,
         self.os,
         self.configfile,
         self.oscpath,
         repr(self.message),
         self.withcolon,
         self.options,
        )

  def __init__(self, options):
    self.options = options
    self.configfile = os.path.expanduser( self.configfile )
    self.withcolon=self.checkconfig()
    if not self.withcolon:
      self.oscpath = self.project
    else:
      self.oscpath = "/".join(self.project.split(":"))
    if self.options.obsparentprj:
      self.parentprj = self.options.obsparentprj
    self.getcurrentOS()
    

  def getcurrentOS(self):
     """Get the current operating system and version number"""
     release="/etc/SuSE-release"
     # Something like this is inside content:
     # ['openSUSE 11.2 (x86_64)\n', 'VERSION = 11.2\n']
     content = open(release, 'r').readlines()
     self.os = content[0].strip().split(" ")[0]
     self.version = content[1].strip().split("=")[1].strip()
     log.info("OS: %s, version: %s" % (self.os, self.version) )
     return (self.os, self.version)

  @property
  def project(self):
    """Returns the current project"""
    return self.__project % self.user

  def checkout(self):
    """Checkout our current project"""
    #cmd="osc co %s %s" % (self.project, self.package)
    log.debug("Parent project=%s" % self.parentprj )
    log.debug("Package=%s" % self.package)
    log.debug("Project=%s" % self.project)
    cmd="osc bco -m'Unittest' -c %s %s %s" % (self.parentprj, 
          self.package, self.project )
    self.debug(cmd)
    p = subprocess.Popen( cmd, #.split(" ", 1),
             shell=True,
             close_fds=False,
             stdin=subprocess.PIPE, stdout=subprocess.PIPE)
    return getoutput(p)


  def checkconfig(self):
    """Reads only value of checkout_no_colon in OSC user config"""
    # Theoretically it would be better to import osc.OscConfigParser
    # and work with that. As we need it to only ask an option and 
    # osc is based on ConfigParser this should be safe.
    from ConfigParser import ConfigParser
    
    osc = ConfigParser()
    osc.readfp( open(self.configfile, 'r') )
    try:
      colon = osc.getboolean("general", "checkout_no_colon")
    except:
      colon=0
      # print 'osc.getboolean("general", "checkout_no_colon") failed, using %s' % colon
    log.info("checkout_no_colon: %s" % colon)
    return colon

  def checkversion(self):
    """Returns version string from spec file"""
    sdocpath=os.path.join(self.oscpath, self.package)

    ver=""
    # Open spec file and search for version string
    specfile= "%s/%s.spec" % (sdocpath, self.package)
    with open(specfile, 'rw') as spec:
      # tmp = tempfile.TemporaryFile( suffix=".spec", dir=".")
      fd, name = tempfile.mkstemp(suffix=".spec", dir=".", text=True)
      tmp = open(name, "w")
      for line in spec:
        if line.startswith("Version:"):
          # If user gave us a version string, let's use it:
          if self.options.obsversion:
            ver=self.options.obsversion
            self.previousversion=self.pkgversion=ver
          else:
            ver=line
            self.previousversion=self.pkgversion=ver.split(":")[-1].strip()
            ver, minor=self.pkgversion.rsplit(".", 1)
            minor=int(minor)+1
            self.pkgversion="%s.%s" % (ver, minor)
          tmp.write("Version:        %s\n" % (self.pkgversion) )
        else:
          tmp.write(line)
      tmp.close()
    log.info("Found version %s" % ver)
    # Move the temp file to the correct location
    os.rename(name, specfile)
    # print os.listdir(".")
    return self.pkgversion


  def movetarball(self, tarname):
    """Move tar ball to the correct location"""
    assert os.path.exists(tarname), "Tar ball does not exist"
    self.debug("Moving tarball '%s' to %s" % (tarname, self.oscpath))
    shutil.move(tarname, os.path.join(self.oscpath, self.package))
    pwd=os.getcwd()
    os.chdir(os.path.join(self.oscpath, self.package))
    cmd="osc add %s" % tarname
    self.debug(cmd)
    ret = subprocess.call(cmd, shell=True, close_fds=False)
    assert ret==0, "Something went wrong with osc add"
    os.chdir(pwd)


  def removeoldtar(self):
    """Remove old tar ball"""
    path = os.path.join(self.oscpath, self.package)
    tmppath= os.path.join(self.options.tempdir, path)
    tars = glob.glob("%s/*.tar.bz2" % tmppath)
    # print tars
    assert len(tars)==1, "Which tarball should I delete? I have: %s" % (" ".join(tars),)
    cmd="osc rm %s" % tars[0]
    self.debug(cmd)
    ret = subprocess.call(cmd, shell=True, close_fds=False)
    assert ret==0, "Something went wrong with osc rm"


  def createmessage(self):
    """Create message for OSC"""
    #
    path = os.path.join(self.oscpath, self.package)
    tmppath= os.path.join(self.options.tempdir, path)
    pwd=os.getcwd()
    os.chdir(tmppath)

    if self.options.msgfile:
      if self.options.msgfile.startswith("/"):
         f=self.options.msgfile
      else:
         f=os.path.join(self.options.pwd, self.options.msgfile)
      log.info("Reading message from file '%s'" % self.options.msgfile )
      msg=open(f, 'r').readlines()
      self.message="".join(msg).replace('"', '\\"').replace('*', '\\*')
      # self.message
    elif self.options.msg:
      self.message=self.options.msg.replace("\\n", "\n")
    else:
      self.message=get_input("Enter you message (press Ctrl+D to enter two empty lines to abort):\n> ", "> ")

    cmd="osc vc --message \"%s\" " % self.message.replace("\\n", "\n")
    self.debug("%s %s" % (os.getcwd(), repr(cmd)) )
    try:
      ret = subprocess.call(cmd, shell=True, close_fds=False)
      log.info("Command %s returned: %s" % (cmd, ret) )
      assert ret==0, "Something went wrong with osc vc"
    finally:
       os.chdir(pwd)

  def buildrpm(self):
    """Build the RPM package with osc"""
    path = os.path.join(self.oscpath, self.package)
    tmppath= os.path.join(self.options.tempdir, path)
    pwd=os.getcwd()
    os.chdir(tmppath)
    cmd="osc build %s_%s" % (self.os, self.version)
    self.debug(cmd)
    p = subprocess.Popen( cmd, #.split(" ", 1),
             shell=True,
             close_fds=False,
             stdout=subprocess.PIPE)
    ret = getoutput(p)
    assert ret == 0, "osc reported an error. Please check: %s" % ret

  @echo
  def commitpackage(self):
    """Commit new package to OBS"""
    cmd="osc ci --message \"%s\"" % self.message
    if not self.options.dryrun:
      self.debug(cmd)
      p = subprocess.Popen( cmd, #.split(" ", 1),
             shell=True,
             close_fds=False,
             stdout=subprocess.PIPE)
      ret = getoutput(p)
      log.info("Command %s returned: %s" % (cmd, ret) )
      assert ret==0, "Something went wrong during osc commit"
    

  @echo
  def submitreq(self):
    """Execute submit request to our devel project"""
    # Check first, if already a submitreq lies around:
    cmd="osc request list %s" % self.parentprj
    self.debug(cmd)
    ret = subprocess.Popen(cmd, shell=True, stdout=subprocess.PIPE ).communicate()
    log.info("Command returned: %s" % (ret,) )
    # Make sure we have no submit requests:
    if ret[0].strip() != '':
      raise OBSException("Your devel project %s contains one or more submit requests" % self.parentprj)      
    
    cmd="osc sr --cleanup --message \"%s\"" % self.message
    # %s %s %s" % \
    #  (self.message, self.project, self.package, self.parentprj)
    self.debug(cmd)
    ret = subprocess.Popen(cmd, shell=True, stdout=subprocess.PIPE ).communicate()
    log.info("Command returned: %s" % (ret,) )
    assert ret[1]==0, "Something went wrong during osc commit"
    import re
    # FIXME: Accept the submitreq
    # created request id 12345
    m = re.search("created request id (?P<id>[\d]+)", ret[0].strip())
    assert m.group('id') != '', \
       "Expected osc sr returned an request id, but got nothing: %s" % ret
    cmd="osc request accept %s --message='automatically set to ok.'" % m.group('id')
    self.debug(cmd)
    ret = subprocess.Popen(cmd, shell=True, stdout=subprocess.PIPE ).communicate()
    log.debug("Command %s returned: %s" % (cmd, ret))
    assert ret[1]==0, "osc request was not happy. Got %s" % ret
    return
 
    
  @echo
  def createtag(self):
    """Create a tag in BerliOS' tag directory"""
    pkg="%s-%s" % ( self.package, self.pkgversion )
    self.debug("Preparing tagging...")
    return self.svn.createtag(pkg, self.message, self.options.dryrun)

  @echo
  def main(self):
    """Do the stuff """
    if self.options.obscheckout:
      self.checkout()
      self.checkversion()
    else:
      log.info("Using existing OBS directory")
    
    self.svn = BerliOS(self.package, self.pkgversion, self.options)
    #print (svn)
    if self.options.svncheckout:
      self.svn.export()
    else:
      log.info("Using existing SVN directory")
    tarname = self.svn.makearchive()
    if self.options.obscheckout:
      self.removeoldtar()
      self.movetarball(tarname)

    self.createmessage()
    self.buildrpm()
    self.commitpackage()
    
    if self.options.svntag:
      self.createtag()
    else:
      log.info("Tagging SVN skipped.")
      
    if self.options.submitreq:
      self.submitreq()
    else:
      log.info("Submitrequest skipped.")


##
## BerliOS class
##
class BerliOS(object):
  """Data for BerliOS SVN server"""
  url="https://svn.berlios.de/svnroot/repos/opensuse-doc/"
  path="branches/tools/docmaker"
  tags="tags/tools/docmaker"
  # package=None

  def __init__(self, package, version, options):
    self.package = package
    self.version = version
    self.options = options

  def debug(self, msg):
    """Prints message, if debug is enabled"""
    if self.options.debug:
      log.info(msg)


  def export(self):
    """Exporting SVN repository """
    # svn export --quiet $BERLIOS_URL/$BERLIOS_susedoc ${OBS_PACKAGE}
    cmd="svn export %s %s" % ( os.path.join(self.url, self.path), "%s-svn" % self.package )
    self.debug(cmd)
    p = subprocess.Popen( cmd, #.split(" ", 1),
             shell=True,
             close_fds=False,
             stdin=subprocess.PIPE, stdout=subprocess.PIPE)
    ret = getoutput(p)
    log.info("Command %s returned: %s" % (cmd, ret) )
    assert ret==0, "Something went wrong during svn export"

  @echo
  def makearchive(self, name=None):
    """Creating tar archive"""
    log.debug("Making archive..." )
    tarname = "%s-%s.tar.bz2" % (self.package, self.version)
    cmd="tar cjhf %(tar)s " \
       "--exclude-from=%(pkg)s-svn/packaging/exclude-files_for_susedoc_package.txt " \
       "--transform=s/%(pkg)s-svn/%(pkg)s/ " \
       "%(pkg)s-svn" % \
       {
         'tar': tarname,
         'pkg': self.package
       }

    self.debug(cmd)
    ret = subprocess.call(cmd, shell=True, close_fds=False,)
    log.info("Command %s returned: %s" % (cmd, ret) )
    return tarname

  @echo
  def createtag(self, package, message, dryrun=False):
    """Create a tag in BerliOS' tag directory """
    cmd="svn copy --message \"%(msg)s\" " \
        "%(url)s/%(src)s " \
        "%(url)s/%(dest)s/obs/%(pkg)s" % \
        {
          "url": self.url,
          "src": self.path,
          "dest": self.tags,
          "pkg": package,
          "msg": message,
        }
    self.debug(cmd)
    ret = subprocess.call(cmd, shell=True, close_fds=False,)
    log.info("Command %s returned: %s" % (cmd, ret) )
    return ret

  def __str__(self):
    return pprint.pformat(self.options)


# ----------------------------------------------
class MyParser(optparse.OptionParser):
  """Customization class for "raw" formatting of epilog"""
  def format_epilog(self, formatter):
      return self.epilog

# @echo
def main():
  d = {"proc": os.path.basename(sys.argv[0]), \
       "version": __version__,
      }
  log.info("Started %(proc)s version %(version)s" % d )
  parser = MyParser(__doc__.strip() % d, \
                    version=__version__, \
                    epilog="""
The script does the following things:
 1. Check out from OBS repository, if --skip-obscheckout is NOT set
 2. Raise version automatically, if --skip-obscheckout is NOT set
 3. Export SVN repository, if --skip-svncheckout is NOT set
 4. Create a tarball
 5. If --skip-obscheckout is NOT set, remove old tar ball and move
    new tar ball into the checked out OBS repository
 6. Create your commit message
 7. Build RPM packaage
 8. If --skip-tag is NOT set, create a SVN tag
 9. If --skip-submitreq is NOT set, create and accept submit request
"""
                    )
  parser.add_option("", "--show-opts",
      dest="showopts",
      action="store_true",
      help=optparse.SUPPRESS_HELP,
      # help="Shows only the options and arguments"
      )
  parser.add_option("-d", "--debug",
      dest="debug",
      action="store_true",
      help="Switch on debug options"
      )
  parser.add_option("-D", "--dry-run",
      dest="dryrun",
      action="store_true",
      help="Print the commands, but don't execute them (default %default)"
      )
  parser.add_option("-t", "--temp",
      dest="tempdir",
      metavar="TEMPDIR",
      help="Use existing temp directory in DIR from previous call"
      )
  parser.add_option("-k", "--keep-temp",
      dest="keeptempdir",
      action="store_true",
      help="Keeps the temp directory (useful for debugging)"
      )
  parser.add_option("-F", "--file",
      dest="msgfile",
      metavar="FILE",
      help="Read log message from FILE"
      )
  parser.add_option("-m", "--message",
      dest="msg",
      metavar="TEXT",
      help="Specifies log message TEXT for the .changes file " \
           "and also used as log message for tagging"
      )
  # OBS Group
  group = optparse.OptionGroup(parser, \
      "openSUSE Build Server Options")
  group.add_option("-P", "--obs-parent-project",
      dest="obsparentprj",
      help="Specifies the devel project or where all submitrequests end (default is %default)",
      )
  group.add_option("-p", "--obs-project",
      dest="obsproject",
      help="Specifies the branch project (default is %default)"
      )
  group.add_option("-a", "--obs-package",
      dest="obspackage",
      help="Specifies the OBS package (default is %default)"
      )
  group.add_option("-u", "--obs-user",
      dest="obsuser",
      help="Specifies the OBS user (default is %default)"
      )
  group.add_option("", "--obs-version",
      dest="obsversion",
      help="Definies manually the version for the package",
      )
  group.add_option("", "--skip-obscheckout",
      dest="obscheckout",
      action="store_false",
      help="Is a checkout of the OBS repo needed (default is %default)? " \
           "Used in combination with -t/--temp"
      )
  group.add_option("", "--skip-submitreq",
      dest="submitreq",
      action="store_false",
      help="Should additionally a submitrequest be executed? (default is %default)",
      )
  parser.add_option_group(group)

  # BerliOS Group
  group = optparse.OptionGroup(parser, \
      "BerliOS SVN Options")
  group.add_option("-A", "--svn-package",
      dest="svnpackage",
      help="Specifies the OBS package (default is %default)"
      )
  group.add_option("-U", "--svn-user",
      dest="svnuser",
      help="Specifies the SVN user (default is %default)"
      )
  group.add_option("", "--skip-svncheckout",
      dest="svncheckout",
      action="store_false",
      help="Is a checkout of the SVN repo needed (default is %default)? " \
           "Used in combination with -t/--temp"
      )
  group.add_option("-s", "--skip-svntag",
      dest="svntag",
      action="store_false",
      help="Do we want a SVN tag (default is %default)? "
      )
  parser.add_option_group(group)

  # Set default values:
  parser.set_defaults(debug=False,
      keeptempdir=False,
      dryrun=False,
      showopts=False,
      # OBS default values:
      obsuser=OBS.user,
      obscheckout=True,
      obsparentprj=parentproject,
      obsproject=project % OBS.user, #OBS.project,
      obspackage=OBS.package,
      submitreq=True,
      # BerliOS default values:
      svnpackage=OBS.package,
      svnuser=os.getlogin(),
      svncheckout=True,
      svntag=True,
      )

  options, args  = parser.parse_args()
  log.info("Options: %s %s" % (options, args))
  
  if len(sys.argv)==1:
    parser.print_help()
    sys.exit(0)

  if options.showopts:
     print("Parser options %s %s" % (options, args))
     sys.exit(100)

  if options.msg and options.msgfile:
    parser.error("options -m/--message and -F/--file are mutually exclusive")
  # If there was -F/--file option, the file should be present as well:
  if options.msgfile and not os.path.exists(os.path.abspath(options.msgfile)):
     parser.error("Log message file '%s' does not exist" % options.msgfile)
     
  return options, args


if __name__=="__main__":
  log.info("-"*20)
  options, args = main()
  pwd = os.getcwd()
  options.pwd = pwd
  returncode=0
  
  try:
    # Create temporary directory automatically when nothing is specified
    if not options.tempdir:
      options.tempdir=tempfile.mkdtemp(prefix="%s-" % OBS.package)

    os.chdir(options.tempdir)
    obs = OBS(options)
    obs.main()

  except KeyboardInterrupt:
    returncode=10
    # Add any exceptions here
  except OBSException, e:
    log.error(e)
    print >> sys.stderr, e
    returncode=100
  finally:
    os.chdir(pwd)
    if not options.keeptempdir:
      log.debug("Going to remove temp dir %s" % options.tempdir)
      # shutil.rmtree(options.tempdir)
    else:
      log.debug("Keeping temp dir %s" % options.tempdir)
      
  
  log.info("Finished.")
  sys.exit(returncode)

  

# EOF
