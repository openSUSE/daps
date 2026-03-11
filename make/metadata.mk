# Copyright (C) 2012-2015 SUSE Linux Products GmbH
#
# Author:
# Frank Sundermeyer <fsundermeyer at opensuse dot org>
#
# Metadata target for DAPS
#
# Please submit feedback or patches to
# <fsundermeyer at opensuse dot org>
#
# Returns various metadata from the XML in json or human
# readable format

# Defined in common_variables:
#
#LOCDROP_TMP_DIR
#MANIFEST_TRANS
#MANIFEST_NOTRANS


################################
#  !!!! IMPORTANT !!!! 
#
# This makefile _only_ works when profiled XML files exist, since this is
# a prerequisite for generating the image file lists
#
# This cannot be solved with dependencies,
# therefore "profile_first" MUST be called in the wrapper script prior to
# executing the locdrop target
#################################

#---------------
# Metadata
#
# requires filelist.mk because of a setting for FILE4ID

METAFILE = $(PROFILEDIR)/$(notdir $(FILE4ID))
ifeq "$(ROOTID)" ""
  _ROOTID = $(shell $(XMLSTARLET) sel -N d=http://docbook.org/ns/docbook -T -t -v "/d:*/@xml:id" $(METAFILE))
else
  _ROOTID = $(ROOTID)
endif

METAPARAMS := --stringparam "rootid=$(_ROOTID)"
ifeq "$(PRETTY_OUTPUT)" "1"
  METAPARAMS += --param "json=0"
endif

.PHONY: metadata
metadata: $(PROFILES) $(DOCFILES) validate
ifneq "$(METADATA_OUTPUT)" ""
	@$(XSLTPROC) $(PARAMS) $(STRINGPARAMS) $(METAPARAMS) --stylesheet $(META_STYLE) --file $(METAFILE) $(XSLTPROCESSOR) 2>/dev/null > $(METADATA_OUTPUT)
	@echo "Find the metadata at $(METADATA_OUTPUT)"
else
	@$(XSLTPROC) $(PARAMS) $(STRINGPARAMS) $(METAPARAMS) --stylesheet $(META_STYLE) --file $(METAFILE) $(XSLTPROCESSOR) 2>/dev/null
endif
