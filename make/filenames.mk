# Copyright (C) 2012 SUSE Linux Products GmbH
#
# Author: Frank Sundermeyer
#
# Setting up filenames for DAPS
#
# Please submit feedback or patches to
# <fsundermeyer at opensuse dot org>
#

#---------------
# HTML
#

HTML_DIR := $(RESULT_DIR)/
ifeq ($(TARGET),jsp)
  HTML_DIR    := $(HTML_DIR)/jsp/$(DOCNAME)$(DRAFT_STR)$(META_STR)
  HTML_RESULT := $(HTML_DIR)/index.jsp
else
  ifeq ($(HTMLSINGLE),1)
    HTML_DIR    := $(HTML_DIR)/single-html/$(DOCNAME)$(DRAFT_STR)$(META_STR)
    HTML_RESULT := $(HTML_DIR)/$(DOCNAME)$(DRAFT_STR)$(META_STR).html
  else
    HTML_DIR    := $(HTML_DIR)/html/$(DOCNAME)$(DRAFT_STR)$(META_STR)
    HTML_RESULT := $(HTML_DIR)/index.html
  endif
endif

#---------------
# PDF
#
PDF_RESULT := $(RESULT_DIR)/$(DOCNAME)
ifeq ($(GRAYSCALE),1)
  PDF_RESULT := $(PDF_RESULT)_gray
else
  PDF_RESULT := $(PDF_RESULT)_color
endif

# cropmarks are currently only supported by XEP
ifeq ($(CROPMARKS),1)
  ifeq ($(FORMATTER),xep)
    PDF_RESULT := $(PDF_RESULT)_crop
  endif
endif

PDF_RESULT := $(PDF_RESULT)$(DRAFT_STR)$(META_STR)$(LANGSTRING).pdf
