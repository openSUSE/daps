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


# Temporary bigfile that is either moved to OD_BIGFILE or converted
# to DB4/NOVDOC
#

OD_TMP_BIG := $(TMP_DIR)/$(DOCNAME)_for_conversion.xml

# Final bigfile
#
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
# creates a temporary bigfile either for a book (with --noset) or for
# the complete set
# Set to intermediate to recreate every time

.INTERMEDIATE: $(OD_TMP_BIG)
$(OD_TMP_BIG): | $(OD_EXPORT_BOOKDIR)
$(OD_TMP_BIG): $(DOCFILES) $(PROFILES) $(PROFILEDIR)/.validate
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
# Create the final bigfile from OD_TMP_BIG by either moving the tmp file or by
# converting it
# Make this target PHONY to ensure it is always rebuilt - otherwise running
# e.g. a dbtonovdoc conversion right after a db5tohtml conversion will not
# result in a NovDoc document
#
.PHONY: $(OD_BIGFILE)
$(OD_BIGFILE): | $(TMP_DIR)
$(OD_BIGFILE): $(OD_TMP_BIG)
  ifeq "$(DBNOCONV)" "1"
	cp $< $@
  else
    ifeq "$(DOCBOOK_VERSION)" "5"
      ifeq "$(DB5TODB4)" "1"
	$(XSLTPROC) --output $@ --stylesheet $(DAPSROOT)/daps-xslt/migrate/db5to4/db5to4-withdoctype.xsl --file $< $(XSLTPROCESSOR) $(DEVNULL) $(ERR_DEVNULL)
      else ifeq "$(DB5TODB4NH)" "1"
	$(XSLTPROC) --output $@ \
	  --stylesheet $(DAPSROOT)/daps-xslt/migrate/db5to4/db5to4.xsl \
	  --file $< $(XSLTPROCESSOR) $(DEVNULL) $(ERR_DEVNULL)
      else
        # DB5 -> DB4
	$(XSLTPROC) \
	  --output $(TMP_DIR)/$(DOCNAME)_for_conversion_db4.xml \
	  --stylesheet $(DAPSROOT)/daps-xslt/migrate/db5to4/db5to4.xsl \
	  --file $< $(XSLTPROCESSOR) $(DEVNULL) $(ERR_DEVNULL)
        # DB4 -> NOVDOC
	$(XSLTPROC) --output $@ \
	  --stylesheet $(DAPSROOT)/daps-xslt/migrate/db5to4/db4tonovdoc.xsl \
	  --file $(TMP_DIR)/$(DOCNAME)_for_conversion_db4.xml \
	  $(XSLTPROCESSOR) $(DEVNULL) $(ERR_DEVNULL)
      endif
    else
      # Since we have no means to determine whether a document is DB4 or NovDoc
      # we assume it is always DB4 and process it to NovDoc. In case it already
      # has been NovDoc the result will be OK, too
	$(XSLTPROC) --output $@ \
	  --stylesheet $(DAPSROOT)/daps-xslt/migrate/db5to4/db4tonovdoc.xsl \
	  --file $< $(XSLTPROCESSOR) $(DEVNULL) $(ERR_DEVNULL)
    endif
    ifeq "$(VERBOSITY)" "2"
	@ccecho "info" "Validating online-docs bigfile"
    endif
	xmllint --noent --postvalid --noout --xinclude $@
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
      ifneq "$(strip $(SVGONLINE))" ""
	tar rhf $(OD_GRAPHICS_TMP) --exclude-vcs --ignore-failed-read \
	  --absolute-names --transform=s%$(IMG_GENDIR)/color%images/src/svg% \
	 $(IMG_GENDIR)/color/*.svg
      endif
	bzip2 -9f $(OD_GRAPHICS_TMP)
  else
	@ccecho "info" "Selected set or book contains no graphics"
  endif
