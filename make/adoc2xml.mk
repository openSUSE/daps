# Copyright (C) 2012-2020 SUSE Software Solutions Germany GmbH
#
# Author:
# Frank Sundermeyer <fsundermeyer at opensuse dot org>
#
# Convert asciidoc to DocBook5
#
# Please submit feedback or patches to
# <fsundermeyer at opensuse dot org>
#

#--------------------------------------------------
# CHECKS
#

# Some variables need to be preset from the wrapper script
# Double-check whether they are set
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
ifndef ADOC_MAIN
  $(error $(shell ccecho "error" "Fatal error: No MAIN file set"))
endif

# ADOC default attributes

# overridable defaults: idprefix and idseparator are set to avoid AsciiDoctor's
# default underscores which will appear in URLs and are causing SEO penalties
# by Google (however, we only replace id* attributes if not set in the
# .adoc sources)

ADOC_OVERRIDABLE_ATTRIBUTES := --attribute="idprefix=id-@" \
			   --attribute="idseparator=-@"

# fixed defaults: get rid of any data-url and imagesdir definitions to make
# DAPS produce correct links.

ADOC_DEFAULT_ATTRIBUTES := --attribute=data-uri! \
			   --attribute=imagesdir! \
			   --attribute=attribute-missing=warn

# If ASCIICoc attrributes are specified with the DAPS command line or
# via the DC file, the asciidoc attribute "daps-adoc-attributes"
# will be set and will contain all key=value paiirs specified this way.
# This allows to use daps-adoc-attributes in the asciidoc sources in order to
# display these very parameters by using something like
#
# ifeval::[ "\{daps-adoc-attributes}" != "" ]
# This document was build using the following {adoc} attributes:
#
# [source, subs="attributes"]
# ----
# {daps-adoc-attributes}
# ----
# endif::[]
#
# remove  --attribute= and sort key/value pairs
#
ADOC_SHOW_ATTRIBUTES := $(subst --attribute=,,$(ADOC_ATTRIBUTES))
ADOC_SHOW_ATTRIBUTES := $(sort $(strip $(subst --attribute,,$(ADOC_SHOW_ATTRIBUTES))))
ADOC_SHOW_ATTRIBUTES := --attribute=daps-adoc-attributes="$(ADOC_SHOW_ATTRIBUTES)"

# Check whether asciidoctor supports --failure-level (since version 1.5.7)
#
_ADOC_VERSION := 1.5.7
_ADOC_VERSION += $(shell $(ASCIIDOC) --version | head -n1 | awk '{print $$2}')

# Nasty workaround to compare version strings. 
# We are creating a string with "1.5.7 <current>",
#  e.g. "1.5.7 1.2.1" in $(_ADOC_VERSION)
# Afterwards we are sorting it (lowest first) in $(_ADOC_VERSION_SORT)
# Afterwards both strings are compared. If both are the same, the asciidoctor
# version is >=1.5.7, otherwise it is lower than that (which means it does not
# support the --failure-level switch)

_ADOC_VERSION_SORT := $(shell echo "$(_ADOC_VERSION)" | tr " " "\n" | sort -b --version-sort )

_ADOC_SUPPORTS_FAILURE := $(shell if [ "$(_ADOC_VERSION)" == "$(_ADOC_VERSION_SORT)" ]; then echo "yes"; else echo "no"; fi)

ifeq "$(strip $(_ADOC_SUPPORTS_FAILURE))" "yes"
  ADOC_FAILURE := --failure-level $(ADOC_FAILURE_LEVEL)
endif

# Get the adoc sourcefiles
#
# include statements always start at the begin of the line, no other
# characters (incl. space) are allowed before it
#
# If grep fails, we at least have ADOC_MAIN
#
ADOC_SRCFILES := $(ADOC_MAIN) $(wildcard $(addprefix \
 $(DOC_DIR)/adoc/,$(shell egrep '^include::' $(ADOC_MAIN) 2>/dev/null | sed 's/.*::\([^\[]*\).*/\1/g' 2>/dev/null)))
#ADOC_SRCFILES := $(wildcard $(DOC_DIR)/adoc/*.adoc)

#
# ADOC sources usually have images in a single directory. If ADOC_IMG_DIR
# is set (via --adocimgdir), we will set up the required image structure
# automatically

ifneq "$(strip $(ADOC_IMG_DIR))" ""
  IDIR :=  $(BUILD_DIR)/.adoc_images/src

  DIA_DIR := $(IDIR)/dia
  DIA     := $(subst $(ADOC_IMG_DIR)/,$(DIA_DIR)/,$(wildcard $(ADOC_IMG_DIR)/*.dia))
  EPS_DIR := $(IDIR)/eps
  EPS     := $(subst $(ADOC_IMG_DIR)/,$(EPS_DIR)/,$(wildcard $(ADOC_IMG_DIR)/*.eps))
  JPG_DIR := $(IDIR)/jpg
  JPG     := $(subst $(ADOC_IMG_DIR)/,$(JPG_DIR)/,$(wildcard $(ADOC_IMG_DIR)/*.jpg))
  ODG_DIR := $(IDIR)/odg
  ODG     := $(subst $(ADOC_IMG_DIR)/,$(ODG_DIR)/,$(wildcard $(ADOC_IMG_DIR)/*.odg))
  PDF_DIR := $(IDIR)/pdf
  PDF     := $(subst $(ADOC_IMG_DIR)/,$(PDF_DIR)/,$(wildcard $(ADOC_IMG_DIR)/*.pdf))
  PNG_DIR := $(IDIR)/png
  PNG     := $(subst $(ADOC_IMG_DIR)/,$(PNG_DIR)/,$(wildcard $(ADOC_IMG_DIR)/*.png))
  SVG_DIR := $(IDIR)/svg
  SVG     := $(subst $(ADOC_IMG_DIR)/,$(SVG_DIR)/,$(wildcard $(ADOC_IMG_DIR)/*.svg))

  NEW_IMAGES      := $(DIA) $(EPS) $(JPG) $(ODG) $(PDF) $(PNG) $(SVG)
  NEW_IMAGES_DIRS := $(DIA_DIR) $(EPS_DIR) $(JPG_DIR) $(ODG_DIR) $(PDF_DIR) $(PNG_DIR) $(SVG_DIR)
endif

all: $(MAIN)
ifneq "$(strip $(ADOC_IMG_DIR))" ""
  all: $(NEW_IMAGES)
endif

#
# Since asciidoctor only refuses to write a file on FATAL errors
# (but we already exit on ERROR and WARN), we always need to rebuild
# MAIN. According to https://stackoverflow.com/questions/7643838/how-to-force-make-to-always-rebuild-a-file
# this should do the trick
#

.PHONY: FORCE
FORCE:

#
# If ADOC_SET is set to 1 (and we are to create a set from an AsciiDoc
# multipart book), pipe the asciidoctor output to an xsltproc call
# runinng the "setify" stylesheet, otherwise let asciidoctor create
# the file directly
#
# set -o pipefail makes sure make exits when the asciidoctor command
# returns != 0

#all: $(MAIN)
$(MAIN): FORCE $(ADOC_SRCFILES) | $(ADOC_DIR)
  ifeq "$(VERBOSITY)" "2"
	@ccecho "info"  "   Creating XML from AsciiDoc..."
  endif
  ifeq "$(ADOC_SET)" "yes"
	  (set -o pipefail; $(ASCIIDOC) \
	  $(ADOC_OVERRIDABLE_ATTRIBUTES) $(ADOC_ATTRIBUTES) $(ADOC_DEFAULT_ATTRIBUTES)  $(ADOC_SHOW_ATTRIBUTES) \
	  --backend=$(ADOC_BACKEND) \
	  --doctype=$(ADOC_TYPE) $(ADOC_FAILURE) \
	  --out-file=- $(ADOC_MAIN) | $(XSLTPROC) --output $@ --xinclude \
	  --stylesheet $(ADOC_SET_STYLE) $(XSLTPROCESSOR) $(DEVNULL) \
	  $(ERR_DEVNULL))
  else
	$(ASCIIDOC) \
	  $(ADOC_OVERRIDABLE_ATTRIBUTES) $(ADOC_ATTRIBUTES) $(ADOC_DEFAULT_ATTRIBUTES) $(ADOC_SHOW_ATTRIBUTES) \
	  --backend=$(ADOC_BACKEND) --doctype=$(ADOC_TYPE) \
	  $(ADOC_FAILURE) --out-file=$@ $(ADOC_MAIN)
  endif
  ifeq "$(VERBOSITY)" "2"
	@ccecho "info" "Successfully created XML file $@"
  endif

$(DIA_DIR)/%.dia: $(ADOC_IMG_DIR)/%.dia | $(DIA_DIR)
	(cd $(@D); ln -sf $<)

$(EPS_DIR)/%.eps: $(ADOC_IMG_DIR)/%.eps | $(EPS_DIR)
	(cd $(@D); ln -sf $<)

$(JPG_DIR)/%.jpg: $(ADOC_IMG_DIR)/%.jpg | $(JPG_DIR)
	(cd $(@D); ln -sf $<)

$(ODG_DIR)/%.odg: $(ADOC_IMG_DIR)/%.odg | $(ODG_DIR)
	(cd $(@D); ln -sf $<)

$(PDF_DIR)/%.pdf: $(ADOC_IMG_DIR)/%.pdf | $(PDF_DIR)
	(cd $(@D); ln -sf $<)

$(PNG_DIR)/%.png: $(ADOC_IMG_DIR)/%.png | $(PNG_DIR)
	(cd $(@D); ln -sf $<)

$(SVG_DIR)/%.svg: $(ADOC_IMG_DIR)/%.svg | $(SVG_DIR)
	(cd $(@D); ln -sf $<)

$(ADOC_DIR) $(NEW_IMAGES_DIRS):
	@mkdir -p $@
