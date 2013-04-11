# Copyright (C) 2012 SUSE Linux Products GmbH
#
# Author: Frank Sundermeyer
#
# Profiling stuff for DAPS
#
# Please submit feedback or patches to
# <fsundermeyer at opensuse dot org>
#

# includes are set in selector.mk
# include $(DAPSROOT)/make/setfiles.mk

PROFILES      := $(subst $(DOC_DIR)/xml/,$(PROFILEDIR)/,$(SRCFILES))

# Will be used on profiling only
#
ifdef HTMLROOT
  HROOTSTRING  := --stringparam "provo.root=$(HTMLROOT)"
endif

# Allows to set a custom publication date
#
ifdef SETDATE
  PROFSTRINGS += --stringparam "pubdate=$(SETDATE)"
  .INTERMEDIATE: $(PROFILES)
endif

# Resolve profile urn because saxon does not accept urns
#
ifdef PROFILE_URN
  ifeq ($(shell expr substr $(PROFILE_URN) 1 4),urn:)
    PROFILE_STYLESHEET := $(shell xmlcatalog $(XML_MAIN_CATALOG) $(PROFILE_URN) 2>/dev/null)
  else
    PROFILE_STYLESHEET := $(PROFILE_URN)
  endif
  PROFILE_STYLESHEET := $(subst file://,,$(PROFILE_STYLESHEET))
  ifndef PROFILE_STYLESHEET
    $(error $(shell ccecho "error" "Could not resolve URN \"$(PROFILE_URN)\" with xmlcatalog via catalog file \"$(XML_MAIN_CATALOG)\""))
  endif
endif

.PHONY: profile
profile: $(PROFILES)
  ifeq ($(MAKECMDGOALS),profile)
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

$(PROFILEDIR)/%: $(DOC_DIR)/xml/% | $(PROFILEDIR)
  ifeq ($(VERBOSITY),2)
	@(tput el1; echo -en "\r   Profiling $<")
  endif
  ifdef PROFILE_URN
	$(XSLTPROC) --output $@ $(PROFSTRINGS) $(HROOTSTRING) \
	  --stringparam "filename=$(notdir $<)" --stylesheet $(PROFILE_STYLESHEET) \
	  --file $< $(XSLTPROCESSOR)
  else
        # The xmllint command works nicely with one exception:
        # The entity declarations are always written literally
        # into the Header
        # This is absolutely useless and therefore I do not like it at all
        # Working around this is cumbersome because there is no easy way
        # to retrieve the header of an existing DocBook document
        # If it would be possible to extract the header, this could be passed as
        # a stringparam to xsltproc and then be used to write the document
        #
        # Get root element:
        # xml sel -t -v "local-name(/*)" XML_FILE
        # Get public identifier:
        # ??
        # Get system identifier:
        # ??
	xmllint --output $@ --nonet --noent --loaddtd $<
  endif
