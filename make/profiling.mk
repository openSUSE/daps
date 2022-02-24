# Copyright (C) 2012-2020 SUSE Software Solutions Germany GmbH
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

#
# Set $(PROFILES) and the profiling stylesheets.
# AsciiDoc:
#
# If ADOC_POST is set to yes, we use ADOC_POST_STYLE, otherwise a noprofile
# stylesheet
#
# XML:
#
# If PROFILE_URN is set, we resolve it, otherwise we use a nonprofiling
# stylesheet 

ifeq "$(strip $(SRC_FORMAT))" "adoc"
  PROFILES := $(subst $(ADOC_RESULT_DIR)/,$(PROFILEDIR)/,$(MAIN))
  ifeq "$(strip $(ADOC_POST))" "yes"
    PROFILE_STYLESHEET := $(ADOC_POST_STYLE)
  endif
else 
  PROFILES := $(sort $(subst $(SRC_DIR)/,$(PROFILEDIR)/,$(SRCFILES)))
  ifdef PROFILE_URN
    # Resolve profile urn because saxon does not accept urns
    ifeq "$(shell expr substr $(PROFILE_URN) 1 4 2>/dev/null)" "urn:"
      PROFILE_STYLESHEET := $(shell $(DAPSROOT)/libexec/xml_cat_resolver $(PROFILE_URN) 2>/dev/null)
    else
      PROFILE_STYLESHEET := $(PROFILE_URN)
    endif
    #
    # depending on the distribution, xmlcatalog returns file://... or file:... 
    # make sure both cases are matched
    #
    PROFILE_STYLESHEET := $(patsubst //%,%,$(subst file:%,%,$(PROFILE_STYLESHEET)))
    ifeq "$(strip $(PROFILE_STYLESHEET))" ""
      $(error $(shell ccecho "error" "Could not resolve URN \"$(PROFILE_URN)\" with xmlcatalog via catalog file \"$(XML_MAIN_CATALOG)\""))
    endif
  endif
endif

#
# If not profiling stylesheet has been set by now, we need to use a
# noprofiling stylesheet
#
ifeq "$(strip $(PROFILE_STYLESHEET))" ""
  ifeq "$(DOCBOOK_VERSION)" "5"
    PROFILE_STYLESHEET := $(DAPSROOT)/daps-xslt/profiling/noprofile5.xsl
  else
    PROFILE_STYLESHEET := $(DAPSROOT)/daps-xslt/profiling/noprofile4.xsl
  endif
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

# Also needs a prerequisite on the entity files, since entities are resolved
# during profiling, so profiling needs to be redone whenever the entities
# change. 
# The like is also true for the DC file.
#

$(PROFILES):
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
$(PROFILEDIR)/%.xml: $(SRC_DIR)/%.xml $(ENTITIES_DOC) $(DOCCONF) | $(PROFILEDIR)
    ifeq "$(VERBOSITY)" "2"
	@(tput el1; echo -en "\r   Profiling $<")
    endif
	$(XSLTPROC) --output $@ $(PROFSTRINGS) $(HROOTSTRING) \
	  --stringparam "filename=$(notdir $<)" \
	  --stylesheet $(PROFILE_STYLESHEET) --file $< $(XSLTPROCESSOR)


# Files included with xi:include parse="text" $(TEXTFILES) are linked into
# the profile directory. the profiling stylesheets rewrites all paths to
# these files with just the filename (href="../foo/bar.txt" -> href="bar.txt")
# Since these text files can come from arbitrary locations, it is not possible
# to write a pattern rule for creating the links. We use the
# PHONY link_txt_files to generate them.
#
# "Clean" paths and file:// entries are supported, other protocols not
#
ifdef TEXTFILES
  .PHONY: link_txt_files
  link_txt_files: | $(PROFILEDIR)
	for TF in $(TEXTFILES); do \
	  TF=$${TF#file://*}; \
	  if [[ "$${TF:0:1}" != "/" ]]; then \
	    TF="$(SRC_DIR)/$$TF"; \
	    (cd $(PROFILEDIR) && ln -sf $$(realpath --relative-to="$(PROFILEDIR)" $$TF)); \
	  else \
	    (cd $(PROFILEDIR) && ln -sf $$TF); \
	  fi; \
	done
endif
