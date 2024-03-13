# Copyright (C) 2012-2021 SUSE Software Solutions Germany GmbH
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

ifeq "$(suffix $(DOCBOOK5_RNG))" ".rnc"
  JING_FLAGS += -c
endif

# IMPORTANT:
# When writing $(PROFILEDIR)/.validate on a "noref" check and running
# a regular build afterwards, $(PROFILEDIR)/.validate will not be renewed
# and thus a check on xrefs will not be performed. Therefore we declare
# $(PROFILEDIR)/.validate as intermediate for "noref" checks, to make sure
# it is rebuilt during regular validate runs even if the prerequisites have not
# been updated. The downside is that a noref check will be performed in
# absolutely every case.
#
ifeq "$(NOREFCHECK)" "1"
  JING_FLAGS += -i
  .INTERMEDIATE: $(PROFILEDIR)/.validate
endif

#
# Search for missing images., This can be done outside the target, since
# it does not require profiled sources
#
ifeq "$(strip $(VALIDATE_IMAGES))" "1"
  _IMG_USED := $(sort $(shell $(XSLTPROC) --stringparam "filetype=img" \
	  --file $(SETFILES_TMP) --stylesheet \
		$(DAPSROOT)/daps-xslt/common/extract-files-and-images.xsl \
		$(XSLTPROCESSOR) 2>/dev/null))
  _IMG_DUPES := $(sort $(wildcard $(addprefix $(IMG_SRC_DIR)/*/,$(addsuffix .*, \
		  $(filter \
		  $(shell echo $(basename $(notdir $(SRC_IMG_ALL)) 2>/dev/null) | \
		  tr " " "\n" | sort |uniq -d 2>/dev/null),$(basename $(_IMG_USED)  \
		  2>/dev/null)) \
		))))
  _IMG_MISS := $(sort $(filter-out $(notdir $(basename $(SRC_IMG_ALL))), \
                $(basename $(_IMG_USED))))
endif

#
# * Using $(eval ...) to capture the command output
# * The final `awk` command in FAULTY_TABLES replaces `\n` with `\\n` -- this
#   allows proper output of the table validation results which need newlines.
#   cf. https://stackoverflow.com/questions/38672680
#

.PHONY: validate
$(PROFILEDIR)/.validate validate: $(PROFILES)
  ifeq "$(VERBOSITY)" "2"
	@ccecho "info" "   Validating..."
  endif
  ifeq "$(DOCBOOK_VERSION)" "4"
	$(eval FAULTY_XML=$(shell xmllint --noent --postvalid --noout --xinclude $(PROFILED_MAIN) 2>&1 ))
  else
	$(eval FAULTY_XML=$(shell unset VERBOSE && $(JING_WRAPPER) $(JING_FLAGS) $(DOCBOOK5_RNG) $(PROFILED_MAIN) 2>&1))
  endif
  ifeq "$(strip $(VALIDATE_TABLES))" "1"
	$(eval FAULTY_TABLES=$(shell $(LIBEXEC_DIR)/validate-tables.py $(PROFILED_MAIN) 2>&1 | sed -r -e 's,^/([^/: ]+/)*,,' -e 's,.http://docbook.org/ns/docbook.,,' | sed -rn '/^- / !p' | awk -v ORS='\\n' '1'))
  endif
  ifeq "$(strip $(VALIDATE_IDS))" "1"
	$(eval FAULTY_IDS=$(shell $(XSLTPROC) --xinclude --stylesheet $(DAPSROOT)/daps-xslt/common/get-all-xmlids.xsl --file $(PROFILED_MAIN) $(XSLTPROCESSOR) | grep -P '[^-a-zA-Z0-9]'))
  endif
  ifeq "$(strip $(VALIDATE_INLINES))" "1"
	$(eval FAULTY_INLINES=$(shell $(XSLTPROC) --xinclude --stylesheet $(DAPSROOT)/contrib/check-source/find-empty-inlines.xsl --file $(PROFILED_MAIN) $(XSLTPROCESSOR) 2>&1))
  endif
	@if [[ -n '$(FAULTY_XML)' ]]; then \
	  ccecho "error" "[ERROR]: The document contains XML errors:"; \
	  echo -e '$(FAULTY_XML)'; \
	  echo "--------------------------------"; \
	fi
	@if [[ -n '$(FAULTY_TABLES)' ]]; then \
	  ccecho "error" "[ERROR]: The following table(s) contain errors:"; \
	  echo -e '$(FAULTY_TABLES)'; \
	  echo "--------------------------------"; \
	fi
	@if [[ -n "$(FAULTY_IDS)" ]]; then \
	  ccecho "error" "[ERROR]: The following ID(s) contain unwanted characters:"; \
	  echo -e "$(subst $(SPACE),\n,$(sort $(FAULTY_IDS)))"; \
	  echo "--------------------------------"; \
	fi
	@if [[ -n "$(FAULTY_INLINES)" ]]; then \
	  ccecho "error" "[ERROR] The following inline elements are empty:"; \
	  echo -e "$(subst $(SPACE)$(SPACE)$(SPACE)$(SPACE)$(SPACE)$(SPACE)$(SPACE)$(SPACE)$(SPACE),\n\t,$(subst [ERROR],\n[ERROR],$(FAULTY_INLINES)))"; \
	  echo "--------------------------------"; \
	fi
	@if [[ -n "$(_IMG_MISS)" ]]; then \
	  ccecho "error" "[ERROR]: The following images are missing:"; \
	  echo -e "$(subst $(SPACE),\n,$(sort $(_IMG_MISS)))"; \
	  echo "--------------------------------"; \
	fi
	@if [[ -n "$(_IMG_DUPES)" ]]; then \
	  ccecho "error" "[ERROR]: Image names not unique$(COMMA) multiple sources available for the following images:"; \
	  echo -e "$(subst $(SPACE),\n,$(sort $(_IMG_DUPES)))"; \
	  echo "--------------------------------"; \
	fi
	@if [[ -n '$(strip $(FAULTY_XML)$(FAULTY_TABLES)$(FAULTY_IDS)$(FAULTY_INLINES)$(_IMG_MISS))' ]]; then \
	  ccecho "error" "Document does not validate!"; \
	  exit 1; \
	fi
	@touch $(PROFILEDIR)/.validate
  ifeq "$(TARGET)" "validate"
	@ccecho "result" "Document is valid."
  endif
  ifeq ($(VERBOSITY),2)
	@ccecho "info" "   Successfully validated profiled sources."
  endif
