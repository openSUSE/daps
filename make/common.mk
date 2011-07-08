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

#SHELL := /bin/bash

#------------------------------------------------------------------------
# Paths

# the following values should have been set by the daps wrapper script
# let's provide sane defaults to prevent harm in case someone calls make
# directly
#

ifndef BASE_DIR
BASE_DIR           := $(shell pwd)
endif
ifndef DTDROOT
DTDROOT := "/usr/share/daps"
endif
ifndef BOOK
BOOK    := mybook
endif
ifndef LIB_DIR
LIB_DIR := $(DTDROOT)/lib
endif
ifndef FOP
FOP     := $(LIB_DIR)/daps-fop
endif


# if BUILD_DIR was not set, use $(BASE_DIR)/build
#
ifdef BUILD_DIR
RESULT_DIR         := $(BUILD_DIR)/$(BOOK)
PROFILE_PARENT_DIR := $(BUILD_DIR)/.profiled
IMG_GENDIR         := $(BUILD_DIR)/.images
TMP_DIR            := $(BUILD_DIR)/.tmp
else
RESULT_DIR         := $(BASE_DIR)/build/$(BOOK)
PROFILE_PARENT_DIR := $(BASE_DIR)/build/.profiled
IMG_GENDIR         := $(BASE_DIR)/build/.images
TMP_DIR            := $(BASE_DIR)/build/.tmp
endif

IMG_SRCDIR         := $(BASE_DIR)/images/src

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
ifndef STYLENOV
GETXMLSTY    := $(DTDROOT)/xslt/misc/get-xml-stylesheet.xsl
STYLENOV     := $(shell xsltproc $(GETXMLSTY) $(BASE_DIR)/xml/$(MAIN))
endif

# PROFILEDIR is one of the most critical variables. Depending on
# this variable, the profiling is done completely different.
ifdef STYLENOV
ifndef PROFCONDITION
PROFILEDIR  := $(PROFILE_PARENT_DIR)/$(subst ;,-,$(PROFARCH))_$(subst ;,-,$(PROFOS))$(REMARK_STR)$(COMMENT_STR)
else
PROFILEDIR  := $(PROFILE_PARENT_DIR)/$(subst ;,-,$(PROFARCH))_$(subst ;,-,$(PROFOS))$(REMARK_STR)$(COMMENT_STR)_$(PROFCONDITION)
endif
else
PROFILEDIR  := $(PROFILE_PARENT_DIR)/noprofile
endif

#------------
# result paths

# TMP_BOOK is the filename for result files
#
# the default:
TMP_BOOK    := $(BOOK)$(REMARK_STR)$(COMMENT_STR)$(DRAFT_STR)
#
# The rootid should be used when manually set:
ifdef ROOTID
#ifneq ($(ROOTID),THE_WHOLE_DOCUMENT)
ifndef PDFNAME
TMP_BOOK := $(ROOTID)$(REMARK_STR)$(COMMENT_STR)$(DRAFT_STR)
endif
endif
# draft mode is only relevant for HTML and PDF
TMP_BOOK_NODRAFT := $(subst _draft,,$(TMP_BOOK))

# Path to temporary XML file (needed for bigfile, epub and man)
TMP_XML := $(TMP_DIR)/$(TMP_BOOK_NODRAFT).xml

# HTML / HTML-SINGLE
#
# HTMLGRAPHICS uses LSTYLECSS from layout.mk. This variable is used to define
# dependencies for dist-html
HTML_DIR := $(RESULT_DIR)/html/$(BOOK)$(REMARK_STR)$(COMMENT_STR)$(DRAFT_STR)

# JSP
JSP_DIR := $(RESULT_DIR)/jsp/$(BOOK)$(REMARK_STR)$(COMMENT_STR)$(DRAFT_STR)

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


# Testpage for checking links in our books
TESTPAGE   ?= $(TMP_DIR)/$(TMP_BOOK)-links.html


# The following directories might not be present and therefore might have to
# be created
#

DIRECTORIES := $(PROFILEDIR) $(TMP_DIR) $(RESULT_DIR) \
	       $(IMG_SRCDIR)/fig $(IMG_SRCDIR)/png $(IMG_SRCDIR)/svg \
               $(IMG_SRCDIR)/dia $(IMG_GENDIR)/online $(IMG_GENDIR)/print \
               $(IMG_GENDIR)/gen/png $(IMG_GENDIR)/gen/svg


#------------------------------------------------------------------------
# Misc variables
#
QUIET  ?=
USESVN := $(shell svn pg doc:maintainer $(BASE_DIR)/xml/$(MAIN) 2>/dev/null)

#------------------------------------------------------------------------
# xslt stylsheets

HTMLBIGFILE    := $(DTDROOT)/xslt/html/docbook.xsl
METAXSLT       := $(DTDROOT)/xslt/misc/svn2docproperties.xsl
STYLEEXTLINK   := $(DTDROOT)/xslt/profiling/process-xrefs.xsl
STYLEREMARK    := $(DTDROOT)/xslt/misc/get-remarks.xsl
STYLEROOTIDS   := $(DTDROOT)/xslt/misc/get-rootids.xsl
STYLESEARCH    := $(DTDROOT)/xslt/misc/search4includedfiles.xsl
STYLELANG      := $(DTDROOT)/xslt/misc/get-language.xsl
STYLEDESK      := $(DTDROOT)/xslt/desktop/docbook.xsl
STYLE_DOCUMENT := $(DTDROOT)/xslt/yelp/docbook.xsl
STYLELINKS     := $(DTDROOT)/xslt/misc/get-links.xsl
STYLEBURN      := $(DTDROOT)/xslt/misc/reduce-from-set.xsl
STYLEINDEX     := $(DTDROOT)/xslt/index/xml2idx.xsl
STYLESEAIND    := $(DTDROOT)/xslt/misc/search4index.xsl
STYLEPUB       := $(DTDROOT)/xslt/epub/db2db.xsl
STYLEDB2ND     := $(DTDROOT)/xslt/misc/db2novdoc.xsl

# ruby script to generate ePUBs
# not a stylesheet, but part of package docbook-xsl-stylesheets
DB2EPUB := /usr/share/xml/docbook/stylesheet/nwalsh/current/epub/bin/dbtoepub

#------------------------------------------------------------------------
# xslt stringparams

ifdef PROFVENDOR
VENDOR      := --stringparam profile.vendor "$(PROFVENDOR)"
endif
ifdef PROFCONDITION
CONDITION   := --stringparam profile.condition "$(PROFCONDITION)" 
endif

PROFSTRINGS  := --stringparam profile.arch "$(PROFARCH)" \
	        --stringparam profile.os "$(PROFOS)" \
	        --stringparam show.comments $(COMMENTS) \
	        --stringparam show.remarks $(REMARKS) $(VENDOR) $(CONDITION)

#ifdef PROFVENDOR
#PROFSTRINGS += --stringparam profile.vendor "$(PROFVENDOR)
#endif

HTMLSTRINGS  := --stringparam base.dir $(HTML_DIR)/ \
                --stringparam show.comments $(COMMENTS) \
	        --stringparam show.remarks $(REMARKS)
JSPSTRINGS   := --stringparam base.dir $(JSP_DIR)/ \
                --stringparam show.comments $(COMMENTS) \
                --stringparam show.remarks $(REMARKS) 
FOSTRINGS    := --stringparam show.comments $(COMMENTS) \
	        --stringparam show.remarks $(REMARKS) \
                --stringparam format.print 1 \
	        --stringparam img.src.path "$(IMG_GENDIR)/print/" \
                --param ulink.show 1 \
	        --stringparam dtdroot $(DTDROOT)
EPUBSTRINGS  := --stringparam img.src.path "$(IMG_GENDIR)/online/"
# CAUTION: path in FOCOLSTRINGS must end with a trailing /
FOCOLSTRINGS := --stringparam show.comments $(COMMENTS) \
	        --stringparam show.remarks $(REMARKS) \
                --stringparam use.xep.cropmarks 0 \
                --stringparam format.print 0 \
	        --stringparam img.src.path "$(IMG_GENDIR)/online/" \
                --param ulink.show 1 \
	        --stringparam dtdroot $(DTDROOT)
ifdef DRAFT
FOSTRINGS    += --stringparam draft.mode "$(DRAFT)" \
                --stringparam xml.source.dir "$(BASE_DIR)/xml/"
FOCOLSTRINGS += --stringparam draft.mode "$(DRAFT)"
HTMLSTRINGS  += --stringparam draft.mode "$(DRAFT)"
JSPSTRINGS   += --stringparam draft.mode "$(DRAFT)"
endif

ifdef ROOTID
ROOTSTRING   := --stringparam rootid "$(ROOTID)"
endif

# HTML stuff
ifdef HTMLROOT
HROOTSTRING  := --stringparam provo.root "$(HTMLROOT)"
endif
ifeq ($(USEMETA), 1)
METASTRING   := --stringparam use.meta 1
endif
ifdef USEXHTML
XHTMLSTRING  := --stringparam generate.jsp.marker 0
endif


# Language string
LL         ?= $(shell xsltproc --nonet $(STYLELANG) $(BASE_DIR)/xml/$(MAIN))

# for creating desktop files
DESKSTRINGS  := --stringparam uselang "${LL}" \
	        --stringparam docpath "@PATH@/" \
                --stringparam base.dir $(DESKTOP_FILES_DIR)/

# index
# the index file must be in the same directory than the profiled $(MAIN).
ifdef USEINDEX
INDEX       := $(shell xsltproc --xinclude $(ROOTSTRING) $(STYLESEAIND) \
               $(BASE_DIR)/xml/$(MAIN))
INDEXSTRING := --stringparam indexfile $(TMP_BOOK).ind
endif


#------------------------------------------------------------------------

# find all xml files in subdirectory xml
# and generate profile targets
#SRCFILES    := $(wildcard $(BASE_DIR)/xml/*.xml)

# find all xml files for the current set and generate profile targets
#
# xsltproc call does not put out $MAIN, this needs to be added
# separately
#
# xslt/misc/get-all-used-files.xsl creates an XML "file" with a list
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
		  --stringparam xml.src.path "$(BASE_DIR)/xml/" \
		  $(DTDROOT)/xslt/misc/get-all-used-files.xsl \
		  $(BASE_DIR)/xml/$(MAIN) | tr \" \')

SRCFILES     := $(shell echo "$(SETFILES)" | xsltproc \
		  --stringparam xml.or.img xml \
		  $(DTDROOT)/xslt/misc/extract-files-and-images.xsl - ) \
		  $(BASE_DIR)/xml/$(MAIN)

PROFILES    := $(subst $(BASE_DIR)/xml/,$(PROFILEDIR)/,$(SRCFILES))
DISTPROFILE := $(subst $(BASE_DIR)/xml/,$(PROFILE_PARENT_DIR)/dist/,$(SRCFILES))


#------------------------------------------------------------------------

USED_LC     := $(shell echo $(USED) | tr [:upper:] [:lower:] )
WRONG_CAP   := $(filter-out $(USED_LC), $(USED))

#------------------------------------------------------------------------
# Include the other make files
#
include $(DTDROOT)/make/images.mk
include $(DTDROOT)/make/layout.mk
include $(DTDROOT)/make/package.mk
#include $(DTDROOT)/make/variables.mk
#include $(DTDROOT)/make/obb.mk
#include $(DTDROOT)/make/help.mk

#------------------------------------------------------------------------
#
# define the targets for building books
#
#--------------
# PDF (default)
#
.PHONY: all pdf
all pdf: | $(DIRECTORIES)
all pdf: $(RESULT_DIR)/$(TMP_BOOK)-$(FOPTYPE).pdf
	@ccecho "result" "PDF book built with REMARKS=$(REMARKS), COMMENTS=$(COMMENTS) and DRAFT=$(DRAFT):\n$(RESULT_DIR)/$(TMP_BOOK)-$(FOPTYPE).pdf"


#--------------
# COLOR-PDF
#
.PHONY: color-pdf pdf-color
pdf-color color-pdf: | $(DIRECTORIES)
pdf-color color-pdf: $(RESULT_DIR)/$(TMP_BOOK)-$(FOPTYPE)-online.pdf
	@ccecho "result" "COLOR-PDF book built with REMARKS=$(REMARKS), COMMENTS=$(COMMENTS) and DRAFT=$(DRAFT):\n$(RESULT_DIR)/$(TMP_BOOK)-$(FOPTYPE)-online.pdf"

#--------------
# HTML
#
.PHONY: html
html: | $(DIRECTORIES)
html: $(PROFILEDIR)/.validate $(HTML_DIR)/index.html
	@ccecho "result" "HTML book built with REMARKS=$(REMARKS), COMMENTS=$(COMMENTS), DRAFT=$(DRAFT) and USEMETA=$(USEMETA):\nfile://$(HTML_DIR)/index.html"

#--------------
# HTML-SINGLE
#
.PHONY: html-single htmlsingle
html-single htmlsingle: | $(DIRECTORIES)
html-single htmlsingle: $(PROFILEDIR)/.validate $(HTML_DIR)/$(BOOK).html
	@ccecho "result" "HTML-SINGLE book built with REMARKS=$(REMARKS), COMMENTS=$(COMMENTS) and DRAFT=$(DRAFT):\nfile://$(HTML_DIR)/$(BOOK).html\033[m\017"

#--------------
# JSP
#
.PHONY: jsp
jsp: | $(DIRECTORIES)
jsp: $(JSP_DIR)
jsp: $(PROFILEDIR)/.validate $(JSP_DIR)/index.jsp
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
epub: $(PROFILEDIR)/.validate $(RESULT_DIR)/$(TMP_BOOK_NODRAFT).epub
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
# TODO:
# The stylesheet writes into the current directory (filename: COMMAND.1)
# we need to specify the --output parameter in order to write it to
# $(RESULT_DIR)/man/COMMAND.1
# This may also have an impact on packaging, check with
# toms and ke
#
# see http://docbook.sourceforge.net/release/xsl/current/doc/manpages/man.output.base.dir.html and
# http://docbook.sourceforge.net/release/xsl/current/doc/manpages/output.html
#
.PHONY: man
man: | $(DIRECTORIES)
man: $(PROFILEDIR)/.validate $(TMP_XML)
	xsltproc $(ROOTSTRING) $(STYLEMAN) $(TMP_XML)

#--------------
# FORCE
#
.PHONY: force
force: | $(DIRECTORIES)
force: $(PROFILEDIR)/.validate 
	touch $(BASE_DIR)/xml/$(MAIN)
	rm -f $(TMP_DIR)/$(TMP_BOOK)-$(FOPTYPE).fo # pdf only!
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
.PHONY: validate
$(PROFILEDIR)/.validate validate: $(PROFILES)
	@if [ -z $(QUIET) ]; then \
	  ccecho "info" "Validating..."; \
	fi
	$(QUIET)xmllint --noent --postvalid --noout \
		--xinclude $(PROFILEDIR)/$(MAIN) $(QUIET2)
	$(QUIET)touch $(PROFILEDIR)/.validate $(QUIET2)
#	@echo "checking for unexpected characters: ... "
#	egrep -n "[^[:alnum:][:punct:][:blank:]]" $(SRCFILES) && \
#	    echo "Found non-printable characters" || echo "OK"
	@if [ -z $(QUIET) ]; then \
	  ccecho "info" "...validating done"; \
	fi


#--------------
# cleaning up
#
.PHONY: clean
clean: | $(DIRECTORIES)
	rm -rf $(PROFILE_PARENT_DIR)/*
	rm -rf $(TMP_DIR)/*

.PHONY: clean-images
clean-images: | $(DIRECTORIES)
	find $(IMG_GENDIR) -type f | xargs rm -f

.PHONY: clean-book
clean-book: clean
clean-book: clean-images
	rm -rf $(RESULT_DIR)

.PHONY: clean-all real-clean
ifdef BUILD_DIR
	rm -rf $(BUILD_DIR)/.[^.]* $(BUILD_DIR)/*
else
	rm -rf $(BASE_DIR)/build
endif

#--------------
# file lists
#
# use validate as a dependency, otherwise you may get a wrong list

# Files used in $BOOK
#
#

.PHONY: projectfiles
projectfiles: INCLUDED = $(shell echo "$(SETFILES)" | xsltproc $(ROOTSTRING) \
			--stringparam xml.or.img xml \
			$(DTDROOT)/xslt/misc/extract-files-and-images.xsl - ) \
			$(BASE_DIR)/xml/$(MAIN)
projectfiles: ENTITIES = $(shell $(LIB_DIR)/getentityname.py $(INCLUDED))
projectfiles:
	@echo $(sort $(INCLUDED)) $(addprefix $(BASE_DIR)/xml/, \
		$(ENTITIES)) $(BASE_DIR)/$(ENVFILE)

# Files _not_ used in $BOOK
#
.PHONY: remainingfiles
remainingfiles: INCLUDED = $(shell echo "$(SETFILES)" | xsltproc $(ROOTSTRING) \
			--stringparam xml.or.img xml \
			$(DTDROOT)/xslt/misc/extract-files-and-images.xsl - ) \
			$(BASE_DIR)/xml/$(MAIN)
remainingfiles: ENTITIES = $(shell $(LIB_DIR)/getentityname.py $(INCLUDED))
remainingfiles: INCLUDED += $(addprefix $(BASE_DIR)/xml/, $(ENTITIES)) \
				$(BASE_DIR)/$(ENVFILE)
remainingfiles:
	@echo $(sort $(filter-out $(INCLUDED), $(SRCFILES)))

# Source graphics used for $BOOK/ROOTID
#
.PHONY: projectgraphics
projectgraphics: 
	@echo $(sort $(USED_SVG) $(USED_PNG) $(USED_DIA) $(USED_FIG))

# Source graphics _not_ used for $BOOK/ROOTID
#
.PHONY: remaininggraphics
remaininggraphics: INCLUDED = $(USED_SVG) $(USED_PNG) $(USED_DIA) $(USED_FIG)
remaininggraphics:
	@echo $(sort $(filter-out $(INCLUDED), $(SRCPNG) $(SRCSVG) \
		$(SRCFIG) $(SRCDIA)))

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
	@echo $(sort $(SVGONLINE) $(PNGONLINE))

# xmlgraphics-bw -> b/w images only
#
.PHONY: xmlgraphics-bw
xmlgraphics-bw: provide-images
	@echo $(sort $(SVGPRINT) $(PNGPRINT))

# Graphics missing in $BOOK
#
.PHONY: missinggraphics
missinggraphics:
ifdef MISSING
	@ccecho "warn" "The following graphics are missing:\n$(MISSING)"
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
		$(PROFILEDIR)/$(MAIN))
dist: | $(DIRECTORIES)
dist: $(PROFILEDIR)/.validate
	for i in $(ROOTIDS); do \
	    make pdf ROOTID=$$i; \
	done

#--------------
# dist-xml:

# create tarball with xml files for the _whole set_ plus entity declaration
# files and the ENV-file that is sourced. Such an archive is needed to
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
dist-xml: INCLUDED = $(addprefix $(PROFILE_PARENT_DIR)/dist/,\
			$(shell xsltproc --nonet --xinclude \
			$(STYLESEARCH) $(PROFILE_PARENT_DIR)/dist/$(MAIN)) \
			$(MAIN))
dist-xml: ENTITIES = $(shell $(LIB_DIR)/getentityname.py $(INCLUDED))
dist-xml: TARBALL  = $(RESULT_DIR)/$(BOOK)_$(LL).tar
dist-xml:
#
# Weird result without the sort function
# Need to check why!
#
	tar chf $(TARBALL) --absolute-names \
	  --xform=s%$(PROFILE_PARENT_DIR)/dist%xml% \
	  $(sort $(INCLUDED))
	tar rhf $(TARBALL)  --absolute-names --xform=s%$(BASE_DIR)/%% \
	  $(BASE_DIR)/$(ENVFILE) $(addprefix $(BASE_DIR)/xml/,$(ENTITIES))
	bzip2 -9f $(TARBALL)
	@ccecho "result" "Find the tarball at:\n$(TARBALL).bz2"

#--------------
# dist-book: Create an archive with profiled xml, ENV-file, and entity
# declarations. Entities in xml sources are preserved, see explanation
# on dist-xml target
#
.PHONY: dist-book
dist-book: $(DISTPROFILE)
dist-book: link-entity-dist
dist-book: INCLUDED = $(addprefix $(PROFILE_PARENT_DIR)/dist/,\
			$(shell xsltproc --nonet $(ROOTSTRING) \
			--xinclude $(STYLESEARCH) \
	        	$(PROFILE_PARENT_DIR)/dist/$(MAIN)) $(MAIN))
dist-book: ENTITIES = $(shell $(LIB_DIR)/getentityname.py $(INCLUDED))
dist-book: TARBALL  = $(RESULT_DIR)/$(BOOK)_$(LL).tar
dist-book:
	tar chf $(TARBALL) --absolute-names \
	  --xform=s%$(PROFILE_PARENT_DIR)/dist%xml% \
	  $(sort $(INCLUDED))
	tar rhf $(TARBALL) --absolute-names --xform=s%$(BASE_DIR)/%% \
	  $(BASE_DIR)/$(ENVFILE) $(addprefix $(BASE_DIR)/xml/,$(ENTITIES))
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
  ifdef USED_PNG
	tar chf $(TARBALL) --exclude=.svn --ignore-failed-read \
          --absolute-names --xform=s%$(IMG_GENDIR)/online%images/src/png% \
          $(sort $(USED_PNG));
    # also add SVGs if available
    ifdef SVGONLINE
	tar rhf $(TARBALL) --exclude=.svn --ignore-failed-read \
	  --absolute-names --xform=s%$(IMG_GENDIR)/gen%images/src% \
	  $(sort $(SVGONLINE))
    endif
  else
        # if there are no PNGs, there must be SVGs
	tar chf $(TARBALL) --exclude=.svn --ignore-failed-read \
	  --absolute-names --xform=s%$(IMG_GENDIR)/gen%images/src% \
	  $(sort $(SVGONLINE));
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
ifdef PNGPRINT
	BZIP2=--best \
	tar cjhf $(TARBALL) --exclude=.svn --ignore-failed-read \
	  --absolute-names --xform=s%$(IMG_GENDIR)/online%images/src/png% \
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
dist-html: HTML-USED = $(addprefix $(HTML_DIR)/images/,$(USED))
dist-html: $(PROFILES) $(PROFILEDIR)/.validate $(HTML_DIR)/index.html
dist-html: provide-color-images
	BZIP2=--best \
	tar cjhf $(TARBALL) --exclude=.svn --no-recursion \
	  -T $(HTML_DIR)/HTML.manifest \
	  --absolute-names --xform=s%$(RESULT_DIR)/html/%% \
	  $(HTML-USED) $(HTML_DIR)/index.html $(HTML_DIR)/navig/* \
	  $(HTML_DIR)/admon/* $(HTML_DIR)/callouts/* \
	  $(HTML_DIR)/$(notdir $(LSTYLECSS))
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
	BZIP2=--best \
	tar cjhf $(TARBALL) --exclude=.svn --no-recursion \
	  --absolute-names --xform=s%$(RESULT_DIR)/html/%% \
	  $(HTML_DIR)/$(BOOK).html $(HTML-USED) $(HTML_DIR)/navig/* \
	  $(HTML_DIR)/admon/* $(HTML_DIR)/callouts/* \
	  $(HTML_DIR)/$(notdir $(LSTYLECSS))
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
	BZIP2=--best \
	tar cjhf $(TARBALL) --exclude=.svn --no-recursion \
	  -T $(JSP_DIR)/JSP.manifest \
	  --absolute-names --xform=s%$(RESULT_DIR)/jsp/%% \
	  $(JSP-USED) $(JSP_DIR)/index.jsp $(JSP_DIR)/navig/* \
	  $(JSP_DIR)/admon/* $(JSP_DIR)/callouts/* \
	  $(JSP_DIR)/$(notdir $(LSTYLECSS))
	@ccecho "result" "Find the tarball at:\n$(TARBALL)"

#---------------
# dist-all
#
# calls validate and chklink and creates dist-xml dist-html dist color-pdf
#
.PHONY: dist-all
dist-all: validate chklink dist-xml dist-html dist color-pdf

#------------------------------------------------------------------------
# Keep / remove stuff
#

# see images.mk
.PRECIOUS: $(SRCSVGDIA)
.PRECIOUS: $(SRCSVGFIG)
.PRECIOUS: $(IMG_GENDIR)/gen/png/%.png
.PRECIOUS: $(IMG_GENDIR)/gen/svg/%.svg


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
$(TMP_XML): $(PROFILES)
	xsltproc --xinclude --output $@ --stringparam resolve.suse-pi 1 \
        --stringparam show.comments $(COMMENTS) \
        --stringparam show.remarks $(REMARKS) \
	--stringparam projectfile PROJECTFILE.$(BOOK) $(STYLENOV) \
	$(PROFILEDIR)/$(MAIN)

#------------------------------------------------------------------------
#
# "Helper" targets for profiling ( $PROFILES and $DISTPROFILE)
# 

$(PROFILE_PARENT_DIR)/dist:
	mkdir -p $@

$(TMP_DIR)/dist/xml:
	mkdir -p $@

$(PROFILES): $(PROFILEDIR)/PROJECTFILE.$(BOOK)
$(TMPDIST): $(TMP_DIR)/dist/PROJECTFILE.$(BOOK)

#---------------
# Normal profiling
#
#
# The entity declarations are needed for the target dist-xml because we want
# to recover all the entities after the profiling step when exporting our xml.
# If STYLENOV is undefined, there is no profiling information in $MAIN. This
# means, we will continue without profiling.
#
$(PROFILEDIR)/%.xml: $(BASE_DIR)/xml/%.xml
ifdef STYLENOV
	$(QUIET)xsltproc --nonet --output $@ $(PROFSTRINGS) \
	  --stringparam filename "$(notdir $<)" $(HROOTSTRING) \
	  $(STYLENOV) $< $(QUIET2)
else
	$(QUIET)ln -sf $< $@
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
# $(DTDROOT)/etc/entities.preserve.sed and
# $(DTDROOT)/etc/entities.recover.sed. Intermediate profiled sources in
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

$(PROFILE_PARENT_DIR)/dist/%.xml: $(PROFILE_PARENT_DIR)/dist
ifdef STYLENOV
$(PROFILE_PARENT_DIR)/dist/%.xml: $(TMP_DIR)/dist/xml/%.xml
	$(QUIET)$(LIB_DIR)/entities-exchange.sh -s -d preserve $<
	$(QUIET)xsltproc --nonet --output $@ \
		$(subst show.remarks 1,show.remarks 0, \
		  $(subst show.comments 1,show.comments 0, \
		  $(PROFSTRINGS))) \
	        --stringparam filename "$(notdir $<)" \
	        $(STYLENOV) $< $(QUIET2)
	$(QUIET)$(LIB_DIR)/entities-exchange.sh -d recover $@
else
$(PROFILE_PARENT_DIR)/dist/%.xml: $(BASE_DIR)/xml/%.xml link-entity-noprofile
	$(QUIET)ln -sf $< $@
endif

#
# the TMP stuff
#
#$(TMP_DIR)/dist/xml/%.xml: $(TMP_DIR)/dist/PROJECTFILE.$(BOOK)
$(TMP_DIR)/dist/xml/%.xml: $(TMP_DIR)/dist/xml
$(TMP_DIR)/dist/xml/%.xml: $(BASE_DIR)/xml/%.xml link-entity-dist
	$(QUIET)$(LIB_DIR)/entities-exchange.sh -s -o $(dir $@) -d preserve $<


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
link-entity: ENTITIES = $(shell $(LIB_DIR)/getentityname.py $(BASE_DIR)/xml/$(MAIN))
link-entity: | $(DIRECTORIES)
	if test -n "$(ENTITIES)"; then \
	  for i in $(ENTITIES); do \
	    ln -sf $(BASE_DIR)/xml/$$i $(PROFILE_PARENT_DIR)/noprofile; \
	  done \
	fi

.PHONY: link-entity-dist
link-entity-dist: $(PROFILE_PARENT_DIR)/dist $(TMP_DIR)/dist/xml
link-entity-dist: ENTITIES = $(shell $(LIB_DIR)/getentityname.py $(BASE_DIR)/xml/$(MAIN))
link-entity-dist:
	if test -n "$(ENTITIES)"; then \
	  for i in $(ENTITIES); do \
	    ln -sf $(BASE_DIR)/xml/$$i $(PROFILE_PARENT_DIR)/dist/$$i; \
	    ln -sf $(BASE_DIR)/xml/$$i $(TMP_DIR)/dist/xml/$$i; \
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
$(PROFILEDIR)/PROJECTFILE.$(BOOK): ENTITIES = $(shell $(LIB_DIR)/getentityname.py $(BASE_DIR)/xml/$(MAIN))
$(PROFILEDIR)/PROJECTFILE.$(BOOK): | $(DIRECTORIES)
$(PROFILEDIR)/PROJECTFILE.$(BOOK): $(BASE_DIR)/$(ENVFILE)
	if test -n "$(ENTITIES)"; then \
	  for i in $(shell $(LIB_DIR)/getentityname.py $(BASE_DIR)/xml/$(MAIN)); do \
	    ln -sf $(BASE_DIR)/xml/$$i $(PROFILEDIR)/; \
	  done \
	fi
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

# Print result file names
#
.PHONY: pdf-name
pdf-name:
	@ccecho "result" "$(RESULT_DIR)/$(TMP_BOOK)-$(FOPTYPE).pdf"

.PHONY: pdf-color-name color-pdf-name
pdf-color-name color-pdf-name:
	@ccecho "result" "$(RESULT_DIR)/$(TMP_BOOK)-$(FOPTYPE)-online.pdf"


# Generate fo from xml
#
# b/w PDF
#
.PRECIOUS: $(TMP_DIR)/$(TMP_BOOK)-$(FOPTYPE).fo
ifeq ("$(INDEX)", "Yes")
$(TMP_DIR)/$(TMP_BOOK)-$(FOPTYPE).fo: $(PROFILEDIR)/$(TMP_BOOK).ind
endif
$(TMP_DIR)/$(TMP_BOOK)-$(FOPTYPE).fo: $(PROFILES) $(PROFILEDIR)/.validate
$(TMP_DIR)/$(TMP_BOOK)-$(FOPTYPE).fo: $(STYLEFO)
	xsltproc --xinclude $(FOSTRINGS) $(ROOTSTRING) $(INDEXSTRING) \
		--stringparam projectfile PROJECTFILE.$(BOOK) \
		-o $@ $(STYLEFO) \
	$(PROFILEDIR)/$(MAIN)
	@ccecho "info" "Created fo file $(TMP_DIR)/$(TMP_BOOK)-$(FOPTYPE).fo"

# Color PDF
#
.PRECIOUS: $(TMP_DIR)/$(TMP_BOOK)-$(FOPTYPE)-online.fo
ifeq ("$(INDEX)", "Yes")
$(TMP_DIR)/$(TMP_BOOK)-$(FOPTYPE)-online.fo: $(PROFILEDIR)/$(TMP_BOOK).ind
endif
$(TMP_DIR)/$(TMP_BOOK)-$(FOPTYPE)-online.fo: $(PROFILES) $(PROFILEDIR)/.validate
$(TMP_DIR)/$(TMP_BOOK)-$(FOPTYPE)-online.fo: $(STYLEFO)
	xsltproc --xinclude $(FOCOLSTRINGS) $(ROOTSTRING) $(INDEXSTRING) \
		--stringparam projectfile PROJECTFILE.$(BOOK) \
		-o $@ $(STYLEFO) \
	$(PROFILEDIR)/$(MAIN)

# Create PDF from fo
#
$(RESULT_DIR)/%.pdf: $(TMP_DIR)/%.fo $(FOP_CONFIG_FILE) provide-images warn-images
ifeq ("$(FOPTYPE)","fop")
	FOP_CONFIG_FILE=$(FOP_CONFIG_FILE) $(FOP) $(FOPOPTIONS) $< $@
else
	XEP_CONFIG_FILE=$(FOP_CONFIG_FILE) $(FOP) $(FOPOPTIONS) $< $@
endif
ifdef MISSING
	@ccecho "warn" "Looks like the following graphics are missing: $(MISSING)"
endif
	@pdffonts $@ | grep -v -e "^name" -e "^---" | cut -c 51-71 | \
		grep -v -e "yes yes yes" >& /dev/null && \
		(@ccecho "warn" "Not all fonts are embedded";) || :

# Create COLOR-PDF from fo
#
$(RESULT_DIR)/%-online.pdf: $(TMP_DIR)/%-online.fo $(FOP_CONFIG_FILE) provide-color-images warn-images
ifeq ($(FOPTYPE), fop)
	FOP_CONFIG_FILE=$(FOP_CONFIG_FILE) $(FOP) $(FOPOPTIONS) $< $@
else
	XEP_CONFIG_FILE=$(FOP_CONFIG_FILE) $(FOP) $(FOPOPTIONS) $< $@
endif
ifdef MISSING
	@ccecho "warn" "Looks like the following graphics are missing: $(MISSING)"
endif
	@pdffonts $@ | grep -v -e "^name" -e "^---" | cut -c 51-71 | \
		grep -v -e "yes yes yes" >& /dev/null && \
		(@ccecho "warn" "Not all fonts are embedded";) || :

# Index creation
#
ifeq ("$(INDEX)", "Yes")
$(PROFILEDIR)/$(TMP_BOOK).idx: $(PROFILES) $(PROFILEDIR)/.validate
	xsltproc $(ROOTSTRING) --xinclude --output $@ $(STYLEINDEX) \
	$(PROFILEDIR)/$(MAIN)

# not used
#.idx.ind:
#	$(DTDROOT)/bin/daps-sortindexterms.py -l $(LL) $< --output $@
endif

#------------------------------------------------------------------------
#
# "Helper" targets for HTML and HTML-SINGLE
#

HTMLGRAPHICS = $(HTML_DIR)/$(notdir $(LSTYLECSS)) $(HTML_DIR)/navig $(HTML_DIR)/admon $(HTML_DIR)/callouts $(HTML_DIR)/images

$(HTML_DIR):
	mkdir -p $@

$(HTML_DIR)/$(notdir $(LSTYLECSS)): $(STYLECSS) $(HTML_DIR)
	ln -sf $(STYLECSS) $(HTML_DIR)/

$(HTML_DIR)/navig: $(DTDROOT)/images/navig $(HTML_DIR)
	ln -sf $(DTDROOT)/images/navig/ $(HTML_DIR)

$(HTML_DIR)/admon: $(DTDROOT)/images/admon $(HTML_DIR) 
	ln -sf $(DTDROOT)/images/admon/ $(HTML_DIR)

$(HTML_DIR)/callouts: $(DTDROOT)/images/callouts/ $(HTML_DIR) 
	ln -sf $(DTDROOT)/images/callouts/ $(HTML_DIR)

$(HTML_DIR)/images: $(IMG_GENDIR)/online/ $(HTML_DIR) 
	ln -sf $(IMG_GENDIR)/online/ $(HTML_DIR)/images

# Print result directory names 
#
.PHONY: html-dir-name
html-dir:
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



# target to generate METAFILE for html stylesheets
#
ifdef USESVN
.PHONY: meta
meta: $(PROFILEDIR)/METAFILE

$(PROFILEDIR)/METAFILE: $(SRCFILES)
	@ccecho "info"  "Generating $@..."
	svn pl -v --xml $< > $(TMP_DIR)/.docprops.xml
	xsltproc -o $@ $(METAXSLT) $(TMP_DIR)/.docprops.xml
endif


# Generate HTML from profiled xml
#
ifdef USESVN
$(HTML_DIR)/index.html: meta
endif
$(HTML_DIR)/index.html: provide-color-images  warn-images
$(HTML_DIR)/index.html: $(STYLEH) $(PROFILES) $(HTML_DIR) $(HTMLGRAPHICS)
	xsltproc $(HTMLSTRINGS) $(ROOTSTRING) $(METASTRING) $(MANIFEST) \
		 --stringparam projectfile PROJECTFILE.$(BOOK) \
	         --xinclude $(STYLEH) $(PROFILEDIR)/$(MAIN)
	@if [ ! -f  $@ ]; then \
	  ln -sf $(HTML_DIR)/$(ROOTID).html $@; \
	fi
#ifdef ROOTID
#	ln -sf $(HTML_DIR)/$(ROOTID).html $(HTML_DIR)/index.html;
#endif

# Generate HTML SINGLE from profiled xml
#
ifdef USESVN
$(HTML_DIR)/$(BOOK).html: meta
endif
$(HTML_DIR)/$(BOOK).html: provide-color-images  warn-images
$(HTML_DIR)/$(BOOK).html: $(STYLEH) $(PROFILES) $(HTML_DIR) $(HTMLGRAPHICS)
	xsltproc $(HTMLSTRINGS) $(ROOTSTRING) $(METASTRING) $(MANIFEST) \
		 --stringparam projectfile PROJECTFILE.$(BOOK) \
		 --output $(HTML_DIR)/$(BOOK).html \
	         --xinclude $(HTMLBIGFILE) $(PROFILEDIR)/$(MAIN) 

#------------------------------------------------------------------------
#
# "Helper" targets for JSP
#

JSPGRAPHICS = $(JSP_DIR)/$(notdir $(LSTYLECSS)) $(JSP_DIR)/navig $(JSP_DIR)/admon $(JSP_DIR)/callouts $(JSP_DIR)/images

$(JSP_DIR):
	mkdir -p $@

$(JSP_DIR)/$(notdir $(LSTYLECSS)): $(STYLECSS) $(JSP_DIR)
	ln -sf $(STYLECSS) $(JSP_DIR)/

$(JSP_DIR)/navig: $(DTDROOT)/images/navig $(JSP_DIR)
	ln -sf $(DTDROOT)/images/navig/ $(JSP_DIR)

$(JSP_DIR)/admon: $(DTDROOT)/images/admon/ $(JSP_DIR)
	ln -sf $(DTDROOT)/images/admon/ $(JSP_DIR)

$(JSP_DIR)/callouts: $(DTDROOT)/images/callouts/ $(JSP_DIR)
	ln -sf $(DTDROOT)/images/callouts/ $(JSP_DIR)

$(JSP_DIR)/images: $(IMG_GENDIR)/online/ $(JSP_DIR)
	ln -sf $(IMG_GENDIR)/online/ $(JSP_DIR)/images

# Print result directory names
#
.PHONY: jsp-dir-name
jsp-dir:
	@ccecho "result" "$(JSP_DIR)"

# Generate JSP from profiled xml
#
ifdef USESVN
$(JSP_DIR)/index.jsp: meta
endif
$(JSP_DIR)/index.jsp: $(STYLEJ) $(PROFILES) $(JSP_DIR)
$(JSP_DIR)/index.jsp: provide-color-images warn-images $(JSPGRAPHICS) 
	xsltproc $(JSPSTRINGS) $(ROOTSTRING) $(METASTRING) $(XHTMLSTRING) \
		$(MANIFEST) --stringparam projectfile PROJECTFILE.$(BOOK) \
		--xinclude $(STYLEJ) $(PROFILEDIR)/$(MAIN)
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
	w3m -dump $< > $@


#------------------------------------------------------------------------
#
# "Helper" targets for EPUB
#

$(EPUB_TMP_DIR):
	mkdir -p $@

# Print result file
#
.PHONY: epub-name
epub-name:
	@ccecho "result" "$(RESULT_DIR)/$(TMP_BOOK_NODRAFT).epub"

# Generate "epub xml" from $(TMP_XML)
#
$(EPUB_TMP_DIR)/$(TMP_BOOK_NODRAFT).xml: $(TMP_XML)
	xsltproc --output $@ $(ROOTSTRING) $(STYLEPUB) $<

# Generate epub from "epub xml" file 
#
$(RESULT_DIR)/$(TMP_BOOK_NODRAFT).epub: $(EPUB_TMP_DIR)/$(TMP_BOOK_NODRAFT).xml $(STYLEPUB) validate provide-epub-images
	$(DB2EPUB) \
		-s $(STYLEPUBXSLT) \
		--verbose --css $(STYLEPUBCSS) \
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
	xsltproc --output $@ $(ROOTSTRING) --xinclude $(STYLEWIKI) \
	         $(PROFILEDIR)/$(MAIN)


#------------------------------------------------------------------------
# Miscellaneous
# should be moved to make/misc.mk
#

#---------------
# Check external links (<ulink>)
#
.PHONY: chklink jana
chklink jana: $(PROFILES)
	xsltproc --xinclude --noout $(ROOTSTRING) -o $(TESTPAGE) $(STYLELINKS) \
		 $(PROFILEDIR)/$(MAIN)
	checkbot --url file://localhost/$(TESTPAGE) \
		    $(CB_OPTIONS) --file $(TMP_DIR)/$(BOOK)-checkbot.html
	@ccecho "result" "Find the link check report at:\nfile://$(TMP_DIR)/$(BOOK)-checkbot-localhost.html"


#---------------
# DocBook to NovDoc conversion
#

.PHONY: db2novdoc 
db2novdoc: $(TMP_DIR)/$(TMP_BOOK_NODRAFT)/$(BOOK)-novdoc.xml
	xsltproc --output $< $(ROOTSTRING) $(STYLEDB2ND) $(TMP_XML)
	xmllint --noent --valid \
		--noout $(TMP_DIR)/$(TMP_BOOK_NODRAFT)/$(BOOK)-novdoc.xml
	mv -iv $(TMP_DIR)/$(TMP_BOOK_NODRAFT)/$(BOOK)-novdoc.xml \
		$(BASE_DIR)/xml/

$(TMP_DIR)/$(TMP_BOOK_NODRAFT)/$(BOOK)-novdoc.xml: ENTITIES = $(shell $(LIB_DIR)/getentityname.py $(BASE_DIR)/xml/$(MAIN))
$(TMP_DIR)/$(TMP_BOOK_NODRAFT)/$(BOOK)-novdoc.xml: $(TMP_XML)
	mkdir -p $(dir $@)
	ln -sf $< $@
	if test -n "$(ENTITIES)"; then \
	  for i in $(ENTITIES); do \
	    ln -sf $(BASE_DIR)/xml/$$i $(dir $@); \
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
	@echo "$($(VARIABLE))"
endif

#---------------
# Print a set of selected variables
#
.PHONY: check
check: ROOTIDS = $(shell xsltproc --xinclude $(ROOTSTRING) $(STYLEROOTIDS) $(PROFILEDIR)/$(MAIN))
check:
	@echo "XML_CATALOG_FILES = $(XML_CATALOG_FILES)"
	@echo "DTDROOT           = $(DTDROOT)"
	@echo "STYLENOV          = $(STYLENOV)"
	@echo
	@echo "LL                = $(LL)"
	@echo "PROFARCH          = $(PROFARCH)"
	@echo "PROFOS            = $(PROFOS)"
	@echo "MAIN              = $(BASE_DIR)/$(MAIN)"
	@echo "BOOK              = $(BOOK)"
	@echo "COMMENTS          = $(COMMENTS)"
	@echo "REMARKS           = $(REMARKS)"
	@echo "DISTVER           = $(DISTVER)"
	@echo "FOP               = $(FOP)"
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
	@echo "FOPTYPE           = $(FOPTYPE)"
	@echo "STYLENOV          = $(STYLENOV)"
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
	echo "Done doing nothing"



