# Copyright (C) 2012-2020 SUSE Software Solutions Germany GmbH
#
# Author:
# Frank Sundermeyer <fsundermeyer at opensuse dot org>
#
# FO/PDF generation for DAPS
#
# Please submit feedback or patches to
# <fsundermeyer at opensuse dot org>
#
# fs 2012-10-10
# TODO: --meta stuff not working in PDFs (Stlyesheet Issue??)

# Draft mode can be enabled for HTML, so we need to add the
# corresponding strings to the resulting filename
#
# Draft mode can be enabled for PDFs, so we need to add the
# corresponding strings to the resulting filename
#

# binary checks
ifeq "$(FORMATTER)" "xep"
  HAVE_XEP := $(shell command -v xep 2>/dev/null)
  ifndef HAVE_XEP
    $(error $(shell ccecho "error" "Error: PDF formatter xep is not installed"))
  endif
endif

HAVE_PDFINFO  := $(shell command -v pdfinfo 2>/dev/null)
HAVE_PDFFONTS := $(shell command -v pdffonts 2>/dev/null)

STYLEFO    := $(firstword $(wildcard $(addsuffix \
	        /fo/docbook.xsl, $(STYLE_ROOTDIRS))))
STYLE_GENINDEX := $(DAPSROOT)/daps-xslt/index/xml2idx.xsl
STYLE_ISINDEX  := $(DAPSROOT)/daps-xslt/common/search4index.xsl

# Draft mode can be enabled for PDFs, so we need to add the
# corresponding strings to the resulting filename
#
%DOCNAME := $(DOCNAME)$(DRAFT_STR)$(META_STR)

INDEX   := $(shell $(XSLTPROC) --xinclude $(ROOTSTRING) --stylesheet $(STYLE_ISINDEX) --file $(MAIN) $(XSLTPROCESSOR) 2>/dev/null)

ifeq "$(INDEX)" "Yes"
  INDEXSTRING := --stringparam "indexfile=$(DOCNAME).ind"
endif

#----------
# FO stringparams
#
FOSTRINGS := --param "show.comments=$(REMARKS)" \
             --param "generate.permalink=0"  \
	     --param "ulink.show=1" \
	     --stringparam "draft.mode=$(DRAFT)" \
             --stringparam "styleroot=$(dir $(STYLEIMG))"

#----------
# Settings depending on --grayscale and --cropmarks
#
# PDF_RESULT is set in filenames.mk

FOFILE     := $(TMP_DIR)/$(DOCNAME)-$(FORMATTER)

ifeq "$(GRAYSCALE)" "1"
  FOSTRINGS  += --param "format.print=1" \
	        --stringparam "img.src.path=$(IMG_GENDIR)/grayscale/"
  FOFILE     := $(FOFILE)_gray
else
  FOSTRINGS  += --param "format.print=0" \
	        --stringparam "img.src.path=$(IMG_GENDIR)/color/"
  FOFILE     := $(FOFILE)
endif

# cropmarks are currently only supported by XEP
ifeq "$(CROPMARKS)" "1"
  FOSTRINGS  += --param "use.xep.cropmarks=1" --param "crop.marks=1" 
  FOFILE     := $(FOFILE)_crop
endif

FOFILE := $(FOFILE)$(LANGSTRING).fo

# Formatter dependent stuff
#
# Command line options are set via variables in the config files
# and are processed in the wrapper files
#
ifeq "$(FORMATTER)" "fop"
  FOSTRINGS += --param "fop1.extensions=1" \
               --param "xep.extensions=0"
  FORMATTER_CMD := $(FOP_WRAPPER)
endif
ifeq "$(FORMATTER)" "xep"
  FOSTRINGS += --param "fop1.extensions=0" \
               --param "xep.extensions=1"
  FORMATTER_CMD := $(XEP_WRAPPER)
endif


# Issue #419
# The upstream stylesheets set paths for admon, callout, and navig graphics
# to "images/" by default. However, it is easier to collect images, css, and Javascript
# files under a directory "<STYLEROOT>/static". DAPS supports this
#
# For fo it supports the following:
# 1. <STYLEROOT>/fo/static/images
# 2. <STYLEROOT>/fo/images
# 3. <STYLEROOT>/static/images
# 4. <STYLEROOT>/images
#
# In this order. First one wins
#

ifdef STATIC_DIR
  _STYLEIMG  := $(STATIC_DIR)
else
  _STYLEIMG := $(firstword $(wildcard \
		$(addsuffix static/images, $(dir $(STYLEFO)))\
		$(addsuffix images, $(dir $(STYLEFO)))\
		$(addsuffix static/images,$(dir $(patsubst %/,%,$(dir $(STYLEFO)))))\
		$(addsuffix images,$(dir $(patsubst %/,%,$(dir $(STYLEFO)))))))
endif

# Remove trailing slash if present
#
STYLEIMG=$(patsubst %/,%,$(_STYLEIMG))

FOSTRINGS += --stringparam "admon.graphics.path=$(STYLEIMG)/" \
             --stringparam "callout.graphics.path=$(STYLEIMG)/callouts/"

#--------------
# PDF
#
# Including a workaround for failed FOP builds where FOP creates
# corrupt PDFs which are considered a successful build by make when
# run a second time (pdfinfo call)
#
.PHONY: pdf
pdf: list-images-multisrc list-images-missing
ifeq "$(LEAN)" "1"
  pdf: $(LEAN_PDF_RESULT)
else
  pdf: $(PDF_RESULT)
endif
  ifneq "$(HAVE_PDFINFO)" ""
	pdfinfo $(PDF_RESULT) > /dev/null 2>&1 || ( ccecho "error" "PDF $(PDF_RESULT) has a size of 0 bytes"; false )
  endif
  ifeq "$(TARGET)" "pdf"
	@ccecho "result" "PDF book built with REMARKS=$(REMARKS), DRAFT=$(DRAFT) and META=$(META):\n$<"
  endif

#--------------
# Generate fo
#
# the link to $(STYLEIMG) at the end of this rule is needed in case the
# paths to callouts, admonition and draft graphics are specified relatively
# in the stylesheets (which is the case in the DocBook stylesheets)
#
$(FOFILE): | $(TMP_DIR)
ifdef METASTRING
  $(FOFILE): $(PROFILEDIR)/METAFILE
endif
ifeq "$(INDEX)" "Yes"
  $(FOFILE): $(PROFILEDIR)/$(DOCNAME).ind
endif
ifeq "$(VERBOSITY)" "1"
  $(FOFILE): FONTDEBUG := --param "debug.fonts=0"
endif
$(FOFILE): $(PROFILES) $(DOCFILES) $(STYLEFO) validate
  ifeq "$(VERBOSITY)" "2"
	@ccecho "info"  "   Creating fo-file..."
  endif
	  $(XSLTPROC) --xinclude $(FOSTRINGS) $(ROOTSTRING) $(METASTRING) \
	    $(INDEXSTRING) $(FONTDEBUG) $(DAPSSTRINGS) $(XSLTPARAM) $(PARAMS) \
	    $(STRINGPARAMS) --output $(FOFILE) --stylesheet $(STYLEFO) \
	    --file $(PROFILED_MAIN) $(XSLTPROCESSOR) $(DEVNULL) \
	    $(ERR_DEVNULL);
  ifeq "$(VERBOSITY)" "2"
	@ccecho "info" "Successfully created fo file $(FOFILE)"
  endif

#--------------
# Generate PDF
#

#
# If the FO file contains relative links (as is the case when using the
# original DocBook stylesheets) the formatter (well, at least FOP) must be
# run from the directory where the .do file is located. Therefore we do a 
# cd $(dir $(FOFILE)) before running the formatter.

$(PDF_RESULT): | $(BUILD_DIR) $(RESULT_DIR)
ifeq "$(GRAYSCALE)" "1"
  $(PDF_RESULT): $(GRAYSCALE_IMAGES)
else
  $(PDF_RESULT): $(COLOR_IMAGES)
endif
ifneq "$(IS_STATIC)" "static"
  $(PDF_RESULT): $(TMP_STATIC_IMG_DIR)
  $(PDF_RESULT): $(TMP_IMG_DIR)
else
  $(PDF_RESULT): $(TMP_STATIC_DIR)
endif
$(PDF_RESULT): $(FOFILE)
  ifeq "$(VERBOSITY)" "2"
	@ccecho "info" "   Creating PDF from fo-file..."
  endif
	(cd $(dir $(FOFILE)) && $(FORMATTER_CMD) $< $@ $(DEVNULL) $(ERR_DEVNULL))
  ifeq "$(VERBOSITY)" "2"
    ifneq "$(HAVE_PDFFONTS)" ""
	@pdffonts $@ | tail -n +3 | awk '{print $5}' | grep -v "yes" \
		>& /dev/null && \
		(ccecho "warn" "Not all fonts are embedded" >&2;) || :
    endif
  endif

#--------------
# Generate a lean PDF from the original one
# (PDF with reduced graphics quality and a considerable smaller file size)
#
$(LEAN_PDF_RESULT): $(PDF_RESULT)
  ifeq "$(VERBOSITY)" "2"
	@ccecho "info" "   Creating lean PDF from $(PDF_RESULT)..."
  endif
	gs -sDEVICE=pdfwrite -dCompatibilityLevel=1.4 -dPDFSETTINGS=/ebook \
	  -dNOPAUSE -dQUIET -dBATCH -sOutputFile=$@ $<

#--------------
# Generate Index
#
$(PROFILEDIR)/$(DOCNAME).ind: $(PROFILES)
  ifeq "$(VERBOSITY)" "2"
	 @ccecho "info" "   Creating Index..."
  endif
	$(XSLTPROC) $(ROOTSTRING) --xinclude --output $@ \
	  --stylesheet $(STYLE_GENINDEX) --file $(PROFILED_MAIN) \
	  $(XSLTPROCESSOR)

