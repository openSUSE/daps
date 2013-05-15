# Copyright (C) 2012 SUSE Linux Products GmbH
#
# Author: Frank Sundermeyer
#
# Stuff for DAPS that did not fit anywhere else
#
# Please submit feedback or patches to
# <fsundermeyer at opensuse dot org>
#

# fs 2012-10-26
# TODO: dist-webhelp

DESKTOP_FILES_DIR := $(TMP_DIR)/desktop

# Help file format
#
ifeq ($(MAKECMDGOALS),package-pdf)
  HF_FORMAT := pdf
endif
ifeq ($(MAKECMDGOALS),package-html)
  HF_FORMAT := html
endif

DESKTOPFILES_RESULT  := $(PACK_DIR)/$(DOCNAME)$(LANGSTRING)-desktop.tar.bz2
DOCUMENTFILES_RESULT := $(PACK_DIR)/$(DOCNAME)$(LANGSTRING)-$(HF_FORMAT).document
PAGEFILES_RESULT     := $(PACK_DIR)/$(DOCNAME).page

$(PACK_DIR) $(DESKTOP_FILES_DIR):
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
package-src: TARBALL := $(PACK_DIR)/$(DOCNAME)$(LANGSTRING)_src_set.tar
ifdef DEF_FILE
  package-src: DC_FILES := $(addprefix $(DOC_DIR)/,$(shell awk '/^[ \t]*#/ {next};NF {printf "DC-%s ", $$2}' $(DEF_FILE)))
endif
package-src: $(PROFILES) $(PROFILEDIR)/.validate
  ifdef MISSING
	@ccecho "error" "Fatal error: The following images are missing:"
	@echo -e "$(subst $(SPACE),\n,$(sort $(MISSING)))"
	exit 1
  else
	tar chf $(TARBALL) --absolute-names \
	  --transform=s%$(PROFILEDIR)%xml% $(PROFILES)
	tar rfh $(TARBALL) --absolute-names --transform=s%$(DOC_DIR)/%% \
	  $(USED_ALL) $(DOCCONF)
    ifdef DEF_FILE
	tar rfh $(TARBALL) --absolute-names --transform=s%$(DOC_DIR)/%% \
	  $(DC_FILES)
    endif
	bzip2 -9f $(TARBALL)
	@ccecho "result" "Find the sources at:\n$(TARBALL).bz2"
  endif

#--------------
# package-pdf
#
.PHONY: package-pdf
package-pdf: | $(PACK_DIR)
ifeq ($(DESKTOPFILES),1)
  package-pdf: $(DESKTOPFILES_RESULT)
endif
ifeq ($(DOCUMENTFILES),1)
  package-pdf: $(DOCUMENTFILES_RESULT)
endif
ifeq ($(PAGEFILES),1)
  package-pdf: $(PAGEFILES_RESULT)
endif
package-pdf: $(PDF_RESULT)
  ifdef MISSING
	@ccecho "error" "Fatal error: The following images are missing:"
	@echo -e "$(subst $(SPACE),\n,$(sort $(MISSING)))"
	exit 1
  else
	(cd $(PACK_DIR); ln -sf $(PDF_RESULT) $(DOCNAME)$(LANGSTRING).pdf)
	@ccecho "result" "Find the package-pdf results at:\n$(PACK_DIR)"
  endif

#--------------
# package-html
#
.PHONY: package-html
package-html: | $(PACK_DIR)
ifeq ($(DESKTOPFILES),1)
  package-html: $(DESKTOPFILES_RESULT)
endif
ifeq ($(DOCUMENTFILES),1)
  package-html: $(DOCUMENTFILES_RESULT)
endif
ifeq ($(PAGEFILES),1)
  package-html: $(PAGEFILES_RESULT)
endif
package-html: dist-html
  ifdef MISSING
	@ccecho "error" "Fatal error: The following images are missing:"
	@echo -e "$(subst $(SPACE),\n,$(sort $(MISSING)))"
	exit 1
  else
	@ccecho "result" "Find the package-html results at:\n$(PACK_DIR)"
  endif

#--------------
# dist-html
#
.PHONY: dist-html
dist-html: | $(PACK_DIR)
dist-html: TARBALL := $(PACK_DIR)/$(DOCNAME)$(LANGSTRING)-html.tar.bz2
dist-html: html
  ifdef MISSING
	@ccecho "error" "Fatal error: The following images are missing:"
	@echo -e "$(subst $(SPACE),\n,$(sort $(MISSING)))"
	exit 1
  else
	BZIP2="--best" tar cfhj $(TARBALL) -C $(RESULT_DIR)/html $(DOCNAME)
	@ccecho "result" "Find the HTML archive at:\n$(TARBALL)"
  endif

#--------------
# dist-single-html
#
.PHONY: dist-single-html
dist-single-html: | $(PACK_DIR)
dist-single-html: TARBALL :=\
			$(PACK_DIR)/$(DOCNAME)$(LANGSTRING)-singlehtml.tar.bz2
dist-single-html: single-html
  ifdef MISSING
	@ccecho "error" "Fatal error: The following images are missing:"
	@echo -e "$(subst $(SPACE),\n,$(sort $(MISSING)))"
	exit 1
  else
	BZIP2="--best" tar cfhj $(TARBALL) -C $(RESULT_DIR)/single-html \
	  $(DOCNAME)
	@ccecho "result" "Find the single-HTML archive at:\n$(TARBALL)"
  endif
#--------------
# package-jsp dist-jsp
#
.PHONY: package-jsp dist-jsp
package-jsp dist-jsp: | $(PACK_DIR)
package-jsp dist-jsp: TARBALL :=\
			$(PACK_DIR)/$(DOCNAME)$(LANGSTRING)-jsp.tar.bz2
package-jsp dist-jsp: jsp
  ifdef MISSING
	@ccecho "error" "Fatal error: The following images are missing:"
	@echo -e "$(subst $(SPACE),\n,$(sort $(MISSING)))"
	exit 1
  else
	BZIP2="--best" tar cfhj $(TARBALL) -C $(RESULT_DIR)/jsp $(DOCNAME)
	@ccecho "result" "Find the JSP archive at:\n$(TARBALL)"
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
#   |   |-book.color-pfd
#   |   |-book.dist-single-html
#
# When called with --noset, or without --export-dir all files are copied
# to $OD_EXPORT_DIR/$DOCNAME
# The bigfile generated with this option has all links pointing to
# locations outside the specified ROOTID converted to text
# (same as the bigfile target)
#
# NOTE:
# Generting a graphics tarball containing images for the complete
# set is not possible, therefore we are generating tarballs for each
# book

ifndef OD_EXPORT_DIR
  OD_EXPORT_DIR     := $(RESULT_DIR)/online-docs
  OD_EXPORT_BOOKDIR := $(OD_EXPORT_DIR)
else
  OD_EXPORT_BOOKDIR := $(addsuffix /$(DOCNAME),$(OD_EXPORT_DIR))
endif

ifeq ($(NOSET),1)
  OD_BIGFILE  := $(OD_EXPORT_DIR)/$(DOCNAME)/$(DOCNAME)$(LANGSTRING).xml
  OD_GRAPHICS := $(OD_EXPORT_DIR)/$(BOOK)/$(BOOK)$(LANGSTRING)-png-graphics.tar.bz2
else
  OD_BIGFILE  := $(OD_EXPORT_DIR)/set$(LANGSTRING)_bigfile.xml
  OD_GRAPHICS := $(OD_EXPORT_DIR)/$(BOOK)$(LANGSTRING)-png-graphics.tar.bz2
endif

# fs 2012-10-12:
# I am aware that calling make from within make is an ugly hack.
# But since HTML_DIR and the PDF stuff depends on MAKECMDGOALS
# I have not found a way to correctly build pdf, and html-flavours
# when they are dependencies of other targets
# Suggestions for improvements are welcome

.PHONY: online-docs
online-docs: | $(OD_EXPORT_BOOKDIR)
online-docs: $(OD_BIGFILE) $(OD_GRAPHICS) warn-cap
online-docs:
  ifdef MISSING
	@ccecho "error" "Fatal error: The following images are missing:"
	@echo -e "$(subst $(SPACE),\n,$(sort $(MISSING)))"
	exit 1
  else
	$(MAKE) -f $(DAPSROOT)/make/selector.mk color-pdf 
	$(MAKE) -f $(DAPSROOT)/make/selector.mk epub
	$(MAKE) -f $(DAPSROOT)/make/selector.mk dist-single-html
	cp $(PDF_RESULT) $(EPUB_RESULT) \
	  $(PACK_DIR)/$(DOCNAME)$(LANGSTRING)-singlehtml.tar.bz2 \
	  $(OD_EXPORT_BOOKDIR)
	@ccecho "result" "Find the online-docs result at:\n$(OD_EXPORT_DIR)"
  endif

#----
# also creates $(OD_EXPORT_DIR)
#
$(OD_EXPORT_BOOKDIR):
	mkdir -p $@

#----
# creates a bigfile either for a book (with --noset) or for the complete set
#
$(OD_BIGFILE): $(DOCFILES) $(PROFILES) $(PROFILEDIR)/.validate
  ifeq ($(NOSET),1)
    ifeq ($(VERBOSITY),2)
	@ccecho "info" "Creating bigfile for book"
    endif
	$(XSLTPROC) --xinclude --output $@ $(ROOTSTRING) \
	  --stylesheet $(STYLEBIGFILE) --file $(PROFILED_MAIN) \
	  $(XSLTPROCESSOR) $(DEVNULL) $(ERR_DEVNULL)
  else
    ifeq ($(VERBOSITY),2)
	@ccecho "info" "Creating bigfile for complete set"
    endif
	xmllint --xinclude --output $@ $(PROFILED_MAIN)
  endif

#----
# creates an archive with all generated graphics for HTML/EPUB
#
$(OD_GRAPHICS): $(FOR_HTML_IMAGES)
  ifdef FOR_HTML_IMAGES
    ifeq ($(VERBOSITY),2)
	@ccecho "info" "Creating online-docs graphics tarball..."
    endif
	BZIP2=--best \
	tar cjhf $@ --exclude-vcs --ignore-failed-read \
	  --absolute-names --transform=s%$(IMG_GENDIR)/online%images/src/png% \
	  $(sort $(FOR_HTML_IMAGES))
  else
	@ccecho "info" "Selected set or book contains no graphics"
  endif


#--------------
# locdrop
#
# * tarball with XML sources to be translated
# * tarball with rest of XML sources (complete set)
# * Graphics tarball (book only)
# * Color PDF
#

ifndef LOCDROP_EXPORT_DIR
  LOCDROP_EXPORT_BOOKDIR := $(RESULT_DIR)/locdrop
else
  LOCDROP_EXPORT_BOOKDIR := $(addsuffix /$(DOCNAME),$(LOCDROP_EXPORT_DIR))
endif
ifdef USESVN
  TO_TRANS_FILES := $(subst $(DOC_DIR)/xml,$(PROFILEDIR),$(shell svn pl -v --xml $(DOCFILES) | $(XSLTPROC) --stylesheet $(DAPSROOT)/daps-xslt/common/get-svn-props.xsl $(XSLTPROCESSOR)))
endif
TO_TRANS_TAR    := $(LOCDROP_EXPORT_BOOKDIR)/translation-$(DOCNAME)$(LANGSTRING).tar.bz2

NO_TRANS_FILES := $(filter-out $(TO_TRANS_FILES),$(subst $(DOC_DIR)/xml,$(PROFILEDIR),$(SRCFILES)))
NO_TRANS_TAR   := $(LOCDROP_EXPORT_BOOKDIR)/setfiles-$(DOCNAME)$(LANGSTRING).tar

.PHONY: locdrop
locdrop: | $(LOCDROP_EXPORT_BOOKDIR)
locdrop: $(SRCFILES) $(USED_ALL) $(PROFILES) $(PROFILEDIR)/.validate
  ifdef DEF_FILE
    locdrop: DC_FILES := $(addprefix $(DOC_DIR)/,$(shell awk '/^[ \t]*#/ {next};NF {printf "DC-%s ", $$2}' $(DEF_FILE)))
  endif
  ifndef USESVN
	@ccecho "error" "Fatal error: Cannot get list of translated files because\n$(MAIN) is not SVN controlled"
	exit 1
  endif
 ifndef TO_TRANS_FILES
	@ccecho "error" "Fatal error: This book does not contain any files for translation"
	exit 1
  endif
  ifdef MISSING
	@ccecho "error" "Fatal error: The following images are missing:"
	@echo -e "$(subst $(SPACE),\n,$(sort $(MISSING)))"
	exit 1
  else
        # tarball with files for translation
	BZIP2=--best tar chfj $(TO_TRANS_TAR) --absolute-names \
	  --transform=s%$(PROFILEDIR)/%xml/% $(TO_TRANS_FILES)
        # tarball with files not being translated
	tar chf $(NO_TRANS_TAR) --absolute-names \
	  --transform=s%$(PROFILEDIR)/%xml/% $(NO_TRANS_FILES)
	tar rhf $(NO_TRANS_TAR) --absolute-names --transform=s%$(DOC_DIR)/%% \
	  $(DOCCONF)
    ifdef DEF_FILE
	tar rhf $(NO_TRANS_TAR) --absolute-names --transform=s%$(DOC_DIR)/%% \
	  $(DEF_FILE) $(DC_FILES)
    endif
	bzip2 -9f $(NO_TRANS_TAR)
        # graphics tarball
	BZIP2=--best tar cfhj \
	  $(LOCDROP_EXPORT_BOOKDIR)/graphics-$(DOCNAME)$(LANGSTRING).tar.bz2 \
	  --absolute-names --transform=s%$(DOC_DIR)/%% $(USED_ALL)
    ifneq ($(NOPDF),1)
	$(MAKE) -f $(DAPSROOT)/make/selector.mk color-pdf DOCNAME=$(DOCNAME)
	cp $(RESULT_DIR)/$(DOCNAME)$(LANGSTRING).pdf $(LOCDROP_EXPORT_BOOKDIR)
    endif
	@ccecho "result" "Find the locdrop results at:\n$(LOCDROP_EXPORT_BOOKDIR)"
  endif

#----
# also creates $(LOCDROP_EXPORT_DIR)
#
$(LOCDROP_EXPORT_BOOKDIR):
	mkdir -p $@

#-------------
# Page file
#
STYLE_MALLARD := $(DAPSROOT)/daps-xslt/mallard/docbook.xsl

$(PAGEFILES_RESULT): | $(PACK_DIR)
$(PAGEFILES_RESULT): $(PROFILES) $(PROFILEDIR)/.validate
	$(XSLTPROC) --output $@ --xinclude \
	  --stringparam "packagename=$(DOCNAME)" --stylesheet $(STYLE_MALLARD) \
	  --file $(PROFILED_MAIN) $(XSLTPROCESSOR)

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
	  --file $(PROFILED_MAIN) $(XSLTPROCESSOR)

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
	  $(XSLTPROCESSOR)
	BZIP2="--best" tar cjf $@ --absolute-names \
	  --transform=s%$(DESKTOP_FILES_DIR)%desktop/% $(DESKTOP_FILES_DIR)
	rm -rf $(DESKTOP_FILES_DIR)/*
