#
#
#
AUTOMAKE_OPTIONS = 1.10 foreign no-define no-dist no-installinfo -Wall -Werror -Wno-portability
SUBDIRS=

DAPS_CATALOG := for-catalog-$(PACKAGE).xml
DAPSROOT     := $(shell pwd)
DIRECTORIES  := catalogs

DESTDIR      ?=

# stylesheets with which to build the documentation
STYLEROOT    := $(DAPSROOT)/suse-xslt

# Man pages
DC_MANPAGES := DC-daps-manpages
MAN_PAGE_DIR=$(subst DC-,,$(DC_MANPAGES))

# Manuals
MANUALS=$(subst doc/DC-,,$(wildcard doc/DC-*))

#------------------------
# Automake primaries

dist_pkgdata_DATA  = catalogs/$(DAPS_CATALOG)
dist_bin_SCRIPTS   = $(wildcard bin/*)

man_MANS = man/build/$(MAN_PAGE_DIR)/man/ccecho.1 man/build/$(MAN_PAGE_DIR)/man/daps.1 man/build/$(MAN_PAGE_DIR)/man/daps-susespell.1

all-local: manuals

#--------------------------------------------------------------------------

# create needed directories
$(DIRECTORIES):
	mkdir -p $@

# create DAPS catalog entries
catalogs/$(DAPS_CATALOG): $(DIRECTORIES)
catalogs/$(DAPS_CATALOG): DAPS_PROFDIR := $(datadir)/daps/daps-xslt/profiling
catalogs/$(DAPS_CATALOG): URN_SUSE     := urn:x-suse:xslt:profiling
catalogs/$(DAPS_CATALOG): URN_DAPS     := urn:x-daps:xslt:profiling
catalogs/$(DAPS_CATALOG):
	$(XMLCATALOG) --noout --create $@
	$(XMLCATALOG) --noout --add \
	  "system" "$(URN_DAPS):docbook41-profile.xsl" \
	  "file://$(DAPS_PROFDIR)/docbook41-profile.xsl" $@
	$(XMLCATALOG) --noout --add \
	  "system" "$(URN_DAPS):docbook42-profile.xsl" \
	  "file://$(DAPS_PROFDIR)/docbook42-profile.xsl" $@
	$(XMLCATALOG) --noout --add \
	  "system" "$(URN_DAPS):docbook43-profile.xsl" \
	  "file://$(DAPS_PROFDIR)/docbook43-profile.xsl" $@
	$(XMLCATALOG) --noout --add \
	  "system" "$(URN_DAPS):docbook44-profile.xsl" \
	  "file://$(DAPS_PROFDIR)/docbook44-profile.xsl" $@
	$(XMLCATALOG) --noout --add \
	  "system" "$(URN_DAPS):docbook45-profile.xsl" \
	  "file://$(DAPS_PROFDIR)/docbook45-profile.xsl" $@
	$(XMLCATALOG) --noout --add \
	  "system" "$(URN_DAPS):docbook50-profile.xsl" \
	  "file://$(DAPS_PROFDIR)/docbook50-profile.xsl" $@
	$(XMLCATALOG) --noout --add \
	  "system" "$(URN_DAPS):docbook51-profile.xsl" \
	  "file://$(DAPS_PROFDIR)/docbook51-profile.xsl" $@
	$(XMLCATALOG) --noout --add \
	  "system" "$(URN_DAPS):novdoc-profile.xsl" \
	  "file://$(DAPS_PROFDIR)/novdoc-profile.xsl" $@
	$(XMLCATALOG) --noout --add \
	  "system" "$(URN_SUSE):docbook41-profile.xsl" \
	  "file://$(DAPS_PROFDIR)/docbook41-profile.xsl" $@
	$(XMLCATALOG) --noout --add \
	  "system" "$(URN_SUSE):docbook42-profile.xsl" \
	  "file://$(DAPS_PROFDIR)/docbook42-profile.xsl" $@
	$(XMLCATALOG) --noout --add \
	  "system" "$(URN_SUSE):docbook43-profile.xsl" \
	  "file://$(DAPS_PROFDIR)/docbook43-profile.xsl" $@
	$(XMLCATALOG) --noout --add \
	  "system" "$(URN_SUSE):docbook44-profile.xsl" \
	  "file://$(DAPS_PROFDIR)/docbook44-profile.xsl" $@
	$(XMLCATALOG) --noout --add \
	  "system" "$(URN_SUSE):docbook45-profile.xsl" \
	  "file://$(DAPS_PROFDIR)/docbook45-profile.xsl" $@
	$(XMLCATALOG) --noout --add \
	  "system" "$(URN_SUSE):docbook50-profile.xsl" \
	  "file://$(DAPS_PROFDIR)/docbook50-profile.xsl" $@
	$(XMLCATALOG) --noout --add \
	  "system" "$(URN_SUSE):docbook51-profile.xsl" \
	  "file://$(DAPS_PROFDIR)/docbook51-profile.xsl" $@
	$(XMLCATALOG) --noout --add \
	  "system" "$(URN_SUSE):novdoc-profile.xsl" \
	  "file://$(DAPS_PROFDIR)/novdoc-profile.xsl" $@
	$(SED) -i '/^<!DOCTYPE .*>$$/d' $@
	$(SED) -i '/<catalog/a\ <group id="$(PACKAGE)">' $@
	$(SED) -i '/<\/catalog/i\ </group>' $@

# Generate documentation on the fly
.PHONY: manuals
manuals:
	for BOOK in $(MANUALS); do \
	  bin/daps --debug --dapsroot=$(DAPSROOT) \
	    --docconfig=$(DAPSROOT)/doc/DC-$$BOOK --color=0 \
	    --styleroot=$(STYLEROOT) html-single --static \
	    --css=$(STYLEROOT)/html/susebooks.css; \
	done

#.PHONY: manpages
#manpages:
$(man_MANS):
	bin/daps --debug --dapsroot=$(DAPSROOT) --color=0 \
	  --docconfig=$(DAPSROOT)/man/$(DC_MANPAGES) man --nogzip
