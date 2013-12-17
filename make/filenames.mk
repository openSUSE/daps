# Copyright (C) 2012 SUSE Linux Products GmbH
#
# Author: Frank Sundermeyer
#
# Setting up filenames for DAPS
#
# Please submit feedback or patches to
# <fsundermeyer at opensuse dot org>
#

#--------------
# EPUB
#
EPUB_RESULT := $(RESULT_DIR)/$(DOCNAME)$(LANGSTRING).epub
MOBI_RESULT := $(RESULT_DIR)/$(DOCNAME)$(LANGSTRING).mobi

#---------------
# HTML
#
HTML_DIR := $(RESULT_DIR)
ifeq ($(JSP),1)
  HTML_DIR    := $(HTML_DIR)/jsp/$(DOCNAME)$(DRAFT_STR)$(META_STR)

  # We have a hen and egg problem when setting JSP_SUBDIR in case
  # PROFILED_MAIN does not exist.
  # The following hack uses the unprofiled $MAIN in case the profiled
  # variant does not exist (firstword function). The problem with
  # this solution is, that, if the source has more than one PI to set the
  # JSP_SUBDIR (separated by profiling), the first one will win when using
  # the unprofiled MAIN
  # The ideal solution would be to quickly profile the MAIN here, but the
  # variables needed for profiling are set later in profiling.mk
  #
  JSP_SUBDIR  = $(shell $(XSLTPROC) --xinclude --stylesheet $(DAPSROOT)/daps-xslt/jsp/get.dbjsp.xsl --stringparam "rootid=$(ROOTID)" --file $(firstword $(wildcard $(PROFILED_MAIN) $(MAIN))) $(XSLTPROCESSOR) 2>/dev/null)
  HTML_RESULT = $(HTML_DIR)/$(JSP_SUBDIR)/index.jsp
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
# MAN
#
MAN_DIR := $(RESULT_DIR)/man

#---------------
# Package-pdf, Package-html
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
# Package-src
#
PACKAGE_SRC_TARBALL :=  $(PACK_DIR)/$(DOCNAME)$(LANGSTRING)_src_set.tar
PACKAGE_SRC_RESULT  :=  $(PACKAGE_SRC_TARBALL).bz2

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


#---------------
# TXT
#
TXT_RESULT := $(RESULT_DIR)/$(DOCNAME).txt
