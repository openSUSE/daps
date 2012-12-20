
# Help file format
#
ifeq ($(MAKECMDGOALS),package-pdf)
  HF_FORMAT := pdf
endif
ifeq ($(MAKECMDGOALS),package-html)
  HF_FORMAT := html
endif

DESKTOPFILES_RESULT  := $(PACK_DIR)/$(BOOK)$(LANGSTRING)-desktop.tar.bz2
DOCUMENTFILES_RESULT := $(PACK_DIR)/$(BOOK)$(LANGSTRING)-$(HF_FORMAT).document
PAGEFILES_RESULT     := $(PACK_DIR)/$(BOOK).page

$(PACK_DIR) $(DESKTOP_FILES_DIR):
	mkdir -p $@

#--------------
# package-src
#
# If a DEF-file is specified, get additional DC-files from the DEF file
#
# ROOTID is _never_ set with package-src (see common.mk), therefore
# we always operate on the complete set
#
#
.PHONY: package-src
package-src: | $(PACK_DIR)
package-src: TARBALL := $(PACK_DIR)/$(BOOK)$(LANGSTRING)_src_set.tar
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

package-src-name:
	@ccecho "result" "$(RESULT_DIR)/package/src/$(BOOK)_$(LL).tar.bz2"

#--------------
# package-html
#
#  * HTML tarball
#  * desktop files (for KDE)
#  * yelp files HTML (for GNOME)
#
#
.PHONY: package-html
package-html:  | $(PACK_DIR)
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
	cp $(RESULT_DIR)/$(TMP_BOOK)_$(LL)-html.tar.bz2 \
	  $(PACK_DIR)/$(BOOK)_$(LL)-html.tar.bz2
	@ccecho "result" "Find the package-html results at:\n$(PACK_DIR)"
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
package-pdf: color-pdf
  ifdef MISSING
	@ccecho "error" "Fatal error: The following images are missing:"
	@echo -e "$(subst $(SPACE),\n,$(sort $(MISSING)))"
	exit 1
  else
	ln -sf $(RESULT_DIR)/$(TMP_BOOK)_$(LL).pdf $(PACK_DIR)/$(BOOK)_$(LL).pdf
	@ccecho "result" "Find the package-pdf results at:\n$(PACK_DIR)"
  endif

#--------------
#
# package-jsp
#
#  * JSP tarball
#
.PHONY: package-jsp
package-jsp: PACKDIR = $(RESULT_DIR)/package/jsp
package-jsp: dist-jsp
  ifdef MISSING
	@ccecho "error" "Fatal error: The following images are missing:"
	@echo -e "$(subst $(SPACE),\n,$(sort $(MISSING)))"
	exit 1
  else
# remove old stuff
	rm -rf $(PACKDIR) && mkdir -p $(PACKDIR)
# copy JSP tarball
	cp $(RESULT_DIR)/$(TMP_BOOK)_$(LL)-jsp.tar.bz2 \
	  $(PACKDIR)/$(BOOK)_$(LL)-jsp.tar.bz2
	@ccecho "result" "Find the package-jsp results at:\n$(PACKDIR)"
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
  LOCDROP_EXPORT_BOOKDIR := $(addsuffix /$(BOOK),$(LOCDROP_EXPORT_DIR))
endif

ifdef USESVN
  TO_TRANS_FILES := $(shell svn pl -v --xml $(DOCFILES) | xsltproc $(DAPSROOT)/daps-xslt/common/get-svn-props.xsl -)
endif
TO_TRANS_TAR    := $(LOCDROP_EXPORT_BOOKDIR)/translation-$(BOOK)$(LANGSTRING).tar.bz2

NO_TRANS_FILES := $(filter-out $(TOTRANSFILES), $(SRCFILES))
NO_TRANS_TAR   := $(LOCDROP_EXPORT_BOOKDIR)/setfiles-$(BOOK)$(LANGSTRING).tar


.PHONY: locdrop
locdrop: | $(LOCDROP_EXPORT_BOOKDIR)
locdrop: $(SRCFILES) $(USED_ALL) $(PROFILES) $(PROFILEDIR)/.validate
ifndef NOPDF
locdrop: color-pdf
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
	  --transform=s%$(DOC_DIR)%xml% $(TO_TRANS_FILES)
        # tarball with files not being translated
	tar chf $(NO_TRANS_TAR) --absolute-names \
	  --transform=s%$(DOC_DIR)%xml% $(NO_TRANS_FILES)
	tar rhf $(NO_TRANS_TAR) --absolute-names --transform=s%$(DOC_DIR)/%% \
	  $(DOCCONF)
    ifdef DEF_FILE
	tar rhf $(NO_TRANS_TAR) --absolute-names --transform=s%$(DOC_DIR)/%% \
	  $(DEF_FILE)
    endif
	bzip2 -9f $(NO_TRANS_TAR)
        # graphics tarball
	BZIP2=--best tar rfh \
	  $(LOCDROP_EXPORT_BOOKDIR)/$(BOOK)$(LANGSTRING)-graphics.tar.bz2 \
	  --absolute-names --transform=s%$(DOC_DIR)/%% $(USED_ALL)
    ifneq ($(NOPDF),1)
	cp $(RESULT_DIR)/$(TMP_BOOK)$(LANGSTRING).pdf $(LOCDROP_EXPORT_BOOKDIR)
    endif
	@ccecho "result" "Find the locdrop results at:\n$(LOCDROP_EXPORT_BOOKDIR)"
  endif


#----
# also creates $(LOCDROP_EXPORT_DIR)
#
$(LOCDROP_EXPORT_BOOKDIR):
	mkdir -p $@


#--------------
# online-docs
#

# need by SUSE to publish documents on www.suse.com/documentation
# when _NOT_ called with --noset creates the following files
# $OD_EXPORT_DIR/
#   |-set_bigfile.xml
#   |-set_graphics_png.tar.bz2
#   |-$DOCNAME
#   |   |-book.epub
#   |   |-book.color-pfd
#   |   |-book.dist-single-html
#
# When called with --noset, all files are copied to $OD_EXPORT_DIR/$DOCNAME
# The bigfile generated with this option has all links pointing to
# locations outside the specified ROOTID converted to text
# (same as the bigfile target)

ifndef OD_EXPORT_DIR
  OD_EXPORT_DIR     := $(RESULT_DIR)/online-docs
  OD_EXPORT_BOOKDIR := $(OD_EXPORT_DIR)
else
  OD_EXPORT_BOOKDIR := $(addsuffix /$(BOOK),$(OD_EXPORT_DIR))
endif

ifeq ($(NOSET),1)
  OD_BIGFILE  := $(OD_EXPORT_DIR)/$(BOOK)/$(BOOK)$(LANGSTRING).xml
  OD_GRAPHICS := $(OD_EXPORT_DIR)/$(BOOK)/$(BOOK)$(LANGSTRING)-png-graphics.tar.bz2
else
  OD_BIGFILE  := $(OD_EXPORT_DIR)/set$(LANGSTRING).xml
  OD_GRAPHICS := $(OD_EXPORT_DIR)/set$(LANGSTRING)-png-graphics.tar.bz2
endif

.PHONY: online-docs
online-docs: | $(OD_EXPORT_BOOKDIR)
online-docs: $(OD_BIGFILE) $(OD_GRAPHICS) warn-cap
online-docs: color-pdf dist-htmlsingle epub 
  ifdef MISSING
	@ccecho "error" "Fatal error: The following images are missing:"
	@echo -e "$(subst $(SPACE),\n,$(sort $(MISSING)))"
	exit 1
  else
	cp $(RESULT_DIR)/$(TMP_BOOK)$(LANGSTRING).pdf \
	   $(RESULT_DIR)/$(TMP_BOOK)$(LANGSTRING)-htmlsingle.tar.bz2 \
	   $(RESULT_DIR)/$(TMP_BOOK_NODRAFT).epub $(OD_EXPORT_BOOKDIR)
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
    ifeq ($(VERBOSITY),1)
	@ccecho "info" "Creating bigfile for book"
    endif
	xsltproc --xinclude --output $@ $(ROOTSTRING) \
	  $(STYLEBURN) $(PROFILED_MAIN) $(DEVNULL)
  else
    ifeq ($(VERBOSITY),1)
	@ccecho "info" "Creating bigfile for complete set"
    endif
	xmllint --xinclude --output $@ $(PROFILED_MAIN)
  endif

#----
# creates an archive with all generated png graphics
#
$(OD_GRAPHICS): $(PNGONLINE)
  ifdef PNGONLINE
    ifeq ($(VERBOSITY),2)
	@ccecho "info" "Creating online-docs graphics tarball..."
    endif
	BZIP2=--best \
	tar cjhf $@ --exclude-vcs --ignore-failed-read \
	  --absolute-names --transform=s%$(IMG_GENDIR)/online%images/src/png% \
	  $(sort $(PNGONLINE))
  else
	@ccecho "info" "Selected set or book contains no graphics"
  endif


#--------------
# online-localized
# 
# Replaces xrefs to other books with an ulink to <?provo dirname>
# plus text like "See book FOO, chapter BAR"
# This allows to deliver only one book with this target, since the xrefs have
# been replaced (normally we deliver a complete set where all xrefs cen be
# resolved)
#
# Useful for delivering translated manuals, when only part of the set has been
# translated
#
# Only useful when delivering stuff to Provo (rballard)
#
.PHONY: online-localized
online-localized: ODDIR = $(RESULT_DIR)/online-localized
online-localized: dist-graphics-png $(TMP_XML)
# remove old stuff
	rm -rf $(ODDIR) && mkdir -p $(ODDIR)
# create bigfile
	xsltproc --nonet --output $(ODDIR)/$(notdir $(MAIN)) $(ROOTSTRING) \
		--param use.id.as.filename 1 $(STYLEEXTLINK) $(TMP_XML)
ifdef USED
# copy graphics
	cp $(RESULT_DIR)/$(TMP_BOOK)_$(LL)-png-graphics.tar.bz2 \
	  $(ODDIR)/$(BOOK)_$(LL)-graphics.tar.bz2
	@ccecho "info" "Created $(ODDIR)/$(BOOK)_$(LL)-graphics.tar.bz2"
else
	@ccecho "info" "Selected book/set contains no graphics"
endif
	@ccecho "result" "Find the online-localized results at:\n$(ODDIR)"


#--------------
# Document file
#
YELPSTRINGS := --stringparam docpath "@PATH@/" \
		--stringparam outformat "$(HF_FORMAT)" \
		--stringparam docid "com.novell.$(DOCNAME)$(subst _,,$(LL))$(HF_FORMAT)" \

$(DOCUMENTFILES_RESULT): | $(PACK_DIR)
	xsltproc $(YELPSTRINGS) $(ROOTSTRING) --output $@ --xinclude \
	  $(STYLE_YELP) $(PROFILED_MAIN)


#-------------
# Page file (for GNOME 3 help)
#

$(PAGEFILES_RESULT): | $(PACK_DIR)
	xsltproc --output $@ --xinclude \
	  --stringparam packagename $(TMP_BOOK) $(STYLE_MALLARD) \
	  $(PROFILED_MAIN)


#--------------
# Desktop files tarball
#

$(DESKTOPFILES_RESULT): | $(PACK_DIR)
$(DESKTOPFILES_RESULT): | $(DESKTOP_FILES_DIR)
	xsltproc $(DESKTOP_FILES_STRINGS) $(ROOTSTRING) --xinclude \
	  $(STYLE_DESKTOP_FILES) $(PROFILED_MAIN)
	BZIP2="--best" tar cjf $@ --absolute-names \
	  --transform=s%$(DESKTOP_FILES_DIR)%desktop/% $(DESKTOP_FILES_DIR)
	rm -rf $(DESKTOP_FILES_DIR)/*


