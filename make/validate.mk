# Copyright (C) 2012-2020 SUSE Software Solutions Germany GmbH
#
# Author:
# Frank Sundermeyer <fsundermeyer at opensuse dot org>
#
# Validation for DAPS
#
# Please submit feedback or patches to
# <fsundermeyer at opensuse dot org>
#
# Use xmllint for DocBook 4 and jing for DocBook 5
# (xmllint -> DTD, jing Relax NG)

# search for IDS with characters that are not A-Z, a-z, 0-9, or -
ifeq "$(strip $(VALIDATE_IDS))" "1"
  FAULTY_IDS = $(shell $(XSLTPROC) --xinclude --stylesheet $(DAPSROOT)/daps-xslt/common/get-all-xmlids.xsl --file $(MAIN) $(XSLTPROCESSOR) | grep -P '[^-a-zA-Z0-9]')
endif

ifeq "$(suffix $(DOCBOOK5_RNG))" ".rnc"
  JING_FLAGS += -c
endif

# IMPORTANT:
# When writing $(PROFILEDIR)/.validate on a "noref" check and running
# a regular build afterwards, $(PROFILEDIR)/.validate will not be renewed
# and thus a check on xrefs will not be performed. Therefore we declare
# $(PROFILEDIR)/.validate as intermediate for "noref" checks, to make sure
# it is rebuild on a regular check, even if the prerequisites do not have
# been updated. The downside is that a noref check will always be performed,
# even when the profiled files have not been updated.
#
ifeq "$(NOREFCHECK)" "1"
  JING_FLAGS += -i
  .INTERMEDIATE: $(PROFILEDIR)/.validate
endif

.PHONY: validate
  $(PROFILEDIR)/.validate validate: $(PROFILES)
  ifeq "$(VERBOSITY)" "2"
	@ccecho "info" "   Validating..."
  endif
  ifeq "$(DOCBOOK_VERSION)" "4"
	xmllint --noent --postvalid --noout --xinclude $(PROFILED_MAIN)
  else
	$(JING_WRAPPER) $(JING_FLAGS) $(DOCBOOK5_RNG) $(PROFILED_MAIN)
  endif
	touch $(PROFILEDIR)/.validate
  ifeq "$(TARGET)" "validate"
	@ccecho "result" "All files are valid.";
  else
    ifeq ($(VERBOSITY),2)
	@ccecho "info" "   Successfully validated profiled sources."
    endif
  endif
  ifeq "$(strip $(VALIDATE_IMAGES))" "1"
    ifneq "$(strip $(DOUBLE_IMG))" ""
	@ccecho "warn" "Warning: Image names not unique$(COMMA) multiple sources available for the following images::"
	@echo -e "$(subst $(SPACE),\n,$(sort $(DOUBLE_IMG)))"
    endif
    ifneq "$(strip $(MISSING_IMG))" ""
	@ccecho "error" "Fatal error: The following images are missing:"
	@echo -e "$(subst $(SPACE),\n,$(sort $(MISSING_IMG)))"
	@exit 1
    endif
  endif
  ifeq "$(strip $(VALIDATE_IDS))" "1"
    ifneq "$(strip $(FAULTY_IDS))" ""
	@ccecho "error" "Fatal error: The following IDs contain unwanted characters:"
	@echo -e "$(subst $(SPACE),\n,$(sort $(FAULTY_IDS)))"
	@exit 1
    endif
  endif
#	@echo "checking for unexpected characters: ... "
#	egrep -n "[^[:alnum:][:punct:][:blank:]]" $(SRCFILES) && \
#	    echo "Found non-printable characters" || echo "OK"
