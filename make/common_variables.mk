# Copyright (C) 2012-2020 SUSE Software Solutions Germany GmbH
#
# Author:
# Frank Sundermeyer  <fsundermeyer at opensuse dot org>
#
# Basic variable settings for DAPS
#
# Please submit feedback or patches to
# <fsundermeyer at opensuse dot org>
#

#--------------------------------------------------
# SHELL
#
# we make use of bash only syntax
#
#SHELL := /bin/bash -x
SHELL := /bin/bash

#--------------------------------------------------
# CHECKS
#
# Some variables need to be preset from the wrapper script
# Double-check whther they are set
#
ifndef BOOK
  $(error $(shell ccecho "error" "Fatal error: BOOK is not set"))
endif
ifndef BUILD_DIR
  $(error $(shell ccecho "error" "Fatal error: No path to build directory set"))
endif
ifndef DOC_DIR
  $(error $(shell ccecho "error" "Fatal error: No path to working directory set"))
endif
ifndef MAIN
  $(error $(shell ccecho "error" "Fatal error: No MAIN file set"))
endif
ifndef XSLTPROCESSOR
  $(error $(shell ccecho "error" "Fatal error: No XSLT processor file set"))
endif

#--------------------------------------------------
# SPACE REPLACEMENT / Newline / Comma
#
# If wanting to replace a " " with subst, a variable containing
# a space is needed, since it is not possible to replace a literal
# space (same goes for comma)
#
empty :=
SPACE := $(empty) $(empty)

COMMA := ,

define \n


endef

#--------------------------------------------------
# xmlstarlet
#
# Prior to openSUSE 13.2 the suse xmlstarlet package had /usr/bin/xml, while
# other distributions used /usr/bin/xmlstarlet

HAVE_XMLSTARLET := $(shell which xmlstarlet 2>/dev/null)

ifndef HAVE_XMLSTARLET
  XMLSTARLET := /usr/bin/xml
else
  XMLSTARLET := /usr/bin/xmlstarlet
endif

#--------------------------------------------------
# VERBOSITY
#

ifndef VERBOSITY
  VERBOSITY := 0
endif
ifneq "$(VERBOSITY)" "$(filter $(VERBOSITY),2 3)"
  DEVNULL     := >/dev/null
  ERR_DEVNULL := 2>/dev/null
endif

#--------------------------------------------------
# Build DIRECTORIES
#

RESULT_DIR         := $(BUILD_DIR)/$(BOOK)
TMP_DIR            := $(BUILD_DIR)/.tmp
PACK_DIR           := $(RESULT_DIR)/package

#-------
# PROFILE_PARENT_DIR
#
# The default location for the PROFILE_PARENT_DIR is $(BUILD_DIR)/.profiled
# However in some rare cases a special profiling is needed - ATM this is
# the case when setting a custom publication date (because this needs to be
# done during profiling). These specially profiled files need to be generated
# as intermediate files in tmp, otherwise the default profiles would have the
# custom pubdate, too.

ifdef SETDATE
  PROFILE_PARENT_DIR := $(TMP_DIR)/profiled
else
  PROFILE_PARENT_DIR := $(BUILD_DIR)/.profiled
endif

#-------
# PROFILE DIRECTORY SETTING
#
# If $MAIN contains a profiling PI
# <?xml-stylesheet href="urn:x-daps:xslt:profiling:??" ... >
# all xml files will be profiled to $PROFILE_PARENT_DIR/$PROFILEDIR
#
# If $MAIN does not contain a profiling PI
# all xml files will be linked to $PROFILE_PARENT_DIR/noprofile
#
# 1. Check for profiling PI in $MAIN:
#

# This has already been done in bin/daps

# 2. Set PROFILEDIR and profiling stringparams
#
# The directory name depends on the profiling values of the
# supported profiling attributes as listed at
# http://sagehill.net/docbookxsl/Profiling.html
# That setup allows to not have to redo profiling every time.
#

# Determine whether profiling is turned on and if so, set PROFILE_URN
# Add SETDATE here, because is set we need to do profiling as well to
# be able to set a custom date
#
IS_PROFILE := $(PROFARCH) $(PROFAUDIENCE) $(PROFCONDITION) \
  $(PROFCONFORMANCE) $(PROFLANG) $(PROFOS) $(PROFOUTPUTFORMAT) \
  $(PROFREVISION) $(PROFREVISIONFLAG) $(PROFROLE) $(PROFSECURITY) \
  $(PROFSTATUS) $(PROFUSERLEVEL) $(PROFVENDOR) $(PROFWORDSIZE) $(SETDATE)
ifneq "$(strip $(IS_PROFILE))" ""
  ifeq "$(strip $(DOCBOOK_VERSION))" "4"
    PROFILE_URN := $(DOCBOOK4_PROFILE_URN)
  else
    PROFILE_URN := $(DOCBOOK5_PROFILE_URN)
  endif
  ifdef PROFARCH
    PROFILEDIR := $(PROFILEDIR)_$(PROFARCH)
    PROFSTRINGS += --stringparam "profile.arch=$(PROFARCH)"
  endif
  ifdef PROFAUDIENCE
    PROFILEDIR := $(PROFILEDIR)_$(PROFAUDIENCE)
    PROFSTRINGS += --stringparam "profile.audience=$(PROFAUDIENCE)"
  endif
  ifdef PROFCONDITION
    PROFILEDIR := $(PROFILEDIR)_$(PROFCONDITION)
    PROFSTRINGS += --stringparam "profile.condition=$(PROFCONDITION)"
  endif
  ifdef PROFCONFORMANCE
    PROFILEDIR := $(PROFILEDIR)_$(PROFCONFORMANCE)
    PROFSTRINGS += --stringparam "profile.conformance=$(PROFCONFORMANCE)"
  endif
  ifdef PROFLANG
    PROFILEDIR := $(PROFILEDIR)_$(PROFLANG)
    PROFSTRINGS += --stringparam "profile.lang=$(PROFLANG)"
  endif
  ifdef PROFOS
    PROFILEDIR := $(PROFILEDIR)_$(PROFOS)
    PROFSTRINGS += --stringparam "profile.os=$(PROFOS)"
  endif
  ifdef PROFOUTPUTFORMAT
    PROFILEDIR := $(PROFILEDIR)_$(PROFOUTPUTFORMAT)
    PROFSTRINGS += --stringparam "profile.outputformat=$(PROFOUTPUTFORMAT)"
  endif
  ifdef PROFREVISION
    PROFILEDIR := $(PROFILEDIR)_$(PROFREVISION)
    PROFSTRINGS += --stringparam "profile.revision=$(PROFREVISION)"
  endif
  ifdef PROFREVISIONFLAG
    # Revisionflag only allows a fixed set of values
    ifneq "$(PROFREVISIONFLAG)" "$(filter $(PROFREVISIONFLAG),changed added deleted off)"
      $(error Invalid value for PROFREVISIONFLAG. Needs to be one of "added, changed, deleted, off")
    endif
    PROFILEDIR := $(PROFILEDIR)_$(PROFREVISIONFLAG)
    PROFSTRINGS += --stringparam "profile.revisionflag=$(PROFREVISIONFLAG)"
  endif
  ifdef PROFROLE
    PROFILEDIR := $(PROFILEDIR)_$(PROFROLE)
    PROFSTRINGS += --stringparam "profile.role=$(PROFROLE)"
  endif
  ifdef PROFSECURITY
    PROFILEDIR := $(PROFILEDIR)_$(PROFSECURITY)
    PROFSTRINGS += --stringparam "profile.security=$(PROFSECURITY)"
  endif
  ifdef PROFSTATUS
    PROFILEDIR := $(PROFILEDIR)_$(PROFSTATUS)
    PROFSTRINGS += --stringparam "profile.status=$(PROFSTATUS)"
  endif
  ifdef PROFUSERLEVEL
    PROFILEDIR := $(PROFILEDIR)_$(PROFUSERLEVEL)
    PROFSTRINGS += --stringparam "profile.userlevel=$(PROFUSERLEVEL)"
  endif
  ifdef PROFVENDOR
    PROFILEDIR := $(PROFILEDIR)_$(PROFVENDOR)
    PROFSTRINGS += --stringparam "profile.vendor=$(PROFVENDOR)"
  endif
  ifdef PROFWORDSIZE
    PROFILEDIR := $(PROFILEDIR)_$(PROFWORDSIZE)
    PROFSTRINGS += --stringparam "profile.wordsize=$(PROFWORDSIZE)"
  endif
  #
  # cleanup
  #
  # remove leading "_"
#  PROFILEDIR := $(shell echo "$(PROFILEDIR)" | cut -c2-)
  PROFILEDIR := $(patsubst _%,%,$(PROFILEDIR))

  # Profiling attributes can be entered as a semicolon separated list, we
  # need to replace the ";" with "_"
  # In case the attributes contain spaces, we need to replace them with "_"
  # as well, since make cannot cope with spaces in directory and filenames
  PROFILEDIR := $(subst ;,_,$(PROFILEDIR))
  PROFILEDIR := $(subst $(SPACE),_,$(PROFILEDIR))
  # replace illegal and unwanted characters with "_"
  PROFILEDIR := $(subst /,_,$(PROFILEDIR))
  PROFILEDIR := $(subst \,_,$(PROFILEDIR))
  PROFILEDIR := $(subst %,_,$(PROFILEDIR))
  PROFILEDIR := $(subst |,_,$(PROFILEDIR))
  PROFILEDIR := $(subst *,_,$(PROFILEDIR))
  PROFILEDIR := $(subst ?,_,$(PROFILEDIR))
else
  # no PROFILE_URN specified
  PROFILEDIR := noprofile
endif

#
# Also set to noprofile in case none of the profiling variables is set
# in order to avoid an empty PROFILEDIR variable
ifeq "$(strip $(PROFILEDIR))" ""
  PROFILEDIR := noprofile
endif

#
# if remarks is turned on, add corresponding strings
PROFILEDIR := $(PROFILEDIR)$(REMARK_STR)

#
# FINALLY, prefix PROFILEDIR with PROFILE_PARENT_DIR
PROFILEDIR := $(PROFILE_PARENT_DIR)/$(PROFILEDIR)


#
# profiled MAIN
PROFILED_MAIN := $(PROFILEDIR)/$(notdir $(MAIN))


#-------
# DAPS version string params
#
DAPSSTRINGS := --stringparam "converter.name=$(MY_NAME)" \
	--stringparam "converter.version=$(VERSION)" \
	--stringparam "converter.url=$(MY_URL)"


#-------
# Image Directories
#
IMG_GENDIR         := $(BUILD_DIR)/.images
ifneq "$(strip $(ADOC_IMG_DIR))" ""
  IMG_SRCDIR := $(BUILD_DIR)/.adoc_images/src
else
  IMG_SRCDIR         := $(DOC_DIR)/images/src
endif

IMG_GEN_DIRECTORIES := $(IMG_GENDIR)/gen/png \
                   $(IMG_GENDIR)/gen/svg \
                   $(IMG_GENDIR)/color $(IMG_GENDIR)/grayscale

# generate lists of all existing images
# Image formats: dia ditaa jpg odg png svg
#
SRCDIA      := $(wildcard $(IMG_SRCDIR)/dia/*.dia)
SRCDITAA    := $(wildcard $(IMG_SRCDIR)/ditaa/*.ditaa)
SRCJPG      := $(wildcard $(IMG_SRCDIR)/jpg/*.jpg)
SRCODG      := $(wildcard $(IMG_SRCDIR)/odg/*.odg)
SRCPNG      := $(wildcard $(IMG_SRCDIR)/png/*.png)
SRCSVG      := $(wildcard $(IMG_SRCDIR)/svg/*.svg)
SRC_IMG_ALL := $(SRCDIA) $(SRCDITAA) $(SRCJPG) $(SRCODG) $(SRCPNG) $(SRCSVG)

#-------
# List of all required directories
#
# If the following directories are not be present we have to create them
#
DIRECTORIES := $(PROFILEDIR) $(TMP_DIR) $(RESULT_DIR) $(IMG_GEN_DIRECTORIES)

#--------------------------------------------------
# FILENAMES
#
# DOCNAME: Filename of the resulting document
#

ifdef OUTPUTNAME
  DOCNAME   := $(OUTPUTNAME)
else
  ifdef ROOTID
    DOCNAME := $(ROOTID)
  else
    DOCNAME := $(BOOK)
  endif
endif

# Add REMARK_STR to the docname if the build was called with --remarks
# DRAFT_STR and META_STR do not affect profiling and are only relevant for
# HTML and PDF builds, so we will add it later
#
DOCNAME     := $(DOCNAME)$(REMARK_STR)


#--------------------------------------------------
# STYLESHEETS
#
# xslt stylsheets

# needed for targets bigfile and online docs
#
STYLEBIGFILE := $(DAPSROOT)/daps-xslt/common/reduce-from-set.xsl

# get language from xml:lang
STYLELANG      := $(DAPSROOT)/daps-xslt/common/get-language.xsl

# Not needed?
# for docbook to novdoc. Move? 
# STYLEDB2ND     := $(DAPSROOT)/daps-xslt/common/db2novdoc.xsl

# The original DocBook stylesheets are the default. They are set via bin/daps,
# which also automatically detects whether DocBook 4 or 5 is used (the
# stylesheets are set accordingly)
#
# The following variables let you use a custom stylesheet set in the DC file
#
# STYLEROOT         : path to stylesheet directory, mandatory
# FALLBACK_STYLEROOT: path to alternative stylesheet directory, optional
# HTML_CSS          : css file for HTML (full path), optional
# EPUB_CSS          : css file for EPUB (full path), optional
#
# A custom layout does not need to provide stylesheets for all targets
# If stylesheet subdirectories for a certain target are not found, we
# will fall back to the docbook stylesheets, or--if specified--to
# FALLBACK_STYLEROOT (with the docbook stylsheets remaining the last resort).
# This allows to only define custom stylesheets for e.g. FO but still
# being able to build e.g. HTML
#
# The subdirectory layout in each STYLEROOT directory needs to be the same as
# in the original DocBook stylesheet directories
#
STYLE_CUSTOM          := $(STYLEROOT)
#
# It only makes sense to set a custom fallback with a custom styleroot
#
ifdef STYLE_CUSTOM
  STYLE_CUSTOM_FALLBACK := $(FALLBACK_STYLEROOT)
endif
#
# Create a list with all stylesheet root directories. When setting the
# stylesheets to be used for the targets, the _first_ element from this
# list is used (firstword). As a consequence the ORDER is IMPORTANT!
#
# STYLEDEVEL, which can be set in $USER_CONFIG, is useful when devolping
# stylesheets. It always takes precedence over STYLEROOT.
#
STYLE_ROOTDIRS := $(wildcard $(STYLEDEVEL) $(STYLE_CUSTOM) \
		  $(STYLE_CUSTOM_FALLBACK) $(DOCBOOK_STYLES) )

#
# STYLEIMG needs to be defined in epub.mk, html.mk, pdf.mk, ... to make sure
# it is correctly set in case a fallback STYLEROOT is used

#--------------------------------------------------
# MISC
#

#-----
# rootid stringparam
#
# Always set ROOTID, but not with package-src, since we always want to handle
# the complete set with that target.
#
ifdef ROOTID
  ifneq "$(MAKECMDGOALS)" "package-src"
    ROOTSTRING   := --stringparam "rootid=$(ROOTID)"
  endif
endif

#-----
# Language
#
# get language string from $MAIN and transform "-" to "_"
# For use in filenames we keep the capitalization as is (LANGSTRING), for
# use in stylessheets we convert it to all lowercase (the same way the Docbook
# Stylesheets do)
#

XMLLANG ?= $(shell $(XSLTPROC) --stylesheet $(STYLELANG) --file $(MAIN) $(XSLTPROCESSOR) | tr - _ 2>/dev/null)

ifneq "$(strip $(XMLLANG))" ""
  LL ?= $(shell tr '[:upper:]' '[:lower:]' <<< $(XMLLANG) 2>/dev/null)
  LANGSTRING   := _$(XMLLANG)
endif

#-----
# graphics for html and webhelp
#
# By default graphics for the builds mentioned above are linked into the
# result directory. However, when prodicing the --static option they are copied
# into the result directory. Overwriting links by files with cp or overwriting
# files with links is not possible by default. Therefore we need
# --remove-destination
# (Using cp -rs rather than ln -sf because it only links files and creates
# the directories rather than linking the directories. The latter has the
# disadvantage tha one cannot write into adirectory that is just linked)
#
ifeq "$(STATIC_HTML)" "0"
  # copy directories recursively, create links on files
  HTML_GRAPH_COMMAND := cp -rsL --remove-destination
else
  # copy and resolve links
  HTML_GRAPH_COMMAND := cp -rL --remove-destination
endif

#-----
# locdrop
#
LOCDROP_TMP_DIR  := $(TMP_DIR)/$(BOOK)_locdrop
MANIFEST_TRANS   := $(LOCDROP_TMP_DIR)/$(DOCNAME)_manifest_trans.txt
MANIFEST_NOTRANS := $(LOCDROP_TMP_DIR)/$(DOCNAME)_manifest_notrans.txt

#-----
# define function to print filelists
# (used in filelist.mk and images.mk)
#

define print_list
  @if [[ -t 0 || 1 = "$(strip $(PRETTY_FILELIST))" ]]; then \
    echo -e "$(subst $(SPACE),\n,$(sort $(1)))"; \
  else \
    echo $(sort $(1)); \
  fi
endef

#-----
# define ccecho that is only displayed when the output
# goes to a terminal
#

define print_info
  @if [[ -t 0 ]]; then \
    ccecho "$(1)" "$(2)"; \
  fi
endef
