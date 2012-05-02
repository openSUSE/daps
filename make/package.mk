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
# remove old stuff
	rm -rf $(PACKDIR) && mkdir -p $(PACKDIR)
# copy color PDF
	cp  $(RESULT_DIR)/$(TMP_BOOK)_$(LL).pdf $(PACKDIR)
# copy PDF document files for GNOME
	if test -f $(RESULT_DIR)/$(TMP_BOOK)_$(LL)-pdf-yelp.tar.bz2; then \
	  cp $(RESULT_DIR)/$(TMP_BOOK)_$(LL)-pdf-yelp.tar.bz2 \
	    $(PACKDIR)/$(BOOK)_$(LL)-pdf-yelp.tar.bz2; \
	else \
	  ccecho "info" "No PDF document files for GNOME yelp available"; \
	fi
	@ccecho "result" "Find the package-pdf results at:\n$(PACKDIR)"

#--------------
#
# package-jsp
#
#  * JSP tarball
#
.PHONY: package-jsp
package-jsp: PACKDIR = $(RESULT_DIR)/package/jsp
package-jsp: dist-jsp
# remove old stuff
	rm -rf $(PACKDIR) && mkdir -p $(PACKDIR)
# copy JSP tarball
	cp $(RESULT_DIR)/$(TMP_BOOK)_$(LL)-jsp.tar.bz2 \
	  $(PACKDIR)/$(BOOK)_$(LL)-jsp.tar.bz2
	@ccecho "result" "Find the package-jsp results at:\n$(PACKDIR)"

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
.PHONY: locdrop
locdrop: INCLUDED = $(addprefix $(PROFILE_PARENT_DIR)/dist/,\
			$(shell xsltproc --nonet --xinclude $(STYLESEARCH) \
			$(PROFILE_PARENT_DIR)/dist/$(notdir $(MAIN))) \
			$(notdir $(MAIN)))
locdrop: TOTRANSFILES = $(sort $(subst $(DOC_DIR)/xml, \
			  $(PROFILE_PARENT_DIR)/dist, \
			  $(shell docmanager -d $(DOCCONF) dg -P --include="doc:trans=yes" -H -A -q "%{name} ")))
locdrop: NOTRANSFILES = $(filter-out $(TOTRANSFILES), $(INCLUDED))
locdrop: ENTITIES     = $(shell $(LIBEXEC_DIR)/getentityname.py $(INCLUDED))
locdrop: LOCDROPDIR   = $(RESULT_DIR)/locdrop
locdrop: TOTRANSTAR   = $(LOCDROPDIR)/locdrop-totrans-$(BOOK).tar.bz2
locdrop: NOTRANSTAR   = $(LOCDROPDIR)/locdrop-$(BOOK).tar
locdrop: $(PROFILEDIR)/.validate $(DISTPROFILE) link-entity-dist dist-graphics
ifndef NOPDF
locdrop: color-pdf
endif
locdrop:
# remove old stuff
	rm -rf $(LOCDROPDIR) && mkdir -p $(LOCDROPDIR)
#	@echo "checking for unexpected characters: ... "
#	egrep -n "[^[:alnum:][:punct:][:blank:]]" $(INCLUDED) && \
#	    echo "Found non-printable characters" || echo "OK"
# totrans tarball
ifdef TOTRANSFILES
	@ccecho "warn" "No files for translation available" >&2
	BZIP2=--best && tar chfj $(TOTRANSTAR) --absolute-names \
	  --transform=s%$(PROFILE_PARENT_DIR)/dist%xml% $(TOTRANSFILES)
	@ccecho "info" "Created $(TOTRANSTAR)"
endif
# notrans tarball
	tar chf $(NOTRANSTAR) --absolute-names \
	  --transform=s%$(PROFILE_PARENT_DIR)/dist%xml% $(NOTRANSFILES)
	tar rhf $(NOTRANSTAR)  --absolute-names --transform=s%$(DOC_DIR)/%% \
	  $(DOCCONF) $(addprefix $(DOC_DIR)/xml/,$(ENTITIES))
ifdef DEF_FILE
	tar rhf $(NOTRANSTAR)  --absolute-names --transform=s%$(DOC_DIR)/%% \
	  $(DEF_FILE)
endif
	bzip2 -9f $(NOTRANSTAR)
	@ccecho "info" "Created $(NOTRANSTAR).bz2"
ifdef USED
# copy graphics
	cp $(RESULT_DIR)/$(TMP_BOOK)_$(LL)-graphics.tar.bz2 \
	  $(LOCDROPDIR)/$(BOOK)_$(LL)-graphics.tar.bz2
	@ccecho "info" "Created $(LOCDROPDIR)/$(BOOK)_$(LL)-graphics.tar.bz2"
else
	@ccecho "info" "Selected book/set contains no graphics"
endif
#
# PDF generation can be switched off via wrapper script
#
ifneq ($(NOPDF), 1)
# copy color PDF
	cp $(RESULT_DIR)/$(TMP_BOOK)_$(LL).pdf $(LOCDROPDIR)
	@ccecho "info" "Created $(LOCDROPDIR)/$(TMP_BOOK)_$(LL).pdf"
endif
	@ccecho "result" "Find the locdrop results at:\n$(LOCDROPDIR)"

#--------------
# online-docs
#
# * "bigfile"
# * Graphics tarball (set)
#
# TODO:
# Build PDFs for all books / articles in set in order to be able to
# automatically provide them with the online docs target.
# Needed: Stylesheet that returns book and article IDs
# Code: See target dist in common.mk
# Problem: Articles are not allowed in <set> and therefore must be
#          placed in a book. In some cases we do not want such a book
#          to be printed (e.g. when delivering quickstarts), in other
#          cases we explicitly want such a book (openSUSE StartUp)
#
.PHONY: online-docs
online-docs: ODDIR = $(RESULT_DIR)/online-docs
online-docs: dist-graphics-png $(TMP_XML)
# remove old stuff
	rm -rf $(ODDIR) && mkdir $(ODDIR)
# copy bigfile
	cp $(TMP_XML) $(ODDIR)/$(notdir $(MAIN))
ifdef USED
# copy graphics
	cp $(RESULT_DIR)/$(TMP_BOOK)_$(LL)-png-graphics.tar.bz2 \
	  $(ODDIR)/$(BOOK)_$(LL)-graphics.tar.bz2
	@ccecho "info" "Created $(ODDIR)/$(BOOK)_$(LL)-graphics.tar.bz2"
else
	@ccecho "info" "Selected book/set contains no graphics"
endif
	@ccecho "result" "Find the online-docs results at:\n$(ODDIR)"


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




