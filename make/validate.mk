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

# search for missing and duplicated images. Similar code as in images.mk, but
# here we want to look at all images of the set, not only the ones used in the
# current document [also see https://github.com/openSUSE/daps/issues/627]

ifeq "$(strip $(VALIDATE_IMAGES))" "1"
  _IMG_USED := $(sort $(shell $(XSLTPROC) --stringparam "filetype=img" \
	  --file $(SETFILES_TMP) --stylesheet \
		$(DAPSROOT)/daps-xslt/common/extract-files-and-images.xsl \
		$(XSLTPROCESSOR) 2>/dev/null))
  _IMG_DUPES := $(sort $(wildcard $(addprefix $(IMG_SRCDIR)/*/,$(addsuffix .*, \
		  $(filter \
		  $(shell echo $(basename $(notdir $(SRC_IMG_ALL)) 2>/dev/null) | \
		  tr " " "\n" | sort |uniq -d 2>/dev/null),$(basename $(_IMG_USED)  \
		  2>/dev/null)) \
		))))
  _IMG_MISS := $(sort $(filter-out $(notdir $(basename $(SRC_IMG_ALL))), \
                $(basename $(_IMG_USED))))
endif

ifeq "$(strip $(VALIDATE_TABLES))" "1"
  FAULTY_TABLES := $(shell $(LIBEXEC_DIR)/validate-tables.py $(SRCFILES) 2>&1 | sed -r -e 's,^/([^/: ]+/)*,,' -e 's,.http://docbook.org/ns/docbook.,,' | sed -rn '/^- / !p' | tr "\n" "@")
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
    ifneq "$(strip $(_IMG_DUPES))" ""
	@ccecho "warn" "Warning: Image names not unique$(COMMA) multiple sources available for the following images:"
	@echo -e "$(subst $(SPACE),\n,$(sort $(_IMG_DUPES)))"
    endif
    ifneq "$(strip $(_IMG_MISS))" ""
	@ccecho "error" "Fatal error: The following images are missing:"
	@echo -e "$(subst $(SPACE),\n,$(sort $(_IMG_MISS)))"
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
  ifeq "$(strip $(VALIDATE_TABLES))" "1"
    ifneq "$(strip $(FAULTY_TABLES))" ""
	@ccecho "warn" "Fatal error: The following tables contain errors:"
	@echo -e "$(subst @,\n,$(FAULTY_TABLES))"
	@exit 1
    endif
  endif
#	@echo "checking for unexpected characters: ... "
#	egrep -n "[^[:alnum:][:punct:][:blank:]]" $(SRCFILES) && \
#	    echo "Found non-printable characters" || echo "OK"
