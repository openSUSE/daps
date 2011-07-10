#!/usr/bin/env python
# -*- coding: utf-8 -*-

import os
from setuptools import setup, find_packages

from setuptools_dmutils import CleanCommand, TestCommand


# Utility function to read the README file.
# Used for the long_description.  It's nice, because now 
# 1) we have a top level README file and 
# 2) it's easier to type in the README file than to put a raw
#    string in below ...
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


# List your project dependencies here.
# For more details, see:
# http://packages.python.org/distribute/setuptools.html#declaring-dependencies
# Note: Dependency versions are specified in parentheses as per PEP314 and
# PEP345.  They will be adjusted automatically to comply with distribute/
# setuptools install_requires convention.

REQUIRES=[
#    'setuptools',
#    'optparse',
    'lxml',
    'optcomplete',
]
TEST_REQUIRES=[
  "unittest2",
  #"mocker",
  # "mox",
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
  
  # Commands which modifies/extends our setup.py
  cmdclass={'clean': CleanCommand,
            'test':  TestCommand,
           },
  
  # The scripts:
  scripts=["bin/docmanager2.py", ], # "bin/dm.py" 
 
  # 
  platforms = 'any',
 
  # Classifiers a la Sourceforge
  classifiers=trove_classifiers,
 
  # Our testsuite, including its requirements
  test_suite = 'dm.tests',
  tests_require=TEST_REQUIRES,
  
  # Any requirements:
  # install_requires=REQUIRES,
  
  # All files are unzipped during installing:
  zip_safe = False,
)
