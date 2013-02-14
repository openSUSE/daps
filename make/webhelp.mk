# Copyright (C) 2012 SUSE Linux Products GmbH
#
# Author: Frank Sundermeyer
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
ifndef LL
  $(error "The language needs to be set via xml:lang attribute in\n$(MAIN)\notherwise the indexer will not work correctly")
endif


# Draft mode can be enabled for webhelp, so we need to add the
# corresponding strings to the resulting filename
#
DOCNAME := $(DOCNAME)$(DRAFT_STR)

WEBHELP_DIR := $(RESULT_DIR)/webhelp/$(DOCNAME)

#----------
# Stylesheets
#
STYLEWEBHELP  := $(firstword $(wildcard $(addsuffix \
			/webhelp/xsl/webhelp.xsl, $(STYLE_ROOTDIRS))))

# webhelp is special, because it also contains subdirectorieys we need
STYLEWEBHELP_BASE  := $(firstword $(wildcard $(addsuffix \
			/webhelp, $(STYLE_ROOTDIRS))))
STYLWEBHELP        := $(addsuffix /xsl/webhelp.xsl, $(STYLEWEBHELP_BASE))

#----------
# Stringparams
#  
WEBHELPSTRINGS := --param "keep.xml.comments=$(COMMENTS)" \
	          --param "show.comments=$(REMARKS)" \
                  --param "use.id.as.filename=1" \
                  --param "admon.graphics=1" \
                  --param "navig.graphics=0" \
                  --param w"ebhelp.gen.index=0" \
		  --stringparam "base.dir=$(WEBHELP_DIR)/" \
	          --stringparam "draft.mode=$(DRAFT)" \
                  --stringparam "admon.graphics.path=style_images/" \
                  --stringparam "admon.graphics.extension=.png" \
                  --stringparam "navig.graphics.path=style_images/" \
                  --stringparam "navig.graphics.extension=.png" \
                  --stringparam "callout.graphics.path=style_images/callouts/" \
                  --stringparam "callout.graphics.extension=.png" \
                  --stringparam "img.src.path=images/" \
                  --stringparam "webhelp.common.dir=common/" \
                  --stringparam "webhelp.start.filename=index.html" \
                  --stringparam "webhelp.base.dir=$(WEBHELP_DIR)/" \
                  --stringparam "webhelp.indexer.language=$(LL)"

ifeq ("$(WH_SEARCH)", "no")
  WEBHELPSTRINGS += --stringparam "webhelp.include.search.tab=false"
endif
ifdef HTML_CSS
  WEBHELPSTRINGS += --stringparam "html.stylesheet=$(notdir $(HTML_CSS))"
endif
# Remove these once we have decent custom stylesheets
WEBHELPSTRINGS += --param "chunk.fast=1" \
                  --param "chunk.section.depth=0" \
                  --param "suppress.footer.navigation=1"

#--------------
# WEBHELP
#
.PHONY: webhelp
webhelp: $(WEBHELP_DIR)/index.html
	@ccecho "result" "Webhelp book built REMARKS=$(REMARKS) and DRAFT=$(DRAFT):\n$<"

#------------------------------------------------------------------------
#
# "Helper" targets for HTML and HTML-SINGLE
#

$(WEBHELP_DIR) $(WEBHELP_DIR)/images $(WEBHELP_DIR)/search/stemmers $(WEBHELP_DIR)/style_images:
	mkdir -p $@

# option --clean removes the contents of the HTML result directory
# before creating the files
#
.PHONY: clean_webhelp
clean_webhelp: | $(WEBHELP_DIR)
	rm -rf $(WEBHELP_DIR)/*

#---------------
# Webhelpgraphics
#

$(WEBHELP_DIR)/$(notdir $(HTML_CSS)): | $(WEBHELP_DIR) 
$(WEBHELP_DIR)/$(notdir $(HTML_CSS)): $(HTML_CSS)
	$(HTML_GRAPH_COMMAND) $< $(WEBHELP_DIR)/

# images
wh_copy_inline_images: | $(WEBHELP_DIR)/images
wh_copy_inline_images: $(ONLINE_IMAGES)
  ifdef PNGONLINE
	for IMG in $(PNGONLINE); do \
	  $(HTML_GRAPH_COMMAND) $$IMG $(WEBHELP_DIR)/images; \
	done
  endif

# STYLEIMG contains admon and navig images as well as
# callout images in callouts/
# STYLEIMG may contain .svn directories which we do not want to copy
# therefore we use tar with the --exclude-vcs option to copy
# the files
#
# style images
wh_copy_static_images: | $(WEBHELP_DIR)
wh_copy_static_images: $(STYLEIMG)
  ifeq ($(STATIC_HTML), 1)
	if [ -L $(WEBHELP_DIR)/style_images ]; then rm -f $(WEBHELP_DIR)/style_images; fi
	tar cph --exclude-vcs --transform=s%images/%style_images/% \
	  -C $(dir $<) images/ | (cd $(WEBHELP_DIR); tar xpv) >/dev/null
  else
	if [ -d $(WEBHEL$(WEBHELP_DIR)/style_imagesP_DIR)/style_images ]; then rm -rf $(WEBHELP_DIR)/style_images; fi
	$(HTML_GRAPH_COMMAND) $< $(WEBHELP_DIR)/style_images
  endif

# With the SUSE Stylesheets we use an alternative draft image for HTML
# builds (draft_html.png). The original DocBook Stylesheets use draft.png for
# both HML and FO
# The following is a HACK to allow draft_html.png Upstream should have
# draft.svg and draft.png, that would make things easier...

WEBHELP_DRAFT_IMG = $(subst $(STYLEIMG)/,style_images/, \
		   $(firstword $(wildcard \
		   $(STYLEIMG)/draft_html.png \
		   $(STYLEIMG)/draft.png)))
ifdef WEBHELP_DRAFT_IMG
  WEBHELPSTRINGS += --stringparam "draft.watermark.image=$(WEBHELP_DRAFT_IMG)" 
endif

# search stuff
create_search_index: | $(WEBHELP_DIR)/search/stemmers
create_search_index: $(STYLEWEBHELP_BASE)/template/content/search 
	$(HTML_GRAPH_COMMAND) $</default.props $(WEBHELP_DIR)/search
	$(HTML_GRAPH_COMMAND) $</punctuation.props $(WEBHELP_DIR)/search
	$(HTML_GRAPH_COMMAND) $</nwSearchFnt.js $(WEBHELP_DIR)/search
	$(HTML_GRAPH_COMMAND) "$</stemmers/$(LL)_stemmer.js" \
	  $(WEBHELP_DIR)/search/stemmers/stemmers
	for LPROPS in "$</$(LL)*.props $</*.js"; do \
	  $(HTML_GRAPH_COMMAND) $$LPROPS $(WEBHELP_DIR)/search; \
	done

# common stuff /(Javascript, CSS,...)
copy_common: | $(WEBHELP_DIR)
copy_common: $(STYLEWEBHELP_BASE)/template/common
  ifeq ($(STATIC_HTML), 1)
	if [ -L $@ ]; then rm -f $(WEBHELP_DIR)/common; fi
	tar cph --exclude-vcs -C $< | (cd $(WEBHELP_DIR); tar xpv) >/dev/null
  else
	if [ -d $@ ]; then rm -rf $(WEBHELP_DIR)/common; fi
	$(HTML_GRAPH_COMMAND) $< $(WEBHELP_DIR)/common
  endif


#---------------
# Generate WEBHELP from profiled xml
#
# XSLTPARAM is a variable that can be set via wrapper script in order to
# temporarily overwrite styleseet settings such as margins
#
ifeq ($(CLEAN_DIR), 1)
  $(WEBHELP_DIR)/index.html: clean_webhelp
endif
$(WEBHELP_DIR)/index.html: | $(WEBHELP_DIR)
$(WEBHELP_DIR)/index.html: $(DOCFILES) $(DOCBOOK_STYLES)/extensions
$(WEBHELP_DIR)/index.html: $(PROFILES) $(PROFILEDIR)/.validate
$(WEBHELP_DIR)/index.html: list-images-multisrc list-images-missing
$(WEBHELP_DIR)/index.html: wh_copy_static_images copy_common
ifdef PNGONLINE
  $(WEBHELP_DIR)/index.html: wh_copy_inline_images
endif
ifneq ("$(WH_SEARCH)", "no")
  $(WEBHELP_DIR)/index.html: create_search_index
endif
ifdef HTML_CSS
  $(WEBHELP_DIR)/index.html: $(WEBHELP_DIR)/$(notdir $(HTML_CSS))
endif
$(WEBHELP_DIR)/index.html:
  ifeq ($(VERBOSITY),2)
	@ccecho "info" "   Creating webhelp pages"
  endif
	$(XSLTPROC) $(WEBHELPSTRINGS) $(ROOTSTRING) $(CSSSTRING) \
	  $(XSLTPARAM) --xinclude --stylesheet $(STYLEWEBHELP) \
	  --file $(PROFILED_MAIN) $(XSLTPROCESSOR) $(DEVNULL) $(ERR_DEVNULL)
	if [ ! -f  $@ ]; then \
	  (cd $(WEBHELP_DIR) && ln -sf $(ROOTID).html $@); \
	fi
	java -DhtmlDir=$(WEBHELP_DIR)/ -DindexerLanguage=$LL \
	  -DfillTheRest=true \
	  -Dorg.xml.sax.driver=org.ccil.cowan.tagsoup.Parser \
	  -Djavax.xml.parsers.SAXParserFactory=org.ccil.cowan.tagsoup.jaxp.SAXFactoryImpl \
	  -classpath $(DOCBOOK_STYLES)/extensions/webhelpindexer.jar:$(wildcard $(firstword $(DOCBOOK_STYLES)/extensions/lucene-analyzers-3.*.jar)):$(wildcard $(firstword $(DOCBOOK_STYLES)/extensions/tagsoup-1.*.jar)):$(wildcard $(firstword $(DOCBOOK_STYLES)/extensions/lucene-core-3.*.jar)) \
	  com.nexwave.nquindexer.IndexerMain $(DEVNULL)
	rm -f $(WEBHELP_DIR)/search/*.props

