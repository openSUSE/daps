# known layouts:
# LfL, openSUSE
# LfL: LAYOUTROOT defaults to ../../common
# openSUSE: LAYOUTROOT defaults to ../../novdoc
# fallback is /usr/share/daps and original stylesheets
#
# Fallback is
# known fop processors:
# fop, xep
#
# Variables that must be set accordingly:
# STYLEFO, STYLEH
# --> introducing LAYOUTROOT instead
#
# We may build with the rpm that installs everything in /usr/share/daps
# or we may want to build from the subversion directory. The location of
# the stylesheets is $(DTDDIR)/xslt/*

# do set the default layout:
LAYOUT        ?= openSUSE

# we need the path to some stylesheets below LAYOUTROOT:
# In this first section, this is only names that are similar for all layouts.
LSTYLEH       := /html/chunk.xsl
LSTYLEJ       := /jsp/chunk.xsl
LSTYLEWIKI    := /db2mediawiki/docbook.xsl
LSTYLEMAN     := /manpages/docbook.xsl
LSTYLEPUBXSLT := /epub/docbook.xsl
LSTYLEPUBCSS  := /epub/susebooks.css


# I don't want to write that nwalsh filepath too often!
# all the possible locations of layout stylesheets:
STYLENWD      := /usr/share/xml/docbook/stylesheet/nwalsh/current
#STYLELFLD     := $(shell test -d ../../common/xslt && (cd ../../common/xslt; pwd))
STYLEDEVEL  := $(DTDROOT)/xslt
STYLEDAPSD := /usr/share/daps/xslt
#
# pretend to be intelligent: stylesheets will be used if available.
# defaults are just selected by the sequence of directory variables
ifndef LAYOUTROOT
ifeq ($(LAYOUT), LfL)
LAYOUTROOT=$(wildcard $(STYLEDEVEL) $(STYLEDAPSD) $(STYLENWD))
LSTYLECSS = /html/lessons4lizards.css
LSTYLEFO  = /fo/docbook.xsl
else
ifeq ($(LAYOUT), openSUSE)
LAYOUTROOT=$(wildcard $(STYLEDEVEL) $(STYLEDAPSD) $(STYLENWD))
LSTYLECSS = /html/susebooks.css
LSTYLEFO  = /fo/docbook.xsl
else
ifeq ($(LAYOUT), provo)
LAYOUTROOT=$(wildcard $(STYLEDEVEL) $(STYLEDAPSD) $(STYLENWD))
LSTYLECSS = /html/susebooks.css
HTMLSTRINGS += --stringparam generate.toc \
	"book toc,title,figure,table,example  article toc,title  appendix \
	title  chapter title  part toc,title  set toc,title" \
	--stringparam provo.minitoc "1"
LSTYLEFO  = /fo/docbook.xsl
else
ifeq ($(LAYOUT), flyer)
LAYOUTROOT=$(wildcard $(STYLEDEVEL) $(STYLEDAPSD) $(STYLENWD))
LSTYLECSS = /html/susebooks.css
LSTYLEFO  = /flyer/docbook.xsl
else
ifeq ($(LAYOUT), pocket)
LAYOUTROOT=$(wildcard $(STYLEDEVEL) $(STYLEDAPSD) $(STYLENWD))
LSTYLECSS = /html/susebooks.css
LSTYLEFO  = /pocket/docbook.xsl
else
LAYOUTROOT=$(wildcard $(STYLEDEVEL) $(STYLEDAPSD) $(STYLENWD))
LSTYLECSS = /html/susebooks.css
LSTYLEFO  = /fo/docbook.xsl
endif
endif
endif
endif
endif
endif
# finally lets put together the paths and select the first existing:

# ATTENTION:
# When exporting a shell variable in bash as FOO="" FOO ?= bar in
# make wil NOT WORK!! We need to use ifndef instead!!
#
ifndef STYLEH
STYLEH  := $(firstword $(addsuffix $(LSTYLEH), $(LAYOUTROOT)))
endif
ifndef STYLEj
STYLEJ  := $(firstword $(addsuffix $(LSTYLEJ), $(LAYOUTROOT)))
endif
ifndef STYLEFO
STYLEFO := $(firstword $(addsuffix $(LSTYLEFO), $(LAYOUTROOT)))
endif
ifndef STYLEWIKI
STYLEWIKI := $(firstword $(wildcard $(addsuffix $(LSTYLEWIKI), $(LAYOUTROOT))))
endif
ifndef STYLECSS
STYLECSS  := $(firstword $(wildcard $(addsuffix $(LSTYLECSS), $(LAYOUTROOT))))
endif
ifndef STYLEMAN
STYLEMAN  := $(firstword $(wildcard $(addsuffix $(LSTYLEMAN), $(LAYOUTROOT))))
endif
ifndef STYLEPUBXSLT
STYLEPUBXSLT := $(firstword $(wildcard $(addsuffix $(LSTYLEPUBXSLT), $(LAYOUTROOT))))
endif
ifndef STYLEPUBCSS
STYLEPUBCSS  ?= $(firstword $(wildcard $(addsuffix $(LSTYLEPUBCSS), $(LAYOUTROOT))))
endif
# inform  the stylesheets about the used fop processor
#
# FIXME - this should go into a wrapper script
#
ifeq ($(FOPTYPE), fop)
FOCOLSTRINGS  += --stringparam fop1.extensions 1 \
                 --stringparam xep.extensions 0
FOSTRINGS  += --stringparam fop1.extensions 1 \
              --stringparam xep.extensions 0
ifeq ($(DTDROOT), $(DEFAULT_DTDROOT))
FOP_CONFIG_FILE ?=/etc/daps/fop/fop-daps.xml
else
FOP_CONFIG_FILE ?=$(DTDROOT)/etc/fop/fop-daps.xml 
endif
else
ifeq ($(DTDROOT), $(DEFAULT_DTDROOT))
FOP_CONFIG_FILE ?=/etc/daps/xep/xep-daps.xml
else
FOP_CONFIG_FILE ?=$(DTDROOT)/etc/xep/xep-daps.xml 
endif
endif


.PHONY: layout-help
layout-help:
	@echo "The layout functionality of this Makefile tries to be intelligent."
	@echo "Currently, there are five different layouts defined. All of them"
	@echo "share the same stylesheet names for chunking, wiki transforming and"
	@echo "manpage generation. Differences are found in html CSS stylesheets "
	@echo "and FO stylesheets for PDF generation."
	@echo
	@echo "LfL:      CSS stylesheet: html/lessons4lizards.css "
	@echo "          FO  stylesheet: fo/docbook.xsl "
	@echo "openSUSE: CSS stylesheet: html/susebooks.css "
	@echo "          FO  stylesheet: fo/docbook.xsl "
	@echo "provo:    CSS stylesheet: html/susebooks.css "
	@echo "          FO  stylesheet: fo/docbook.xsl "
	@echo "          additional: stringparams generate.toc and provo.minitoc "
	@echo "default:  CSS stylesheet: html/susebooks.css "
	@echo "          FO  stylesheet: fo/docbook.xsl"
	@echo
	@echo "The mechanics searches for those different filenames in several directories."
	@echo "These are (in the following sequence): "
	@echo "- /usr/share/daps/xslt (like in the daps package) "
	@echo "- ../../common/xslt (as seen from the project directory) "
	@echo "- $$ DTDROOT/xslt"
	@echo "- /usr/share/xml/docbook/stylesheet/nwalsh/current "
	@echo
	@echo "For the layout flyer, there is a different sequence:"
	@echo "- $$ DTDROOT/xslt "
	@echo "- /usr/share/daps/xslt (like in the daps package) "
	@echo "- ../../common/xslt (as seen from the project directory) "
	@echo "- /usr/share/xml/docbook/stylesheet/nwalsh/current "
	@echo
	@echo "The files with the correct names that are found first will be used."
	@echo
	@echo "The environment variable FOP is always set when using this Makefile. Either "
	@echo "it was set by $$ {DTDROOT}/etc/system.profile, or later on by some ENV file "
	@echo "or just manually. If this variable is missing, no fo->pdf engine was found."
	@echo "FOP is expected to be one of the following: "
	@echo "- an absolute path to a FOP processor"
	@echo "- just the program name without path"
	@echo "- some wrapper script (with, or without path) that prependes daps- to the "
	@echo "  processor name. This mechanics is aware of RenderX XEP, or fop from the "
	@echo "  apache project."

