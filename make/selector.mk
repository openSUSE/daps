# Copyright (C) 2012-2020 SUSE Software Solutions Germany GmbH
#
# Author:
# Frank Sundermeyer <fsundermeyer at opensuse dot org>
#
# Make file selector for DAPS
#
# This file defines which makefiles to load for each target
#
# Please submit feedback or patches to
# <fsundermeyer at opensuse dot org>
#

ifndef DAPSROOT
  $(error $(shell ccecho "error" "Fatal error: No path to DAPSROOT set"))
endif

#
# Using TARGET instead of MAKECMDGOALS in all makefiles (except this one of
# course) allows us to overwrite the real target for debugging and thus
# get specific other values (rather than those for HTML) for the targets
# showvariable and daspenv
#
ifndef TARGET
  TARGET := $(firstword $(MAKECMDGOALS))
endif

#---------------
# DEFAULT INCLUDE
# common_variables.mk is _always_ needed
include $(DAPSROOT)/make/common_variables.mk
include $(DAPSROOT)/make/filenames.mk

# On directory creation see:
# http://www.cmcrossroads.com/ask-mr-make/6936-making-directories-in-gnu-make
#
$(DIRECTORIES):
	mkdir -p $@


# Note on the ifeq statements below
# ifeq ($(foo),$(filter $(foo),<LIST>) is used to fake a logical "or"
# because $(filter $(foo),<LIST>) returns $foo, if it is part of 
# <LIST>

ifeq "$(MAKECMDGOALS)" "debug"
  include $(DAPSROOT)/make/setfiles.mk
endif

#---------------
# Clean
#
CLEANTARGETS := clean clean-images clean-package clean-results clean-all real-clean

ifeq "$(MAKECMDGOALS)" "$(filter $(MAKECMDGOALS),$(CLEANTARGETS))"
	include $(DAPSROOT)/make/clean.mk
endif

#---------------
# Debugging
#
DEBUGGINGTARGETS := dapsenv nothing showvariable

ifeq "$(MAKECMDGOALS)" "$(filter $(MAKECMDGOALS),$(DEBUGGINGTARGETS))"
  include $(DAPSROOT)/make/setfiles.mk
  include $(DAPSROOT)/make/profiling.mk
  include $(DAPSROOT)/make/validate.mk
  include $(DAPSROOT)/make/misc.mk
  include $(DAPSROOT)/make/images.mk
  include $(DAPSROOT)/make/filelist.mk
  include $(DAPSROOT)/make/packaging.mk
  include $(DAPSROOT)/make/html.mk
  include $(DAPSROOT)/make/text.mk
  include $(DAPSROOT)/make/webhelp.mk
  include $(DAPSROOT)/make/man.mk
  include $(DAPSROOT)/make/pdf.mk
  include $(DAPSROOT)/make/epub.mk
  include $(DAPSROOT)/make/print_results.mk
  include $(DAPSROOT)/make/debug.mk
endif

#---------------
# EPUB
#
EPUBTARGETS := epub mobi

ifeq "$(MAKECMDGOALS)" "$(filter $(MAKECMDGOALS),$(EPUBTARGETS))"
  include $(DAPSROOT)/make/setfiles.mk
  include $(DAPSROOT)/make/profiling.mk
  include $(DAPSROOT)/make/validate.mk
  include $(DAPSROOT)/make/images.mk
  include $(DAPSROOT)/make/misc.mk
  include $(DAPSROOT)/make/epub.mk
endif

#---------------
# File Listings
#
LISTTARGETS := list-file list-images-missing list-images-multisrc list-srcfiles list-srcfiles-unused

ifeq "$(MAKECMDGOALS)" "$(filter $(MAKECMDGOALS),$(LISTTARGETS))"
  ifeq "$(strip $(SRC_FORMAT))" "adoc"
    include $(DAPSROOT)/make/adoc2xml.mk
  endif
  include $(DAPSROOT)/make/setfiles.mk
  include $(DAPSROOT)/make/images.mk
  include $(DAPSROOT)/make/filelist.mk
endif

#---------------
# HTML/HTMLSINGLE
#
HTMLTARGETS := html

ifeq "$(MAKECMDGOALS)" "$(filter $(MAKECMDGOALS),$(HTMLTARGETS))"
  include $(DAPSROOT)/make/setfiles.mk
  include $(DAPSROOT)/make/profiling.mk
  include $(DAPSROOT)/make/validate.mk
  include $(DAPSROOT)/make/images.mk
  include $(DAPSROOT)/make/html.mk
endif

#---------------
# Images
#

IMGTARGETS := optipng images

ifeq "$(MAKECMDGOALS)" "$(filter $(MAKECMDGOALS),$(IMGTARGETS))"
  include $(DAPSROOT)/make/setfiles.mk
  include $(DAPSROOT)/make/profiling.mk
  include $(DAPSROOT)/make/images.mk
endif

#---------------
# MAN pages
#
ifeq "$(MAKECMDGOALS)" "man"
  include $(DAPSROOT)/make/setfiles.mk
  include $(DAPSROOT)/make/profiling.mk
  include $(DAPSROOT)/make/validate.mk
  include $(DAPSROOT)/make/misc.mk
  include $(DAPSROOT)/make/man.mk
endif

#---------------
# Miscellaneous
#

MISCTARGETS := bigfile docinfo linkcheck stylecheck productinfo

ifeq "$(MAKECMDGOALS)" "$(filter $(MAKECMDGOALS),$(MISCTARGETS))"
  include $(DAPSROOT)/make/setfiles.mk
  include $(DAPSROOT)/make/profiling.mk
  include $(DAPSROOT)/make/validate.mk
  include $(DAPSROOT)/make/misc.mk
endif

#---------------
# Packaging
#
PACKAGETARGETS_HTML := package-html
PACKAGETARGETS_PDF  := package-pdf

ifeq "$(MAKECMDGOALS)" "$(filter $(MAKECMDGOALS),$(PACKAGETARGETS_HTML))"
  include $(DAPSROOT)/make/setfiles.mk
  include $(DAPSROOT)/make/profiling.mk
  include $(DAPSROOT)/make/validate.mk
  include $(DAPSROOT)/make/images.mk
  include $(DAPSROOT)/make/html.mk
  include $(DAPSROOT)/make/packaging.mk
endif
ifeq "$(MAKECMDGOALS)" "$(filter $(MAKECMDGOALS),$(PACKAGETARGETS_PDF))"
  include $(DAPSROOT)/make/setfiles.mk
  include $(DAPSROOT)/make/profiling.mk
  include $(DAPSROOT)/make/validate.mk
  include $(DAPSROOT)/make/images.mk
  include $(DAPSROOT)/make/pdf.mk
  include $(DAPSROOT)/make/packaging.mk
endif
ifeq "$(MAKECMDGOALS)" "dist-webhelp"
  include $(DAPSROOT)/make/setfiles.mk
  include $(DAPSROOT)/make/profiling.mk
  include $(DAPSROOT)/make/validate.mk
  include $(DAPSROOT)/make/images.mk
  include $(DAPSROOT)/make/webhelp.mk
  include $(DAPSROOT)/make/packaging.mk
endif
ifeq "$(MAKECMDGOALS)" "package-src"
  ifeq "$(strip $(SRC_FORMAT))" "adoc"
    include $(DAPSROOT)/make/adoc2xml.mk
  endif
  include $(DAPSROOT)/make/setfiles.mk
  include $(DAPSROOT)/make/profiling.mk
  include $(DAPSROOT)/make/validate.mk
  include $(DAPSROOT)/make/images.mk
  include $(DAPSROOT)/make/packaging.mk
endif
ifeq "$(MAKECMDGOALS)" "locdrop"
  include $(DAPSROOT)/make/setfiles.mk
  include $(DAPSROOT)/make/profiling.mk
  include $(DAPSROOT)/make/validate.mk
  include $(DAPSROOT)/make/images.mk
  ifneq "$(NOPDF)" "1"
    include $(DAPSROOT)/make/pdf.mk
  endif
  include $(DAPSROOT)/make/locdrop.mk
endif

#---------------
# PDF
#

ifeq "$(MAKECMDGOALS)" "pdf"
  include $(DAPSROOT)/make/setfiles.mk
  include $(DAPSROOT)/make/profiling.mk
  include $(DAPSROOT)/make/validate.mk
  include $(DAPSROOT)/make/images.mk
  include $(DAPSROOT)/make/pdf.mk
endif

#---------------
# Profiling
#
ifeq "$(MAKECMDGOALS)" "profile"
  include $(DAPSROOT)/make/setfiles.mk
  include $(DAPSROOT)/make/profiling.mk
endif

#---------------
# Result names
#
NAMETARGETS := dist-webhelp-name epub-name html-dir-name man-dir-name mobi-name package-html-dir-name package-pdf-dir-name package-src-name pdf-name text-name webhelp-dir-name

ifeq "$(MAKECMDGOALS)" "$(filter $(MAKECMDGOALS),$(NAMETARGETS))"
  include $(DAPSROOT)/make/print_results.mk
endif

#---------------
# Text
#

ifeq "$(MAKECMDGOALS)" "text"
  include $(DAPSROOT)/make/setfiles.mk
  include $(DAPSROOT)/make/profiling.mk
  include $(DAPSROOT)/make/validate.mk
  include $(DAPSROOT)/make/text.mk
endif

#---------------
# Validating
#
ifeq "$(MAKECMDGOALS)" "validate"
  include $(DAPSROOT)/make/setfiles.mk
  include $(DAPSROOT)/make/profiling.mk
  include $(DAPSROOT)/make/validate.mk
endif

#---------------
# Webhelp
#
ifeq "$(MAKECMDGOALS)" "webhelp"
  include $(DAPSROOT)/make/setfiles.mk
  include $(DAPSROOT)/make/profiling.mk
  include $(DAPSROOT)/make/validate.mk
  include $(DAPSROOT)/make/images.mk
  include $(DAPSROOT)/make/webhelp.mk
endif


