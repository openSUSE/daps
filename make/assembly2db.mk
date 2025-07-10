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
GETRESOURCES := $(DAPSROOT)/daps-xslt/assembly/find-resources.xsl

# used to select one structure among several (if assembly file provides
# multiple structures)
# Let's use ROOTID for this purpose
# NEEDS TO BE FIXED: ASSEMBLY_STRUCTURE and ROOTID are bothe needed
#
ifneq "$(strip $(STRUCTID))" ""
  ASSEMBLYSTRINGS := --stringparam "structure.id=$(STRUCTID)"
endif

# Get list of all resource files
#
# GETRESOURCES produces a list of paths relative to the assembly, e.g.
# ../common/legal.xml. We will replace ../ with PRJ_DIR
# use sort to get rid of empty lines
#
# Make this a two step process to also generate the empty files that indicate
# successful validation (located under $(ASSEMBLY_RESULT_DIR))
# Since resource files are located in several subdirectories, filenames may be
# the same across subdirectories (foo/bar.xml, bar/bar.xml), therfore we are
# using the directory name as a prefix: foo_bar.validate bar_bar-validate
#

# ../common/legal.xml -> common/legal.xml
ASSEMBLYFILES := $(subst ../,,$(sort $(shell $(XSLTPROC) --param "header=0" --xinclude --stylesheet $(GETRESOURCES) --file $(ASSEMBLY_MAIN) $(XSLTPROCESSOR))))

# common/legal.xml -> common_legal.validate
ASSEMBLY_VALIDATION_FILES := $(addprefix $(ASSEMBLY_RESULT_DIR)/,$(addsuffix .validate,$(basename $(subst /,_,$(ASSEMBLYFILES)))))
ASSEMBLY_VALIDATION_MAIN  := $(addprefix $(ASSEMBLY_RESULT_DIR)/,$(addsuffix .validate,$(notdir $(basename $(ASSEMBLY_MAIN)))))

# common/legal.xml -> $(PRJ_DIR)/common/legal.xml
ASSEMBLYFILES := $(addprefix $(PRJ_DIR)/,$(ASSEMBLYFILES))

#$(error $(ASSEMBLYFILES))



all: $(MAIN)

$(MAIN): $(ASSEMBLY_MAIN) $(ASSEMBLY_VALIDATION_MAIN) $(ASSEMBLY_VALIDATION_FILES) | $(ASSEMBLY_RESULT_DIR)
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

# Assembly validation
# see https://github.com/openSUSE/daps/issues/732 for why this is needed
# We need to validate MAIN with jing and the assembly validation schema
# and the resources files with xing

$(ASSEMBLY_VALIDATION_MAIN): $(ASSEMBLY_MAIN) | $(ASSEMBLY_RESULT_DIR)
	$(JING_WRAPPER) -i $(ASSEMBLY_RNG) $<
	touch $@

$(ASSEMBLY_VALIDATION_FILES): $(ASSEMBLYFILES) | $(ASSEMBLY_RESULT_DIR)
	${LIBEXEC_DIR}/daps-xmlwellformed --xinclude $<
	touch $@

$(ASSEMBLY_RESULT_DIR):
	@mkdir -p $@
