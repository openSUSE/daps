# Copyright (C) 2012 SUSE Linux Products GmbH
#
# Author: Frank Sundermeyer
#
# FO/PDF generation for DAPS
#
# Please submit feedback or patches to
# <fsundermeyer at opensuse dot org>
#

# fs 2012-10-10
# TODO: --meta stuff not working in PDFs (Stlyesheet Issue??)


# includes are set in selector.mk
# include $(DAPSROOT)/make/setfiles.mk
# include $(DAPSROOT)/make/profiling.mk
# include $(DAPSROOT)/make/validate.mk
# include $(DAPSROOT)/make/images.mk
# include $(DAPSROOT)/make/meta.mk

# Draft mode can be enabled for HTML, so we need to add the
# corresponding strings to the resulting filename
#
# Draft mode can be enabled for PDFs, so we need to add the
# corresponding strings to the resulting filename
#

STYLEFO    := $(firstword $(wildcard $(addsuffix \
	        /fo/docbook.xsl, $(STYLE_ROOTDIRS))))
STYLE_GENINDEX := $(DAPSROOT)/daps-xslt/index/xml2idx.xsl
STYLE_ISINDEX  := $(DAPSROOT)/daps-xslt/common/search4index.xsl

#
# Make sure to use the STYLEIMG directory that comes alongside the
# STYLEROOT that is actually used. This is needed to ensure that the
# correct STYLEIMG is used, even when the current STYLEROOT is a
# fallback directory
#
# dir (patsubst %/,%,(dir STYLEEPUB)):
#  - remove filename
#  - remove trailing slash (dir function only works when last character
#    is no "/") -> patsubst is greedy
#  - remove dirname
#
STYLEIMG := $(addsuffix images,$(dir $(patsubst %/,%,$(dir $(STYLEFO)))))

DOCNAME := $(DOCNAME)$(DRAFT_STR)$(META_STR)
INDEX   := $(shell $(XSLTPROC) --xinclude $(ROOTSTRING) --stylesheet $(STYLE_ISINDEX) --file $(MAIN) $(XSLTPROCESSOR) 2>/dev/null)

ifeq ($(INDEX),Yes)
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

ifeq ($(GRAYSCALE),1)
  FOSTRINGS  += --param "format.print=1" \
	        --stringparam "img.src.path=$(IMG_GENDIR)/grayscale/"
  FOFILE     := $(FOFILE)_gray
else
  FOSTRINGS  += --param "format.print=0" \
	        --stringparam "img.src.path=$(IMG_GENDIR)/color/"
  FOFILE     := $(FOFILE)_color
endif

# cropmarks are currently only supported by XEP
ifeq ($(CROPMARKS),1)
  FOSTRINGS  += --param "use.xep.cropmarks=1" --param "crop.marks=1" 
  FOFILE     := $(FOFILE)_crop
endif

FOFILE := $(FOFILE)$(LANGSTRING).fo

# Formatter dependent stuff
#
ifeq ("$(FORMATTER)","fop")
  FOSTRINGS += --param "fop1.extensions=1" \
               --param "xep.extensions=0"
  ifdef FOP_CONFIG_FILE
    FORMATTER_CMD := $(FOP_WRAPPER) $(FOP_OPTIONS) -c $(FOP_CONFIG_FILE)
  else
    FORMATTER_CMD := $(FOP_WRAPPER) $(FOP_OPTIONS)
  endif
endif
ifeq ("$(FORMATTER)","xep")
  FOSTRINGS += --param "fop1.extensions=0" \
               --param "xep.extensions=1"
  FORMATTER_CMD := $(XEP_WRAPPER) $(XEP_OPTIONS)
endif

#--------------
# PDF
#
.PHONY: pdf
pdf: list-images-multisrc list-images-missing
pdf: $(PDF_RESULT)
  ifeq ($(TARGET),pdf)
	@ccecho "result" "PDF book built with REMARKS=$(REMARKS), DRAFT=$(DRAFT) and META=$(META):\n$<"
  endif

#--------------
# Generate fo
#
# the link to $(STYLEIMG) is needed in case the paths to callouts,
# admonition and draft graphics are specified relatively in the
# stylesheets (which is the case in the DocBook stylesheets)
#
$(FOFILE): | $(TMP_DIR)
ifdef METASTRING
  $(FOFILE): $(PROFILEDIR)/METAFILE
endif
ifeq ($(INDEX),Yes)
  $(FOFILE): $(PROFILEDIR)/$(DOCNAME).ind
endif
ifeq ($(VERBOSITY),1)
  $(FOFILE): FONTDEBUG := --param "debug.fonts=0"
endif
$(FOFILE): $(PROFILES) $(PROFILEDIR)/.validate $(DOCFILES) $(STYLEFO)
  ifeq ($(VERBOSITY),2)
	@ccecho "info"  "   Creating fo-file..."
  endif
	$(XSLTPROC) --xinclude $(FOSTRINGS) $(ROOTSTRING) $(METASTRING) \
	  $(INDEXSTRING) $(FONTDEBUG) $(XSLTPARAM) \
	  --output $(FOFILE) --stylesheet $(STYLEFO) --file $(PROFILED_MAIN) \
	  $(XSLTPROCESSOR) $(DEVNULL) $(ERR_DEVNULL)
  ifeq ($(VERBOSITY),2)
	@ccecho "info" "Successfully created fo file $(FOFILE)"
  endif
	(cd $(TMP_DIR); ln -sf $(STYLEIMG))

#--------------
# Generate PDF
#

$(PDF_RESULT): | $(BUILD_DIR) $(RESULT_DIR)
ifeq ($(GRAYSCALE),1)
  $(PDF_RESULT): $(GRAYSCALE_IMAGES)
else
  $(PDF_RESULT): $(COLOR_IMAGES)
endif
$(PDF_RESULT): $(FOFILE)
  ifeq ($(VERBOSITY),2)
	@ccecho "info" "   Creating PDF from fo-file..."
  endif
	$(FORMATTER_CMD) $< $@ $(DEVNULL) $(ERR_DEVNULL)
  ifeq ($(VERBOSITY),2)
	@pdffonts $@ | tail -n +3 | awk '{print $5}' | grep -v "yes" \
		>& /dev/null && \
		(ccecho "warn" "Not all fonts are embedded" >&2;) || :
  endif

#--------------
# Generate Index
#
$(PROFILEDIR)/$(DOCNAME).ind:
  ifeq ($(VERBOSITY),2)
	 @ccecho "info" "   Creating Index..."
  endif
	$(XSLTPROC) $(ROOTSTRING) --xinclude --output $@ \
	  --stylesheet $(STYLE_GENINDEX) --file $(PROFILED_MAIN) \
	  $(XSLTPROCESSOR)
