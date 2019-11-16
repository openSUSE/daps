#!/usr/bin/env python3

from setuptools import setup
import sys

sys.path.insert(0, "bin")

import getentityname as gen

setup(
    name="getentityname",
    version=gen.__version__,
    description="Returns all entities from one or more XML files",
    long_description=gen.__doc__,
    author=gen.__author__,
    author_email=gen.__author__.split(" ", 2)[1],
    url='https://github.com/tomschr/gententities',
    download_url='https://github.com/openSUSE/daps/releases',
    # py_modules=[package.__name__],
    include_package_data=True,
    classifiers=[
        'Environment :: Web Environment',
        'Intended Audience :: Developers',
        'License :: OSI Approved :: GNU General Public License v3 (GPLv3)',
        'Operating System :: OS Independent',
        'Programming Language :: Python',
        'Programming Language :: Python :: 3',
        'Programming Language :: Python :: 3.5',
        'Programming Language :: Python :: 3.6',
        'Programming Language :: Python :: 3.7',
        'Topic :: Utilities',
        'Topic :: Text Processing',
    ],
    setup_requires=['pytest-runner', ],
    tests_require=['pytest', 'virtualenv'],
    scripts=['bin/getentityname.py'],
)
