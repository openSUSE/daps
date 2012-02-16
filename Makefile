# Makefile for DocBook Authoring and Publishing Suite (daps)
# Generate catalogs and install daps
#
# Copyright (C) 2011,2012 Frank Sundermeyer <fsundermeyer@opensuse.org>
#
# Author:
# Frank Sundermeyer <fsundermeyer@opensuse.org>

# IMPORTANT:
# Correct VERSION needs to be provided on the command line,
# for make all and make install !!!!
# this is just a fallback!!
#

PACKAGE    := daps

DAPS_CATALOG  := for-catalog-$(PACKAGE).xml

DAPSROOT := $(shell pwd)

DIRECTORIES := catalogs


#-------
# Directories for installation
PREFIX           ?= /usr/share
DAPS_CONFDIR  := $(DESTDIR)/etc/daps
DAPS_SHAREDIR := $(DESTDIR)$(PREFIX)/daps
DAPS_DOCDIR   := $(DESTDIR)$(PREFIX)/doc/packages/daps

# from the suse-xsl-stylesheets package
STYLEROOT     := $(PREFIX)/xml/docbook/stylesheet/suse

#-------
# Man pages
#
DC-manpages := DC-daps-manpages
MAN_PAGE_DIR=$(subst DC-,,$(DC-manpages))

#-------
# Manuals
#
MANUALS=$(subst doc/DC-,,$(wildcard doc/DC-*))

all: catalogs/$(DAPS_CATALOG) manuals manpages
	@echo "Ready to install..."

install: create-install-dirs
	install -m755 bin/* $(DESTDIR)/usr/bin
	install -m644 fonts/*.ttf $(DESTDIR)$(PREFIX)/fonts/truetype
	install -m644 lib/docbook_macros.el $(DESTDIR)$(PREFIX)/emacs/site-lisp
	install -m644 lib/suse_aspell.rws $(DESTDIR)$(PREFIX)/aspell-0.60
	install -m644 catalogs/$(DAPS_CATALOG) $(DESTDIR)/etc/xml
	install -m644 BUGS COPYING* INSTALL README* TODO $(DAPS_DOCDIR)
ifdef MAN_PAGE_DIR
	cp -a man/build/$(MAN_PAGE_DIR)/man $(DESTDIR)$(PREFIX)
endif
ifdef MANUALS
	for BOOK in $(MANUALS); do \
	  cp -a doc/build/$$BOOK/html/* $(DAPS_DOCDIR)/html; \
	done
endif
	cp -a make/ $(DAPS_SHAREDIR)
	cp -a daps-xslt/ $(DAPS_SHAREDIR)
	cp -a etc/* $(DAPS_CONFDIR)
	tar cp --exclude=docbook_macros.el lib/* | (cd $(DAPS_SHAREDIR); tar xpv)
	find {$(DAPS_CONFDIR),$(DAPS_DOCDIR),$(DAPS_SHAREDIR)} -type d -exec chmod 755 {} \;
	find {$(DAPS_CONFDIR),$(DAPS_DOCDIR),$(DAPS_SHAREDIR)} -type f -exec chmod 644 {} \;
	(cd $(DAPS_SHAREDIR)/lib; chmod 755 *.sh *.py daps-{fop,xep})

create-install-dirs:
ifdef MANUALS
	mkdir -p $(DAPS_DOCDIR)/html
else
	mkdir -p $(DAPS_DOCDIR)
endif
	mkdir -p $(DAPS_CONFDIR)
	mkdir -p $(DAPS_SHAREDIR)
	mkdir -p $(DESTDIR)/usr/bin
	mkdir -p $(DESTDIR)$(PREFIX)/emacs/site-lisp
# version number in path ;-(( needs to be checked
	mkdir -p $(DESTDIR)$(PREFIX)/aspell-0.60
	mkdir -p $(DESTDIR)$(PREFIX)/fonts/truetype
	mkdir -p $(DESTDIR)/etc/xml


.PHONY: clean
clean:
	rm -rf catalogs/ man/build/ doc/build/

#-----------------------------
# Generate DAPS catalog
#
# since xmlcatalog cannot create groups (<group>) we need to use sed
# to fix this; while we are at it, we also remove the DOCTYPE line since 
# it may cause problems with some XML parsers (hen/egg probem)
#

catalogs/$(DAPS_CATALOG): $(DIRECTORIES)
catalogs/$(DAPS_CATALOG): DAPS_PROFDIR := $(PREFIX)/daps/daps-xslt/profiling
catalogs/$(DAPS_CATALOG): URN_SUSE     := urn:x-suse:xslt:profiling
catalogs/$(DAPS_CATALOG): URN_DAPS     := urn:x-daps:xslt:profiling
catalogs/$(DAPS_CATALOG):
	xmlcatalog --noout --create $@
	xmlcatalog --noout --add \
	  "system" "$(URN_DAPS):docbook41-profile.xsl" \
	  "file://$(DAPS_PROFDIR)/docbook41-profile.xsl" $@
	xmlcatalog --noout --add \
	  "system" "$(URN_DAPS):docbook42-profile.xsl" \
	  "file://$(DAPS_PROFDIR)/docbook42-profile.xsl" $@
	xmlcatalog --noout --add \
	  "system" "$(URN_DAPS):docbook43-profile.xsl" \
	  "file://$(DAPS_PROFDIR)/docbook43-profile.xsl" $@
	xmlcatalog --noout --add \
	  "system" "$(URN_DAPS):docbook44-profile.xsl" \
	  "file://$(DAPS_PROFDIR)/docbook44-profile.xsl" $@
	xmlcatalog --noout --add \
	  "system" "$(URN_DAPS):docbook45-profile.xsl" \
	  "file://$(DAPS_PROFDIR)/docbook45-profile.xsl" $@
	xmlcatalog --noout --add \
	  "system" "$(URN_DAPS):docbook50-profile.xsl" \
	  "file://$(DAPS_PROFDIR)/docbook50-profile.xsl" $@
	xmlcatalog --noout --add \
	  "system" "$(URN_DAPS):docbook51-profile.xsl" \
	  "file://$(DAPS_PROFDIR)/docbook51-profile.xsl" $@
	xmlcatalog --noout --add \
	  "system" "$(URN_DAPS):novdoc-profile.xsl" \
	  "file://$(DAPS_PROFDIR)/novdoc-profile.xsl" $@
	xmlcatalog --noout --add \
	  "system" "$(URN_SUSE):docbook41-profile.xsl" \
	  "file://$(DAPS_PROFDIR)/docbook41-profile.xsl" $@
	xmlcatalog --noout --add \
	  "system" "$(URN_SUSE):docbook42-profile.xsl" \
	  "file://$(DAPS_PROFDIR)/docbook42-profile.xsl" $@
	xmlcatalog --noout --add \
	  "system" "$(URN_SUSE):docbook43-profile.xsl" \
	  "file://$(DAPS_PROFDIR)/docbook43-profile.xsl" $@
	xmlcatalog --noout --add \
	  "system" "$(URN_SUSE):docbook44-profile.xsl" \
	  "file://$(DAPS_PROFDIR)/docbook44-profile.xsl" $@
	xmlcatalog --noout --add \
	  "system" "$(URN_SUSE):docbook45-profile.xsl" \
	  "file://$(DAPS_PROFDIR)/docbook45-profile.xsl" $@
	xmlcatalog --noout --add \
	  "system" "$(URN_SUSE):docbook50-profile.xsl" \
	  "file://$(DAPS_PROFDIR)/docbook50-profile.xsl" $@
	xmlcatalog --noout --add \
	  "system" "$(URN_SUSE):docbook51-profile.xsl" \
	  "file://$(DAPS_PROFDIR)/docbook51-profile.xsl" $@
	xmlcatalog --noout --add \
	  "system" "$(URN_SUSE):novdoc-profile.xsl" \
	  "file://$(DAPS_PROFDIR)/novdoc-profile.xsl" $@
	sed -i '/^<!DOCTYPE .*>$$/d' $@
	sed -i '/<catalog/a\ <group id="$(PACKAGE)">' $@
	sed -i '/<\/catalog/i\ </group>' $@


# create needed directories
#
$(DIRECTORIES):
	mkdir -p $@

#-----------------------------
# Generate documentation on the fly
#

.PHONY: manuals
manuals:
	for BOOK in $(MANUALS); do \
	  bin/daps --debug --dapsroot=$(DAPSROOT) \
	    --docconfig=$(DAPSROOT)/doc/DC-$$BOOK --color=0 \
	    --styleroot=$(STYLEROOT) html-single --static \
	    --css=$(STYLEROOT)/html/susebooks.css; \
	done

.PHONY: manpages
manpages:
	bin/daps --debug --dapsroot=$(DAPSROOT) --color=0 \
	  --docconfig=$(DAPSROOT)/man/$(DC-manpages) man
