# Copyright (C) 2012-2022 SUSE Software Solutions Germany GmbH
#
# Author:
# Frank Sundermeyer <fsundermeyer at opensuse dot org>
#
# Convert DocBook assemblies to a DocBook bigfile ("realized XML")
#
# Please submit feedback or patches to
# <fsundermeyer at opensuse dot org>
#

include $(DAPSROOT)/make/common_variables.mk

# Stylesheets and Settings

STYLEASSEMBLY  := $(firstword $(wildcard $(addsuffix \
	        /assembly/assemble.xsl, $(STYLE_ROOTDIRS))))

# used to select one structure among several (if assembly file provides
# multiple structures)
# Let's use ROOTID for this purpose
#
ifneq "$(strip $(ROOTID))" ""
  ASSEMBLYSTRINGS := --stringparam "structure.id=$(ROOTID)"
endif

# Since we do not have a list of files used from the assembly, we always need
# to rebuild. According to
# https://stackoverflow.com/questions/7643838/how-to-force-make-to-always-rebuild-a-file
# this should do the trick
#

#.PHONY: FORCE
#FORCE:

#
# If ADOC_SET is set to 1 (and we are to create a set from an AsciiDoc
# multipart book), pipe the asciidoctor output to an xsltproc call
# runinng the "setify" stylesheet, otherwise let asciidoctor create
# the file directly
#
# set -o pipefail makes sure make exits when the asciidoctor command
# returns != 0

#all: $(MAIN)
$(MAIN): $(ASSEMBLY_MAIN) | $(ASSEMBLY_RESULTDIR)
  ifeq "$(VERBOSITY)" "2"
	@ccecho "info"  "   Creating XML bigfile from assembly..."
  endif
	$(XSLTPROC) $(ASSEMBLYSTRINGS) $(XSLTPARAM) $(PARAMS) \
	    $(STRINGPARAMS) --output $@ --stylesheet $(STYLEASSEMBLY) \
	    --file $< $(XSLTPROCESSOR) $(DEVNULL) \
	    $(ERR_DEVNULL);
  ifeq "$(VERBOSITY)" "2"
	@ccecho "info" "Successfully created XML bigfile $@"
  endif

$(ASSEMBLY_RESULTDIR):
	@mkdir -p $@
