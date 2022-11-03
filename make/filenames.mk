# Copyright (C) 2012-2020 SUSE Software Solutions Germany GmbH
#
# Author:
# Frank Sundermeyer <fsundermeyer at opensuse dot org>
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
ifeq "$(HTMLSINGLE)" "1"
  HTML_DIR    := $(HTML_DIR)/single-html/$(DOCNAME)$(DRAFT_STR)$(META_STR)
  HTML_RESULT := $(HTML_DIR)/$(DOCNAME)$(DRAFT_STR)$(META_STR).html
else
  HTML_DIR    := $(HTML_DIR)/html/$(DOCNAME)$(DRAFT_STR)$(META_STR)
  HTML_RESULT := $(HTML_DIR)/index.html
endif


#---------------
# MAN
#
MAN_DIR := $(RESULT_DIR)/man

#---------------
# Package-pdf, Package-html
#
ifeq "$(TARGET)" "$(filter $(TARGET),package-pdf package-pdf-dir-name showvariable)"
  PACKAGE_PDF_DIR      := $(PACK_DIR)/pdf
  PACKAGE_PDF_RESULT   := $(PACKAGE_PDF_DIR)/$(DOCNAME)$(LANGSTRING).pdf
  DESKTOPFILES_RESULT  := $(PACKAGE_PDF_DIR)/$(DOCNAME)$(LANGSTRING)-desktop.tar.bz2
  DOCUMENTFILES_RESULT := $(PACKAGE_PDF_DIR)/$(DOCNAME)$(LANGSTRING).document
  PAGEFILES_RESULT     := $(PACKAGE_PDF_DIR)/$(DOCNAME)$(LANGSTRING).page
endif
ifeq "$(TARGET)" "$(filter $(TARGET),package-html package-html-dir-name showvariable)"
  PACKAGE_HTML_DIR     := $(PACK_DIR)/html
  ifeq "$(HTMLSINGLE)" "1"
    PACKAGE_HTML_RESULT := $(PACKAGE_HTML_DIR)/$(DOCNAME)$(LANGSTRING)-single-html.tar.bz2
  else
    PACKAGE_HTML_RESULT := $(PACKAGE_HTML_DIR)/$(DOCNAME)$(LANGSTRING)-html.tar.bz2
  endif
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
ifeq "$(GRAYSCALE)" "1"
  PDF_RESULT := $(PDF_RESULT)_gray
else
  PDF_RESULT := $(PDF_RESULT)
endif

# cropmarks are currently only supported by XEP
ifeq "$(CROPMARKS)" "1"
  ifeq "$(FORMATTER)" "xep"
    PDF_RESULT := $(PDF_RESULT)_crop
  endif
endif

# if --lean is specified, create an additional lean PDF
ifeq "$(LEAN)" "1"
  LEAN_PDF_RESULT := $(PDF_RESULT)_lean.pdf
endif

PDF_RESULT := $(PDF_RESULT)$(DRAFT_STR)$(META_STR)$(LANGSTRING).pdf

#---------------
# Webhelp
#
WEBHELP_DIR    := $(RESULT_DIR)/webhelp/$(DOCNAME)$(DRAFT_STR)
WEBHELP_RESULT := $(WEBHELP_DIR)/index.html


#---------------
# TXT
#
TXT_RESULT := $(RESULT_DIR)/$(DOCNAME).txt
