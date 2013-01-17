# known layouts:
#
# Docbook:
#
# docbook4: e.g. /usr/share/xml/docbook/stylesheet/nwalsh/current
# docbook5: e.g. /usr/share/xml/docbook/stylesheet/nwalsh5/current
#
# bin/daps automatically detects if $MAIN is docbook5
# or docbook4 and sets DOCBOOK_STYLES accordingly

# The following variables need to be set for a custom layout
#
# STYLEROOT         : path to stylesheet directory, mandatory
# FALLBACK_STYLEROOT: path to alternative stylesheet directory, optional
# HTML_CSS          : css file for HTML (full path), optional
# EPUB_CSS          : css file for EPUB (full path), optional

# A custom layout does not need to provide stylesheets for all targets
# If stylesheet subdirectories for a certain target are not found, we
# will fall back to the docbook stylesheets, or--if specified--to
# FALLBACK_STYLEROOT (with the docbook stylsheets remaining the last resort).
# This allows to only define custom stylesheets for e.g. FO but still
# being able to build e.g. HTML
#
# The subdirectory layout in each STYLEROOT directory needs to be the same as
# in the original DocBook stylesheet directories


STYLE_CUSTOM          := $(STYLEROOT)

# It only makes sense to set a custom fallback when a custom styleroot 
# has been specified
#
ifdef STYLEROOT
  STYLE_CUSTOM_FALLBACK := $(FALLBACK_STYLEROOT)
endif

# Create a list with all stylesheet root directories. When setting the
# stylesheets to be used for the targets, the _first_ element from this
# list is used (firstword). As a consequence the ORDER is IMPORTANT!
#
# STYLEDEVEL, which can be set in $USER_CONFIG, is useful when devolping
# stylesheets. It always takes precedence over STYLEROOT.
#

STYLE_ROOTDIRS := $(wildcard $(STYLEDEVEL) $(STYLE_CUSTOM) \
		  $(STYLE_CUSTOM_FALLBACK) $(DOCBOOK_STYLES) )

#----------------------------
# No let's put it all together
#
# We assume that the directory layout for all stylesheet root directories is
# the same as with the original DocBook stylesheets
#
# The following variables are actually used to build the targets:
#
# STYLEEPUB:     epub
# STYLEFO:       fo (pdf)
# STYLEH:        html
# STYLEJ:        jsp
# STYLEMAN:      man
# STYLEWEBHELP   webhelp
# STYLEWIKI:     wiki
#
# STYLEIMG:      images
#
# STYLE_EPUBCSS: css file for epub
# STYLE_HTMLCSS: cssfile for html
#
#
# The combination of firstword and wildcard makes the following specifications
# "intelligent". wildcard filters the list of files to only include the ones
# that really exist, while firstword picks the first element of that
# list.
# So existing files are chosen in the order defined in $STYLE_ROOTDIRS
# So the DocBook stylesheets always remain the last resort

# HTML is special, because we optionally allow html4.

ifeq ("$(HTML4)", "yes")
  H_DIR := /html
else
  H_DIR := /xhtml
endif
HTML_STYLE        := $(H_DIR)/chunk.xsl
HTML_SINGLE_STYLE := $(H_DIR)/docbook.xsl


STYLEEPUB     := $(firstword $(wildcard $(addsuffix \
			/epub/docbook.xsl, $(STYLE_ROOTDIRS))))
STYLEFO       := $(firstword $(wildcard $(addsuffix \
			/fo/docbook.xsl, $(STYLE_ROOTDIRS))))
STYLEH        := $(firstword $(wildcard $(addsuffix \
			$(H_DIR)/chunk.xsl, $(STYLE_ROOTDIRS))))
STYLEHSINGLE  := $(firstword $(wildcard $(addsuffix \
			$(H_DIR)/docbook.xsl, $(STYLE_ROOTDIRS))))
STYLEJ        := $(firstword $(wildcard $(addsuffix \
			/jsp/chunk.xsl, $(STYLE_ROOTDIRS))))
STYLEMAN      := $(firstword $(wildcard $(addsuffix \
			/manpages/docbook.xsl, $(STYLE_ROOTDIRS))))
STYLEWEBHELP  := $(firstword $(wildcard $(addsuffix \
			/webhelp/xsl/webhelp.xsl, $(STYLE_ROOTDIRS))))
STYLEWIKI     := $(firstword $(wildcard $(addsuffix \
			/db2mediawiki/docbook.xsl, $(STYLE_ROOTDIRS))))

# webhelp is special, too, because it also contains subdirectorieys we need
STYLEWEBHELP_BASE  := $(firstword $(wildcard $(addsuffix \
			/webhelp, $(STYLE_ROOTDIRS))))
STYLWEBHELP        := $(addsuffix /xsl/webhelp.xsl, $(STYLEWEBHELP_BASE))


# images provided with the stylesheets
#STYLEIMG := $(firstword $(wildcard $(addsuffix /images, $(STYLE_ROOTDIRS))))

STYLEIMG := $(firstword $(wildcard \
		$(addsuffix /static,$(STYLE_ROOTDIRS)) \
		$(addsuffix /images,$(STYLE_ROOTDIRS))))
IS_RESDIR := $(notdir $(STYLEIMG))

#
# CSS
ifdef HTML_CSS
  STYLE_HTMLCSS := $(HTML_CSS)
endif
ifdef EPUB_CSS
  STYLE_EPUBCSS := $(EPUB_CSS)
endif
