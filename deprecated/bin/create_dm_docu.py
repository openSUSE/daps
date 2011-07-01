#!/bin/sh
#
# Needed package: epydoc
# Creates DocManager API documentation with epydoc:

epydoc -o html/ docmanager2.py dm/{base.py,branch.py,colorprint.py,dmexceptions.py,docget.py,docset.py,formatter.py,locdrop.py,svncmd.py,svnentrieshandler.py,svnquery.py,tag.py} ../python/optcomplete.py

