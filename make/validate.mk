# Copyright (C) 2012 SUSE Linux Products GmbH
#
# Author: Frank Sundermeyer
#
# Validation for DAPS
#
# Please submit feedback or patches to
# <fsundermeyer at opensuse dot org>
#
# Use xmllint for DocBook 4 and jing for DocBook 5
# (xmllint -> DTD, jing Relax NG)

.PHONY: validate
$(PROFILEDIR)/.validate validate: $(PROFILES)
  ifeq ($(VERBOSITY), 2)
	@ccecho "info" "   Validating..."
  endif
  ifeq ($(DOCBOOK_VERSION), 4)
	xmllint --noent --postvalid --noout --xinclude $(PROFILED_MAIN)
  else
	ADDITIONAL_FLAGS="$(JING_FLAGS)" jing $(DOCBOOK5_RNG) \
	  $(PROFILED_MAIN)
  endif
	touch $(PROFILEDIR)/.validate
#	@echo "checking for unexpected characters: ... "
#	egrep -n "[^[:alnum:][:punct:][:blank:]]" $(SRCFILES) && \
#	    echo "Found non-printable characters" || echo "OK"
  ifeq ($(TARGET),validate)
	@ccecho "result" "All files are valid.";
  else
    ifeq ($(VERBOSITY),2)
	@ccecho "info" "   Successfully validated profiled sources."
    endif
  endif
