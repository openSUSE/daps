# Copyright (C) 2012-2015 SUSE Linux GmbH
#
# Author:
# Frank Sundermeyer <fsundermeyer at opensuse dot org>
#
# Profiling stuff for DAPS
#
# Please submit feedback or patches to
# <fsundermeyer at opensuse dot org>
#

# includes are set in selector.mk
# include $(DAPSROOT)/make/setfiles.mk

# Files included with xi:include parse="text" $(TEXTFILES) are linked into
# the profile directory. the profiling stylesheets rewrites all paths to
# these files with just the filename (href="../foo/bar.txt" -> href="bar.txt")
# Since these text files can come from arbitrary locations, it is not possible
# to write a pattern rule for creating the links. We use the
# PHONY link_txt_files to generate them.

PROFILES      := $(sort $(subst $(DOC_DIR)/xml/,$(PROFILEDIR)/,$(SRCFILES)))

# Will be used on profiling only
#
ifdef HTMLROOT
  HROOTSTRING  := --stringparam "provo.root=$(HTMLROOT)"
endif

# Allows to set a custom publication date
#
ifdef SETDATE
  ifdef PROFILE_URN
    PROFSTRINGS += --stringparam "pubdate=$(SETDATE)"
    .INTERMEDIATE: $(PROFILES)
  else
    $(warn $(shell ccecho "warn" "Warning: Ignoring --setdate option since $(MAIN) does not include a profiling URN"))
  endif
endif

# Resolve profile urn because saxon does not accept urns
#
ifdef PROFILE_URN
  ifeq "$(shell expr substr $(PROFILE_URN) 1 4)" "urn:"
    PROFILE_STYLESHEET := $(shell $(DAPSROOT)/libexec/xml_cat_resolver $(PROFILE_URN) 2>/dev/null )
  else
    PROFILE_STYLESHEET := $(PROFILE_URN)
  endif
  #
  # depending on the distribution, xmlcatalog returns file://... or file:... 
  # make sure both cases are matched
  #
  PROFILE_STYLESHEET := $(subst //,,$(subst file:,,$(PROFILE_STYLESHEET)))
  ifeq "$(strip $(PROFILE_STYLESHEET))" ""
    $(error $(shell ccecho "error" "Could not resolve URN \"$(PROFILE_URN)\" with xmlcatalog via catalog file \"$(XML_MAIN_CATALOG)\""))
  endif
else
  ifeq "$(DOCBOOK_VERSION)" "5"
    PROFILE_STYLESHEET := $(DAPSROOT)/daps-xslt/profiling/noprofile5.xsl
  else
    PROFILE_STYLESHEET := $(DAPSROOT)/daps-xslt/profiling/noprofile4.xsl
  endif
endif

# Also needs a prerequisite on the entity files, since entities are resolved
# during profiling, so profiling needs to be redone whenever the entities
# change. 
# The like is also true for the DC file.
#
$(PROFILES): $(ENTITIES_DOC) $(DOCCONF)
ifdef TEXTFILES
  $(PROFILES): link_txt_files
endif

.PHONY: profile
profile: $(PROFILES)
  ifeq "$(MAKECMDGOALS)" "profile"
	@ccecho "result" "Profiled sources can be found at\n$(PROFILEDIR)"
  endif

# Profiling stringparams
#... are already defined in setfiles.mk

#--------------------------------------------------
# Normal profiling
#
# Creating the profiled xml sources
#
# linking the entity files is not needed when profiling, because the
# entities are already resolved
#

$(PROFILEDIR)/%.xml: $(DOC_DIR)/xml/%.xml | $(PROFILEDIR)
  ifeq "$(VERBOSITY)" "2"
	@(tput el1; echo -en "\r   Profiling $<")
  endif
	$(XSLTPROC) --output $@ $(PROFSTRINGS) $(HROOTSTRING) \
	  --stringparam "filename=$(notdir $<)" \
	  --stylesheet $(PROFILE_STYLESHEET) --file $< $(XSLTPROCESSOR)


# Files listed in TEXTFILES are relative to the XML directory
#
# "Clean" paths and file:// entries are supported, other protocols not
#
ifdef TEXTFILES
  .PHONY: link_txt_files
  link_txt_files: | $(PROFILEDIR)
	for TF in $(TEXTFILES); do \
	  TF=$${TF#file://*}; \
	  if [[ "$${TF:0:1}" != "/" ]]; then \
	    TF="$(DOC_DIR)/xml/$$TF"; \
	    (cd $(PROFILEDIR) && ln -sf $$(realpath --relative-to="$(PROFILEDIR)" $$TF)); \
	  else \
	    (cd $(PROFILEDIR) && ln -sf $$TF); \
	  fi; \
	done
endif
