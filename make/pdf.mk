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

STYLEFO    := $(firstword $(wildcard $(addsuffix \
	        /fo/docbook.xsl, $(STYLE_ROOTDIRS))))
STYLE_GENINDEX := $(DAPSROOT)/daps-xslt/index/xml2idx.xsl
STYLE_ISINDEX  := $(DAPSROOT)/daps-xslt/common/search4index.xsl

# Issue #419
# The upstream stylesheets set paths for admon, callout, and navig graphics
# to "images/" by default. However, DAPS' HTML builds require to set these
# paths to static/images/ regardless what the stylesheets set
# To ensure the same path ("static/images/") can be used for HTML and PDF
# we need to create "static/images/" relative to the FO file
# This is done by the target $(TMP_STATIC_IMG_DIR): by setting a link to the
# stylesheet image or static directory
# In addition to that, we will also create a link $(TMP_DIR)/images to ensure
# building PDFs without explicitly setting a path for admon/callouts works
# as well.
#
# First, determine whether we have <STYLEROOT>/static or <STYLEROOT>/images
# (for a detailed explanation see html.mk)
#
# If we have a static directory, we can create a link to it in $(TMP_DIR)
# If we have an image directory, $(TMP_DIR)/static needs to be created and
# then a link to images in $(TMP_DIR)/static
#
ifdef STATIC_DIR
  STYLEIMG  := $(STATIC_DIR)
  IS_STATIC := static
else
  STYLEIMG := $(firstword $(wildcard \
		$(addsuffix static, $(dir $(STYLEFO)))\
		$(addsuffix static,$(dir $(patsubst %/,%,$(dir $(STYLEFO)))))\
		$(addsuffix images,$(dir $(patsubst %/,%,$(dir $(STYLEFO)))))))
  IS_STATIC := $(notdir $(STYLEIMG))
endif

TMP_STATIC_DIR     := $(TMP_DIR)/static

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


# Issue #419 continued
# The links to image or static directories need to be removed once the PDF
# has been built, since we do not know which stylesheets (and therefore
# which image directories) will be used in the next build.
# Since $(TMP_DIR)/static/ can be a directory, INTERMEDIATE will not work
# (does not remove directories), therefor using an explicit
# rm in $(PDF_RESULT):

ifneq "$(IS_STATIC)" "static"
  #  
  # we have <STYLEROOT>/image
  # 1. create $(TMP_DIR)/static
  # 2. create link to images in $(TMP_DIR)/static
  # 3. create lilnk $(TMP_DIR)/images
  #
  TMP_IMG_DIR        := $(TMP_DIR)/images
  TMP_STATIC_IMG_DIR := $(TMP_STATIC_DIR)/images


  $(TMP_STATIC_DIR): | $(TMP_DIR)
	mkdir -p $@

  $(TMP_STATIC_IMG_DIR): | $(TMP_STATIC_DIR)
	(cd $(TMP_STATIC_DIR) && ln -sf $(STYLEIMG))

  $(TMP_IMG_DIR): | $(TMP_DIR)
	(cd $(TMP_DIR) && ln -sf $(STYLEIMG))

else
  #  
  # we have <STYLEROOT>/static
  # create link to static in $(TMP_DIR)
  #
  $(TMP_STATIC_DIR): | $(TMP_DIR)
	(cd $(TMP_DIR) && ln -sf $(STYLEIMG))

endif


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
	pdfinfo $(PDF_RESULT) > /dev/null 2>&1 || ( ccecho "error" "PDF $(PDF_RESULT) has a size of 0 bytes"; false )
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
$(FOFILE): $(PROFILES) $(PROFILEDIR)/.validate $(DOCFILES) $(STYLEFO)
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
	@rm -rf $(TMP_STATIC_DIR) $(TMP_IMG_DIR)
  ifeq "$(VERBOSITY)" "2"
	@pdffonts $@ | tail -n +3 | awk '{print $5}' | grep -v "yes" \
		>& /dev/null && \
		(ccecho "warn" "Not all fonts are embedded" >&2;) || :
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

