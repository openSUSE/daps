# Copyright (C) 2012 SUSE Linux Products GmbH
#
# Author: Frank Sundermeyer
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
# get e.g. JSP specific values (rather than HTML) for the targets showvariable
# and daspenv
#
ifndef TARGET
  TARGET := $(firstword $(MAKECMDGOALS))
endif

#---------------
# DEFAULT INCLUDE
# common_variables.mk is _always_ needed
include $(DAPSROOT)/make/common_variables.mk

# On directory creation see:
# http://www.cmcrossroads.com/ask-mr-make/6936-making-directories-in-gnu-make
#
$(DIRECTORIES):
	mkdir -p $@


# Note on the ifeq statements below
# ifeq ($(foo),$(filter $(foo),<LIST>) is used to fake a logical "or"
# because $(filter $(foo),<LIST>) returns $foo, if it is part of 
# <LIST>

ifeq ($(MAKECMDGOALS),debug)
  include $(DAPSROOT)/make/setfiles.mk
endif

#---------------
# Clean
#
CLEANTARGETS := clean clean-images clean-package clean-results clean-all real-clean

ifeq ($(MAKECMDGOALS),$(filter $(MAKECMDGOALS),$(CLEANTARGETS)))
	include $(DAPSROOT)/make/clean.mk
endif

#---------------
# Debugging
#
DEBUGGINGTARGETS := dapsenv nothing showvariable

ifeq ($(MAKECMDGOALS),$(filter $(MAKECMDGOALS),$(DEBUGGINGTARGETS)))
  include $(DAPSROOT)/make/setfiles.mk
  include $(DAPSROOT)/make/profiling.mk
  include $(DAPSROOT)/make/validate.mk
  include $(DAPSROOT)/make/misc.mk
  include $(DAPSROOT)/make/images.mk
  include $(DAPSROOT)/make/filelist.mk
  include $(DAPSROOT)/make/meta.mk
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

ifeq ($(MAKECMDGOALS),$(filter $(MAKECMDGOALS),$(EPUBTARGETS)))
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
LISTTARGETS := list-images-missing list-images-multisrc list-srcfiles list-srcfiles-unused

ifeq ($(MAKECMDGOALS),$(filter $(MAKECMDGOALS),$(LISTTARGETS)))
  include $(DAPSROOT)/make/setfiles.mk
  include $(DAPSROOT)/make/images.mk
  include $(DAPSROOT)/make/filelist.mk
endif

#---------------
# HTML/HTMLSINGLE
#
HTMLTARGETS := html single-html

ifeq ($(MAKECMDGOALS),$(filter $(MAKECMDGOALS),$(HTMLTARGETS)))
  include $(DAPSROOT)/make/setfiles.mk
  include $(DAPSROOT)/make/profiling.mk
  include $(DAPSROOT)/make/validate.mk
  include $(DAPSROOT)/make/images.mk
  include $(DAPSROOT)/make/meta.mk
  include $(DAPSROOT)/make/html.mk
endif

#---------------
# Images
#

IMGTARGETS := optipng images

ifeq ($(MAKECMDGOALS),$(filter $(MAKECMDGOALS),$(IMGTARGETS)))
  include $(DAPSROOT)/make/setfiles.mk
  include $(DAPSROOT)/make/profiling.mk
  include $(DAPSROOT)/make/images.mk
endif

#---------------
# JSP
#
ifeq ($(MAKECMDGOALS),jsp)
  include $(DAPSROOT)/make/setfiles.mk
  include $(DAPSROOT)/make/profiling.mk
  include $(DAPSROOT)/make/validate.mk
  include $(DAPSROOT)/make/images.mk
  include $(DAPSROOT)/make/meta.mk
  include $(DAPSROOT)/make/html.mk
endif

#---------------
# MAN pages
#
ifeq ($(MAKECMDGOALS),man)
  include $(DAPSROOT)/make/setfiles.mk
  include $(DAPSROOT)/make/profiling.mk
  include $(DAPSROOT)/make/validate.mk
  include $(DAPSROOT)/make/misc.mk
  include $(DAPSROOT)/make/man.mk
endif

#---------------
# Miscellaneous
#
MISCTARGETS := bigfile checklink productinfo

ifeq ($(MAKECMDGOALS),$(filter $(MAKECMDGOALS),$(MISCTARGETS)))
  include $(DAPSROOT)/make/setfiles.mk
  include $(DAPSROOT)/make/profiling.mk
  include $(DAPSROOT)/make/validate.mk
  include $(DAPSROOT)/make/misc.mk
endif

#---------------
# Packaging
#
PACKAGETARGETS_HTML := dist-html dist-jsp dist-single-html package-html package-jsp
PACKAGETARGETS_PDF  := locdrop package-pdf

ifeq ($(MAKECMDGOALS),$(filter $(MAKECMDGOALS),$(PACKAGETARGETS_HTML)))
  include $(DAPSROOT)/make/setfiles.mk
  include $(DAPSROOT)/make/profiling.mk
  include $(DAPSROOT)/make/validate.mk
  include $(DAPSROOT)/make/images.mk
  include $(DAPSROOT)/make/html.mk
  include $(DAPSROOT)/make/packaging.mk
endif
ifeq ($(MAKECMDGOALS),$(filter $(MAKECMDGOALS),$(PACKAGETARGETS_PDF)))
  include $(DAPSROOT)/make/setfiles.mk
  include $(DAPSROOT)/make/profiling.mk
  include $(DAPSROOT)/make/validate.mk
  include $(DAPSROOT)/make/images.mk
  include $(DAPSROOT)/make/pdf.mk
  include $(DAPSROOT)/make/packaging.mk
endif
ifeq ($(MAKECMDGOALS),dist-webhelp)
  include $(DAPSROOT)/make/setfiles.mk
  include $(DAPSROOT)/make/profiling.mk
  include $(DAPSROOT)/make/validate.mk
  include $(DAPSROOT)/make/images.mk
  include $(DAPSROOT)/make/webhelp.mk
  include $(DAPSROOT)/make/packaging.mk
endif


ifeq ($(MAKECMDGOALS),online-docs)
  include $(DAPSROOT)/make/setfiles.mk
  include $(DAPSROOT)/make/profiling.mk
  include $(DAPSROOT)/make/validate.mk
  include $(DAPSROOT)/make/images.mk
  include $(DAPSROOT)/make/packaging.mk
  include $(DAPSROOT)/make/html.mk
  include $(DAPSROOT)/make/pdf.mk
  include $(DAPSROOT)/make/epub.mk
endif

ifeq ($(MAKECMDGOALS),package-src)
  include $(DAPSROOT)/make/setfiles.mk
  include $(DAPSROOT)/make/profiling.mk
  include $(DAPSROOT)/make/validate.mk
  include $(DAPSROOT)/make/images.mk
  include $(DAPSROOT)/make/packaging.mk
endif


#---------------
# PDF
#
PDFTARGETS := color-pdf pdf

ifeq ($(MAKECMDGOALS),$(filter $(MAKECMDGOALS),$(PDFTARGETS)))
  include $(DAPSROOT)/make/setfiles.mk
  include $(DAPSROOT)/make/profiling.mk
  include $(DAPSROOT)/make/validate.mk
  include $(DAPSROOT)/make/images.mk
  include $(DAPSROOT)/make/meta.mk
  include $(DAPSROOT)/make/pdf.mk
endif

#---------------
# Profiling
#
ifeq ($(MAKECMDGOALS),profile)
  include $(DAPSROOT)/make/setfiles.mk
  include $(DAPSROOT)/make/profiling.mk
endif

#---------------
# Result names
#
NAMETARGETS := color-pdf-name dist-html-name dist-jsp-name dist-webhelp-name epub-name html-dir-name jsp-dir-name man-dir-name mobi-name package-dir-name package-src-name pdf-name single-html-dir-name text-name webhelp-dir-name

ifeq ($(MAKECMDGOALS),$(filter $(MAKECMDGOALS),$(NAMETARGETS)))
  include $(DAPSROOT)/make/print_results.mk
endif

#---------------
# Text
#

ifeq ($(MAKECMDGOALS),text)
  include $(DAPSROOT)/make/setfiles.mk
  include $(DAPSROOT)/make/profiling.mk
  include $(DAPSROOT)/make/validate.mk
  include $(DAPSROOT)/make/images.mk
  include $(DAPSROOT)/make/html.mk
  include $(DAPSROOT)/make/text.mk
endif

#---------------
# Validating
#
ifeq ($(MAKECMDGOALS),validate)
  include $(DAPSROOT)/make/setfiles.mk
  include $(DAPSROOT)/make/profiling.mk
  include $(DAPSROOT)/make/validate.mk
endif

#---------------
# Webhelp
#
ifeq ($(MAKECMDGOALS),webhelp)
  include $(DAPSROOT)/make/setfiles.mk
  include $(DAPSROOT)/make/profiling.mk
  include $(DAPSROOT)/make/validate.mk
  include $(DAPSROOT)/make/images.mk
  include $(DAPSROOT)/make/webhelp.mk
endif


