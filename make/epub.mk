# Copyright (C) 2012 SUSE Linux Products GmbH
#
# Author: Frank Sundermeyer
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
ifeq ($(EPUB3),1)
  STYLEEPUB   := $(firstword $(wildcard $(addsuffix \
			/epub3/chunk.xsl, $(STYLE_ROOTDIRS))))
else
  STYLEEPUB   := $(firstword $(wildcard $(addsuffix \
			/epub/docbook.xsl, $(STYLE_ROOTDIRS))))
endif

#
# Make sure to use the STYLEIMG directory that comes alongside the
# STYLEROOT that is actually used. This is needed to ensure that the
# correct STYLEIMG is used, even when the current STYLEROOT is a
# fallback directory
#
# dir (patsubst %/,%,(dir STYLEEPUB)):
#  - remove filename
#  - remove trailing slash (dir function only works when last character
#    is no "/") -> patsubst is greedy
#  - remove dirname
#
STYLEIMG := $(addsuffix images,$(dir $(patsubst %/,%,$(dir $(STYLEEPUB)))))

#
# NOTE: Style image handling needs to go into a function. It is needed by
#       epub, html and webhelp
#
# Three scenarios:
#
# <STYLESHEETDIR>/epub/static
#                        |-css
#                        |-js
#                        |-images
#
# or
# <STYLESHEETDIR>/static
#                        |-css
#                        |-js
#                        |-images
#
#
# or we have the DocBook standard layout:
#  <STYLESHEETDIR>/images
#  <STYLESHEETDIR>/epub/<FOO>.css
#
# If <STYLESHEETDIR>/epub/static exists, it is used by default. If not,
# <STYLESHEETDIR>/static is used. We also assume that
# parameters for [admon|callout|navig].graphics.path are correctly set in
# the stylesheets. Alternatively, a custom static directory can be specified
# with the --statdir parameter.
# 
# In case we have the standard docbook layout, we need to set
# [admon|callout|navig].graphics.path. 
#
# IS_STATIC is used to determine
# whether we have a static dir (IS_STATIC=static) or not.
#
# Set the styleimage directory. If no custom directory is set with --statdir,
# it can either be <STYLEROOT>/epub/static, <STYLEROOT>/static or
# <STYLEROOT>/images. If more than one of these directories exist, they will
# be used in the order listed (firstword function)
#
ifdef STATIC_DIR
  STYLEIMG  := $(STATIC_DIR)
  IS_STATIC := static
else
  #
  # Make sure to use the STYLEIMG directory that comes alongside the
  # STYLEROOT that is actually used. This is needed to ensure that the
  # correct STYLEIMG is used, even when the current STYLEROOT is a
  # fallback directory
  #
  # dir (patsubst %/,%,(dir STYLEEPUB)):
  #  - remove filename
  #  - remove trailing slash (dir function only works when last character
  #    is no "/") -> patsubst is greedy
  #  - remove dirname
  #

  STYLEIMG := $(firstword $(wildcard \
		$(addsuffix static, $(dir $(STYLEEPUB)))\
		$(addsuffix images,$(dir $(patsubst %/,%,$(dir $(STYLEEPUB)))))))

  IS_STATIC := $(notdir $(STYLEIMG))
  ifndef EPUB_CSS
    ifneq ($(IS_STATIC),static)
      EPUB_CSS := $(shell readlink -e $(firstword $(wildcard $(dir $(STYLEEPUB))*.css)) 2>/dev/null )
      ifeq ($(VERBOSITY),1)
        ifneq "$(strip $(EPUB_CSS))" ""
          EPUB_CSS_INFO := No CSS file specified. Automatically using\n$(EPUB_CSS)
        else
          EPUB_CSS_INFO := No CSS file specified and no fallback found. Not using a CSS file.
        endif
      endif
    endif
  endif
endif


STYLEEPUB_BIGFILE := $(DAPSROOT)/daps-xslt/epub/db2db.xsl


# Directories
#
# TODO:
# Check image directory with daps 1.x branch - there it works
#
#

# Admonitions do not work for epub (not epub3) due to a bug in the official
# DocBook Stylesheets:
# https://sourceforge.net/tracker/?func=detail&aid=2849681&group_id=21935&atid=373747
#


EPUB_TMPDIR := $(TMP_DIR)/epub_$(DOCNAME)
EPUB_RESDIR := $(EPUB_TMPDIR)/OEBPS
EPUB_IMGDIR := $(EPUB_RESDIR)
EPUB_STATIC := $(EPUB_RESDIR)/static

# use sort to filter duplicates
EPUB_DIRECTORIES := $(sort $(EPUB_TMPDIR) $(EPUB_RESDIR) $(EPUB_IMGDIR) $(EPUB_STATIC) $(EPUB_STATIC)/css)

# Images
#
EPUB_INLINE_IMGS  := $(subst $(IMG_GENDIR)/color,$(EPUB_IMGDIR),$(COLOR_IMAGES))

# Stringparams
#
# if setting img.src.path to images/, the original DocBook stylesheets generate
# a correct path in the xhtml, but do not use the images/ prefix in packages.opf
EPUBSTRINGS := --stringparam "img.src.path=\"\""

# the static/ directories have all images in the images/ subdir
# the standard DocBook directory has a subdirectory images/callouts 
#
ifeq ($(EPUB3),1)
  EPUBSTRINGS += --stringparam "base.dir=$(EPUB_RESDIR)/"
  ifneq ($(IS_STATIC),static)
    EPUBSTRINGS += --stringparam "callout.graphics.path=static/images/callouts/" \
                 --stringparam "admon.graphics.path=static/images/"
  endif
else
  EPUBSTRINGS += --stringparam "base.dir=$(EPUB_RESDIR)/" \
	       --stringparam "epub.oebps.dir=$(EPUB_RESDIR)/" \
	       --stringparam "epub.metainf.dir=$(EPUB_TMPDIR)/META-INF/"
  ifneq ($(IS_STATIC),static)
    EPUBSTRINGS += --stringparam "callout.graphics.path=static/images/callouts/"
  endif
endif

ifneq "$(strip $(EPUB_CSS))" ""
  ifneq ($(EPUB_CSS),none)
    EPUBSTRINGS += --stringparam "html.stylesheet=static/css/$(notdir $(EPUB_CSS))"
  else
    EPUBSTRINGS += --stringparam "html.stylesheet=\"\""
    EPUB_CSS_INFO := CSS was set to none, using no CSS
  endif
endif

# building epub requires to create an intermediate bigfile
# that has links pointing to other books transformed into
# text only
#
EPUBBIGFILE := $(TMP_DIR)/epub_$(DOCNAME).xml

#--------------
# EPUB
#
.PHONY: epub
epub: list-images-missing
ifeq ("$(EPUBCHECK)", "yes")
  epub: epub-check
endif
epub: $(EPUB_RESULT)
  ifeq ($(TARGET),epub)
	@ccecho "result" "Find the EPUB book at:\n$<"
  endif


.PHONY: mobi
mobi: list-images-missing
mobi: $(MOBI_RESULT)
	@ccecho "result" "Find the Amazon Kindle book (.mobi) at:\n$<"


#------------------------------------------------------------------------
#
# "Helper" targets
#

#--------------
# EPUB_TMPDIR and subdirectories
#
$(EPUB_DIRECTORIES):
	mkdir -p $@


#---------------
# Copy static and inline images
#
# static target needs to be PHONY, since I do not know which files need to
# be linked, we just link the whole directory
#

.PHONY: copy_static_images
ifneq ($(IS_STATIC),static)
  copy_static_images: | $(EPUB_STATIC)
  ifdef EPUB_CSS
    copy_static_images: | $(EPUB_STATIC)/css
  endif
  copy_static_images: $(STYLEIMG)
	cp -rs --remove-destination $< $(EPUB_STATIC)
else
  copy_static_images: | $(EPUB_STATIC)
  ifdef EPUB_CSS
    copy_static_images: | $(EPUB_STATIC)/css
  endif
  copy_static_images: $(STYLEIMG)
	cp -rs --remove-destination $</* $(EPUB_STATIC)
endif
ifdef EPUB_CSS
  ifneq ($(EPUB_CSS),none)
	cp -rs --remove-destination $(EPUB_CSS) $(EPUB_STATIC)/css/
  endif
endif



#--------------
# generate EPUB-bigfile
#
$(EPUBBIGFILE): $(PROFILES) $(PROFILEDIR)/.validate
  ifeq ($(VERBOSITY),2)
	@ccecho "info" "   Generating EPUB-bigfile"
  endif
	$(XSLTPROC) --xinclude --output $@ $(ROOTSTRING) \
	  --stylesheet $(STYLEEPUB_BIGFILE) \
	  --file $(PROFILED_MAIN) $(XSLTPROCESSOR)

#--------------
# HTML from EPUB-bigfile
#
$(EPUB_TMPDIR)/OEBPS/index.html: $(EPUBBIGFILE)
  ifeq ($(VERBOSITY),2)
	@ccecho "info" "   Creating HTML files for EPUB"
  endif
	$(XSLTPROC) $(EPUBSTRINGS) --stylesheet $(STYLEEPUB) \
	  --file $< $(XSLTPROCESSOR) $(DEVNULL) $(ERR_DEVNULL) 


#--------------
# mimetype file
#
$(EPUB_TMPDIR)/mimetype: | $(EPUB_TMPDIR)
	@echo -n "application/epub+zip" > $@

#--------------
# Images
#
#$(EPUB_ADMON_IMGS): | $(EPUB_ADMONDIR)
#$(EPUB_CALLOUT_IMGS): | $(EPUB_CALLOUTDIR)
$(EPUB_INLINE_IMGS): | $(EPUB_IMGDIR)
$(EPUB_INLINE_IMGS): $(COLOR_IMAGES)
	ln -sf $(IMG_GENDIR)/color/$(notdir $@) $@


#$(EPUB_IMGDIR)/%.png: $(IMG_GENDIR)/color/%.png
#	ln -sf $< $@

#$(EPUB_IMGDIR)/%.jpg: $(IMG_GENDIR)/color/%.jpg
#	ln -sf $< $@

#--------------
# CSS
#
#$(EPUB_CSSFILE): | $(EPUB_RESDIR)
#	(cd $(EPUB_RESDIR); ln -sf $(EPUB_CSS))

#--------------
# Generate EPUB-file
#
#ifdef EPUB_CSS
#  $(EPUB_RESULT): $(EPUB_CSSFILE) 
#endif
$(EPUB_RESULT): | $(RESULT_DIR)
$(EPUB_RESULT): $(EPUB_INLINE_IMGS)
ifeq ($(EPUB3),1)
 $(EPUB_RESULT): $(EPUB_TMPDIR)/mimetype
endif
$(EPUB_RESULT): copy_static_images
$(EPUB_RESULT): $(EPUB_TMPDIR)/OEBPS/index.html
  ifeq ($(VERBOSITY),2)
	@ccecho "info" "   Creating EPUB"
    ifdef EPUB_CSS_INFO
	@ccecho "info" "$(EPUB_CSS_INFO)"
    endif
  endif
  ifeq ($(EPUB3),1)
	(cd $(EPUB_TMPDIR); \
	  zip -q0X $@.tmp mimetype; \
	  zip -qXr9D $@.tmp META-INF/ OEBPS/package.opf \
	    $(addprefix OEBPS/,$(shell xsltproc $(DAPSROOT)/daps-xslt/epub/get_manifest.xsl $(EPUB_RESDIR)/package.opf)); \
	  mv $@.tmp $@;)
  else
        # Fix needed due to bug? in DocBook ePUB stylesheets (not epub3)
        #
	sed -i 's:\(rootfile full-path="\)$(EPUB_TMPDIR)/\(OEBPS/content.opf"\):\1\2:' $(EPUB_TMPDIR)/META-INF/container.xml
	(cd $(EPUB_TMPDIR); \
	  zip -q0X $@.tmp mimetype; \
	  zip -qXr9D $@.tmp META-INF/ OEBPS/content.opf \
	    $(addprefix OEBPS/,$(shell xsltproc $(DAPSROOT)/daps-xslt/epub/get_manifest.xsl $(EPUB_RESDIR)/content.opf)); \
	  mv $@.tmp $@;)
  endif


#--------------
# Check epub file
#
# Check the epub file
#
.PHONY: epub-check
epub-check: $(EPUB_RESULT)
	@ccecho "result" "#################### BEGIN epubcheck report ####################"
	epubcheck $< || true
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
