# Copyright (C) 2012-2015 SUSE Linux GmbH
#
# Author:
# Frank Sundermeyer <fsundermeyer at opensuse dot org>
#
# webhelp generation for DAPS
#
# Please submit feedback or patches to
# <fsundermeyer at opensuse dot org>
#

# includes are set in selector.mk
# include $(DAPSROOT)/make/setfiles.mk
# include $(DAPSROOT)/make/profiling.mk
# include $(DAPSROOT)/make/validate.mk
# include $(DAPSROOT)/make/images.mk

# if no language is set in the XML file, we need to exit, because the
# indexer would not work
#
ifeq "$(MAKECMDGOALS)" "webhelp"
  ifndef LL
    $(error "The language needs to be set via xml:lang attribute in\n$(MAIN)\notherwise the indexer will not work correctly")
  endif
endif

#----------
# webhelp is special, because it also needs the extensions from
# STYLEROOT/extensions and other resources
#
STYLEWEBHELP_BASEDIR := $(firstword $(wildcard $(addsuffix \
			/webhelp, $(STYLE_ROOTDIRS))))

STYLEWEBHELP  := $(STYLEWEBHELP_BASEDIR)/xsl/webhelp.xsl
WH_COMMON_DIR := $(STYLEWEBHELP_BASEDIR)/template/common
WH_SEARCH_DIR := $(STYLEWEBHELP_BASEDIR)/template/search

EXTENSIONS_BASEDIR := $(firstword $(wildcard $(addsuffix \
			/extensions, $(STYLE_ROOTDIRS))))

WH_INDEXER        := $(EXTENSIONS_BASEDIR)/webhelpindexer.jar
WH_TAGSOUP        := $(wildcard $(firstword $(EXTENSIONS_BASEDIR)/tagsoup-1.*.jar))
WH_LUCENE_ANALYZE := $(wildcard $(firstword $(EXTENSIONS_BASEDIR)/lucene-analyzers-3.*.jar))
WH_LUCENE_CORE    := $(wildcard $(firstword $(EXTENSIONS_BASEDIR)/lucene-core-3.0.0.jar))

WH_CLASSPATH := $(WH_INDEXER):$(WH_TAGSOUP):$(WH_LUCENE_ANALYZE):$(WH_LUCENE_CORE)

# FILES excluded from indexing:
WH_EXCLUDE_INDEX := ix01.html

#----------
# Style images
#
# NOTE: Style image handling needs to go into a function. It is needed by
#       epub, html and webhelp
#
# Three scenarios:
#
# <STYLESHEETDIR>/webhelp/static
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
# If <STYLESHEETDIR>/xhtml/static exists, it is used by default. If not,
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
# it can either be <STYLEROOT>/xhtml/static, <STYLEROOT>/static or
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
	$(addsuffix static, $(dir $(STYLEWEBHELP_BASEDIR))) \
	$(addsuffix static,$(dir $(patsubst %/,%,$(STYLEWEBHELP_BASEDIR)))) \
	$(addsuffix images,$(dir $(patsubst %/,%,$(STYLEWEBHELP_BASEDIR))))))

  ifeq "$(strip $(STYLEIMG))" ""
    $(warning $(shell ccecho "error" "Fatal error: Could not find stylesheet images"))
  endif

  IS_STATIC := $(notdir $(STYLEIMG))
  ifndef HTML_CSS
    ifneq "$(IS_STATIC)" "static"
      HTML_CSS := $(shell readlink -e $(firstword $(wildcard $(dir $(STYLEWEBHELP))*.css)) 2>/dev/null )
      ifeq "$(VERBOSITY)" "1"
        ifneq "$(HTML_CSS)" ""
	  HTML_CSS_INFO := No CSS file specified. Automatically using\n$(HTML_CSS)
        endif
      endif
    endif
  endif
endif


#----------
# Stringparams
#  
WEBHELPSTRINGS := --param "show.comments=$(REMARKS)" \
                  --param "use.id.as.filename=1" \
	          --stringparam "draft.mode=$(DRAFT)" \
		  --stringparam "base.dir=$(WEBHELP_DIR)/" \
                  --stringparam "img.src.path=images/" \
                  --stringparam "webhelp.indexer.language=$(LL)"

#------------
# Whether the search tab is generated or not is configurable
ifeq "$(WH_SEARCH)" "no"
  WEBHELPSTRINGS += --stringparam "webhelp.include.search.tab=false"
else
  WEBHELPSTRINGS += --stringparam "webhelp.include.search.tab=true"
endif

# Remove these once we have decent custom stylesheets
#WEBHELPSTRINGS += --param "chunk.fast=1" \
#                  --param "chunk.section.depth=0"
#                  --param "suppress.footer.navigation=1"

# test if DocBook layout
ifneq "$(IS_STATIC)" "static"
  WEBHELPSTRINGS  += --stringparam "admon.graphics.path=static/images/" \
		  --stringparam "callout.graphics.path=static/images/callouts/" \
		  --stringparam "navig.graphics.path=static/images/"

# With the SUSE Stylesheets we use an alternative draft image for HTML
# builds (draft_html.png). The original DocBook Stylesheets use draft.png for
# _both_ HML and FO

  HTML_DRAFT_IMG = $(subst $(STYLEIMG)/,static/images/,$(firstword \
		     $(wildcard $(STYLEIMG)/draft_html.png \
		     $(STYLEIMG)/draft.png)))

  ifdef HTML_DRAFT_IMG
    WEBHELPSTRINGS += --stringparam "draft.watermark.image=$(HTML_DRAFT_IMG)" 
  endif
endif

ifdef HTML_CSS
  ifneq "$(HTML_CSS)" "none"
    WEBHELPSTRINGS += --stringparam "html.stylesheet=static/css/$(notdir $(HTML_CSS))"
  else
    HTML_CSS_INFO := CSS was set to none, using no CSS
    WEBHELPSTRINGS += --stringparam "html.stylesheet=\"\""
  endif
endif

# inline Images
#
WEBHELP_INLINE_IMAGES := $(subst $(IMG_GENDIR)/color/,$(WEBHELP_DIR)/images/,$(ONLINE_IMAGES))


#--------------
# WEBHELP
#
# In order to avoid unwanted results when deleting $(HTML_DIR), we are adding
# a security check before deleting 
#
.PHONY: webhelp
ifeq "$(CLEAN_DIR)" "1"
  webhelp: $(shell if [[ $$(expr match "$(WEBHELP_DIR)" "$(RESULT_DIR)") -gt 0 && -d "$(WEBHELP_DIR)" ]]; then rm -r "$(WEBHELP_DIR)"; fi 2>&1 >/dev/null)
endif
webhelp: list-images-multisrc list-images-missing
ifdef ONLINE_IMAGES
  webhelp: $(ONLINE_IMAGES) copy_inline_images
endif
webhelp: copy_static_images_wh
webhelp: $(WEBHELP_RESULT)
  ifeq "$(TARGET)" "webhelp"
	@ccecho "result" "Webhelp book built with REMARKS=$(REMARKS), DRAFT=$(DRAFT):\n$(WEBHELP_DIR)/"
  endif

#------------------------------------------------------------------------
#
# "Helper" targets for HTML and HTML-SINGLE
#

$(WEBHELP_DIR) $(WEBHELP_DIR)/images $(WEBHELP_DIR)/search $(WEBHELP_DIR)/static $(WEBHELP_DIR)/static/css:
	mkdir -p $@

#---------------
# Copy static and inline images
#
# static target needs to be PHONY, since I do not know which files need to
# be copied/linked, we just copy/link the whole directory
#
.PHONY: copy_static_images_wh
ifneq "$(IS_STATIC)" "static"
  copy_static_images_wh: | $(WEBHELP_DIR)/static
  ifdef HTML_CSS
    copy_static_images_wh: | $(WEBHELP_DIR)/static/css
  endif
  copy_static_images_wh: $(STYLEIMG)
    ifeq "$(STATIC_HTML)" "0"
	$(HTML_GRAPH_COMMAND) $(STYLEIMG) $(WEBHELP_DIR)/static
    else
	tar cph --exclude-vcs -C $(dir $<) images | \
          (cd $(WEBHELP_DIR)/static; tar xpv) >/dev/null
    endif
else
  copy_static_images_wh: | $(WEBHELP_DIR)/static
  ifdef HTML_CSS
    copy_static_images_wh: | $(WEBHELP_DIR)/static/css
  endif
  copy_static_images_wh: $(STYLEIMG)
    ifeq "$(STATIC_HTML)" "0"
	$(HTML_GRAPH_COMMAND) $</* $(WEBHELP_DIR)/static
    else
	tar cph --exclude-vcs -C $(dir $<) static | \
	  (cd $(WEBHELP_DIR); tar xpv) >/dev/null
    endif
endif
ifdef HTML_CSS
  ifneq "$(HTML_CSS)" "none"
	$(HTML_GRAPH_COMMAND) $(HTML_CSS) $(WEBHELP_DIR)/static/css/
  endif
endif

# inline images
# needs to be PHONY, because we either create links (of no --static) or
# copies of the images (with --static). Using a PHONY target ensures that
# links can be overwritten with copies and vice versa
# Thus we also need the ugly for loop instead of creating images by 
# $(WEBHELP_DIR)/images/% rule
#
.PHONY: copy_inline_images_wh
copy_inline_images_wh: | $(WEBHELP_DIR)/images
copy_inline_images_wh: $(ONLINE_IMAGES)
	for IMG in $(ONLINE_IMAGES); do $(HTML_GRAPH_COMMAND) $$IMG $(WEBHELP_DIR)/images; done


#---------------
# Copy common files
# 
copy_common: | $(WEBHELP_DIR) $(WEBHELP_DIR)/search
copy_common: 
	cp -r $(WH_COMMON_DIR) $(WEBHELP_DIR)
	cp -r $(WH_SEARCH_DIR)/* $(WEBHELP_DIR)/search

#---------------
# Generate WEBHELP from profiled xml
#
$(WEBHELP_RESULT): | $(WEBHELP_DIR)
$(WEBHELP_RESULT): $(PROFILES) $(PROFILEDIR)/.validate $(DOCFILES)
ifneq "$(WH_SEARCH)" "no"
  $(WEBHELP_RESULT): copy_common
endif
$(WEBHELP_RESULT):
  ifeq "$(VERBOSITY)" "2"
	@ccecho "info" "Creating webhelp pages"
  endif
  ifdef HTML_CSS_INFO
	@ccecho "info" "$(HTML_CSS_INFO)"
  endif
	$(XSLTPROC) $(WEBHELPSTRINGS) $(ROOTSTRING) $(CSSSTRING) \
	  $(XSLTPARAM) $(PARAMS) $(STRINGPARAMS) \
	  --xinclude --stylesheet $(STYLEWEBHELP) \
	  --file $(PROFILED_MAIN) $(XSLTPROCESSOR) $(DEVNULL) $(ERR_DEVNULL)
	if [ ! -f $@ ]; then \
	  (cd $(WEBHELP_DIR) && ln -sf $(ROOTID).html $@); \
	fi
	java \
	  -DhtmlDir=$(WEBHELP_DIR) \
	  -DindexerLanguage=$(LL) \
	  -DhtmlExtension=html \
	  -DdoStem=true \
	  -DindexerExcludedFiles=$(WH_EXCLUDE_INDEX) \
	  -Dorg.xml.sax.driver=org.ccil.cowan.tagsoup.Parser \
	  -Djavax.xml.parsers.SAXParserFactory=org.ccil.cowan.tagsoup.jaxp.SAXFactoryImpl \
	  -classpath $(WH_CLASSPATH) com.nexwave.nquindexer.IndexerMain \
	  $(DEVNULL) $(ERR_DEVNULL)
	rm -f $(WEBHELP_DIR)/search/*.props


