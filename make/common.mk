# Copyright (C) 2004 - 2011 SUSE Linux Products GmbH
#
# Authors:
# Jörg Arndt
# Berthold Gunreben <bg at suse dot de>
# Karl Eichwalder   <ke at suse dot de>
# Jana Jaeger      
# Thomas Schraitle  <toms at suse dot de>
# Frank Sundermeyer <fs at suse dot de>
#
# Please submit to feedback or patches to
# <fs at suse dot de> or <toms at suse dot de>
# 
# Make file to build "books" from DocBook XML sources
# Provides the core functionality for the daps package

#SHELL := /bin/bash -x
SHELL := /bin/bash

# If wanting to replace a " " with subst, a variable containing
# a space is needed, since it is not possible to replace a literal
# space (same goes for comma)
#
SPACE :=
SPACE +=

# Verbosity
#
#
ifndef VERBOSITY
  VERBOSITY := 0
endif
ifeq ($(VERBOSITY), 2)
  DEVNULL :=
else
  DEVNULL := >/dev/null
endif


#------------------------------------------------------------------------
# Paths

RESULT_DIR         := $(BUILD_DIR)/$(BOOK)
PROFILE_PARENT_DIR := $(BUILD_DIR)/.profiled
IMG_GENDIR         := $(BUILD_DIR)/.images
TMP_DIR            := $(BUILD_DIR)/.tmp

IMG_SRCDIR         := $(DOC_DIR)/images/src

#----------
#
# get the profiling stylesheet from $(MAIN)
#
# IMPORTANT:
# This profiling is used for _all_ documents from the set, regardless whether
# a single file contains different profiling information
# If $(MAIN) does not contain a link to a profiling stylesheet, no profiling
# will be used!
#
# ==> if PROFILE_URN is not set, no profiling will be done

ifndef PROFILE_URN
  GETXMLSTY    := $(DAPSROOT)/daps-xslt/common/get-xml-stylesheet.xsl
  PROFILE_URN     := $(shell xsltproc $(GETXMLSTY) $(MAIN))
endif

# PROFILEDIR is the directory where the profiled sources end up
# The directory name depends on the profiling values for the four
# supported profiling attributes arch, condition, os, and vendor.
#
# If everything would end up in one directory, the profiling would have to
# be redone every time.

ifdef PROFILE_URN
  PROFILEDIR := $(PROFILE_PARENT_DIR)/
  ifdef PROFARCH
    PROFILEDIR += $(subst ;,-,$(PROFARCH))_
  endif
  ifdef PROFCONDITION
    PROFILEDIR += $(subst ;,-,$(PROFCONDITION))_
  endif
  ifdef PROFOS
    PROFILEDIR += $(subst ;,-,$(PROFOS))_
  endif
  ifdef PROFVENDOR
    PROFILEDIR += $(subst ;,-,$(PROFVENDOR))
  endif
  PROFILEDIR += $(REMARK_STR)$(COMMENT_STR)
endif

# Use noprofile if PROFILEDIR is still undefined
#
ifndef PROFILEDIR
  PROFILEDIR  := $(PROFILE_PARENT_DIR)/noprofile
endif

# Remove spaces in PROFILEDIR that were introduced by using
# +=
PROFILEDIR := $(subst $(SPACE),,$(PROFILEDIR))


# profiled MAIN
PROFILED_MAIN := $(PROFILEDIR)/$(notdir $(MAIN))


#------------
# result paths

# TMP_BOOK is the filename for result files
# if PDFNAME is set (via --name) do not generate a name, but use PDFNAME
#
ifdef PDFNAME
  TMP_BOOK := $(PDFNAME)
  TMP_BOOK_NODRAFT := $(PDFNAME)
else
  ifndef ROOTID
    # the default:
    TMP_BOOK    := $(BOOK)$(REMARK_STR)$(COMMENT_STR)$(DRAFT_STR)
  else
   TMP_BOOK := $(ROOTID)$(REMARK_STR)$(COMMENT_STR)$(DRAFT_STR)
  endif
  # draft mode is only relevant for HTML and PDF
  TMP_BOOK_NODRAFT := $(subst _draft,,$(TMP_BOOK))
endif

# Path to temporary XML file (needed for bigfile, epub and man)
TMP_XML := $(TMP_DIR)/$(TMP_BOOK_NODRAFT).xml

# HTML / HTML-SINGLE
#
HTML_DIR := $(RESULT_DIR)/html/$(BOOK)$(REMARK_STR)$(COMMENT_STR)$(DRAFT_STR)

# WEBHELP
WEBHELP_DIR := $(RESULT_DIR)/webhelp/$(BOOK)$(REMARK_STR)$(COMMENT_STR)$(DRAFT_STR)

# JSP
JSP_DIR := $(RESULT_DIR)/jsp/$(BOOK)$(REMARK_STR)$(COMMENT_STR)$(DRAFT_STR)

# HTML/WEBHELP/JSP Graphics Copy Flags
# HTML/WEBHELP/JSP graphics are either linked (default) or copied
# (if STATIC_HTML is set)
#
# If a build already exists, we must ensure, a regular file can be overwritten
# with a link and a link can be overwritten with a normal file (both does not
# work by default). Calling cp with --remove-destination solves the problem
#
ifneq ($(STATIC_HTML), 1)
  # linking instead of copying
  HTML_GRAPH_COMMAND := cp -rL --remove-destination
else
  HTML_GRAPH_COMMAND += ln -sf
endif

# EPUB
# building epub with nwalsh's ruby scripts requires to create an intermediate
# xml file and have the images alongside this file in images/
# We want these files to be created in TMP_DIR. The epub file itslef will be
# created in RESULT_DIR
#
EPUB_TMP_DIR := $(TMP_DIR)/$(BOOK)/epub

# Desktop-Files
DESKTOP_FILES_DIR := $(TMP_DIR)/$(BOOK)/desktop

# Yelp files
YELP_DIR := $(TMP_DIR)/yelp

# Man pages
MAN_DIR := $(RESULT_DIR)/man

# Testpage for checking links in our books
TESTPAGE   ?= $(TMP_DIR)/$(TMP_BOOK)-links.html


# The following directories might not be present and therefore might have to
# be created
#
DIRECTORIES := $(PROFILEDIR) $(TMP_DIR) $(RESULT_DIR)

#------------------------------------------------------------------------
# Misc variables
#
#QUIET  ?=
USESVN := $(shell svn pg doc:maintainer $(MAIN) 2>/dev/null)


#-----------------------------------------------------------------------
# include layout

include $(DAPSROOT)/make/layout.mk

#------------------------------------------------------------------------
# xslt stylsheets

METAXSLT       := $(DAPSROOT)/daps-xslt/common/svn2docproperties.xsl
STYLEEXTLINK   := $(DAPSROOT)/daps-xslt/profiling/process-xrefs.xsl
STYLEREMARK    := $(DAPSROOT)/daps-xslt/common/get-remarks.xsl
STYLEROOTIDS   := $(DAPSROOT)/daps-xslt/common/get-rootids.xsl
STYLESEARCH    := $(DAPSROOT)/daps-xslt/common/search4includedfiles.xsl
STYLELANG      := $(DAPSROOT)/daps-xslt/common/get-language.xsl
STYLEDESK      := $(DAPSROOT)/daps-xslt/desktop/docbook.xsl
STYLE_DOCUMENT := $(DAPSROOT)/daps-xslt/yelp/docbook.xsl
STYLELINKS     := $(DAPSROOT)/daps-xslt/common/get-links.xsl
STYLEBURN      := $(DAPSROOT)/daps-xslt/common/reduce-from-set.xsl
STYLEINDEX     := $(DAPSROOT)/daps-xslt/index/xml2idx.xsl
STYLESEAIND    := $(DAPSROOT)/daps-xslt/common/search4index.xsl
STYLEEPUBDB    := $(DAPSROOT)/daps-xslt/epub/db2db.xsl
STYLEDB2ND     := $(DAPSROOT)/daps-xslt/common/db2novdoc.xsl

#------------------------------------------------------------------------
# xslt stringparams
#
# CAUTION: When value is a directory path, it MUST ALWAYS end with
#          a trailing slash


#----------
# Common stringparams
#

# rootid
ifdef ROOTID
  ROOTSTRING   := --stringparam rootid "$(ROOTID)"
endif

# meta information (author, last changed, etc)
ifeq ($(USEMETA), 1)
  METASTRING   := --stringparam use.meta 1
endif

#----------
# FO stringparams
#  fostrings:    b/w pdf
#  focolstrings: color pdf

FOSTRINGS    := --stringparam show.comments $(COMMENTS) \
                --stringparam draft.mode "$(DRAFT)" \
	        --stringparam show.remarks $(REMARKS) \
                --stringparam format.print 1 \
                --stringparam callout.graphics.path \
                  "$(USED_STYLEDIR)/images/callouts/" \
	        --stringparam img.src.path "$(IMG_GENDIR)/print/" \
                --stringparam styleroot "$(USED_STYLEDIR)/" \
		--param ulink.show 1

FOCOLSTRINGS := --stringparam show.comments $(COMMENTS) \
                --stringparam draft.mode "$(DRAFT)" \
	        --stringparam show.remarks $(REMARKS) \
                --stringparam use.xep.cropmarks 0 \
                --stringparam format.print 0 \
                --stringparam callout.graphics.path \
                  "$(USED_STYLEDIR)/images/callouts/" \
	        --stringparam img.src.path "$(IMG_GENDIR)/online/" \
                --stringparam styleroot "$(USED_STYLEDIR)/" \
		--param ulink.show 1

# root directory for custom stylesheets
# see layout.mk

# index
# returns "Yes" if index is used
INDEX       := $(shell xsltproc --xinclude $(ROOTSTRING) \
		$(STYLESEAIND) $(MAIN) 2>/dev/null)
INDEXSTRING := --stringparam indexfile $(TMP_BOOK).ind

# FO formatter specific stuff
# currently supported are xep and fop
#
ifeq ($(FORMATTER), fop)
  FOCOLSTRINGS  += --stringparam fop1.extensions 1 \
                   --stringparam xep.extensions 0
  FOSTRINGS     += --stringparam fop1.extensions 1 \
                   --stringparam xep.extensions 0
endif

ifeq ($(FORMATTER), xep)
  FOCOLSTRINGS  += --stringparam fop1.extensions 0 \
                   --stringparam xep.extensions 1
  FOSTRINGS     += --stringparam fop1.extensions 0 \
                   --stringparam xep.extensions 1
endif

#----------
# HTML stringparams
#  
#

HTMLSTRINGS  := --stringparam base.dir $(HTML_DIR)/ \
                --stringparam show.comments $(COMMENTS) \
		--stringparam draft.mode "$(DRAFT)" \
	        --stringparam show.remarks $(REMARKS) \
                --stringparam admon.graphics.path "style_images/" \
                --stringparam admon.graphics 1 \
                --stringparam navig.graphics.path "style_images/" \
                 --stringparam navig.graphics 1 \
                --stringparam callout.graphics.path "style_images/callouts/" \
                --stringparam img.src.path "images/"


ifdef HTMLROOT
  HROOTSTRING  := --stringparam provo.root "$(HTMLROOT)"
endif
ifdef USEXHTML
  XHTMLSTRING  := --stringparam generate.jsp.marker 0
endif

#----------
# Webhelp stringparams
#  
#

WEBHELPSTRINGS := --stringparam base.dir $(WEBHELP_DIR)/ \
                  --stringparam show.comments $(COMMENTS) \
	          --stringparam draft.mode "$(DRAFT)" \
	          --stringparam show.remarks $(REMARKS) \
                  --stringparam admon.graphics.path "style_images/" \
                  --stringparam admon.graphics 1 \
                  --stringparam admon.graphics.extension ".png" \
                  --stringparam navig.graphics.path "style_images/" \
                  --stringparam navig.graphics 0 \
                  --stringparam navig.graphics.extension ".png" \
                  --stringparam callout.graphics.path "style_images/callouts/" \
                  --stringparam callout.graphics.extension ".png" \
                  --stringparam img.src.path "images/" \
                  --stringparam webhelp.common.dir "common/" \
                  --stringparam webhelp.start.filename "index.html"

ifeq ("$(WH_SEARCH)", "no")
  WEBHELPSTRINGS += --stringparam webhelp.include.search.tab "false"
endif

# Remove these once we have desent custom stylesheets
WEBHELPSTRINGS += --stringparam chunk.fast 1 \
                  --stringparam chunk.section.depth 0

#----------
# JSP stringparams
#  
#
JSPSTRINGS   := --stringparam base.dir $(JSP_DIR)/ \
                --stringparam show.comments $(COMMENTS) \
		--stringparam draft.mode "$(DRAFT)" \
                --stringparam show.remarks $(REMARKS) \
                --stringparam admon.graphics.path "style_images/" \
                --stringparam admon.graphics 1 \
                --stringparam navig.graphics.path "style_images/" \
                 --stringparam navig.graphics 1 \
                --stringparam callout.graphics.path "style_images/callouts/" \
                --stringparam img.src.path "images/"


#----------
# man page stringparams
#  
#

MANSTRINGS   := --stringparam man.output.base.dir "$(MAN_DIR)/" \
		--stringparam refentry.meta.get.quietly 1 \
		--stringparam man.output.in.separate.dir 1
ifeq ("$(MAN_SUBDIRS)", "yes")
  MANSTRINGS  += --stringparam man.output.subdirs.enabled 1
else
  MANSTRINGS  += --stringparam man.output.subdirs.enabled 0
endif



#----------
# Profiling stringparams
#
ifdef PROFILE_URN
  PROFSTRINGS :=
  ifdef PROFARCH
    PROFSTRINGS += --stringparam profile.arch "$(PROFARCH)"
  endif
  ifdef PROFCONDITION
    PROFSTRINGS += --stringparam profile.condition "$(PROFCONDITION)"
  endif
  ifdef PROFOS
    PROFSTRINGS += --stringparam profile.os "$(PROFOS)"
  endif
  ifdef PROFVENDOR
    PROFSTRINGS += --stringparam profile.vendor "$(PROFVENDOR)"
  endif
endif


#----------
# Desktop file stringparams
#
# Language
LL           ?= $(shell xsltproc --nonet $(STYLELANG) $(MAIN))

WEBHELPSTRINGS +=  --stringparam webhelp.indexer.language $(LL)

DESKSTRINGS  := --stringparam uselang "$(LL)" \
	        --stringparam docpath "@PATH@/" \
                --stringparam base.dir $(DESKTOP_FILES_DIR)/


#------------------------------------------------------------------------

# find all xml files in subdirectory xml
# and generate profile targets
#SRCFILES    := $(wildcard $(DOC_DIR)/xml/*.xml)

# find all xml files for the current set and generate profile targets
#
# xsltproc call does not put out $MAIN, this needs to be added
# separately
#
# daps-xslt/common/get-all-used-files.xsl creates an XML "file" with a list
# of all xml and image files and their corresponding ids for the whole
# set taking profiling into account. Generating this list is very time
# consuming and is the _one_ factor that determines the initialization
# of this makefile.
# Therefor we absolutely want to make sure it is only called once!
# We achieve this by writing this XML "file" to a variable that can be used
# as an input source for the actual file list generating stylesheet
# (extract-files-and-images.xsl).
# That stylesheet only takes a few miliseconds to execute, so we can afford to
# run it multiple times (SRCFILES, USED, projectfiles).
#
# In order to be able to pipe SETFILES via echo to extract-files-and-images.xsl
# we need to replace double quotes by single quotes (cannot be done with
# xsltproc)
#
SETFILES     := $(shell xsltproc $(PROFSTRINGS) \
		  --stringparam xml.src.path "$(DOC_DIR)/xml/" \
		  --stringparam mainfile $(notdir $(MAIN)) \
		  $(DAPSROOT)/daps-xslt/common/get-all-used-files.xsl \
		  $(MAIN)  | tr \" \')

# XML source files for the whole set
#
SRCFILES     := $(sort $(shell echo "$(SETFILES)" | xsltproc \
		  --stringparam xml.or.img xml \
		  $(DAPSROOT)/daps-xslt/common/extract-files-and-images.xsl - ))

# XML source files for the currently used document (defined by teh rootid)
#
ifdef ROOTSTRING
  DOCFILES  := $(shell echo "$(SETFILES)" | xsltproc $(ROOTSTRING) \
		--stringparam xml.or.img xml \
		$(DAPSROOT)/daps-xslt/common/extract-files-and-images.xsl - )
else
  DOCFILES  := $(SRCFILES)
endif

PROFILES    := $(subst $(DOC_DIR)/xml/,$(PROFILEDIR)/,$(SRCFILES))
DISTPROFILE := $(subst $(DOC_DIR)/xml/,$(PROFILE_PARENT_DIR)/dist/,$(SRCFILES))


#------------------------------------------------------------------------

USED_LC     := $(shell echo $(USED) | tr [:upper:] [:lower:] )
WRONG_CAP   := $(filter-out $(USED_LC), $(USED))

#------------------------------------------------------------------------
# Include the other make files
#
include $(DAPSROOT)/make/images.mk
include $(DAPSROOT)/make/package.mk
#include $(DAPSROOT)/make/variables.mk
#include $(DAPSROOT)/make/obb.mk

#------------------------------------------------------------------------
#
# define the targets for building books
#
#--------------
# PDF (default)
#
.PHONY: all pdf
all pdf: | $(DIRECTORIES)
all pdf: missing-images $(PROFILEDIR)/.validate
all pdf: $(RESULT_DIR)/$(TMP_BOOK)-print_$(LL).pdf
	@ccecho "result" "PDF book built with REMARKS=$(REMARKS), COMMENTS=$(COMMENTS) and DRAFT=$(DRAFT):\n$<"


#--------------
# COLOR-PDF
#
.PHONY: color-pdf pdf-color
pdf-color color-pdf: | $(DIRECTORIES)
pdf-color color-pdf: missing-images $(PROFILEDIR)/.validate
pdf-color color-pdf: $(RESULT_DIR)/$(TMP_BOOK)_$(LL).pdf
	@ccecho "result" "COLOR-PDF book built with REMARKS=$(REMARKS), COMMENTS=$(COMMENTS) and DRAFT=$(DRAFT):\n$<"

#--------------
# HTML
#
.PHONY: html
html: | $(DIRECTORIES)
html: $(PROFILEDIR)/.validate missing-images $(HTML_DIR)/index.html
	@ccecho "result" "HTML book built with REMARKS=$(REMARKS), COMMENTS=$(COMMENTS), DRAFT=$(DRAFT) and USEMETA=$(USEMETA):\nfile://$(HTML_DIR)/index.html"

#--------------
# HTML-SINGLE
#
.PHONY: html-single htmlsingle
html-single htmlsingle: | $(DIRECTORIES)
html-single htmlsingle: missing-images
html-single htmlsingle: $(PROFILEDIR)/.validate $(HTML_DIR)/$(BOOK).html
	@ccecho "result" "HTML-SINGLE book built with REMARKS=$(REMARKS), COMMENTS=$(COMMENTS) and DRAFT=$(DRAFT):\nfile://$(HTML_DIR)/$(BOOK).html\033[m\017"

#--------------
# WEBHELP
#
.PHONY: webhelp
webhelp: | $(DIRECTORIES)
webhelp: missing-images
webhelp: $(PROFILEDIR)/.validate missing-images $(WEBHELP_DIR)/$(BOOK).html
	@ccecho "result" "Webhelp book built with REMARKS=$(REMARKS), COMMENTS=$(COMMENTS), DRAFT=$(DRAFT) and USEMETA=$(USEMETA):\nfile://$(WEBHELP_DIR)/$(BOOK).html"


#--------------
# JSP
#
.PHONY: jsp
jsp: | $(DIRECTORIES)
jsp: $(JSP_DIR)
jsp: $(PROFILEDIR)/.validate missing-images $(JSP_DIR)/index.jsp
	@ccecho "result" "Find the JSP book at:\nfile://$(JSP_DIR)/index.jsp"

#--------------
# TXT
#
.PHONY: txt text
txt text: | $(DIRECTORIES)
txt text: $(RESULT_DIR)/$(TMP_BOOK_NODRAFT).txt
	@ccecho "result" "Find the TXT book at:\n$(RESULT_DIR)/$(TMP_BOOK_NODRAFT).txt"

#--------------
# EPUB
#
.PHONY: epub
epub: | $(DIRECTORIES)
epub: missing-images
epub: $(PROFILEDIR)/.validate $(RESULT_DIR)/$(TMP_BOOK_NODRAFT).epub
  ifeq ("$(EPUBCHECK)", "yes")
    epub: epub-check
  endif
	@ccecho "result" "Find the EPUB book at:\n$(RESULT_DIR)/$(TMP_BOOK_NODRAFT).epub"

#--------------
# WIKI
#
.PHONY: wiki
wiki: | $(DIRECTORIES)
wiki: $(PROFILEDIR)/.validate $(RESULT_DIR)/$(TMP_BOOK_NODRAFT).wiki
	@ccecho "result" "Find the WIKI book at:\n$(RESULT_DIR)/$(TMP_BOOK_NODRAFT).wiki"

#--------------
# MAN
#
$(MAN_DIR): | $(DIRECTORIES)
	mkdir -p $@

# The problem with man page generation is that multiple man
# pages may be generated with a single xsltproc call and that
# the stylesheet defines name and output directories (following
# the naming conventions for man pages)
# Therefore we need that ugly for loop

.PHONY: man
man: | $(DIRECTORIES)
man: $(MAN_DIR) $(PROFILEDIR)/.validate $(TMP_XML)
man: MAN_RESULTS = $(shell xsltproc --xinclude $(MANSTRINGS) $(DAPSROOT)/daps-xslt/common/get-manpage-filename.xsl $(MAIN))
man:
	xsltproc $(ROOTSTRING) --xinclude $(MANSTRINGS) $(STYLEMAN) $(TMP_XML)
  ifneq ("$(GZIP_MAN)", "no")
	for file in $(MAN_RESULTS); do \
	  gzip -f $$file; \
	done
	@ccecho "result" "Find the man page(s) at:\n$(addsuffix .gz,$(MAN_RESULTS))"	
  else
	@ccecho "result" "Find the man page(s) at:\n$(MAN_RESULTS)"
  endif

#--------------
# FORCE
#
.PHONY: force
force: | $(DIRECTORIES)
force: $(PROFILEDIR)/.validate
	touch $(MAIN)
	rm -f $(TMP_DIR)/$(TMP_BOOK)-$(FORMATTER).fo # pdf only!
	$(MAKE) pdf

#------------------------------------------------------------------------
#
# define other often used targets
#

#--------------
# profiling
#
.PHONY: prof profile
prof profile: | $(DIRECTORIES)
prof profile: $(PROFILES)

#--------------
# validating
#
# Use xmllint for DocBook 4 and jing for DocBook 5
# (xmllint -> DTD, jing Relax NG)

.PHONY: validate
$(PROFILEDIR)/.validate validate: $(PROFILES) missing-images
  ifeq ($(VERBOSITY), 1)
	@echo "   Validating..."
  endif
  ifeq ($(DOCBOOK_VERSION), 4)
	xmllint --noent --postvalid --noout --xinclude $(PROFILED_MAIN)
  else
	ADDITIONAL_FLAGS="$(JING_FLAGS)" jing $(DOCBOOK5_RNG_URI) \
	  $(PROFILED_MAIN)
  endif
	touch $(PROFILEDIR)/.validate
#	@echo "checking for unexpected characters: ... "
#	egrep -n "[^[:alnum:][:punct:][:blank:]]" $(SRCFILES) && \
#	    echo "Found non-printable characters" || echo "OK"
	@ccecho "info" "All files are valid.";


#--------------
# cleaning up
#
.PHONY: clean
clean:
	rm -rf $(PROFILE_PARENT_DIR)/*
	rm -rf $(TMP_DIR)/*
	@ccecho "info" "Successfully removed all profiled and temporary files."

.PHONY: clean-images
clean-images:
	find $(IMG_GENDIR) -type f 2>/dev/null | xargs rm -f
	@ccecho "info" "Successfully removed all generated images."

.PHONY: clean-results
clean-results:
	rm -rf $(RESULT_DIR)/*
	@ccecho "info" "Successfully removed all generated books"

.PHONY: clean-all real-clean
clean-all real-clean:
	rm -rf $(BUILD_DIR)/.[^.]* $(BUILD_DIR)/*
	@ccecho "info" "Successfully removed all generated content"

#--------------
# file lists

# Files used in $BOOK
#
#

.PHONY: projectfiles
projectfiles: $(DOCFILES)
projectfiles: ENTITIES := $(shell $(LIBEXEC_DIR)/getentityname.py $(DOCFILES))
projectfiles: FILES    := $(addprefix $(DOC_DIR)/xml/, $(ENTITIES)) \
			   $(DOCCONF) $(DOCFILES)
projectfiles:
  ifeq ($(PRETTY_FILELIST), 1)
	@echo -e "$(subst $(SPACE),\n,$(sort $(FILES)))"
  else
	@echo $(sort $(FILES))
  endif

# Files _not_ used in $BOOK
#
.PHONY: remainingfiles
remainingfiles: $(DOCFILES)
remainingfiles: ENTITIES := $(shell $(LIBEXEC_DIR)/getentityname.py $(DOCFILES))
remainingfiles: FILES    := $(filter-out \
			     $(addprefix $(DOC_DIR)/xml/, $(ENTITIES)) \
			     $(DOCCONF) $(DOCFILES), $(SRCFILES))
remainingfiles:
  ifeq ($(PRETTY_FILELIST), 1)
	@echo  -e "$(subst $(SPACE),\n,$(sort $(FILES)))"
  else
	@echo $(sort $(FILES))
  endif

# Source graphics used for $BOOK/ROOTID
#
.PHONY: projectgraphics
projectgraphics: FILES := $(USED_SVG) $(USED_PNG) $(USED_DIA) $(USED_FIG)
projectgraphics:
  ifeq ($(PRETTY_FILELIST), 1)
	@echo -e "$(subst $(SPACE),\n,$(sort $(FILES)))"
  else
	@echo $(sort $(FILES))
  endif

# Source graphics _not_ used for $BOOK/ROOTID
#
.PHONY: remaininggraphics
remaininggraphics: INCLUDED := $(filter-out $(USED_SVG) $(USED_PNG) \
				$(USED_DIA) $(USED_FIG), \
				$(SRCPNG) $(SRCSVG) $(SRCFIG) $(SRCDIA))
remaininggraphics:
  ifeq ($(PRETTY_FILELIST), 1)
	@echo -e "$(subst $(SPACE),\n,$(sort $(FILES)))"
  else
	@echo $(sort $(FILES))
  endif

# Graphics as linked in xml sources
# (if a file exists as foo.svg but the xml sources contain a link to foo.png
#  foo.svg will automatically be converted to foo.png)
# Target projectgraphics shows the source files being present in $(IMG_SRCDIR)
# while this target shows which files are actually used
#
# xmlgraphics -> color images only
#
.PHONY: xmlgraphics
xmlgraphics: provide-images provide-color-images
  ifeq ($(PRETTY_FILELIST), 1)
	@echo -e "$(subst $(SPACE),\n,$(sort $(SVGONLINE) $(PNGONLINE)))"
  else
	@echo $(sort $(SVGONLINE) $(PNGONLINE))
  endif

# xmlgraphics-bw -> b/w images only
#
.PHONY: xmlgraphics-bw
xmlgraphics-bw: provide-images
  ifeq ($(PRETTY_FILELIST), 1)
	@echo -e "$(subst $(SPACE),\n,$(sort $(SVGPRINT) $(PNGPRINT)))"
  else
	@echo $(sort $(SVGPRINT) $(PNGPRINT))
  endif

# Graphics missing in $BOOK
#
.PHONY: missinggraphics
missinggraphics:
  ifdef MISSING
	@ccecho "warn" "The following graphics are missing:"
    ifeq ($(PRETTY_FILELIST), 1)
	@echo -e "$(subst $(SPACE),\n,$(sort $(MISSING)))"
    else
	@echo "$(MISSING)"
    endif
  else
	@ccecho "info" "Graphics complete"
  endif

#--------------
# Bigfiles
# Useful for complex validation problems
#
.PHONY: bigfile
bigfile: $(TMP_XML)
	xmllint --noent --valid --noout $(TMP_XML)
	@ccecho "result" "Find the bigfile at:\n$(TMP_XML)"

.PHONY: bigfile-reduced
bigfile-reduced: $(TMP_XML)
	xsltproc --output $(TMP_DIR)/$(BOOK)-reduced.xml $(ROOTSTRING) \
	  $(STYLEBURN) $< 
	xmllint --noent --valid --noout $(TMP_DIR)/$(BOOK)-reduced.xml
	@ccecho "result" "Find the reduced bigfile at:\n$(TMP_DIR)/$(BOOK)-reduced.xml"


#------------------------------------------------------------------------
#
# dist targets
#
# Question:
# Do we want to package sources that may not validate? Adding a dependency on
# $(PROFILEDIR)/.validate will prevent us from doing so

#--------------
# dist: create b/w PDFs for all chapters 
#
.PHONY: dist
dist: ROOTIDS = $(shell xsltproc --xinclude $(STYLEROOTIDS) \
		$(PROFILED_MAIN))
dist: | $(DIRECTORIES)
dist: $(PROFILEDIR)/.validate
	for i in $(ROOTIDS); do \
	    make pdf ROOTID=$$i; \
	done

#--------------
# dist-xml:

# create tarball with xml files for the _whole set_ plus entity declaration
# files and the DC-file that is sourced. Such an archive is needed to
# distribute a book. Only packaging the book itself is not sufficient, because
# it may link into other books of the set and therefore need sources from
# the whole set in order to properly build.
#
# The major problem when creating dist-xml and dist-book are the entities.
# On the one hand we want to package profiled sources, but on the other
# hand we don't want those sources to come with original entities rather than
# resolved ones ( "&prodcut;" instead of "openSUSE"). Unfortunately entities
# _are_ resolved during profiling, so we need to recover them and modify
# the profiled sources after profiling.
# Therefore we cannot use the profiled sources from $PROFILEDIR directly, but
# will create prolifeled sources with recovered entities in
# $(PROFILE_PARENT_DIR)/dist/
#
# TODO:
# Whenever a file gets profiled, its header is being rewritten to out
# standard NOVDOC header including an entity link to entity-decl.ent
# This may not want we want, espacially if the original header was DOCBOOK
# and/or included "manual" entity declaration (they will simply be overwritten) 
#
# $(PROFILE_PARENT_DIR)/dist/ is an intermediate directory, therefore the files
# will always be deleted and freshly created each time. This is wanted and
# needed
#
.PHONY: dist-xml
dist-xml: $(DISTPROFILE)
dist-xml: link-entity-dist
dist-xml: INCLUDED = $(sort $(addprefix $(PROFILE_PARENT_DIR)/dist/,\
			$(shell xsltproc --nonet --xinclude $(STYLESEARCH) \
			$(PROFILE_PARENT_DIR)/dist/$(notdir $(MAIN))) \
			$(notdir $(MAIN))))
dist-xml: ENTITIES = $(shell $(LIBEXEC_DIR)/getentityname.py $(INCLUDED))
dist-xml: TARBALL  = $(RESULT_DIR)/$(BOOK)_$(LL).tar
dist-xml:
  ifeq ($(VERBOSITY),1)
	@echo "   Creating tarball..."
  endif
	tar chf $(TARBALL) --absolute-names \
	  --transform=s%$(PROFILE_PARENT_DIR)/dist%xml% $(INCLUDED)
	tar rhf $(TARBALL)  --absolute-names --transform=s%$(DOC_DIR)/%% \
	  $(DOCCONF) $(addprefix $(DOC_DIR)/xml/,$(ENTITIES))
	bzip2 -9f $(TARBALL)
	@ccecho "result" "Find the tarball at:\n$(TARBALL).bz2"

#--------------
# dist-book: Create an archive with profiled xml, DC-file, and entity
# declarations. Entities in xml sources are preserved, see explanation
# on dist-xml target
#
.PHONY: dist-book
dist-book: $(DISTPROFILE)
dist-book: link-entity-dist
dist-book: INCLUDED = $(sort $(addprefix $(PROFILE_PARENT_DIR)/dist/,\
			$(shell xsltproc --nonet $(ROOTSTRING) \
			--xinclude $(STYLESEARCH) \
			$(PROFILE_PARENT_DIR)/dist/$(notdir $(MAIN))) \
			$(notdir $(MAIN))))
dist-book: ENTITIES = $(shell $(LIBEXEC_DIR)/getentityname.py $(INCLUDED))
dist-book: TARBALL  = $(RESULT_DIR)/$(BOOK)_$(LL).tar
dist-book:
  ifeq ($(VERBOSITY),1)
	@echo "   Creating tarball..."
  endif
	tar chf $(TARBALL) --absolute-names \
	  --transform=s%$(PROFILE_PARENT_DIR)/dist%xml% $(INCLUDED)
	tar rhf $(TARBALL) --absolute-names --transform=s%$(DOC_DIR)/%% \
	  $(DOCCONF) $(addprefix $(DOC_DIR)/xml/,$(ENTITIES))
	bzip2 -9f $(TARBALL)
	@ccecho "result" "Find the tarball at:\n$(TARBALL).bz2"

#--------------
# dist-graphics
# always packs the colour images provided by provide-color-images. It generates
# them in $IMG_GENDIR/{png,svg}. However, in the tarball we need to rewrite
# this directory to images/src/{png,svg}, because this is the place graphics
# need to be when starting a project 
#
# In order to properly calculate the USED* variables from the original XML
# sources, we need to have an up-to-date profiled version of these sources.
# This requires a "make profile" run before make dist-graphics! The daps
# wrapper script automatically takes care of it
#
.PHONY: dist-graphics
dist-graphics: provide-color-images
dist-graphics: TARBALL = $(RESULT_DIR)/$(TMP_BOOK)_$(LL)-graphics.tar
dist-graphics:
  ifdef USED
    ifeq ($(VERBOSITY),1)
	@echo "   Creating tarball..."
    endif
    ifdef PNGONLINE
	tar rhf $(TARBALL) --exclude-vcs --ignore-failed-read \
	  --absolute-names --transform=s%$(IMG_GENDIR)/online%images/src/png% \
	  $(PNGONLINE);
    endif
    # also add SVGs if available
    ifdef SVGONLINE
	tar rhf $(TARBALL) --exclude-vcs --ignore-failed-read \
	  --absolute-names --transform=s%$(IMG_GENDIR)/online%images/src% \
	  $(SVGONLINE)
    endif
    ifdef PDFONLINE
	tar rhf $(TARBALL) --exclude-vcs --ignore-failed-read \
	  --absolute-names --transform=s%$(IMG_GENDIR)/online%images/src% \
	  $(PDFONLINE)
    endif
	bzip2 -9f $(TARBALL)
	@ccecho "result" "Find the tarball at:\n$(TARBALL).bz2"
  else
	@ccecho "info" "Selected book contains no graphics"
  endif

#--------------
# dist-graphics-png
# creates an archive with all graphics in png format
#
.PHONY: dist-graphics-png
dist-graphics-png: provide-color-images
dist-graphics-png: TARBALL = $(RESULT_DIR)/$(TMP_BOOK)_$(LL)-png-graphics.tar.bz2
dist-graphics-png:
  ifdef PNGONLINE
    ifeq ($(VERBOSITY),1)
	@echo "   Creating tarball..."
    endif
	BZIP2=--best \
	tar cjhf $(TARBALL) --exclude-vcs --ignore-failed-read \
	  --absolute-names --transform=s%$(IMG_GENDIR)/online%images/src/png% \
	  $(sort $(PNGONLINE))
	@ccecho "result" "Find the tarball at:\n$(TARBALL)"
  else
	@ccecho "info" "Selected book contains no graphics"
  endif

#--------------
# dist-html
#
# creates a tarball with the HTML version of the book including
# all needed images and css
#
#

.PHONY: dist-html
dist-html: MANIFEST  = --stringparam manifest $(HTML_DIR)/HTML.manifest \
		       --param generate.manifest 1
dist-html: TARBALL   = $(RESULT_DIR)/$(TMP_BOOK)_$(LL)-html.tar.bz2
dist-html: HTML-USED = $(subst $(IMG_GENDIR)/online/,$(HTML_DIR)/images/,$(sort $(PNGONLINE)))
dist-html: $(PROFILES) $(PROFILEDIR)/.validate $(HTML_DIR)/index.html
dist-html: provide-color-images
  ifeq ($(VERBOSITY),1)
	@echo "   Creating tarball..."
  endif
	BZIP2=--best \
	tar cjhf $(TARBALL) --exclude-vcs --no-recursion \
	  -T $(HTML_DIR)/HTML.manifest \
	  --absolute-names --transform=s%$(RESULT_DIR)/html/%% \
	  $(HTML-USED) $(HTML_DIR)/index.html $(HTML_DIR)/style_images/* \
	  $(HTML_DIR)/$(notdir $(STYLE_HTMLCSS))
	@ccecho "result" "Find the tarball at:\n$(TARBALL)"


#---------------
# dist-htmlsingle
#
# creates a tarball with the HTML version of the book including
# all needed images and css
#
.PHONY: dist-htmlsingle dist-html-single
dist-htmlsingle dist-html-single: TARBALL   = $(RESULT_DIR)/$(TMP_BOOK)_$(LL)-htmlsingle.tar.bz2
dist-htmlsingle dist-html-single: HTML-USED = $(addprefix $(HTML_DIR)/images/,$(USED))
dist-htmlsingle dist-html-single: $(PROFILES) $(PROFILEDIR)/.validate
dist-htmlsingle dist-html-single: $(HTML_DIR)/$(BOOK).html
  ifeq ($(VERBOSITY),1)
	@echo "   Creating tarball..."
  endif
	BZIP2=--best \
	tar cjhf $(TARBALL) --exclude-vcs --no-recursion \
	  --absolute-names --transform=s%$(RESULT_DIR)/html/%% \
	  $(HTML_DIR)/$(BOOK).html $(HTML-USED) $(HTML_DIR)/style_images/* \
	  $(HTML_DIR)/$(notdir $(STYLE_HTMLCSS))
	@ccecho "result" "Find the tarball at:\n$(TARBALL)"

#---------------
# dist-jsp
#
# creates a tarball with the JSP version of the book including
# all needed images and css
#
.PHONY: dist-jsp
dist-jsp: MANIFEST = --stringparam manifest $(JSP_DIR)/JSP.manifest \
		     --param generate.manifest 1
dist-jsp: TARBALL  = $(RESULT_DIR)/$(TMP_BOOK)_$(LL)-jsp.tar.bz2
dist-jsp: JSP-USED = $(addprefix $(JSP_DIR)/images/,$(USED))
dist-jsp: $(PROFILES) $(PROFILEDIR)/.validate $(JSP_DIR)/index.jsp
  ifeq ($(VERBOSITY),1)
	@echo "   Creating tarball..."
  endif
	BZIP2=--best \
	tar cjhf $(TARBALL) --exclude-vcs --no-recursion \
	  -T $(JSP_DIR)/JSP.manifest \
	  --absolute-names --transform=s%$(RESULT_DIR)/jsp/%% \
	  $(JSP-USED) $(JSP_DIR)/index.jsp $(JSP_DIR)/style_image/* \
	  $(JSP_DIR)/$(notdir $(STYLE_HTMLCSS))
	@ccecho "result" "Find the tarball at:\n$(TARBALL)"

#---------------
# dist-all
#
# calls validate and chklink and creates dist-xml dist-html dist color-pdf
#
.PHONY: dist-all
dist-all: validate chklink dist-xml dist-html dist color-pdf

#------------------------------------------------------------------------
# Remove stuff
#

.INTERMEDIATE: $(PROFILE_PARENT_DIR)/dist/%.xml
.INTERMEDIATE: $(TMP_DIR)/dist/%.xml

#------------------------------------------------------------------------
#
# General Helper targets
#

# create needed directories
$(DIRECTORIES):
	mkdir -p $@


# Generate a temporary single XML file needed for various targets such as
# epub, man, bigfile etc.
#
# If PROFILE_URN is not set, profiling is not needed. In that case we generate
# a bigfile using xmllint
#
$(TMP_XML): $(PROFILES)
  ifeq ($(VERBOSITY),1)
	@echo "   Creating bigfile"
  endif
  ifdef PROFILE_URN
	xsltproc --xinclude --output $@ \
	  --stringparam resolve.suse-pi 1 \
	  --stringparam show.comments $(COMMENTS) \
	  --stringparam show.remarks $(REMARKS) \
	  --stringparam projectfile PROJECTFILE.$(BOOK) $(PROFILE_URN) \
	  $(PROFILED_MAIN)
  else
	xmllint --xinclude --output $@ $(PROFILED_MAIN)
  endif


#------------------------------------------------------------------------
#
# "Helper" targets for profiling ( $PROFILES and $DISTPROFILE)
# 

$(PROFILE_PARENT_DIR)/dist:
	mkdir -p $@

$(TMP_DIR)/dist/xml:
	mkdir -p $@

$(PROFILESUBDIRS):
	mkdir -p $@


$(PROFILES): $(PROFILEDIR)/PROJECTFILE.$(BOOK) $(wildcard $(DOC_DIR)/xml/*.ent)
$(TMPDIST): $(TMP_DIR)/dist/PROJECTFILE.$(BOOK)

#---------------
# Normal profiling
#
#
# The entity declarations are needed for the target dist-xml because we want
# to recover all the entities after the profiling step when exporting our xml.
# If PROFILE_URN is undefined, there is no profiling information in $MAIN. This
# means, we will continue without profiling.
#

$(PROFILEDIR)/%: | $(PROFILESUBDIRS)
$(PROFILEDIR)/%: $(DOC_DIR)/xml/%
  ifdef PROFILE_URN
    ifeq ($(VERBOSITY),1)
	@echo "   Profiling $(notdir $<)"
    endif
	xsltproc --nonet --output $@ $(PROFSTRINGS) \
	  --stringparam filename "$(notdir $<)" $(HROOTSTRING) \
	  $(PROFILE_URN) $<
  else
	ln -sf $< $@
  endif

#---------------
# Profiling for $DISTPROFILE
# (needed for dist-xml and dist-book)
#
# Preserves the entities by calling entities-exchange.sh before
# and after the profiling, for more information also see the explanations for
# dist-xml
#
# During the profiling, we have to protect all entities in the text,
# because they would be resolved else. The intermediate files without
# entities resides in tmp/dist/xml . The sed scripts that are used to
# protect the entities and convert them back are 
# $(DAPSROOT)/etc/entities.preserve.sed and
# $(DAPSROOT)/etc/entities.recover.sed. Intermediate profiled sources in
# $TMP_DIR/dist/%.xml are used for this.
#
# We want $(PROFILE_PARENT_DIR)/dist/*.xml to be recreated everytime to
# be on the safe side. Explicitly marking the XML files as intermediate
# will cause make to automatically delete them in any case and prevent us
# from having to manually remove them
#
# If no profiling stylesheet ($stylenov) is defined, we do not need to
# bother with all the stuff from above, but rather directly link to the
# original sources
#
# If not for the IMMEDIATE declarations from above, the dependencies
# on the PHONY link-entity* targets ensure that the profiling in
# dist is _always_ redone
#

$(PROFILE_PARENT_DIR)/dist/%: $(PROFILE_PARENT_DIR)/dist
  ifdef PROFILE_URN
    $(PROFILE_PARENT_DIR)/dist/%: $(TMP_DIR)/dist/xml/%
    ifeq ($(VERBOSITY),1)
	@echo "   Profiling $(notdir $<)"
    endif
	$(LIBEXEC_DIR)/entities-exchange.sh -s -d preserve $<
	xsltproc --nonet --output $@ \
		$(subst show.remarks 1,show.remarks 0, \
		  $(subst show.comments 1,show.comments 0, \
		  $(PROFSTRINGS))) \
		  --stringparam filename "$(notdir $<)" \
		  $(PROFILE_URN) $<
	$(LIBEXEC_DIR)/entities-exchange.sh -d recover $@
  else
$(PROFILE_PARENT_DIR)/dist/%: $(DOC_DIR)/xml/% link-entity-noprofile
	ln -sf $< $@
  endif

#
# the TMP stuff
#
$(TMP_DIR)/dist/xml/%: $(TMP_DIR)/dist/xml
$(TMP_DIR)/dist/xml/%: $(DOC_DIR)/xml/% link-entity-dist
	$(LIBEXEC_DIR)/entities-exchange.sh -s -o $(dir $@) -d preserve $<


#------------------------------------------------------------------------
#
# Entity resolution
#

# link entity declaration files
#
# We need to link the entity-decl.ent in addition to all other xml files
# because the entities are not resolved when just linking.
#
# Usually link-entity is used, but the targets dist-xml and dist-book use
# their own profiling directories $(PROFILE_PARENT_DIR)/dist and
# $(TMP_DIR)/dist (see description of these targets for more information)
# and therefor need a separate link-entity-dist target

.PHONY: link-entity-noprofile
link-entity: ENTITIES = $(shell $(LIBEXEC_DIR)/getentityname.py $(DOCFILES))
link-entity: | $(DIRECTORIES)
  ifeq ($(VERBOSITY),1)
	@echo "   Linking entities"
  endif
	if test -n "$(ENTITIES)"; then \
	  for i in $(ENTITIES); do \
	    ln -sf $(DOC_DIR)/xml/$$i $(PROFILE_PARENT_DIR)/noprofile; \
	  done \
	fi

.PHONY: link-entity-dist
link-entity-dist: $(PROFILE_PARENT_DIR)/dist $(TMP_DIR)/dist/xml
link-entity-dist: ENTITIES = $(shell $(LIBEXEC_DIR)/getentityname.py $(DOCFILES))
link-entity-dist:
  ifeq ($(VERBOSITY),1)
	@echo "   Linking entities"
  endif
	if test -n "$(ENTITIES)"; then \
	  for i in $(ENTITIES); do \
	    ln -sf $(DOC_DIR)/xml/$$i $(PROFILE_PARENT_DIR)/dist/$$i; \
	    ln -sf $(DOC_DIR)/xml/$$i $(TMP_DIR)/dist/xml/$$i; \
	  done \
	fi

#---------------
# Create projectfile
#
# This files is used to resolve the PIs for the &productname; &productnamereg;
# ... entities. And while we are at it, we can as well ad some additional
# information (although it is currently not used)
#
# IMPORTANT:
# We need to link the entity files here instead of using a separate PHONY
# target to do this job (which would make things a bit more clear), because
# otherwise the profiling would be redone every time
#
$(PROFILEDIR)/PROJECTFILE.$(BOOK): ENTITIES = $(shell $(LIBEXEC_DIR)/getentityname.py $(DOCFILES))
$(PROFILEDIR)/PROJECTFILE.$(BOOK): | $(DIRECTORIES)
$(PROFILEDIR)/PROJECTFILE.$(BOOK): $(DOCCONF)
  ifeq ($(VERBOSITY),1)
	@echo "   Linking entities"
  endif
#	echo "-----> $(LIBEXEC_DIR)/getentityname.py $(DOCFILES) "
	if test -n "$(ENTITIES)"; then \
	  for i in $(ENTITIES); do \
	    ln -sf $(DOC_DIR)/xml/$$i $(PROFILEDIR)/; \
	  done \
	fi
  ifeq ($(VERBOSITY),1)
	@echo "   Writing projectfile"
  endif
	@echo "<?xml version=\"1.0\" encoding=\"UTF-8\"?>" > $@
	@echo "<!DOCTYPE docproperties [  " >> $@
	@echo "<!ENTITY % ISOlat1 PUBLIC  " >> $@
	@echo " \"ISO 8879:1986//ENTITIES Added Latin 1//EN//XML\" " >> $@
	@echo " \"http://www.oasis-open.org/docbook/xml/4.3/ent/iso-lat1.ent\">" >> $@
	@echo "<!ENTITY % ISOlat2 PUBLIC  " >> $@
	@echo " \"ISO 8879:1986//ENTITIES Added Latin 2//EN//XML\" " >> $@
	@echo " \"http://www.oasis-open.org/docbook/xml/4.3/ent/iso-lat2.ent\">" >> $@
	@echo "<!ENTITY % ISOnum PUBLIC  " >> $@
	@echo " \"ISO 8879:1986//ENTITIES Numeric and Special Graphic//EN//XML\" " >> $@
	@echo " \"http://www.oasis-open.org/docbook/xml/4.3/ent/iso-num.ent\">" >> $@
	@echo "<!ENTITY % ISOpub PUBLIC  " >> $@
	@echo " \"ISO 8879:1986//ENTITIES Publishing//EN//XML\" " >> $@
	@echo " \"http://www.oasis-open.org/docbook/xml/4.3/ent/iso-pub.ent\">" >> $@
	@if test -n "$(ENTITIES)"; then \
	  echo "<!ENTITY % entities SYSTEM " >> $@; \
	  echo "             \"entity-decl.ent\"> "  >> $@; \
	  echo " %ISOlat1; %ISOlat2; %ISOnum; %ISOpub; %entities;]>" >> $@; \
	else \
	  echo " %ISOlat1; %ISOlat2; %ISOnum; %ISOpub;]>" >> $@; \
	fi
	@echo "<docproperties xmlns=\"urn:x-suse:xmlns:docproperties\" version=\"1.0\">" >> $@
	@echo " <productspec>" >> $@
  ifdef TITLE
	@echo "  <title>$(TITLE)</title>" >> $@
  endif
	@echo "  <bookname>$(BOOK)</bookname>" >> $@
  ifdef PRODUCTNAME
	@echo "  <productname>$(PRODUCTNAME)</productname>" >> $@
  endif
  ifdef PRODUCTNAMEREG
	@echo "  <productnamereg>$(PRODUCTNAMEREG)</productnamereg>" >> $@
  endif
  ifdef DISTVER
	@echo "  <productnumber>$(DISTVER)</productnumber>" >> $@
  endif
  ifdef HTMLROOT
	@echo "  <htmlroot>$(HTMLROOT)</htmlroot>" >> $@
  endif
  ifdef ROOTID
	@echo "  <rootid>$(ROOTID)</rootid>" >> $@
  endif
  ifdef MAIN
	@echo "  <main>$(MAIN)</main>" >> $@
  endif
  ifdef PROFOS
	@echo "  <profos>$(PROFOS)</profos>" >> $@
  endif
  ifdef PROFARCH
	@echo "  <profarch>$(PROFARCH)</profarch>" >> $@
  endif
  ifdef LAYOUT
	@echo "  <layout>$(LAYOUT)</layout>" >> $@
  endif
  ifdef PACKAGENAME
	@echo "  <packagename>$(PACKAGENAME)</packagename>" >> $@
  endif
  ifdef PDFNAME
	@echo "  <pdfname>$(PDFNAME)</pdfname>" >> $@
  endif
  ifdef REMARKS
	@echo "  <remark>$(REMARKS)</remark>" >> $@
  endif
  ifdef COMMENTS
	@echo "  <comments>$(COMMENTS)</comments>" >> $@
  endif
	@echo " </productspec>" >> $@
	@echo "</docproperties>" >> $@



#------------------------------------------------------------------------
#
# "Helper" targets for PDF and COLOR-PDF
#

# Formatter command
#
ifeq ("$(FORMATTER)","fop")
  ifdef FOP_CONFIG
    FORMATTER_CMD := $(FOP_WRAPPER) $(FOP_OPTIONS) -c $(FOP_CONFIG)
  else
    FORMATTER_CMD := $(FOP_WRAPPER) $(FOP_OPTIONS)
  endif
endif
ifeq ("$(FORMATTER)","xep")
  FORMATTER_CMD := XEP_CONFIG_FILE=$(XEP_CONFIG) $(XEP_WRAPPER) $(XEP_OPTIONS)
endif


# Print result file names
#

COLOR_FO := $(TMP_DIR)/$(TMP_BOOK)-$(FORMATTER)_$(LL).fo
BW_FO    := $(TMP_DIR)/$(TMP_BOOK)-$(FORMATTER)-print_$(LL).fo

.PHONY: pdf-name
pdf-name:
	@ccecho "result" "$(RESULT_DIR)/$(TMP_BOOK)-print_$(LL).pdf"

.PHONY: pdf-color-name color-pdf-name
pdf-color-name color-pdf-name:
	@ccecho "result" "$(RESULT_DIR)/$(TMP_BOOK)_$(LL).pdf"

# Generate fo from xml
#
# XSLTPARAM is a variable that can be set via wrapper script in order to
# temporarily overwrite styleseet settings such as margins
#
# Using PHONY (rather than INTERMEDIATE) targets to make sure the .fo file
# is always remade _and_ kept for debugging purposes
# 
# b/w PDF
#
.PHONY: bw-fo
ifeq ("$(INDEX)", "Yes")
  bw-fo: $(PROFILEDIR)/$(TMP_BOOK).ind
endif
ifeq ($(VERBOSITY),1)
  bw-fo: FONTDEBUG := --stringparam debug.fonts 0
endif
bw-fo: $(PROFILES) $(PROFILEDIR)/.validate $(STYLEFO)
  ifeq ($(VERBOSITY),1)
	@echo "   Creating fo-file..."
  endif
	xsltproc --xinclude $(FOSTRINGS) $(ROOTSTRING)  $(METASTRING) \
	  $(INDEXSTRING) --stringparam projectfile PROJECTFILE.$(BOOK) \
	  $(FONTDEBUG)  $(XSLTPARAM) \
	  -o $(BW_FO) $(STYLEFO) $(PROFILED_MAIN) $(DEVNULL)
	@ccecho "info" "Created fo file $(BW_FO)"

# Color PDF
#
.PHONY: color-fo
ifeq ("$(INDEX)", "Yes")
  color-fo: $(PROFILEDIR)/$(TMP_BOOK).ind
endif
ifeq ($(VERBOSITY),1)
  color-fo: FONTDEBUG := --stringparam debug.fonts 0
endif
  color-fo: $(PROFILES) $(PROFILEDIR)/.validate $(STYLEFO)
ifeq ($(VERBOSITY),1)
	@echo "   Creating fo-file..."
endif
	xsltproc --xinclude $(FOCOLSTRINGS) $(ROOTSTRING) $(METASTRING)\
	  $(INDEXSTRING) --stringparam projectfile PROJECTFILE.$(BOOK) \
	  $(FONTDEBUG) $(XSLTPARAM) -o $(COLOR_FO) $(STYLEFO) \
	  $(PROFILED_MAIN)
	@ccecho "info" "Created fo file $(COLOR_FO)"


# Create b/w PDF from fo
#
$(RESULT_DIR)/$(TMP_BOOK)-print_$(LL).pdf: provide-images warn-images bw-fo
  ifeq ($(VERBOSITY),1)
	@echo "   Creating PDF from fo-file..."
  endif
	$(FORMATTER_CMD) $(BW_FO) $@ $(DEVNULL)
	@pdffonts $@ | grep -v -e "^name" -e "^---" | cut -c 51-71 | \
		grep -v -e "yes yes yes" >& /dev/null && \
		(ccecho "warn" "Not all fonts are embedded" >&2;) || :
  ifdef MISSING
	@ccecho "warn" "Looks like the following graphics are missing: $(MISSING)" >2& 
  endif

# Create COLOR-PDF from fo
#
$(RESULT_DIR)/$(TMP_BOOK)_$(LL).pdf: provide-color-images warn-images color-fo
  ifeq ($(VERBOSITY),1)
	@echo "   Creating PDF from fo-file..."
  endif
	$(FORMATTER_CMD) $(COLOR_FO) $@ $(DEVNULL)
	@pdffonts $@ | grep -v -e "^name" -e "^---" | cut -c 51-71 | \
		grep -v -e "yes yes yes" >& /dev/null && \
		(ccecho "warn" "Not all fonts are embedded" >&2;) || :
  ifdef MISSING
	@ccecho "warn" "Looks like the following graphics are missing: $(MISSING)" >&2
  endif

# Index creation
#
ifeq ("$(INDEX)", "Yes")
  $(PROFILEDIR)/$(TMP_BOOK).idx: $(PROFILES) $(PROFILEDIR)/.validate
  ifeq ($(VERBOSITY),1)
	@echo "   Creating Index..."
  endif
	xsltproc $(ROOTSTRING) --xinclude --output $@ $(STYLEINDEX) \
	$(PROFILED_MAIN)

# not used
#.idx.ind:
#	$(DAPSROOT)/bin/daps-sortindexterms.py -l $(LL) $< --output $@
endif

#------------------------------------------------------------------------
#
# "Helper" targets for HTML and HTML-SINGLE
#

$(HTML_DIR):
	mkdir -p $@

#---------------
# Print result directory names 
#
.PHONY: html-dir-name
html-dir-name:
	@ccecho "result" "$(HTML_DIR)"

.PHONY: htmlsingle-name html-single-name
htmlsingle-name html-single-name:
	@ccecho "result" "$(HTML_DIR)/$(BOOK).html"

.PHONY: dist-html-name
dist-html-name:
	@ccecho "result" "$(RESULT_DIR)/$(TMP_BOOK)_$(LL)-html.tar.bz2"

.PHONY: dist-htmlsingle-name dist-html-single-name
dist-htmlsingle-name dist-html-single-name:
	@ccecho "result" "$(RESULT_DIR)/$(TMP_BOOK)_$(LL)-htmlsingle.tar.bz2"

#---------------
# Htmlgraphics
#

HTMLGRAPHICS := $(HTML_DIR)/style_images $(HTML_DIR)/images

ifdef STYLE_HTMLCSS
  # Add CSS file to HTMLGRAPHICS
  # Add a stringparam for a CSS file if defined
  HTMLGRAPHICS += $(HTML_DIR)/$(notdir $(STYLE_HTMLCSS))
  CSSSTRING    := --stringparam html.stylesheet $(notdir $(STYLE_HTMLCSS))

  $(HTML_DIR)/$(notdir $(STYLE_HTMLCSS)): $(STYLE_HTMLCSS) $(HTML_DIR)
	$(HTML_GRAPH_COMMAND) $(STYLE_HTMLCSS) $(HTML_DIR)/
endif

# images
$(HTML_DIR)/images: $(HTML_DIR) provide-color-images
  ifeq ($(STATIC_HTML), 1)
    ifdef PNGONLINE
	test -d $@ || mkdir -p $@
	$(HTML_GRAPH_COMMAND) $(PNGONLINE) $@
    endif
  else
	$(HTML_GRAPH_COMMAND) $(IMG_GENDIR)/online/ $@
  endif

# $(USED_STYLEDIR)/images contains admon and navig images as well as
# callout images in callouts/
# USED_STYLEDIR may contain .svn directories which we do not want to copy
# therefore we use tar with the --exclude-vcs option to copy
# the files
#
# style images
$(HTML_DIR)/style_images: $(USED_STYLEDIR)/images $(HTML_DIR)
  ifeq ($(STATIC_HTML), 1)
	if [ -L $@ ]; then rm -f $@; fi
	tar cp --exclude-vcs --transform=s%images/%style_images/% \
	  -C $(USED_STYLEDIR) images/ | (cd $(HTML_DIR); tar xpv) >/dev/null
  else
	if [ -d $@ ]; then rm -rf $@; fi
	$(HTML_GRAPH_COMMAND) $(USED_STYLEDIR)/images/ $(HTML_DIR)/style_images
  endif

#---------------
# target to generate METAFILE for html stylesheets
#
ifdef USESVN
  .PHONY: meta
  meta: $(SRCFILES)
	@ccecho "info"  "Generating $(PROFILEDIR)/METAFILE ..."
	svn pl -v --xml $(SRCFILES) > $(TMP_DIR)/.docprops.xml
	xsltproc -o $(PROFILEDIR)/METAFILE $(METAXSLT) $(TMP_DIR)/.docprops.xml
endif

#---------------
# Generate HTML from profiled xml
#
# XSLTPARAM is a variable that can be set via wrapper script in order to
# temporarily overwrite styleseet settings such as margins
#
ifdef USESVN
  $(HTML_DIR)/index.html: meta
endif
$(HTML_DIR)/index.html: provide-color-images  warn-images
$(HTML_DIR)/index.html: $(STYLEH) $(PROFILES) $(HTML_DIR) $(HTMLGRAPHICS)
  ifeq ($(VERBOSITY),1)
	@echo "   Creating HTML pages"
  endif
	xsltproc $(HTMLSTRINGS) $(ROOTSTRING) $(METASTRING) $(XSLTPARAM) \
	  $(MANIFEST) --stringparam projectfile PROJECTFILE.$(BOOK) \
	  --stringparam use.id.as.filename 1 \
	  $(CSSSTRING) --xinclude $(STYLEH) $(PROFILED_MAIN) \
	  $(DEVNULL)
	@if [ ! -f  $@ ]; then \
	  (cd $(HTML_DIR) && ln -sf $(ROOTID).html $@); \
	fi

#---------------
# Generate HTML SINGLE from profiled xml
#
ifdef USESVN
  $(HTML_DIR)/$(BOOK).html: meta
endif
$(HTML_DIR)/$(BOOK).html: provide-color-images  warn-images
$(HTML_DIR)/$(BOOK).html: $(STYLEH) $(PROFILES) $(HTML_DIR) $(HTMLGRAPHICS)
  ifeq ($(VERBOSITY),1)
	@echo "   Creating single HTML page"
  endif
	xsltproc $(HTMLSTRINGS) $(ROOTSTRING) $(METASTRING)  $(XSLTPARAM) \
	  $(MANIFEST) --stringparam projectfile PROJECTFILE.$(BOOK) \
	  $(CSSSTRING) --output $(HTML_DIR)/$(BOOK).html \
	  --xinclude $(STYLEHSINGLE) $(PROFILED_MAIN) $(DEVNULL)

#------------------------------------------------------------------------
#
# "Helper" targets for WEBHELP
#

$(WEBHELP_DIR):
	mkdir -p $@

#---------------
# Print result directory names 
#
.PHONY: webhelp-dir-name
webhelp-dir-name:
	@ccecho "result" "$(WEBHELP_DIR)"
	@ccecho "result" "$(WEBHELP_DIR)/$(BOOK).html"

.PHONY: dist-webhelp-name
dist-webhelp-name:
	@ccecho "result" "$(RESULT_DIR)/$(TMP_BOOK)_$(LL)-webhelp.tar.bz2"


#---------------
# Webhelpgraphics
#
WEBHELPGRAPHICS := $(WEBHELP_DIR)/style_images $(WEBHELP_DIR)/images \
		   $(WEBHELP_DIR)/common

ifneq ("$(WH_SEARCH)", "no")
  WEBHELPGRAPHICS += $(WEBHELP_DIR)/search
endif

ifdef STYLE_HTMLCSS
  # Add CSS file to WEBHELPGRAPHICS
  # Add a stringparam for a CSS file if defined
  WEBHELPGRAPHICS += $(WEBHELP_DIR)/$(notdir $(STYLE_HTMLCSS))
  CSSSTRING    := --stringparam html.stylesheet $(notdir $(STYLE_HTMLCSS))

  $(WEBHELP_DIR)/$(notdir $(STYLE_HTMLCSS)): $(STYLE_HTMLCSS) $(WEBHELP_DIR)
	$(HTML_GRAPH_COMMAND) $(STYLE_HTMLCSS) $(WEBHELP_DIR)/
endif

# search stuff
$(WEBHELP_DIR)/search: $(WEBHELP_DIR)
$(WEBHELP_DIR)/search: $(USED_STYLEDIR)/webhelp/template/content/search 
	test -d $@/stemmers || mkdir -p $@/stemmers
	$(HTML_GRAPH_COMMAND) $</default.props $@
	$(HTML_GRAPH_COMMAND) $</punctuation.props $@
	$(HTML_GRAPH_COMMAND) $</nwSearchFnt.js $@
	$(HTML_GRAPH_COMMAND) "$</stemmers/$(LL)_stemmer.js" \
	  $@/stemmers
	for LPROPS in "$</$(LL)*.props $</*.js"; do \
	  $(HTML_GRAPH_COMMAND) $$LPROPS $@; \
	done

# images
$(WEBHELP_DIR)/images: $(WEBHELP_DIR) provide-color-images
  ifeq ($(STATIC_HTML), 1)
    ifdef PNGONLINE
	test -d $@ || mkdir -p $@
	$(HTML_GRAPH_COMMAND) $(PNGONLINE) $@
    endif
  else
	$(HTML_GRAPH_COMMAND) $(IMG_GENDIR)/online/ $@
  endif

# $(USED_STYLEDIR)/images contains admon and navig images as well as
# callout images in callouts/
# USED_STYLEDIR may contain .svn directories which we do not want to copy
# therefore we use tar with the --exclude-vcs option to copy
# the files
#
# style images
$(WEBHELP_DIR)/style_images: $(USED_STYLEDIR)/images $(WEBHELP_DIR)
  ifeq ($(STATIC_HTML), 1)
	if [ -L $@ ]; then rm -f $@; fi
	tar cp --exclude-vcs --transform=s%images/%style_images/% \
	  -C $(USED_STYLEDIR) images/ | (cd $(WEBHELP_DIR); tar xpv) >/dev/null
  else
	if [ -d $@ ]; then rm -rf; fi
	$(HTML_GRAPH_COMMAND) $(USED_STYLEDIR)/images/ $@
  endif
# common stuff /(Javascript, CSS,...)
$(WEBHELP_DIR)/common: $(WEBHELP_DIR)
$(WEBHELP_DIR)/common: $(USED_STYLEDIR)/webhelp/template/common
  ifeq ($(STATIC_HTML), 1)
	if [ -L $@ ]; then rm -f $@; fi
	tar cp --exclude-vcs -C $(USED_STYLEDIR)/webhelp/template common | \
	  (cd $(WEBHELP_DIR); tar xpv) >/dev/null
  else
	if [ -d $@ ]; then rm -rf $@; fi
	$(HTML_GRAPH_COMMAND) $< $@
  endif

#---------------
# Generate WEBHELP from profiled xml
#
# XSLTPARAM is a variable that can be set via wrapper script in order to
# temporarily overwrite styleseet settings such as margins
#
$(WEBHELP_DIR)/$(BOOK).html: provide-color-images  warn-images
$(WEBHELP_DIR)/$(BOOK).html: $(STYLEWEBHELP) $(PROFILES) $(WEBHELP_DIR)
$(WEBHELP_DIR)/$(BOOK).html: $(WEBHELPGRAPHICS) $(DOCBOOK_STYLES)/extensions
  ifeq ($(VERBOSITY),1)
	@echo "   Creating webhelp pages"
  endif
	xsltproc $(WEBHELPSTRINGS) $(ROOTSTRING) $(XSLTPARAM) \
	  $(MANIFEST) --stringparam use.id.as.filename 1 \
	  $(CSSSTRING) --xinclude $(STYLEWEBHELP) $(PROFILED_MAIN) \
	  $(DEVNULL)
	@if [ ! -f  $@ ]; then \
	  (cd $(WEBHELP_DIR) && ln -sf $(ROOTID).html $@); \
	fi
	java -DhtmlDir=$(WEBHELP_DIR)/ -DindexerLanguage=$LL \
	  -DfillTheRest=true \
	  -Dorg.xml.sax.driver=org.ccil.cowan.tagsoup.Parser \
	  -Djavax.xml.parsers.SAXParserFactory=org.ccil.cowan.tagsoup.jaxp.SAXFactoryImpl \
	  -classpath $(DOCBOOK_STYLES)/extensions/webhelpindexer.jar:$(DOCBOOK_STYLES)/extensions/lucene-analyzers-3.0.0.jar:$(DOCBOOK_STYLES)/extensions/tagsoup-1.2.1.jar:$(DOCBOOK_STYLES)/extensions/tagsoup-1.2.1.jar:$(DOCBOOK_STYLES)/extensions/lucene-core-3.0.0.jar \
	  com.nexwave.nquindexer.IndexerMain
	rm -f $(WEBHELP_DIR)/search/*.props

#------------------------------------------------------------------------
#
# "Helper" targets for JSP
#

$(JSP_DIR):
	mkdir -p $@

#---------------
# Print result directory names
#
.PHONY: jsp-dir-name
jsp-dir:
	@ccecho "result" "$(JSP_DIR)"

#---------------
# Jspgraphics
#
JSPGRAPHICS = $(JSP_DIR)/style_images $(JSP_DIR)/images

ifdef STYLE_HTMLCSS
  JSPGRAPHICS += $(JSP_DIR)/$(notdir $(STYLE_HTMLCSS))
  CSSSTRING    := --stringparam html.stylesheet $(notdir $(STYLE_HTMLCSS))

  $(JSP_DIR)/$(notdir $(STYLE_HTMLCSS)): $(STYLE_HTMLCSS) $(JSP_DIR)
	$(HTML_GRAPH_COMMAND) $(STYLE_HTMLCSS) $(JSP_DIR)/
endif

# images
$(JSP_DIR)/images: $(JSP_DIR) provide-color-images
  ifeq ($(STATIC_HTML), 1)
    ifdef PNGONLINE
	test -d $@ || mkdir -p $@
	$(HTML_GRAPH_COMMAND) $(PNGONLINE) $@
    endif
  else
	$(HTML_GRAPH_COMMAND) $(IMG_GENDIR)/online/ $@
  endif

# $(USED_STYLEDIR)/images contains admon and navig images as well as
# callout images in callouts/
# USED_STYLEDIR may contain .svn directories which we do not want to copy
# therefore we use tar with the --exclude-vcs option to copy
# the files
#
# style images
$(JSP_DIR)/style_images: $(USED_STYLEDIR)/images $(JSP_DIR)
  ifeq ($(STATIC_HTML), 1)
	if [ -L $@ ]; then rm -f $@; fi
	tar cp --exclude-vcs --transform=s%images/%style_images/% \
	  -C $(USED_STYLEDIR) images/ | (cd $(JSP_DIR); tar xpv) >/dev/null
  else
	if [ -d $@ ]; then rm -rf $@; fi
	$(HTML_GRAPH_COMMAND) $(USED_STYLEDIR)/images/ $(JSP_DIR)/style_images
  endif

#---------------
# Generate JSP from profiled xml
#
ifdef USESVN
  $(JSP_DIR)/index.jsp: meta
endif
$(JSP_DIR)/index.jsp: $(STYLEJ) $(PROFILES) $(JSP_DIR)
$(JSP_DIR)/index.jsp: provide-color-images warn-images $(JSPGRAPHICS) 
  ifeq ($(VERBOSITY),1)
	@echo "   Creating JSP pages"
  endif
	xsltproc $(JSPSTRINGS) $(ROOTSTRING) $(METASTRING) \
	  $(XHTMLSTRING) $(MANIFEST)\
	  --stringparam projectfile PROJECTFILE.$(BOOK) $(CSSSTRING) \
	  --xinclude $(STYLEJ) $(PROFILED_MAIN)
  ifdef ROOTID
	ln -sf $(JSP_DIR)/$(ROOTID).jsp $(JSP_DIR)/index.jsp
  endif


#------------------------------------------------------------------------
#
# "Helper" targets for TXT
#

# Print result file name
#
.PHONY: txt-name
txt-name:
	@ccecho "result" "$(RESULT_DIR)/$(TMP_BOOK_NODRAFT).txt"


# create text from single html file
#
$(RESULT_DIR)/$(TMP_BOOK_NODRAFT).txt: $(HTML_DIR)/$(BOOK).html 
  ifeq ($(VERBOSITY),1)
	@echo "   Creating ASCII file"
  endif
	w3m -dump $< > $@


#------------------------------------------------------------------------
#
# "Helper" targets for EPUB
#

# ruby script to generate ePUBs
# not a stylesheet, but part of the Docbook4 stylesheet package
# (it is _NOT_ available with the DocBook 5 stylesheets!!)
DB2EPUB := ruby $(DOCBOOK_STYLES)/epub/bin/dbtoepub

$(EPUB_TMP_DIR):
	mkdir -p $@

# Print result file
#
.PHONY: epub-name
epub-name:
	@ccecho "result" "$(RESULT_DIR)/$(TMP_BOOK_NODRAFT).epub"

# Check the epub file
.PHONY: epub-check
epub-check: $(RESULT_DIR)/$(TMP_BOOK_NODRAFT).epub
	@ccecho "result" "#################### BEGIN epubcheck report ####################"
	epubcheck $(RESULT_DIR)/$(TMP_BOOK_NODRAFT).epub || true
	@ccecho "result" "#################### END epubcheck report ####################"

# Generate "epub xml" from $(TMP_XML)
#
$(EPUB_TMP_DIR)/$(TMP_BOOK_NODRAFT).xml: $(TMP_XML) 
  ifeq ($(VERBOSITY),1)
	@echo "   Generating XML bigfile"
  endif
	xsltproc --output $@ $(ROOTSTRING) $(STYLEEPUBDB) $<

# Generate epub from "epub xml" file 
#
$(RESULT_DIR)/$(TMP_BOOK_NODRAFT).epub: $(EPUB_TMP_DIR)/$(TMP_BOOK_NODRAFT).xml
$(RESULT_DIR)/$(TMP_BOOK_NODRAFT).epub: $(STYLEEPUBDB) $(PROFILEDIR)/.validate
$(RESULT_DIR)/$(TMP_BOOK_NODRAFT).epub: provide-epub-images
  ifeq ($(VERBOSITY),1)
	@echo "   Creating epub"
  endif
	$(DB2EPUB) -s $(STYLEEPUBXSLT) --verbose --css $(STYLE_EPUBCSS) \
	  -o $@ $(EPUB_TMP_DIR)/$(TMP_BOOK_NODRAFT).xml

#------------------------------------------------------------------------
#
# "Helper" targets for WIKI
#

# Print result file
#
.PHONY: wiki-name
wiki-name:
	@ccecho "result" "wiki/$(BOOK)/$(ROOTID).wiki"

# Generate wiki from profiled xml
$(RESULT_DIR)/$(TMP_BOOK_NODRAFT).wiki: $(STYLEWIKI) $(PROFILES) 
  ifeq ($(VERBOSITY),1)
	@echo "   Creating mediawiki files"
  endif
	xsltproc --output $@ $(ROOTSTRING) --xinclude $(STYLEWIKI) \
	  $(PROFILED_MAIN)


#------------------------------------------------------------------------
# Miscellaneous
# should be moved to make/misc.mk
#

#---------------
# Check external links (<ulink>)
#

.PHONY: checklink chklink jana
checklink chklink jana: $(PROFILES) 
ifeq ($(VERBOSITY),2)
  checklink chklink jana: CB_VERBOSITY := --verbose
endif
checklink chklink jana:
  ifeq ($(VERBOSITY),1)
	@echo "   Creating test page"
  endif
	xsltproc --xinclude --noout $(ROOTSTRING) -o $(TESTPAGE) \
	  $(STYLELINKS) $(PROFILED_MAIN)
  ifeq ($(VERBOSITY),1)
	@echo "   Running linkchecker"
  endif
	checkbot --url file://localhost$(TESTPAGE) $(CB_VERBOSITY) \
	  $(CB_OPTIONS) --file $(TMP_DIR)/$(BOOK)-checkbot.html $(DEVNULL)
	@ccecho "result" "Find the link check report at:\nfile://$(TMP_DIR)/$(BOOK)-checkbot-localhost.html"


#---------------
# DocBook to NovDoc conversion
#

.PHONY: db2novdoc 
db2novdoc: $(TMP_DIR)/$(TMP_BOOK_NODRAFT)/$(BOOK)-novdoc.xml 
  ifeq ($(VERBOSITY),1)
	@echo "   Converting to Novdoc"
  endif
	xsltproc --output $< $(ROOTSTRING) $(STYLEDB2ND) $(TMP_XML)
  ifeq ($(VERBOSITY),1)
	@echo "   Running xmllint"
  endif
	xmllint --noent --valid \
		--noout $(TMP_DIR)/$(TMP_BOOK_NODRAFT)/$(BOOK)-novdoc.xml
  ifeq ($(VERBOSITY),1)
	@echo "   Moving results"
  endif
	mv -iv $(TMP_DIR)/$(TMP_BOOK_NODRAFT)/$(BOOK)-novdoc.xml \
		$(DOC_DIR)/xml/

$(TMP_DIR)/$(TMP_BOOK_NODRAFT)/$(BOOK)-novdoc.xml: ENTITIES = $(shell $(LIBEXEC_DIR)/getentityname.py $(DOCFILES))
$(TMP_DIR)/$(TMP_BOOK_NODRAFT)/$(BOOK)-novdoc.xml: $(TMP_XML)
  ifeq ($(VERBOSITY),1)
	@echo "   Linking entities"
  endif
	mkdir -p $(dir $@)
	ln -sf $< $@
	if test -n "$(ENTITIES)"; then \
	  for i in $(ENTITIES); do \
	    ln -sf $(DOC_DIR)/xml/$$i $(dir $@); \
	  done \
	fi

#---------------
# Funstuff
#
.PHONY: penguin
penguin:
	@echo -e "\033[32m"
	@echo " >o)"
	@echo " /\\"
	@echo "_\_v"
	@echo -e "\033[m\017"

.PHONY: offspring
offspring:
	@echo -e "\033[32m"
	@echo "(o_ (o_ (o_ (o_"
	@echo "(/) (/) (/) (/)"
	@echo -e "\033[m\017"

#------------------------------------------------------------------------
#
# Debugging
#

#---------------
# Print profile directory
# obsolete
#
.PHONY: profiledir
profiledir:
	@ccecho "result" "$(PROFILEDIR)"

#---------------
# Compute and print the value of a given variable
#
.PHONY: showvariable
showvariable:
  ifndef VARIABLE
	@echo "usage: VARIABLE=some_variable make showvariable"
  else
	@ccecho "result" "$(VARIABLE): $($(VARIABLE))"
  endif

#---------------
# Print a set of selected variables
#
.PHONY: check
check: ROOTIDS = $(shell xsltproc --xinclude $(ROOTSTRING) $(STYLEROOTIDS) $(PROFILED_MAIN))
check:
	@echo "XML_CATALOG_FILES = $(XML_CATALOG_FILES)"
	@echo "DAPSROOT          = $(DAPSROOT)"
	@echo "PROFILE_URN       = $(PROFILE_URN)"
	@echo
	@echo "LL                = $(LL)"
	@echo "PROFARCH          = $(PROFARCH)"
	@echo "PROFOS            = $(PROFOS)"
	@echo "MAIN              = $(MAIN)"
	@echo "BOOK              = $(BOOK)"
	@echo "COMMENTS          = $(COMMENTS)"
	@echo "REMARKS           = $(REMARKS)"
	@echo "DISTVER           = $(DISTVER)"
	@echo "FORMATTER         = $(FORMATTER)"
	@echo "ROOTID            = $(ROOTID)"
	@echo "ROOTIDS           = $(ROOTIDS)"
	@echo "DOUBLEIMG         = $(DOUBLEIMG)"
	@echo "MISSING GFX       = $(MISSING)"
	@echo "USED              = $(USED)"
	@echo "PROFILEDIR        = $(PROFILEDIR)"
	@echo "USESVN            = $(USESVN)"
	@echo "STYLEFO           = $(STYLEFO)"
	@echo "STYLEH            = $(STYLEH)"
	@echo "STYLEJ            = $(STYLEJ)"
	@echo "STYLEWIKI         = $(STYLEWIKI)"
	@echo "LAYOUTROOT        = $(LAYOUTROOT)"
	@echo "PROFILE_URN          = $(PROFILE_URN)"
	@echo "T                 = $(T)"
#	@echo "NOPROFILES        = $(NOPROFILES)"
#	@echo "SRCFILES          = $(SRCFILES)"
#	@echo "PROFILES          = $(PROFILES)"
#	@echo "METAFILES         = $(METAFILES)"
#	@echo "USED              = $(USED)"
#	@echo "ONLINEIMG         = $(ONLINEIMG)"
#	@echo "SVGONLINE         = $(SVGONLINE)"
	@echo "USED_SVG          = $(USED_SVG)"
#	@echo "SRCSVGFIG         = $(SRCSVGFIG)"
	@echo "@F                = $(@F)"
#	@echo "secondary         = $(subst images/print,images/gen,$(SVGPRINT))"
#	@echo ".VARIABLES	 = $(.VARIABLES)"

#-------------------------------
#
# target for doing benchmarks
#
.PHONY: nothing
nothing:
	@ccecho "result" "Done doing nothing"



