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

HTML_DIR := $(RESULT_DIR)
ifeq ($(JSP),1)
  HTML_DIR    := $(HTML_DIR)/jsp/$(DOCNAME)$(DRAFT_STR)$(META_STR)
  JSP_SUBDIR  := $(shell $(XSLTPROC) --xinclude --stylesheet $(DAPSROOT)/daps-xslt/jsp/get.dbjsp.xsl --stringparam "rootid=$(ROOTID)" --file $(PROFILED_MAIN) $(XSLTPROCESSOR) 2>/dev/null)
  HTML_RESULT := $(HTML_DIR)/$(JSP_SUBDIR)/index.jsp
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
# Package-pdf, Package-html
#
# Help file format
#

ifeq ($(TARGET),$(filter $(TARGET),package-pdf package-pdf-dir-name))
  PACKAGE_PDF_DIR      := $(PACK_DIR)/pdf
  DESKTOPFILES_RESULT  := $(PACKAGE_PDF_DIR)/$(DOCNAME)$(LANGSTRING)-desktop.tar.bz2
  DOCUMENTFILES_RESULT := $(PACKAGE_PDF_DIR)/$(DOCNAME)$(LANGSTRING).document
  PAGEFILES_RESULT     := $(PACKAGE_PDF_DIR)/$(DOCNAME)$(LANGSTRING).page
endif
ifeq ($(TARGET),$(filter $(TARGET),package-html package-html-dir-name online-docs))
  PACKAGE_HTML_DIR     := $(PACK_DIR)/html
  DESKTOPFILES_RESULT  := $(PACKAGE_HTML_DIR)/$(DOCNAME)$(LANGSTRING)-desktop.tar.bz2
  DOCUMENTFILES_RESULT := $(PACKAGE_HTML_DIR)/$(DOCNAME)$(LANGSTRING).document
  PAGEFILES_RESULT     := $(PACKAGE_HTML_DIR)/$(DOCNAME)$(LANGSTRING).page
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

