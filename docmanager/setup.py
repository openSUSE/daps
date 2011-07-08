#!/usr/bin/env python
# -*- coding: utf-8 -*-

import os
from setuptools import setup, find_packages
from setuptools.command.build_py import build_py as _build_py

#from distutils.core import setup
#from distutils.command.build_py import build_py as _build_py


# Utility function to read the README file.
# Used for the long_description.  It's nice, because now 1) we have a top level
# README file and 2) it's easier to type in the README file than to put a raw
# string in below ...
def read(fname):
    return open(os.path.join(os.path.dirname(__file__), fname)).read()

trove_classifiers=[
    "Intended Audience :: Developers",
    "Intended Audience :: Other Audience",
    "Development Status :: 4 - Beta",
    "Topic :: Utilities",
    "Programming Language :: Python",
    "Programming Language :: Python :: 2.6",
    "License :: OSI Approved :: GNU Library or Lesser General Public License (LGPL)",
    "Topic :: Software Development :: Libraries :: Python Modules",
    "Topic :: Software Development :: Documentation",
    "Topic :: Software Development :: Quality Assurance",
    "Topic :: Software Development :: Version Control",
    # "Topic :: Text Processing",    
    "Topic :: Utilities",
    "Topic :: Text Processing :: Markup :: XML",
]

requirements=[
#    'setuptools',
#    'optparse',
    'lxml',
    'optcomplete',
]

# Run the beast:
setup(
  name="docmanager",
  version="2.0",
  author="Thomas Schraitle",
  author_email="toms@opensuse.org",
  url="https://svn.berlios.de/svnroot/repos/opensuse-doc/trunk/tools/daps/docmanager",
  license="LGPL",
  keywords="SVN properties status",
  packages=['dm'], # find_packages(),
  description="Manages Doc Files through SVN Properties",
  long_description=read("README"),
  
  # The scripts:
  scripts=["bin/docmanager2.py", ], # "bin/dm.py" 
 
  # Classifiers a la Sourceforge
  classifiers=trove_classifiers,
 
  # Our testsuite
  test_suite = 'dm.tests',
  
  # Our extensions to setuptools:
  #entry_points={
    #'setuptools.commands': [
      #'manpage = setuptools_dmutils.setuptools_command:ManpageCommand', 
      #],
   #}
  
  # Any requirements:
  # install_requires=requirements,
  
  # All files are unzipped during installing:
  zip_safe = False,
)
