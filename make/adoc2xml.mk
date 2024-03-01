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
ifndef PRJ_DIR
  $(error $(shell ccecho "error" "Fatal error: No path to working directory set"))
endif
ifndef SRC_DIR
  $(error $(shell ccecho "error" "Fatal error: No path to doc source files set"))
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
# via external script  $(LIBEXEC_DIR)/get_adoc_includes.sh
# (also gets includes within includes)
#

ADOC_DOCINFO := $(addsuffix -docinfo.xml,$(basename $(ADOC_MAIN)))
ADOC_SRCFILES := $(realpath $(wildcard $(addprefix $(ADOC_SRC_DIR)/,$(shell $(LIBEXEC_DIR)/get_adoc_includes.sh $(ADOC_MAIN)))) $(wildcard $(ADOC_DOCINFO)))

all: $(MAIN)

# If ADOC_SET is set to 1 (and we are to create a set from an AsciiDoc
# multipart book), pipe the asciidoctor output to an xsltproc call
# runinng the "setify" stylesheet, otherwise let asciidoctor create
# the file directly
#
# set -o pipefail makes sure make exits when the asciidoctor command
# returns != 0

$(MAIN): $(ADOC_SRCFILES) | $(ADOC_RESULT_DIR)
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

$(ADOC_RESULT_DIR):
	@mkdir -p $@
