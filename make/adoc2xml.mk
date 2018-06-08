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

all: $(MAIN)
$(MAIN): $(ADOC_SRCFILES) | $(ADOC_DIR)
  ifeq "$(VERBOSITY)" "2"
	@ccecho "info"  "   Creating XML from ASCIIDOC..."
  endif
	$(ASCIIDOC) --attribute=imagesdir! $(ADOC_ATTRIBUTES) \
          --backend=$(ADOC_BACKEND) --doctype=$(ADOC_TYPE) \
          --out-file=$@ $(ADOC_MAIN)
  ifeq "$(VERBOSITY)" "2"
	@ccecho "info" "Successfully created XML file $@"
  endif

### 	asciidoc --attribute=imagesdir! --conf-file=$(ADOC_CONFIG_FILE) \
	  --doctype=$(ADOC_TYPE) --out-file=$@ $(ADOC_MAIN)


$(ADOC_DIR):
	@mkdir -p $@
