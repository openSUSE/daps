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

#    --stringparam "draft.watermark.image=$(dir $(STYLEIMG))images/draft.png" \
#    --stringparam "callout.graphics.path=$(STYLEIMG)/callouts/" \




#----------
# Settings depending on pdf or color-pdf
#

ifeq ($(TARGET),pdf)
  PDF_RESULT := $(RESULT_DIR)/$(DOCNAME)-print$(LANGSTRING).pdf
  FOFILE     := $(TMP_DIR)/$(DOCNAME)-$(FORMATTER)-print$(LANGSTRING).fo
  FOSTRINGS  += --param "format.print=1" \
	       --stringparam "img.src.path=$(IMG_GENDIR)/print/"
else
  PDF_RESULT := $(RESULT_DIR)/$(DOCNAME)$(LANGSTRING).pdf
  FOFILE     := $(TMP_DIR)/$(DOCNAME)-$(FORMATTER)$(LANGSTRING).fo
  FOSTRINGS  += --param "use.xep.cropmarks=0" \
               --param "format.print=0" \
	       --stringparam "img.src.path=$(IMG_GENDIR)/online/"
endif

# Formatter dependent stuff
#
ifeq ("$(FORMATTER)","fop")
  FOSTRINGS += --param "fop1.extensions=1" \
               --param "xep.extensions=0"
  ifdef FOP_CONFIG
    FORMATTER_CMD := $(FOP_WRAPPER) $(FOP_OPTIONS) -c $(FOP_CONFIG)
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
pdf: $(RESULT_DIR)/$(DOCNAME)-print$(LANGSTRING).pdf
	@ccecho "result" "PDF book built with REMARKS=$(REMARKS), DRAFT=$(DRAFT) and META=$(META):\n$<"


#--------------
# COLOR-PDF
#
.PHONY: color-pdf
color-pdf: list-images-multisrc list-images-missing
color-pdf: $(RESULT_DIR)/$(DOCNAME)$(LANGSTRING).pdf
	@ccecho "result" "COLOR-PDF book built with REMARKS=$(REMARKS), DRAFT=$(DRAFT) and META=$(META):\n$<"

#--------------
# Generate fo
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

#--------------
# Generate PDF
#
$(PDF_RESULT): | $(BUILD_DIR)
ifeq ($(TARGET),pdf)
  $(PDF_RESULT): $(PRINT_IMAGES)
else
  $(PDF_RESULT): $(ONLINE_IMAGES)
endif
$(PDF_RESULT): $(FOFILE)
  ifeq ($(VERBOSITY),2)
	@ccecho "info" "   Creating PDF from fo-file..."
  endif
	$(FORMATTER_CMD) $< $@ $(DEVNULL) $(ERR_DEVNULL)
  ifeq ($(VERBOSITY),2)
	@pdffonts $@ | grep -v -e "^name" -e "^---" | cut -c 51-71 | \
		grep -v -e "yes yes yes" >& /dev/null && \
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
