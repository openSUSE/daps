#!/usr/bin/python
#
# project_files.py -- find all files that contribute to some ENV
#                     using a library written in perl.
#
# (C) 2010 jw@suse.de, Novell Inc.
# Distribute under GPLv2 or GPLv3
#
# dependencies:
#   home:babelworx:python perlmodule
#   devel:tools:documentation perl-SUSEDOC
#
# TODO: 
#  This is a cheap plastic immitation of project_files.pl -- see there.
#  It has no command line options, and does not format the output nicely.
#  Needs help of a python-literate person.
#  --> toms: Done, but needs improvement if everything is correctly
#            implemented
# 

__version__="$Id: xxx $"

import os,sys,pprint
libdir = os.path.abspath(os.path.dirname(sys.argv[0]) + '/../lib/python')
print libdir
sys.path.insert(0, libdir)


from susedoc import *

import optparse

def parse():
  """Create an OptionParser and analyze the commandline options"""
  # Used descriptions from the Perl script:
  parser = optparse.OptionParser(
     usage="\n  %prog [options] startfile.xml\n" \
           "  %prog [options] ENV-startfile",
     version="%prog " + __version__[3:-1],
     description="Find all files that contribute to some ENV")
  parser.add_option("-v", "--verbose",
      dest="verbose",
      action="store_true",
      help="Be more verbose. Default: %default")
  parser.add_option("-q", "--quiet",
      dest="verbose",
      action="store_false",
      help="Be quiet, not verbose") 	
  # I'm not sure, if this is really intended:
  parser.add_option("-a", "--all",
      dest="all",
      choices=("xml", "files", "images"),
      help="Print all files, xml and images. Default: %default")
  # I'm not sure here either:
  parser.add_option("-i", "--images",
      dest="images",
      # choices=("xml", "files", "images"),
      help="Print images only. Default: xml files (FIXME)")
  parser.add_option("-p", "--profos",
      dest="profos",
      help="Profile for one operating system. " \
           "Default from ENV{PROFOS}, otherwise: any. " \
           "Use '-p --' to ignore profiling from ENV. " \
           "Use '-p -osuse' to exclude openSUSE specifc parts")
  parser.add_option("-l", "--long",
      dest="long",
      help="List 3 column layout: filename, profiling,parent_file[node...] "\
           "A list of node numbers, specifies the xml-node where " \
           "the file was included. " \
           "Default: filenames only.")
  parser.add_option("-P", "--previous-file-cmd",
      dest="previous_file_cmd",
      help="Run the specified command if XML::Parse fails. " \
            "Useful to e.g. fetch an earlier version from svn, "\
            "hoping to avoid a newly introduced bug.")
  parser.add_option("-C", "--cleanup-file-cmd",
      dest="cleanup_file_cmd",
      help="Run the specifed command, after all error recovery attempts. " \
           "This should restore the	file to the state it was before.")
  parser.add_option("-r", "--retry-limit",
      dest="retry_limit",
      type="int",
      help="Run previous-file-cmd at most NNN times for a file. " \
            "Default %default") 
  # Set all the default values for the previous options:
  parser.set_defaults(verbose=True,
                      all="xml",
                      )
  (options, args) = parser.parse_args()
  # Just for debugging purpose, can be removed later:
  print options, args
  return options, args
  # sys.exit(10)
  

if __name__=="__main__":
  # Populate the options and arguments.
  # options is a list, args is a dictionary: 
  options, args = parse()
  envfile = options[0]
  
  ctx = SUSEDOC(env=envfile)
  # ctx = SUSEDOC(**{ 'env': envfile })

  list = ctx.project_files()

  pprint.pprint(copy_in(list))

  for f in sorted(list.keys()):
    if (list[f]['type'] == 'xml'):
      print f

