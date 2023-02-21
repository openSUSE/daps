# Copyright (C) 2012-2020 SUSE Software Solutions Germany GmbH
#
# Author:
# Frank Sundermeyer <fsundermeyer at opensuse dot org>
#
# EPUB generation for DAPS
#
# Please submit feedback or patches to
# <fsundermeyer at opensuse dot org>
#

# includes are set in selector.mk
# include $(DAPSROOT)/make/setfiles.mk
# include $(DAPSROOT)/make/profiling.mk
# include $(DAPSROOT)/make/validate.mk
# include $(DAPSROOT)/make/images.mk
# include $(DAPSROOT)/make/misc.mk

# binary checks
ifeq "$(TARGET)" "epub"
  ifeq "$(RESULTCHECK)" "1"
    HAVE_ECHECK = $(shell which epubcheck 2>/dev/null)
    ifeq "$(HAVE_ECHECK)" ""
      $(error $(shell ccecho "error" "Error: epubcheck is not installed"))
    endif
  endif
endif
ifeq "$(TARGET)" "mobi"
  HAVE_CALIBRE = $(shell which ebook-convert 2>/dev/null)
  ifeq "$(HAVE_CALIBRE)" ""
    $(error $(shell ccecho "error" "Error: ebook-convert (provided by calibre) is not installed"))
  endif
endif

# Stylesheets
#
ifeq "$(EPUB3)" "1"
  STYLEEPUB := $(firstword $(wildcard $(addsuffix \
		/epub3/chunk.xsl, $(STYLE_ROOTDIRS))))
else
  STYLEEPUB   := $(firstword $(wildcard $(addsuffix \
			/epub/docbook.xsl, $(STYLE_ROOTDIRS))))
endif

# Three scenarios:
#
# <STYLESHEETDIR>/xhtml/static
#                        |-css
#                        |-js
#                        |-images
#
# or
#
# <STYLESHEETDIR>/static
#                  |-css
#                  |-js
#                  |-images
#
#
# or we have the DocBook standard layout:
#  <STYLESHEETDIR>/images
#  <STYLESHEETDIR>/xhtml/<FOO>.css
#
# If <STYLESHEETDIR>/epub/static exists, it is used by default. If not,
# <STYLESHEETDIR>/static is used. Alternatively, a custom static directory
# can be specified with the --statdir parameter.
#
# IS_STATIC is used to determine
# whether we have a static dir (IS_STATIC=static) or not.
#
# Set the styleimage directory. If no custom directory is set with --statdir,
# it can either be <STYLEROOT>/epub/static, <STYLEROOT>/static or
# <STYLEROOT>/images. If more than one of these directories exist, they will
# be used in the order listed (firstword function)
#
ifneq "$(strip $(STATIC_DIR))" ""
  STYLEIMG  := $(STATIC_DIR)
  IS_STATIC := static
else
  STYLEIMG := $(firstword $(wildcard \
		$(addsuffix static, $(dir $(STYLEEPUB)))\
		$(addsuffix static,$(dir $(patsubst %/,%,$(dir $(STYLEEPUB)))))\
		$(addsuffix images,$(dir $(patsubst %/,%,$(dir $(STYLEEPUB)))))))
  IS_STATIC := $(notdir $(STYLEIMG))
endif

ifeq "$(strip $(STYLEIMG))" ""
  $(error $(shell ccecho "error" "Fatal error: Could not find stylesheet images"))
endif


STYLEEPUB_BIGFILE := $(DAPSROOT)/daps-xslt/epub/db2db.xsl

EPUB_TMPDIR  := $(TMP_DIR)/epub_$(DOCNAME)
EPUB_OEBPS   := $(EPUB_TMPDIR)/OEBPS
EPUB_STATIC  := $(EPUB_OEBPS)/static
EPUB_BIGFILE := $(TMP_DIR)/epub_$(DOCNAME).xml

# inline images
#
EPUB_INLINE_DIR := $(EPUB_OEBPS)
EPUB_INLINE_IMAGES := $(subst $(IMG_GENDIR)/color,$(EPUB_INLINE_DIR),$(COLOR_IMAGES))

# Directories
#
EPUB_DIRECTORIES := $(EPUB_TMPDIR) $(EPUB_OEBPS) $(EPUB_STATIC)

EPUBSTRINGS := --param "show.comments=$(REMARKS)" \
		--stringparam "epub.oebps.dir=OEBPS/" \
		--stringparam "epub.metainf.dir=META-INF/"

ifeq "$(IS_STATIC)" "static"
  EPUBSTRINGS += --stringparam "callout.graphics.path=static/images/" \
                 --stringparam "admon.graphics.path=static/images/"
else
  EPUBSTRINGS += --stringparam "callout.graphics.path=static/callouts/" \
                 --stringparam "admon.graphics.path=static/"
endif

ifeq "$(EPUB3)" "1"
  EPUB_CONTENT_FILE := OEBPS/package.opf
else
  EPUB_CONTENT_FILE := OEBPS/content.opf
  EPUBSTRINGS       += --stringparam "base.dir=OEBPS/"
endif

EPUB_CONTENT_OPF := $(EPUB_TMPDIR)/$(EPUB_CONTENT_FILE)

ifneq "$(strip $(EPUB_CSS))" ""
  ifneq "$(strip $(EPUB_CSS))" "none"
    EPUBSTRINGS  += --stringparam "html.stylesheet=$(notdir $(EPUB_CSS))"
    EPUB_CSSFILE := $(EPUB_OEBPS)/$(notdir $(EPUB_CSS))
  else
    EPUBSTRINGS += --stringparam "html.stylesheet=\"\""
endif
endif

#--------------
# EPUB
#
# In order not to pack files that do not belong to the current ePUB build,
# we need to clear $(EPUB_TMPDIR) first. In order to avoid unwanted results
# with an unset $(EPUB_TMPDIR), we are adding a security check before
# deleting
#
.PHONY: epub
epub: $(shell if [[ $$(expr match "$(EPUB_TMPDIR)" "$(TMP_DIR)/epub_") -gt 0 && -d "$(EPUB_TMPDIR)" ]]; then rm -r "$(EPUB_TMPDIR)"; fi 2>&1 >/dev/null)
epub: list-images-missing
ifeq "$(RESULTCHECK)" "1"
  epub: epub-check
endif
epub: $(EPUB_RESULT)
  ifeq "$(TARGET)" "epub"
	@ccecho "result" "Find the EPUB book at:\n$<"
  endif

.PHONY: mobi
mobi: list-images-missing
mobi: $(MOBI_RESULT)
	@ccecho "result" "Find the Amazon Kindle book (.mobi) at:\n$<"
#--------------
# Create Directories
#
$(EPUB_DIRECTORIES):
	mkdir -p $@

#--------------
# generate EPUB-bigfile
#
$(EPUB_BIGFILE): $(PROFILES) $(PROFILEDIR)/.validate
  ifeq "$(VERBOSITY)" "2"
	@ccecho "info" "   Generating EPUB-bigfile"
  endif
	$(XSLTPROC) --xinclude --output $@ $(ROOTSTRING) \
	  --stylesheet $(STYLEEPUB_BIGFILE) \
	  --file $(PROFILED_MAIN) $(XSLTPROCESSOR)

#--------------
# HTML from EPUB-bigfile
#
$(EPUB_CONTENT_OPF): | $(EPUB_TMPDIR)
$(EPUB_CONTENT_OPF): $(EPUB_BIGFILE)
  ifeq "$(VERBOSITY)" "2"
	@ccecho "info" "   Creating HTML files for EPUB"
  endif
	(cd $(EPUB_TMPDIR) && $(XSLTPROC) $(EPUBSTRINGS) $(DAPSSTRINGS) \
	  $(PARAMS) $(XSLTPARAM) $(STRINGPARAMS)  \
	  --stylesheet $(STYLEEPUB) --file $< $(XSLTPROCESSOR) \
	  $(DEVNULL) $(ERR_DEVNULL))

#---------------
# Inline Graphics
#
$(EPUB_INLINE_IMAGES): $(COLOR_IMAGES) | $(EPUB_OEBPS)

$(EPUB_INLINE_DIR)/%.png: $(IMG_GENDIR)/color/%.png 
	ln -sf $(shell readlink -e $< 2>/dev/null) $@

$(EPUB_INLINE_DIR)/%.jpg: $(IMG_GENDIR)/color/%.jpg
	ln -sf $(shell readlink -e $< 2>/dev/null) $@

$(EPUB_INLINE_DIR)/%.svg: $(IMG_GENDIR)/color/%.svg
	ln -sf $(shell readlink -e $< 2>/dev/null) $@

#--------------
# mimetype file
#
$(EPUB_TMPDIR)/mimetype: | $(EPUB_TMPDIR)
	@echo -n "application/epub+zip" > $@

#--------------
# Generate EPUB-file
#
$(EPUB_RESULT): | $(EPUB_OEBPS) $(EPUB_STATIC) $(RESULT_DIR)
ifneq "$(EPUB3)" "1"
  $(EPUB_RESULT): $(EPUB_TMPDIR)/mimetype
endif
$(EPUB_RESULT): $(EPUB_CONTENT_OPF) 
$(EPUB_RESULT): $(EPUB_INLINE_IMAGES)
  ifeq "$(VERBOSITY)" "2"
	@ccecho "info" "   Creating EPUB"
  endif
	cp -rs --remove-destination $(STYLEIMG)/* $(EPUB_STATIC)
  ifneq "$(strip $(EPUB_CSS))" ""
	cp -s --remove-destination $(EPUB_CSS) $(EPUB_OEBPS)
  endif
  ifeq "$(IS_STATIC)" "static"
	(cd $(EPUB_TMPDIR); zip -r -X $@ mimetype META-INF OEBPS $(DEVNULL))
  else
	(cd $(EPUB_TMPDIR); \
	  zip -r -X $@ mimetype META-INF $(EPUB_CONTENT_FILE) \
	   $(addprefix OEBPS/,$(shell xsltproc $(DAPSROOT)/daps-xslt/epub/get_manifest.xsl $(EPUB_CONTENT_OPF) 2>/dev/null)) $(DEVNULL))
  endif

#--------------
# Check epub file
#
# Check the epub file
#
.PHONY: epub-check
epub-check: $(EPUB_RESULT)
	@ccecho "result" "#################### BEGIN epubcheck report ####################"
	epubcheck $< 2>&1 || true
	@ccecho "result" "#################### END epubcheck report ####################"
#--------------
# mobi (Amazon Kindle)
#
# we are using calibre's ebook-convert to convert the epub file to mobi
# The format generated is MOBI 6, which is compatible to all Amazon devices

$(MOBI_RESULT): 
$(MOBI_RESULT): $(EPUB_RESULT)
	ebook-convert $< $@ --mobi-ignore-margins --no-inline-toc \
	  --pretty-print $(DEVNULL)

#Options to set metadata in the output
#
#--author-sort
#String to be used when sorting by author.
#
#--authors
#Set the authors. Multiple authors should be separated by ampersands.
#
#--book-producer
#Set the book producer.
#
#--comments
#Set the ebook description.
#
#--cover
#Set the cover to the specified file or URL
#
#--isbn
#Set the ISBN of the book.
#
#--language
#Set the language.
#
#--pubdate
#Set the publication date.
#
#--publisher
#Set the ebook publisher.
#
#--rating
#Set the rating. Should be a number between 1 and 5.
#
#--series
#Set the series this ebook belongs to.
#
#--series-index
#Set the index of the book in this series.
#
#--tags
#Set the tags for the book. Should be a comma separated list.
#
#--timestamp
#Set the book timestamp (no longer used anywhere)
#
#--title
#Set the title.
#
#--title-sort
#The version of the title to be used for sorting.
#
