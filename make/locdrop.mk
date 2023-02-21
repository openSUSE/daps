# Copyright (C) 2012-2015 SUSE Linux Products GmbH
#
# Author:
# Frank Sundermeyer <fsundermeyer at opensuse dot org>
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

# Defined in common_variables:
#
#LOCDROP_TMP_DIR
#MANIFEST_TRANS
#MANIFEST_NOTRANS


################################
#  !!!! IMPORTANT !!!! 
#
# This makefile _only_ works when profiled XML files exist, since this is
# a prerequisite for generating the image file lists
#
# This cannot be solved with dependencies,
# therefore "profile_first" MUST be called in the wrapper script prior to
# executing the locdrop target
#################################


ifeq "$(strip $(EXPORT_DIR))" ""
  LOCDROP_EXPORT_BOOKDIR := $(RESULT_DIR)/locdrop
else
  LOCDROP_EXPORT_BOOKDIR := $(addsuffix /$(DOCNAME),$(EXPORT_DIR))
endif

#------------------
# Determine which XML files will be translated:
#

# WORKAROUND:
#
# Needs to be determined from DOCFILES rather than PROFILES, since the
# latter does not contain all setfiles
#
# To allow <info> elements profiled with "os=xyz" the XPath
# db5:info[contains(@os, '$(PROFOS)') is used. If this fails
# the translation information is read from the first info element
# available.
# This has a few downsides:
# 1. Only works for os ($PROFOS) profiling
# 2. Only works for single values in PROFOS. If it is set to e.g.
#    PROFOS="a;b" the XPath will fail in case of os="b;a" or os="a"
# 3. If the first part of the XPath fails, the information will be read
#    from the first info element. Although this seems to be a reasonable
#    fallback, it may not be what is expected.


define db5_get_trans
  for F in $(DOCFILES); do \
    R=`$(XMLSTARLET) sel -N dm="urn:x-suse:ns:docmanager" -N db5="http://docbook.org/ns/docbook" -t -m "/*/db5:info[contains(@os, '$(PROFOS)') or position()=1]/dm:docmanager" -v "normalize-space(dm:translation)" $$F 2>/dev/null || echo "no"`; \
    if [ "yes" = "$$R" ]; then echo -n "$$F "; fi \
  done 2>/dev/null
endef

TO_TRANS_FILES := $(subst $(PRJ_DIR)/xml,$(PROFILEDIR),$(shell $(db5_get_trans)))

TO_TRANS_TAR := $(LOCDROP_EXPORT_BOOKDIR)/translation-$(DOCNAME)$(LANGSTRING).tar

# XML Files that do not get translated
#
NO_TRANS_FILES := $(filter-out $(TO_TRANS_FILES),$(subst $(PRJ_DIR)/xml,$(PROFILEDIR),$(SRCFILES)))
ifneq "$(strip $(NO_TRANS_FILES))" ""
  NO_TRANS_TAR   := $(LOCDROP_EXPORT_BOOKDIR)/setfiles-$(DOCNAME)$(LANGSTRING).tar
endif

# Normally, a manual is completely translated
# Create a list of files that are part of the manual, but are not marked
# for translation. If this list is not empty, a warning will be issued
# during locdrop processing
#
NO_TRANS_BOOK := $(filter-out $(subst $(PROFILEDIR)/,,$(TO_TRANS_FILES)),$(subst $(PRJ_DIR)/xml/,,$(DOCFILES)))
ifneq "$(strip $(NO_TRANS_BOOK))" ""
  NO_TRANS_BOOK := $(subst $(SPACE),\n,$(NO_TRANS_BOOK))
endif

#------------------
# Determine which image files will be "translated":
#
#
# Generating these filelist requires all files to be already profiled!!
# Therefore the profiling target needs to be  called in the wrapper script
# first!!
#
# USED_ALL contains all the images used in the current document. In case
# a document contains a mix of translated and untranslated files using
# USED_ALL will produce wrong results
# Therefore we need to extract the list of images from the TO_TRANS_FILES
# using the get_graphics.xsl stylesheet
# see issue #305 (https://github.com/openSUSE/daps/issues/305)
#
ifneq "$(strip $(USED_ALL))" ""
  # the shell call extracts all images from the profiled XML files that are
  # marked for translation ( TO_TRANS_FILES )
  #
  # The addprefix/addsuffix calls transform it into
  # images/src/*/foo.* and wildcard finds the existing file from this pattern
  #
  TO_TRANS_IMGS := $(sort $(wildcard $(addprefix $(IMG_SRCDIR)/*/,$(addsuffix .*,$(basename $(shell xsltproc $(DAPSROOT)/daps-xslt/common/get-graphics.xsl $(TO_TRANS_FILES) 2>/dev/null))))))
  TO_TRANS_IMG_TAR :=$(LOCDROP_EXPORT_BOOKDIR)/graphics-translation-$(DOCNAME)$(LANGSTRING).tar.bz2
endif

# XML Files that do not get translated
#
# get all images in the current set
#
USED_SET := $(shell $(XSLTPROC) --stringparam "filetype=img" --file $(SETFILES_TMP) --stylesheet $(DAPSROOT)/daps-xslt/common/extract-files-and-images.xsl $(XSLTPROCESSOR) 2>/dev/null)

ifneq "$(strip $(USED_SET))" ""
  # USED_SET contains just the images names as mentioned in the XML sources
  # (foo.png). The addprefix/addsuffix calls transform it into
  # /bar/images/src/*/foo.*, wildcard resolves that string into existing files
  # and sort removes the duplicates
  #
  USED_SET_ALL := $(sort $(wildcard \
     $(addprefix $(IMG_SRCDIR)/*/,$(addsuffix .*,$(basename $(USED_SET)) ))))

  ifdef TO_TRANS_IMGS
    NO_TRANS_IMGS = $(filter-out $(TO_TRANS_IMGS),$(USED_SET_ALL))
  else
    NO_TRANS_IMGS := $(USED_SET_ALL)
  endif
    NO_TRANS_IMG_TAR :=$(LOCDROP_EXPORT_BOOKDIR)/graphics-setfiles-$(DOCNAME)$(LANGSTRING).tar.bz2
endif

.PHONY: locdrop
ifneq "$(strip $(DEF_FILE))" ""
  locdrop: DC_FILES := $(addprefix $(PRJ_DIR)/,$(shell awk '/^[ \t]*#/ {next};NF {printf "DC-%s ", $$2}' $(DEF_FILE) 2>/dev/null))
endif
locdrop: | $(LOCDROP_EXPORT_BOOKDIR) $(LOCDROP_TMP_DIR)
ifeq "$(OPTIPNG)" "1"
  locdrop: optipng
endif
ifneq "$(NOPDF)" "1"
  locdrop: pdf
endif
locdrop: $(SRCFILES) $(MANIFEST_TRANS) $(MANIFEST_NOTRANS) $(USED_ALL) $(PROFILES) $(PROFILEDIR)/.validate
  ifeq "$(strip $(TO_TRANS_FILES))" ""
	$(error $(shell ccecho "error" "Fatal error: Could not find any files to translate"))
  endif
  ifndef DOCCONF
	$(error $(shell ccecho "error" "Fatal error: locdrop is only supported when using a DC-file"))
  endif
  ifneq "$(strip $(MISSING_IMG))" ""
	@ccecho "error" "Fatal error: The following images are missing:"
	@echo -e "$(subst $(SPACE),\n,$(sort $(MISSING_IMG)))"
	$(error )
  endif
  ifneq "$(strip $(NO_TRANS_BOOK))" ""
	ccecho "warn" "Warning: The following files are not marked for translation:\n$(NO_TRANS_BOOK)" >&2
  endif
        # tarball with files for translation
	tar chf $(TO_TRANS_TAR) --absolute-names \
	  --transform=s%$(PROFILEDIR)/%xml/% $(TO_TRANS_FILES)
	tar rhf $(TO_TRANS_TAR) --absolute-names \
	  --transform=s%$(LOCDROP_TMP_DIR)/%% $(MANIFEST_TRANS)
        # tarball with files not being translated
        # contains at least the DC file
	tar chf $(NO_TRANS_TAR) --absolute-names --transform=s%$(PRJ_DIR)/%% \
	  $(DOCCONF)
	tar rhf $(NO_TRANS_TAR) --absolute-names \
	  --transform=s%$(LOCDROP_TMP_DIR)/%% $(MANIFEST_NOTRANS)
    ifneq "$(strip $(NO_TRANS_FILES))" ""
	tar rhf $(NO_TRANS_TAR) --absolute-names \
	  --transform=s%$(PROFILEDIR)/%xml/% $(NO_TRANS_FILES)
    endif
    ifneq "$(strip $(DEF_FILE))" ""
	tar rhf $(NO_TRANS_TAR) --absolute-names --transform=s%$(PRJ_DIR)/%% \
	  $(DEF_FILE) $(DC_FILES)
    endif
    ifneq "$(strip $(TO_TRANS_IMGS))" ""
        # graphics tarball "translated graphics"
	BZIP2=--best tar cfhj $(TO_TRANS_IMG_TAR) \
	  --absolute-names --transform=s%$(PRJ_DIR)/%% $(TO_TRANS_IMGS)
    endif
    ifneq "$(strip $(NO_TRANS_IMGS))" ""
        # graphics tarball "translated graphics"
	BZIP2=--best tar cfhj $(NO_TRANS_IMG_TAR) \
	  --absolute-names --transform=s%$(PRJ_DIR)/%% $(NO_TRANS_IMGS)
    endif
    ifneq "$(NOPDF)" "1"
	cp $(PDF_RESULT) $(LOCDROP_EXPORT_BOOKDIR)
    endif
	@if test -f $(NO_TRANS_TAR); then bzip2 -9f $(NO_TRANS_TAR); fi
	@if test -f $(TO_TRANS_TAR); then bzip2 -9f $(TO_TRANS_TAR); fi
	@ccecho "result" "Find the locdrop results at:\n$(LOCDROP_EXPORT_BOOKDIR)"

#----
# create manifest files
#
$(MANIFEST_TRANS): | $(LOCDROP_TMP_DIR)
	@echo -e "$(subst $(PRJ_DIR)/,,$(DOCCONF))" > $@
  ifdef TO_TRANS_FILES
	@echo -e "$(subst $(SPACE),\n,$(sort $(subst \
	   $(PROFILEDIR),xml,$(TO_TRANS_FILES))))" >> $@
  endif
  ifdef TO_TRANS_IMGS
	@echo -e "$(subst $(SPACE),\n,$(sort $(subst \
	   $(PRJ_DIR)/,,$(TO_TRANS_IMGS))))" >> $@
  endif


$(MANIFEST_NOTRANS): | $(LOCDROP_TMP_DIR)
	echo -n > $@
  ifdef NO_TRANS_FILES
	@echo -e "$(subst $(SPACE),\n,$(sort $(subst $(PROFILEDIR),xml,$(NO_TRANS_FILES))))" >> $@
  endif
  ifdef DEF_FILE
	@echo -e "$(subst $(SPACE),\n,$(sort $(subst $(PRJ_DIR)/,,$(DC_FILES))))" >> $@
  endif
  ifdef NO_TRANS_IMGS
	@echo -e "$(subst $(SPACE),\n,$(sort $(subst \
	   $(PRJ_DIR)/,,$(NO_TRANS_IMGS))))" >> $@
  endif

#----
# create directories
#
$(LOCDROP_EXPORT_BOOKDIR) $(LOCDROP_TMP_DIR):
	mkdir -p $@

