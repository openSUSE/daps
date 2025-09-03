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
# Prefer the one shipped with DAPS
# Can be overwritten in DC files or in shell

STYLEASSEMBLY  ?= $(firstword $(wildcard $(DAPSROOT)/daps-xslt/assembly/assemble.xsl $(addsuffix \
	            /assembly/assemble.xsl, $(STYLE_ROOTDIRS))))

# Error out if no assembly stylesheet can be found
ifeq "$(strip $(STYLEASSEMBLY))" ""
  $(error "FATAL: Could not find assembly/assemble.xsl in the given stylesheet paths. Do you have DocBook >= 5.2 and the respective stylesheets installed?")
endif

#
# Stylesheet to list the resources of an assembly
#
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

# ../common/legal.xml -> $(PRJ_DIR)/common/legal.xml
#
ASSEMBLYFILES := $(addprefix $(PRJ_DIR)/,$(subst ../,,$(sort $(shell $(XSLTPROC) --param "header=0" --xinclude --stylesheet $(GETRESOURCES) --file $(ASSEMBLY_MAIN) $(XSLTPROCESSOR) 2>/dev/null ))))

# The list of files we touch to "store" the successful validation result
# $(PRJ_DIR)/common/legal.xml -> $(ASSEMBLY_RESULT_DIR)/common/legal.avalidate
# use .avlaidate rather than .validate to not get in conflict with the general
# .validate rule in make/validate.mk
#
ASSEMBLY_VALIDATION_FILES := $(subst $(PRJ_DIR),$(ASSEMBLY_RESULT_DIR),$(subst .xml,.avalidate,$(ASSEMBLYFILES) $(ASSEMBLY_MAIN)))

# we want to mirror the directory structure of the assemblies in ASSEMBLY_RESULT_DIR
# to make it easy to create a pattern rule for the valildation
#
ASSEMBLY_RESULT_SUBDIRS := $(sort $(dir $(ASSEMBLY_VALIDATION_FILES)))

# The main files needs to be validated with jing _and_ xmllint (only the latter
# catches unresolved entities). Sigh.
#
ASSEMBLY_JING_VALIDATION_MAIN := $(subst $(PRJ_DIR),$(ASSEMBLY_RESULT_DIR),$(subst .xml,.jvalidate,$(ASSEMBLY_MAIN)))


#
# Create the big file that is passed as MAIN to the "regular make mechanics
#
all: $(MAIN) $(ASSEMBLYFILES)

$(MAIN): $(ASSEMBLY_MAIN) $(ASSEMBLY_JING_VALIDATION_MAIN) $(ASSEMBLY_VALIDATION_FILES) | $(ASSEMBLY_RESULT_DIR)
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
# We need to validate MAIN (the assembly file) with jing to check whether it
# adheres to the assembly validation schema and for checking IDs.
#
# The resources files are validated with xmllint for well-formedness. This
# also includes a second validation of the assembly to check for unresovable
# entities (something jing does not do)

$(ASSEMBLY_JING_VALIDATION_MAIN): $(ASSEMBLY_MAIN) | $(ASSEMBLY_RESULT_DIR) $(ASSEMBLY_RESULT_SUBDIRS)
	$(JING_WRAPPER) -i $(ASSEMBLY_RNG) $<
	touch $@

$(ASSEMBLY_RESULT_DIR)/%.avalidate: $(PRJ_DIR)/%.xml | $(ASSEMBLY_RESULT_DIR) $(ASSEMBLY_RESULT_SUBDIRS)
	${LIBEXEC_DIR}/daps-xmlwellformed --xinclude $<
	touch $@

$(ASSEMBLY_RESULT_DIR) $(ASSEMBLY_RESULT_SUBDIRS):
	@mkdir -p $@
