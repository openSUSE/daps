# Copyright (C) 2012-2015 SUSE Linux GmbH
#
# Author:
# Frank Sundermeyer: <fsundermeyer at opensuse dot org>
#
# Packaging targets for DAPS
#
# Please submit feedback or patches to
# <fsundermeyer at opensuse dot org>
#

# fs 2012-10-26
# TODO: dist-webhelp

DESKTOP_FILES_DIR := $(TMP_DIR)/desktop

$(DESKTOP_FILES_DIR) $(PACK_DIR) $(PACKAGE_HTML_DIR) $(PACKAGE_PDF_DIR):
	mkdir -p $@


#--------------
# package-src
#
# ROOTID is _never_ set with package-src (see common_variables.mk), therefore
# we always operate on the complete set
#
# If a DEF-file is specified, get additional DC-files from the DEF file
#

# fs 2012-10-25:
# TODO: Add a --addfiles option that allows to add files from everywhere
#       in the filesystem. 
#
.PHONY: package-src
package-src: | $(PACK_DIR)
ifeq "$(OPTIPNG)" "1"
  package-src: optipng
endif
ifdef DEF_FILE
  package-src: DC_FILES := $(addprefix $(DOC_DIR)/,$(shell awk '/^[ \t]*#/ {next};NF {printf "DC-%s ", $$2}' $(DEF_FILE)))
endif
ifdef IS_LOCDROP
  package-src: MFT_TRANS := $(wildcard $(addprefix $(DOC_DIR)/,$(notdir $(MANIFEST_TRANS))))
  package-src: MFT_NOTRANS := $(wildcard $(addprefix $(DOC_DIR)/,$(notdir $(MANIFEST_NOTRANS))))
endif
package-src: $(PROFILES) $(PROFILEDIR)/.validate
  ifdef MISSING
	@ccecho "error" "Fatal error: The following images are missing:"
	@echo -e "$(subst $(SPACE),\n,$(sort $(MISSING)))"
	exit 1
  else
	tar chf $(PACKAGE_SRC_TARBALL) --absolute-names \
	  --transform=s%$(PROFILEDIR)%xml% $(PROFILES)
	tar rfh $(PACKAGE_SRC_TARBALL) --absolute-names \
	  --transform=s%$(DOC_DIR)/%% $(USED_ALL) $(DOCCONF)
    ifdef DEF_FILE
	tar rfh $(PACKAGE_SRC_TARBALL) --absolute-names \
	  --transform=s%$(DOC_DIR)/%% $(DC_FILES)
    endif
    ifdef IS_LOCDROP
	tar rfh $(PACKAGE_SRC_TARBALL) --absolute-names \
	  --transform=s%$(DOC_DIR)/%% $(MFT_TRANS) $(MFT_NOTRANS)
    endif
	bzip2 -9f $(PACKAGE_SRC_TARBALL)
	@ccecho "result" "Find the sources at:\n$(PACKAGE_SRC_RESULT)"
  endif

#--------------
# package-pdf
#
.PHONY: package-pdf
package-pdf: | $(PACKAGE_PDF_DIR)
ifeq "$(DESKTOPFILES)" "1"
  package-pdf: $(DESKTOPFILES_RESULT)
endif
ifeq "$(DOCUMENTFILES)" "1"
  package-pdf: $(DOCUMENTFILES_RESULT)
endif
ifeq "$(PAGEFILES)" "1"
  package-pdf: $(PAGEFILES_RESULT)
endif
package-pdf: $(PDF_RESULT)
  ifdef MISSING
	@ccecho "error" "Fatal error: The following images are missing:"
	@echo -e "$(subst $(SPACE),\n,$(sort $(MISSING)))"
	exit 1
  else
	cp $(PDF_RESULT) $(PACKAGE_PDF_RESULT)
	@ccecho "result" "Find the package-pdf results at:\n$(PACKAGE_PDF_DIR)/"
  endif

#--------------
# package-html
#
# Note: CLEAN_DIR is always set to "1" for this target
# (via lib/daps_functions)

.PHONY: package-html
package-html: | $(PACKAGE_HTML_DIR)
ifeq "$(DESKTOPFILES)" "1"
  package-html: $(DESKTOPFILES_RESULT)
endif
ifeq "$(DOCUMENTFILES)" "1"
  package-html: $(DOCUMENTFILES_RESULT)
endif
ifeq "$(PAGEFILES)" "1"
  package-html: $(PAGEFILES_RESULT)
endif
package-html: html
  ifdef MISSING
	@ccecho "error" "Fatal error: The following images are missing:"
	@echo -e "$(subst $(SPACE),\n,$(sort $(MISSING)))"
	exit 1
  else
	BZIP2="--best" tar cfhj $(PACKAGE_HTML_RESULT) -C $(dir $(HTML_DIR)) $(notdir $(HTML_DIR:%/=%))
    ifeq "$(TARGET)" "package-html"
	@ccecho "result" "Find the package-html results at:\n$(PACKAGE_HTML_DIR)/"
    endif
  endif

#--------------
# dist-webhelp
#
.PHONY: dist-webhelp
dist-webhelp: | $(PACK_DIR)
dist-webhelp: TARBALL := $(PACK_DIR)/$(DOCNAME)$(LANGSTRING)-webhelp.tar.bz2
dist-webhelp: webhelp
  ifdef MISSING
	@ccecho "error" "Fatal error: The following images are missing:"
	@echo -e "$(subst $(SPACE),\n,$(sort $(MISSING)))"
	exit 1
  else
	BZIP2="--best" tar cfhj $(TARBALL) --exclude-vcs \
	  -C $(RESULT_DIR)/webhelp $(DOCNAME)
	@ccecho "result" "Find the webhelp archive at:\n$(TARBALL)"
  endif

#--------------
# online-docs
#

# needed by SUSE to publish documents on www.suse.com/documentation
# when _NOT_ called with --noset creates the following files
# $OD_EXPORT_DIR/
#   |-set_bigfile.xml
#   |-$DOCNAME_graphics_png.tar.bz2
#   |-$DOCNAME
#   |   |-book.epub
#   |   |-book.pfd
#   |   |-book.dist-single-html
#
# When called with --noset, or without --export-dir all files are copied
# to $OD_EXPORT_DIR/$DOCNAME
# The bigfile generated with this option has all links pointing to
# locations outside the specified ROOTID converted to text
# (same as the bigfile target)
#
# Note: HTMLSINGLE is always set to "1" for this target
# (via lib/daps_functions)


ifndef OD_EXPORT_DIR
  OD_EXPORT_DIR     := $(RESULT_DIR)/online-docs
  OD_EXPORT_BOOKDIR := $(OD_EXPORT_DIR)
else
  OD_EXPORT_BOOKDIR := $(addsuffix /$(DOCNAME),$(OD_EXPORT_DIR))
endif

ifeq "$(NOSET)" "1"
  OD_BIGFILE  := $(OD_EXPORT_DIR)/$(DOCNAME)$(LANGSTRING).xml
else
  OD_BIGFILE  := $(OD_EXPORT_DIR)/set$(LANGSTRING)_bigfile.xml
endif
OD_GRAPHICS_TMP := $(OD_EXPORT_DIR)/$(DOCNAME)$(LANGSTRING)-online-graphics.tar
OD_GRAPHICS := $(OD_EXPORT_DIR)/$(DOCNAME)$(LANGSTRING)-online-graphics.tar.bz2

.PHONY: online-docs
online-docs: | $(OD_EXPORT_BOOKDIR)
online-docs: $(OD_BIGFILE) $(OD_GRAPHICS)
ifdef HTMLROOT
  online-docs: warn-cap
endif
ifeq "$(OPTIPNG)" "1"
  online-docs: optipng
endif
ifneq "$(NOPDF)" "1"
  online-docs: pdf
endif
ifneq "$(NOEPUB)" "1"
  online-docs: epub
endif
ifneq "$(NOHTML)" "1"
  online-docs: package-html
endif
online-docs:
  ifdef MISSING
	@ccecho "error" "Fatal error: The following images are missing:"
	@echo -e "$(subst $(SPACE),\n,$(sort $(MISSING)))"
	exit 1
  else
    ifneq "$(NOPDF)" "1"
	cp $(PDF_RESULT) $(OD_EXPORT_BOOKDIR)
    endif
    ifneq "$(NOEPUB)" "1"
	cp $(EPUB_RESULT) $(OD_EXPORT_BOOKDIR)
    endif
    ifneq "$(NOHTML)" "1"
	cp $(PACKAGE_HTML_RESULT) $(OD_EXPORT_BOOKDIR)
    endif
	@ccecho "result" "Find the online-docs result at:\n$(OD_EXPORT_DIR)"
  endif

#	cp $(PACKAGE_HTML_DIR)/$(DOCNAME)$(LANGSTRING)-single-html.tar.bz2 \
#	  $(OD_EXPORT_BOOKDIR)



#----
# also creates $(OD_EXPORT_DIR)
#
$(OD_EXPORT_BOOKDIR):
	mkdir -p $@

#----
# creates a bigfile either for a book (with --noset) or for the complete set
#
$(OD_BIGFILE): | $(OD_EXPORT_BOOKDIR)
$(OD_BIGFILE): $(DOCFILES) $(PROFILES) $(PROFILEDIR)/.validate
  ifeq "$(NOSET)" "1"
    ifeq "$(VERBOSITY)" "2"
	@ccecho "info" "Creating bigfile for book"
    endif
	$(XSLTPROC) --xinclude --output $@ $(ROOTSTRING) \
	  --stylesheet $(STYLEBIGFILE) --file $(PROFILED_MAIN) \
	  $(XSLTPROCESSOR) $(DEVNULL) $(ERR_DEVNULL)
  else
    ifeq "$(VERBOSITY)" "2"
	@ccecho "info" "Creating bigfile for complete set"
    endif
	xmllint --xinclude --output $@ $(PROFILED_MAIN)
  endif

#----
# creates an archive with all generated graphics for HTML/EPUB
#
# fs 2013-11-24: Creating the tarball manually (rather than by just
# adding $(ONLINE_IMAGES), because otherwise jpg would end up in
# the png subdirectory as well. If other "online" images will be supported
# in the future (SVG ??), a line for each format has to be added.
#

$(OD_GRAPHICS): | $(OD_EXPORT_BOOKDIR)
$(OD_GRAPHICS): $(ONLINE_IMAGES)
  ifneq "$(strip $(ONLINE_IMAGES))" ""
    ifeq ($(VERBOSITY),2)
	@ccecho "info" "Creating online-docs graphics tarball..."
    endif
      ifneq "$(strip $(PNGONLINE))" ""
	tar chf $(OD_GRAPHICS_TMP) --exclude-vcs --ignore-failed-read \
	  --absolute-names --transform=s%$(IMG_GENDIR)/color%images/src/png% \
	 $(IMG_GENDIR)/color/*.png
      endif
      ifneq "$(strip $(JPGONLINE))" ""
	tar rhf $(OD_GRAPHICS_TMP) --exclude-vcs --ignore-failed-read \
	  --absolute-names --transform=s%$(IMG_GENDIR)/color%images/src/jpg% \
	 $(IMG_GENDIR)/color/*.jpg
      endif
	bzip2 -9f $(OD_GRAPHICS_TMP)
  else
	@ccecho "info" "Selected set or book contains no graphics"
  endif


#-------------
# Page file
#
STYLE_MALLARD := $(DAPSROOT)/daps-xslt/mallard/docbook.xsl

$(PAGEFILES_RESULT): | $(PACK_DIR)
$(PAGEFILES_RESULT): $(PROFILES) $(PROFILEDIR)/.validate
	$(XSLTPROC) --output $@ --xinclude \
	  --stringparam "packagename=$(DOCNAME)" --stylesheet $(STYLE_MALLARD) \
	  --file $(PROFILED_MAIN) $(XSLTPROCESSOR) $(DEVNULL)

#--------------
# Document file
#
STYLE_YELP  := $(DAPSROOT)/daps-xslt/yelp/docbook.xsl
YELPSTRINGS := --stringparam "docpath=@PATH@/" \
	       --stringparam "outformat=$(HF_FORMAT)" \
	       --stringparam "docid=com.novell.$(DOCNAME)$(subst _,,$(LL))$(HF_FORMAT)"

$(DOCUMENTFILES_RESULT): | $(PACK_DIR)
$(DOCUMENTFILES_RESULT): $(PROFILES) $(PROFILEDIR)/.validate
	$(XSLTPROC) $(YELPSTRINGS) $(ROOTSTRING) \
	  --output $@ --xinclude --stylesheet $(STYLE_YELP) \
	  --file $(PROFILED_MAIN) $(XSLTPROCESSOR) $(DEVNULL)

#--------------
# Desktop files tarball
#

STYLE_DESKTOP_FILES   := $(DAPSROOT)/daps-xslt/desktop/docbook.xsl
DESKTOP_FILES_STRINGS := --stringparam "docpath=@PATH@/" \
		        --stringparam "base.dir=$(DESKTOP_FILES_DIR)/"
ifdef LL
  DESKTOP_FILES_STRINGS += --stringparam "uselang=$(LL)"
endif

$(DESKTOPFILES_RESULT): | $(PACK_DIR)
$(DESKTOPFILES_RESULT): | $(DESKTOP_FILES_DIR)
$(DESKTOPFILES_RESULT): $(PROFILES) $(PROFILEDIR)/.validate
	$(XSLTPROC) $(DESKTOP_FILES_STRINGS) $(ROOTSTRING) --xinclude \
	  --stylesheet $(STYLE_DESKTOP_FILES) --file $(PROFILED_MAIN) \
	  $(XSLTPROCESSOR) $(ERR_DEVNULL)
	BZIP2="--best" tar cjf $@ --absolute-names \
	  --transform=s%$(DESKTOP_FILES_DIR)%desktop/% $(DESKTOP_FILES_DIR)
	rm -rf $(DESKTOP_FILES_DIR)
