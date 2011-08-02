#!/usr/bin/env python
# -*- coding: utf-8 -*-

import os
from setuptools import setup, find_packages

from setuptools_dmutils import CleanCommand, ManpageCommand

version="0.9beta8"

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
    "Programming Language :: Python :: 2.7",
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

## Requirements that need docmanager when installed:
REQUIRES=[
    #'setuptools >= 0.6',
    'lxml',
    'optcomplete',
]

## Our test requirements:
TEST_REQUIRES=[
  'unittest2',
  'nose',
  'optcomplete',
  'setuptools',
  'lxml',
]

# Run the beast:
setup(
  name="docmanager",
  version=version,
  author="Thomas Schraitle",
  author_email="toms@opensuse.org",
  url="https://svn.berlios.de/svnroot/repos/opensuse-doc/trunk/tools/daps/docmanager",
  license="LGPL",
  keywords="SVN properties status",
  description="Manages XML Doc Files through SVN Properties",
  long_description="""Docmanager is a command line tool for managing documentation
projects in SVN that are based on Novdoc or DocBook 4.x.
Preferably, use Docmanager in conjunction with daps (DocBook Authoring
and Publishing Suite).

Docmanager allows you to view or set doc-related properties to
files in SVN, such as the properties "doc:status", "doc:maintainer",
"doc:trans", "doc:deadline", or "doc:priority". They are especially
helpful for managing larger documentation projects with multiple
authors (maintainers), deadlines and priorities.

The "doc:status" property reflects the workflow status of each file.
The status can change several times throughout the documentation
process. Whereas the initial state of each file is usually "editing", a
proofreader can search for all files of a project that are already set
to "edited", can set them to "proofing" and to "proofed" afterwards (or
to the status "comments" if the author needs to check some of the
proofreader's remarks in the file). With the "doc:trans" property you
can keep track of the files that need to be translated.
  """,

  # Our packages we want to add;
  packages=['dm'],

  # Commands which modifies/extends our setup.py
  cmdclass={'clean':   CleanCommand,
            'manpage': ManpageCommand,
           },
  
  # The scripts:
  scripts=["bin/docmanager", "bin/dm" ], #  
 
  #manpages=["doc/docmanager.xml"],
  #xslt="db2man.xsl",
  # 
  platforms = 'any',
 
  # Classifiers a la Sourceforge
  classifiers=trove_classifiers,
 
  # Our testsuite, including its requirements
  #test_suite = 'tests.suite',
  #test_suite="nose.collector",
  #tests_require=TEST_REQUIRES,
  
  # Any requirements:
  # install_requires=REQUIRES,
  
  # All files are unzipped during installing:
  zip_safe = False,
)
