# Copyright (C) 2012-2015 SUSE Linux GmbH
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
EPUB_INLINE_IMAGES := $(subst $(IMG_GENDIR)/color,$(EPUB_INLINE_DIR),$(ONLINE_IMAGES))

# Directories
#
EPUB_DIRECTORIES := $(EPUB_TMPDIR) $(EPUB_OEBPS) $(EPUB_STATIC)

EPUBSTRINGS := --stringparam "img.src.path=\"\"" \
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
  EPUBSTRINGS       += --stringparam "base.dir=\"\""
else
  EPUB_CONTENT_FILE := OEBPS/content.opf
  EPUBSTRINGS       += --stringparam "base.dir=OEBPS/"
endif

EPUB_CONTENT_OPF := $(EPUB_TMPDIR)/$(EPUB_CONTENT_FILE)

ifneq "$(strip $(EPUB_CSS))" ""
  EPUBSTRINGS  += --stringparam "html.stylesheet=$(notdir $(EPUB_CSS))"
  EPUB_CSSFILE := $(EPUB_OEBPS)/$(notdir $(EPUB_CSS))
endif



#--------------
# EPUB
#
.PHONY: epub
epub: list-images-missing
ifeq "$(EPUBCHECK)" "yes"
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
$(EPUB_CONTENT_OPF): $(EPUB_BIGFILE)
  ifeq "$(VERBOSITY)" "2"
	@ccecho "info" "   Creating HTML files for EPUB"
  endif
	(cd $(EPUB_TMPDIR) && $(XSLTPROC) $(EPUBSTRINGS) --stylesheet $(STYLEEPUB) \
	  --file $< $(XSLTPROCESSOR) $(DEVNULL) $(ERR_DEVNULL))

#---------------
# Inline Graphics
#
$(EPUB_INLINE_IMAGES): $(ONLINE_IMAGES) | $(EPUB_OEBPS)

$(EPUB_INLINE_DIR)/%.png: $(IMG_GENDIR)/color/%.png 
	ln -sf $(shell readlink -e $<) $@

$(EPUB_INLINE_DIR)/%.jpg: $(IMG_GENDIR)/color/%.jpg
	ln -sf $(shell readlink -e $<) $@

#--------------
# mimetype file
#
$(EPUB_TMPDIR)/mimetype: | $(EPUB_TMPDIR)
	@echo -n "application/epub+zip" > $@

#--------------
# Generate EPUB-file
#
$(EPUB_RESULT): | $(EPUB_OEBPS)
$(EPUB_RESULT): | $(EPUB_STATIC)
ifneq "$(EPUB3)" "1"
  $(EPUB_RESULT): $(EPUB_TMPDIR)/mimetype
endif
$(EPUB_RESULT): $(EPUB_CONTENT_OPF) 
$(EPUB_RESULT): $(EPUB_INLINE_IMAGES)
  ifeq "$(VERBOSITY)" "2"
	@ccecho "info" "   Creating EPUB"
  endif
	cp -rs $(STYLEIMG)/* --remove-destination $(EPUB_STATIC)
  ifneq "$(strip $(EPUB_CSS))" ""
	cp -s --remove-destination $(EPUB_CSS) $(EPUB_OEBPS)
  endif
  ifeq "$(IS_STATIC)" "static"
	(cd $(EPUB_TMPDIR); zip -r -X $@ mimetype META-INF OEBPS $(DEVNULL))
  else
	(cd $(EPUB_TMPDIR); \
	  zip -r -X $@ mimetype META-INF $(EPUB_CONTENT_FILE) \
	   $(addprefix OEBPS/,$(shell xsltproc $(DAPSROOT)/daps-xslt/epub/get_manifest.xsl $(EPUB_CONTENT_OPF))) $(DEVNULL))
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
