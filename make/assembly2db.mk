# Copyright (C) 2012-2022 SUSE Software Solutions Germany GmbH
#
# Author:
# Frank Sundermeyer <fsundermeyer at opensuse dot org>
#
# Convert asciidoc to DocBook5
#
# Please submit feedback or patches to
# <fsundermeyer at opensuse dot org>
#

include $(DAPSROOT)/make/common_variables.mk

# Stylesheets and Settings
# Can be overwritten in DC files or in shell
STYLEASSEMBLY  ?= $(firstword $(wildcard $(addsuffix \
	        /assembly/assemble.xsl, $(STYLE_ROOTDIRS))))

# Error out if no assembly stylesheet can be found
ifeq "$(strip $(STYLEASSEMBLY))" ""
  $(error "FATAL: Could not find assembly/assemble.xsl in the given stylesheet paths. Do you have DocBook >= 5.2 and the respective stylesheets installed?")
endif

# used to select one structure among several (if assembly file provides
# multiple structures)
# Let's use ROOTID for this purpose
# NEEDS TO BE FIXED: ASSEMBLY_STRUCTURE and ROOTID are bothe needed
#
ifneq "$(strip $(STRUCTID))" ""
  ASSEMBLYSTRINGS := --stringparam "structure.id=$(STRUCTID)"
endif

all: $(MAIN)

$(MAIN): $(ASSEMBLY_MAIN) | $(ASSEMBLY_RESULTDIR)
  ifeq "$(VERBOSITY)" "2"
	@ccecho "info"  "   Creating XML bigfile from assembly..."
  endif
	$(XSLTPROC) $(ASSEMBLYSTRINGS) $(XSLTPARAM) $(PARAMS) \
	    $(STRINGPARAMS) --output $@ --stylesheet $(STYLEASSEMBLY) \
	    --xinclude --file $< $(XSLTPROCESSOR) $(DEVNULL) \
	    $(ERR_DEVNULL);
  ifeq "$(VERBOSITY)" "2"
	@ccecho "info" "Successfully created XML bigfile $@"
  endif

$(ASSEMBLY_RESULTDIR):
	@mkdir -p $@
