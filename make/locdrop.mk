# Copyright (C) 2012-2015 SUSE Linux Products GmbH
#
# Author: Frank Sundermeyer
#
# Localization drop target for DAPS
#
# Please submit feedback or patches to
# <fsundermeyer at opensuse dot org>
#
#
# * tarball with XML sources to be translated
# * tarball with rest of XML sources (complete set)
# * Graphics tarball (book only)
# * Color PDF
#

LOCDROP_TMP_DIR  := $(TMP_DIR)/$(BOOK)_locdrop
MANIFEST_TRANS   := $(LOCDROP_TMP_DIR)/manifest_trans.txt
MANIFEST_NOTRANS := $(LOCDROP_TMP_DIR)/manifest_en.txt

ifndef LOCDROP_EXPORT_DIR
  LOCDROP_EXPORT_BOOKDIR := $(RESULT_DIR)/locdrop
else
  LOCDROP_EXPORT_BOOKDIR := $(addsuffix /$(DOCNAME),$(LOCDROP_EXPORT_DIR))
endif

ifdef USESVN
  TO_TRANS_FILES := $(subst $(DOC_DIR)/xml,$(PROFILEDIR),$(shell svn pl -v --xml $(DOCFILES) | $(XSLTPROC) --stylesheet $(DAPSROOT)/daps-xslt/common/get-svn-props.xsl $(XSLTPROCESSOR)))
  TO_TRANS_TAR    := $(LOCDROP_EXPORT_BOOKDIR)/translation-$(DOCNAME)$(LANGSTRING).tar
endif

ifdef TO_TRANS_FILES
  NO_TRANS_FILES := $(filter-out $(TO_TRANS_FILES),$(subst $(DOC_DIR)/xml,$(PROFILEDIR),$(SRCFILES)))
  ifneq "$(strip $(NO_TRANS_FILES))" ""
    NO_TRANS_TAR   := $(LOCDROP_EXPORT_BOOKDIR)/setfiles-$(DOCNAME)$(LANGSTRING).tar
  endif
endif

ifneq "$(strip $(USED_ALL))" ""
  TO_TRANS_IMGS := $(USED_ALL)
  TO_TRANS_IMG_TAR :=$(LOCDROP_EXPORT_BOOKDIR)/graphics-translation-$(DOCNAME)$(LANGSTRING).tar.bz2
endif

# get all images in the current set in case set and current book differ
ifdef ROOTID
  USED_SET := $(shell $(XSLTPROC) --stringparam "xml.or.img=img" --file $(SETFILES_TMP) --stylesheet $(DAPSROOT)/daps-xslt/common/extract-files-and-images.xsl $(XSLTPROCESSOR))

  ifneq "$(strip $(USED_SET))" ""
    # USED_SET contains just the images names as mentioned in the XML sources
    # (foo.png). The addprefix/addsuffix calls transform it into
    # /bar/images/src/*/foo.*, wildcard resolves that string into existing files
    # and sort removes the duplicates
    #
    USED_SET_ALL := $(sort $(wildcard \
       $(addprefix $(IMG_SRCDIR)/*/,$(addsuffix .*,$(basename $(USED_SET)) ))))

    ifdef TO_TRANS_IMGS
      NO_TRANS_IMGS := $(filter-out $(TO_TRANS_IMGS),$(USED_SET_ALL))
    else
      NO_TRANS_IMGS := $(USED_SET_ALL)
    endif
    NO_TRANS_IMG_TAR :=$(LOCDROP_EXPORT_BOOKDIR)/graphics-setfiles-$(DOCNAME)$(LANGSTRING).tar.bz2
  endif
endif

.PHONY: locdrop
ifneq "$(strip $(DEF_FILE))" ""
  locdrop: DC_FILES := $(addprefix $(DOC_DIR)/,$(shell awk '/^[ \t]*#/ {next};NF {printf "DC-%s ", $$2}' $(DEF_FILE)))
endif
locdrop: | $(LOCDROP_EXPORT_BOOKDIR) $(LOCDROP_TMP_DIR)
ifeq ($(OPTIPNG),1)
  locdrop: optipng
endif
ifneq ($(NOPDF),1)
  locdrop: pdf
endif
locdrop: $(SRCFILES) $(MANIFEST_TRANS) $(MANIFEST_NOTRANS) $(USED_ALL) $(PROFILES) $(PROFILEDIR)/.validate
  ifndef USESVN
	$(error $(shell ccecho "error" "Fatal error: Cannot get list of translated files because\n$(MAIN) is not SVN controlled"))
  endif
  ifeq "$(strip $(TO_TRANS_FILES))" ""
	$(error $(shell ccecho "error" "Fatal error: This book does not contain any files for translation"))
  endif
  ifndef DOCCONF
	$(error $(shell ccecho "error" "Fatal error: locdrop is only supported when using a DC-file"))
  endif
  ifdef MISSING
	@ccecho "error" "Fatal error: The following images are missing:"
	@echo -e "$(subst $(SPACE),\n,$(sort $(MISSING)))"
	$(error )
  endif
        # tarball with files for translation
	tar chf $(TO_TRANS_TAR) --absolute-names \
	  --transform=s%$(PROFILEDIR)/%xml/% $(TO_TRANS_FILES)
	tar rhf $(TO_TRANS_TAR) --absolute-names \
	  --transform=s%$(LOCDROP_TMP_DIR)/%% $(MANIFEST_TRANS)
        # tarball with files not being translated
        # contains at least the DC file
	tar chf $(NO_TRANS_TAR) --absolute-names --transform=s%$(DOC_DIR)/%% \
	  $(DOCCONF)
	tar rhf $(NO_TRANS_TAR) --absolute-names \
	  --transform=s%$(LOCDROP_TMP_DIR)/%% $(MANIFEST_NOTRANS)
    ifdef NO_TRANS_FILES
	tar rhf $(NO_TRANS_TAR) --absolute-names \
	  --transform=s%$(PROFILEDIR)/%xml/% $(NO_TRANS_FILES)
    endif
    ifdef DEF_FILE
	tar rhf $(NO_TRANS_TAR) --absolute-names --transform=s%$(DOC_DIR)/%% \
	  $(DEF_FILE) $(DC_FILES)
    endif
    ifdef TO_TRANS_IMGS
        # graphics tarball "translated graphics"
	BZIP2=--best tar cfhj $(TO_TRANS_IMG_TAR) \
	  --absolute-names --transform=s%$(DOC_DIR)/%% $(TO_TRANS_IMGS)
    endif
    ifdef NO_TRANS_IMGS
        # graphics tarball "translated graphics"
	BZIP2=--best tar cfhj $(NO_TRANS_IMG_TAR) \
	  --absolute-names --transform=s%$(DOC_DIR)/%% $(NO_TRANS_IMGS)
    endif
    ifneq ($(NOPDF),1)
	cp $(PDF_RESULT) $(LOCDROP_EXPORT_BOOKDIR)
    endif
	@if test -f $(NO_TRANS_TAR); then bzip2 -9f $(NO_TRANS_TAR); fi
	@if test -f $(TO_TRANS_TAR); then bzip2 -9f $(TO_TRANS_TAR); fi
	@ccecho "result" "Find the locdrop results at:\n$(LOCDROP_EXPORT_BOOKDIR)"

#----
# create manifest files
#
$(MANIFEST_TRANS): | $(LOCDROP_TMP_DIR)
	@echo -e "$(subst $(DOC_DIR)/,,$(DOCCONF))" > $@
  ifdef TO_TRANS_FILES
	@echo -e "$(subst $(SPACE),\n,$(sort $(subst \
	   $(PROFILEDIR),xml,$(TO_TRANS_FILES))))" >> $@
  endif
  ifdef TO_TRANS_IMGS
	@echo -e "$(subst $(SPACE),\n,$(sort $(subst \
	   $(DOC_DIR),xml,$(TO_TRANS_IMGS))))" >> $@
  endif


$(MANIFEST_NOTRANS): | $(LOCDROP_TMP_DIR)
	echo -n > $@
  ifdef NO_TRANS_FILES
	@echo -e "$(subst $(SPACE),\n,$(sort $(subst $(PROFILEDIR),xml,$(NO_TRANS_FILES))))" >> $@
  endif
  ifdef DEF_FILE
	@echo -e "$(subst $(SPACE),\n,$(sort $(subst $(DOC_DIR)/,,$(DC_FILES))))" >> $@
  endif
  ifdef NO_TRANS_IMGS
	@echo -e "$(subst $(SPACE),\n,$(sort $(subst \
	   $(DOC_DIR),xml,$(NO_TRANS_IMGS))))" >> $@
  endif

#----
# create directories
#
$(LOCDROP_EXPORT_BOOKDIR) $(LOCDROP_TMP_DIR):
	mkdir -p $@

