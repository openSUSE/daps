# Copyright (C) 2012-20175 SUSE Linux GmbH
#
# Author:
# Frank Sundermeyer <fsundermeyer at opensuse dot org>
#
# Convert asciidoc to DocBook5
#
# Please submit feedback or patches to
# <fsundermeyer at opensuse dot org>
#

ifndef ADOC_TYPE
  ADOC_TYPE := book
endif

#--------------------------------------------------
# CHECKS
#

# Check whether asciidoctor is present. If not, fall back to asciidoc

HAS_ASCIIDOCTOR := $(shell which asciidoctor 2>/dev/null)
ifdef HAS_ASCIIDOCTOR
  ASCIIDOC     := $(HAS_ASCIIDOCTOR)
  ADOC_BACKEND := docbook5
else
  HAVE_ASCIIDOC := $(shell which asciidoc 2>/dev/null)
  ifdef HAS_ASCIIDOCTOR
    ASCIIDOC     := $(HAS_ASCIIDOC)
    ADOC_BACKEND := docbook45
  else
    $(error $(shell ccecho "error" "Error: Neither asciidoctor nor asciidoc is installed"))
  endif
endif

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

#ADOC_SRCFILES := $(wildcard $(shell grep "include::" $(MAIN) | sed 's/.*::\([^\[]*\).*/\1/g'))

# Get the adoc source files. Since it is not possible to get a list of included
# files from adoc, we assume that all *.adoc files are sources
#
ADOC_SRCFILES := $(wildcard $(DOC_DIR)/adoc/*.adoc)

all: $(MAIN)

$(MAIN): $(ADOC_SRCFILES) | $(ADOC_DIR)
  ifeq "$(VERBOSITY)" "2"
	@ccecho "info"  "   Creating XML from ASCIIDOC..."
  endif
	asciidoc --attribute=imagesdir! --backend=$(ADOC_BACKEND) \
	  --doctype=$(ADOC_TYPE) --out-file=$@ $(ADOC_MAIN)
  ifeq "$(VERBOSITY)" "2"
	@ccecho "info" "Successfully created XML file $@"
  endif


### 	asciidoc --attribute=imagesdir! --conf-file=$(ADOC_CONFIG_FILE) \
	  --doctype=$(ADOC_TYPE) --out-file=$@ $(ADOC_MAIN)


$(ADOC_DIR):
	@mkdir -p $@
