#--------------
# package-html
#
#  * HTML tarball
#  * desktop files (for KDE)
#  * yelp files HTML (for GNOME)
#
#
.PHONY: package-html
package-html: PACKDIR = $(RESULT_DIR)/package/html
package-html: dist-html dist-desktop-files dist-document-files-html
  ifdef MISSING
	@ccecho "error" "Fatal error: The following images are missing:"
	@echo -e "$(subst $(SPACE),\n,$(sort $(MISSING)))"
	exit 1
  else
# remove old stuff
	rm -rf $(PACKDIR) && mkdir -p $(PACKDIR)
# copy HTML tarball
	cp $(RESULT_DIR)/$(TMP_BOOK)_$(LL)-html.tar.bz2 \
	  $(PACKDIR)/$(BOOK)_$(LL)-html.tar.bz2
# copy desktop files for KDE
	if test -f $(RESULT_DIR)/$(TMP_BOOK)_$(LL)-desktop.tar.bz2; then \
	  cp $(RESULT_DIR)/$(TMP_BOOK)_$(LL)-desktop.tar.bz2 \
	    $(PACKDIR)/$(BOOK)_$(LL)-desktop.tar.bz2; \
	else \
	 ccecho "info" "No desktop files for KDE helpcenter available"; \
	fi
# copy document files for GNOME
	if test -f $(RESULT_DIR)/$(TMP_BOOK)_$(LL)-yelp.tar.bz2; then \
	  cp $(RESULT_DIR)/$(TMP_BOOK)_$(LL)-yelp.tar.bz2 \
	    $(PACKDIR)/$(BOOK)_$(LL)-yelp.tar.bz2; \
	else \
	  ccecho "info" "No document files for GNOME yelp available"; \
	fi
	@ccecho "result" "Find the package-html results at:\n$(PACKDIR)"
  endif

#--------------
# package-pdf
#
#  * Color PDF
#  * desktop files (for KDE)
#  * yelp files PDF (for GNOME)
#  * DC-file
#
.PHONY: package-pdf
package-pdf: PACKDIR = $(RESULT_DIR)/package/pdf
package-pdf: color-pdf dist-document-files-pdf
  ifdef MISSING
	@ccecho "error" "Fatal error: The following images are missing:"
	@echo -e "$(subst $(SPACE),\n,$(sort $(MISSING)))"
	exit 1
  else
# remove old stuff
	rm -rf $(PACKDIR) && mkdir -p $(PACKDIR)
# copy color PDF
	cp  $(RESULT_DIR)/$(TMP_BOOK)_$(LL).pdf $(PACKDIR)/$(BOOK)_$(LL).pdf
# copy PDF document files for GNOME
	if test -f $(RESULT_DIR)/$(TMP_BOOK)_$(LL)-pdf-yelp.tar.bz2; then \
	  cp $(RESULT_DIR)/$(TMP_BOOK)_$(LL)-pdf-yelp.tar.bz2 \
	    $(PACKDIR)/$(BOOK)_$(LL)-pdf-yelp.tar.bz2; \
	else \
	  ccecho "info" "No PDF document files for GNOME yelp available"; \
	fi
	@ccecho "result" "Find the package-pdf results at:\n$(PACKDIR)"
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

#------------------
# package-src 
# * graphics tarball
# * Source tarball
#
# TODO:
# when ROOTID is specified, check whether it is the set's ROOTID
# e.g. with daps-xslt/common/get-headlines-ids.xsl
#
.PHONY: package-src
package-src: PACKDIR = $(RESULT_DIR)/package/src
ifdef DEF_FILE
# Get additional DC-files from the DEF file
# the awk scripts extracts the manual names from the second column of
# the DEF file (ignoring comments and blank lines) and adds DC- to it
#
package-src: E-FILES = $(shell awk '/^[ \t]*#/ {next};NF {printf "DC-%s\n", $$2}' $(DEF_FILE))
endif
package-src: dist-graphics dist-xml
package-src:
ifdef MISSING
	@ccecho "error" "Fatal error: The following images are missing:"
	@echo -e "$(subst $(SPACE),\n,$(sort $(MISSING)))"
	exit 1
else
  # remove old stuff
	rm -rf $(PACKDIR) && mkdir -p $(PACKDIR)
  ifdef ROOTID
	@ccecho "warn" "Warning: You specified a ROOTID. Sources may NOT be generated\nfor the whole set if !" >&2
  endif
# "copy" source files tarball (dist-xml) to an uncompressed tarball
	bzcat $(RESULT_DIR)/$(BOOK)_$(LL).tar.bz2 > $(PACKDIR)/$(BOOK)_$(LL).tar
  ifdef USED
# "copy" graphics to an uncompressed tarball
	bzcat $(RESULT_DIR)/$(TMP_BOOK)_$(LL)-graphics.tar.bz2 > \
		$(PACKDIR)/$(BOOK)_$(LL)-graphics.tar
# concat the two archives
	tar -A --file=$(PACKDIR)/$(BOOK)_$(LL).tar \
		$(PACKDIR)/$(BOOK)_$(LL)-graphics.tar
# remove graphics archive
	rm -f $(PACKDIR)/$(BOOK)_$(LL)-graphics.tar
  else
	@ccecho "info" "Selected book/set contains no graphics"
  endif
  ifdef DEF_FILE
# add DC-Files from DEF file
	tar rfh $(PACKDIR)/$(BOOK)_$(LL).tar --absolute-names \
	  --transform=s%$(DOC_DIR)/%% $(addprefix $(DOC_DIR)/, $(E-FILES))
  endif
	bzip2 -9f $(PACKDIR)/$(BOOK)_$(LL).tar
	@ccecho "result" "Find the sources at:\n$(PACKDIR)/$(BOOK)_$(LL).tar.bz2"
endif

package-src-name:
	@ccecho "result" "$(RESULT_DIR)/package/src/$(BOOK)_$(LL).tar.bz2"

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
# yelp-files
# Create tarball with document files for GNOME
#
#
.PHONY: dist-document-files-html
dist-document-files-html: OUTFORMAT = html
dist-document-files-html: TARBALL = $(RESULT_DIR)/$(TMP_BOOK)_$(LL)-html-yelp.tar.bz2
dist-document-files-html: $(YELP_DIR)/%.document
	BZIP2=--best && \
	tar cjf $(TARBALL) --absolute-names \
	  --transform=s%$(YELP_DIR)%yelp% $(YELP_DIR)
	@ccecho "result" "Find the HTML document files tarball at:\n$(TARBALL)" 

.PHONY: dist-document-files-pdf
dist-document-files-pdf: OUTFORMAT = pdf
dist-document-files-pdf: TARBALL = $(RESULT_DIR)/$(TMP_BOOK)_$(LL)-pdf-yelp.tar.bz2
dist-document-files-pdf: $(YELP_DIR)/%.document
	BZIP2=--best && \
	tar cjf $(TARBALL) --absolute-names \
	  --transform=s%$(YELP_DIR)%yelp% $(YELP_DIR)
	@ccecho "result" "Find the PDF document files tarball at:\n$(TARBALL)" 

.PHONY: document-files-html
document-files-html: OUTFORMAT = html
document-files-html: $(YELP_DIR)/%.document
	@ccecho "result" "Created document files in\n$(YELP_DIR)/"

.PHONY: document-files-pdf
document-files-pdf: OUTFORMAT = pdf
document-files-pdf: $(YELP_DIR)/%.document
	@ccecho "result" "Created document files in\n$(YELP_DIR)/"

.PHONY: document-files-dir-name
document-files-dir-name: $(YELP_DIR)
	@ccecho "result" "$(YELP_DIR)"

$(YELP_DIR):
	mkdir -p $@

$(YELP_DIR)/%.document: $(PROFILES) $(YELP_DIR)
# clean up first
	rm -rf $(YELP_DIR) && mkdir -p $(YELP_DIR)
	xsltproc $(DESKSTRINGS) $(ROOTSTRING) --nonet \
		--output $(YELP_DIR)/$(BOOK)_$(LL)-$(OUTFORMAT).document \
		--stringparam projectfile PROJECTFILE.$(BOOK) \
		--stringparam outformat $(OUTFORMAT) \
		--stringparam docid com.novell.$(BOOK)$(subst _,,$(LL))$(OUTFORMAT) \
		--xinclude $(STYLE_DOCUMENT) $(PROFILED_MAIN)

#--------------
# desktop-files
# Create tarball with desktop files for KDE
#
#
.PHONY: dist-desktop-files
dist-desktop-files: TARBALL = $(RESULT_DIR)/$(TMP_BOOK)_$(LL)-desktop.tar.bz2
dist-desktop-files: $(DESKTOP_FILES_DIR)/%.desktop
	BZIP2=--best && \
	tar cjf $(TARBALL) --absolute-names \
	  --transform=s%$(DESKTOP_FILES_DIR)%desktop/% $(DESKTOP_FILES_DIR)
	@ccecho "result" "Find the desktop files files tarball at:\n$(TARBALL)"

.PHONY: desktop-files
desktop-files: $(DESKTOP_FILES_DIR)/%.desktop
	@ccecho "result" "Created desktop files in\n$(DESKTOP_FILES_DIR)"

.PHONY: desktop-files-dir-name
desktop-files-dir-name:
	@ccecho "result" "$(DESKTOP_FILES_DIR)"

$(DESKTOP_FILES_DIR):
	mkdir -p $@

$(DESKTOP_FILES_DIR)/%.desktop: $(PROFILES) $(DESKTOP_FILES_DIR)
# clean up first
	rm -rf $(DESKTOP_FILES_DIR) && mkdir -p $(DESKTOP_FILES_DIR)
	xsltproc $(DESKSTRINGS) $(ROOTSTRING) --nonet \
		--stringparam projectfile PROJECTFILE.$(BOOK) \
		--xinclude $(STYLEDESK) $(PROFILED_MAIN)



#--------------
# page-files (Mallard)
# Create page-file for GNOME3
#
#-------------
# Page file
#

$(PACK_DIR)/$(TMP_BOOK)_$(LL).page: | $(Directories)
	xsltproc --output $@ --xinclude \
	  --stringparam packagename $(TMP_BOOK) $(STYLE_MALLARD) \
	  $(PROFILED_MAIN)

