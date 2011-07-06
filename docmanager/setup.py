#!/usr/bin/env python
# -*- coding: utf-8 -*-

from distutils.core import setup

setup(
   name="docmanager",
   version="2.0",
   description="Manages Doc Files through SVN Properties",
   author="Thomas Schraitle",
   author_email="toms@opensuse.org",
   url="https://svn.berlios.de/svnroot/repos/opensuse-doc/trunk/tools/daps/docmanager",
   license="LGPL",
   # packages=[],
   # long_description=read("README"),
   
   py_modules=["dm"],  
   script_name='docmanager2.py',    #[, "dm.py"]
   classifiers=[
    "Intended Audience :: Developers",
    "Intended Audience :: Other Audience",
    "Development Status :: 4 - Beta",
    "Topic :: Utilities",
    "Programming Language :: Python",
    "License :: OSI Approved :: GNU Library or Lesser General Public License (LGPL)",
    # "Topic :: Text Processing",    
    "Topic :: Software Development :: Libraries :: Python Modules",
    "Topic :: Software Development :: Documentation",
  ],
)