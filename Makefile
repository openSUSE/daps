# Makefile for DocBook Authoring and Publishing Suite (daps)
# Generate catalogs and install daps
#
# Copyright (C) 2011 SUSE Linux Products GmbH
#
# Author:
# Frank Sundermeyer <fs at suse dot de>
#

# IMPORTANT:
# Correct VERSION needs to be provided on the command line,
# for make all and make install !!!!
# this is just a fallback!!
#

VERSION    ?= 5.0

PACKAGE    := daps
DTDNAME    := novdoc
DTDVERSION := 1.0
DBSTYLES   := /usr/share/xml/docbook/stylesheet/nwalsh/current

ROOT_CATALOG  := for-catalog-$(DTDNAME)-$(DTDVERSION).xml
DAPS_CATALOG  := for-catalog-$(PACKAGE)-$(VERSION).xml
NOVDOC_SCHEMA := /usr/share/xml/novdoc/schema/dtd/$(DTDVERSION)


DIRECTORIES := catalogs

#-------
# Directories for installation
PREFIX           ?= /usr/share
DAPS_CONFDIR  := $(DESTDIR)/etc/daps
DAPS_SHAREDIR := $(DESTDIR)$(PREFIX)/daps
DAPS_DOCDIR   := $(DESTDIR)$(PREFIX)/doc/packages/daps

#-------
# Man pages
# we only have man 1 pages ATM
#
MAN_PAGES=$(subst .xml,.1.gz,$(wildcard man/*.xml))

#-------
# Manuals
#
MANUALS=$(subst doc/ENV-,,$(wildcard doc/ENV-*))


all: $(MAN_PAGES) schema/novdocx.rnc schema/novdocx.rng
all: catalogs/$(DAPS_CATALOG) catalogs/$(ROOT_CATALOG)
all: catalogs/CATALOG.$(DTDNAME)-$(DTDVERSION) manuals
	@echo "Ready to install..."

install: create-install-dirs
	install -m755 bin/* $(DESTDIR)/usr/bin
	install -m644 fonts/*.ttf $(DESTDIR)$(PREFIX)/fonts/truetype
	install -m644 man/*.1.gz $(DESTDIR)$(PREFIX)/man/man1
	install -m644 lib/docbook_macros.el $(DESTDIR)$(PREFIX)/emacs/site-lisp
	install -m644 schema/novdocx.{rnc,rng} \
	  $(DESTDIR)$(PREFIX)/xml/$(DTDNAME)/schema/rng/$(DTDVERSION)
	install -m644 schema/{*.dtd,*.ent,catalog.xml,CATALOG} \
	  $(DESTDIR)$(PREFIX)/xml/$(DTDNAME)/schema/dtd/$(DTDVERSION)
	install -m644 catalogs/CATALOG.$(DTDNAME)-$(DTDVERSION) \
	  $(DESTDIR)/var/lib/sgml && \
	  ln -s /var/lib/sgml/CATALOG.$(DTDNAME)-$(DTDVERSION) \
	    $(DESTDIR)/$(PREFIX)/sgml/
	install -m644 catalogs/$(ROOT_CATALOG) $(DESTDIR)/etc/xml
	install -m644 catalogs/$(DAPS_CATALOG) $(DESTDIR)/etc/xml
	install -m644 BUGS COPYING INSTALL README* TODO $(DAPS_DOCDIR)
ifdef MANUALS
	for BOOK in $(MANUALS); do \
	  tar -C $(DAPS_DOCDIR)/html -xjf doc/build/$$BOOK/*-html.tar.bz2; \
	done
endif
	cp -a images/ $(DAPS_SHAREDIR)
	cp -a make/ $(DAPS_SHAREDIR)
	cp -a xslt/ $(DAPS_SHAREDIR)
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
	mkdir -p $(DESTDIR)$(PREFIX)/xml/$(DTDNAME)/schema/{dtd,rng}/$(DTDVERSION)
	mkdir -p $(DESTDIR)$(PREFIX)/emacs/site-lisp
	mkdir -p $(DESTDIR)$(PREFIX)/fonts/truetype
	mkdir -p $(DESTDIR)$(PREFIX)/man/man1
	mkdir -p $(DESTDIR)/var/lib/sgml
	mkdir -p $(DESTDIR)$(PREFIX)/sgml
	mkdir -p $(DESTDIR)/etc/xml


.PHONY: clean
clean:
	rm -rf catalogs/ schema/novdocx.rnc schema/novdocx.rng $(MAN_PAGES) 


#-----------------------------
# Generate man pages

man/%.1.gz: man/%.1
	gzip $<

man/%.1: man/%.xml
	DATE=$(date +"%Y-%m-%d")
	sed -i "s=@VERSION@=${VERSION}=g;s=@DATE@=${DATE}=g" $<
	xsltproc --stringparam man.output.base.dir "man/" \
	  --stringparam man.output.in.separate.dir 1 \
	  --stringparam man.output.subdirs.enabled 0 \
	  $(DBSTYLES)/manpages/docbook.xsl $<

#-----------------------------
# Generate SGML catalog for novdoc
#
catalogs/CATALOG.$(DTDNAME)-$(DTDVERSION): $(DIRECTORIES)
catalogs/CATALOG.$(DTDNAME)-$(DTDVERSION):
	echo \
	  "CATALOG \"$(NOVDOC_SCHEMA)/CATALOG\"" \
	  > $@

#-----------------------------
# Generate RELAX NG schemes for novdoc
#

schema/novdocx.rnc: schema/novdocx.dtd.tmp
	trang -I dtd $< $@

schema/novdocx.rng: schema/novdocx.dtd.tmp
	trang -I dtd $< $@

# To avoid unknown host errors with trang, we have to switch off the external
# entities from DocBook by creating a temporary file novdocx.dtd.tmp.
# As the entities are not used in RELAX NG anyway, this is uncritical.
#
.INTERMEDIATE: schema/novdocx.dtd.tmp
schema/novdocx.dtd.tmp: $(DIRECTORIES)
	sed 's:\(%[ \t]*ISO[^\.]*\.module[ \t]*\)"INCLUDE":\1"IGNORE":g' \
	  < schema/novdocx.dtd > $@


#-----------------------------
# Generate DAPS catalog
#
# since xmlcatalog cannot create groups (<group>) we need to use sed
# to fix this; while we are at it, we also remove the DOCTYPE line since 
# it may cause problems with some XML parsers (hen/egg probem)
#

catalogs/$(DAPS_CATALOG): $(DIRECTORIES)
catalogs/$(DAPS_CATALOG): DAPS_PROFDIR := $(PREFIX)/daps/xslt/profiling
catalogs/$(DAPS_CATALOG): URN_PROF     := urn:x-suse:xslt:profiling
catalogs/$(DAPS_CATALOG):
	xmlcatalog --noout --create $@
	xmlcatalog --noout --add \
	  "system" "$(URN_PROF):docbook41-profile.xsl" \
	  "file://$(DAPS_PROFDIR)/docbook41-profile.xsl" $@
	xmlcatalog --noout --add \
	  "system" "$(URN_PROF):docbook42-profile.xsl" \
	  "file://$(DAPS_PROFDIR)/docbook42-profile.xsl" $@
	xmlcatalog --noout --add \
	  "system" "$(URN_PROF):docbook43-profile.xsl" \
	  "file://$(DAPS_PROFDIR)/docbook43-profile.xsl" $@
	xmlcatalog --noout --add \
	  "system" "$(URN_PROF):docbook44-profile.xsl" \
	  "file://$(DAPS_PROFDIR)/docbook44-profile.xsl" $@
	xmlcatalog --noout --add \
	  "system" "$(URN_PROF):docbook45-profile.xsl" \
	  "file://$(DAPS_PROFDIR)/docbook45-profile.xsl" $@
	xmlcatalog --noout --add \
	  "system" "$(URN_PROF):novdoc-profile.xsl" \
	  "file://$(DAPS_PROFDIR)/novdoc-profile.xsl" $@
	sed -i '/^<!DOCTYPE .*>$$/d' $@
	sed -i '/<catalog/a\ <group id="$(PACKAGE)-$(VERSION)">' $@
	sed -i '/<\/catalog/i\ </group>' $@


#-----------------------------
# Generate ROOT catalog
#

# since xmlcatalog cannot create groups (<group>) we need to use sed
# to fix this; while we are at it, we also remove the DOCTYPE line since 
# it may cause problems with some XML parsers (hen/egg probem)
#
catalogs/$(ROOT_CATALOG): $(DIRECTORIES)
catalogs/$(ROOT_CATALOG):
	xmlcatalog --noout --create $@
	xmlcatalog --noout --add "delegatePublic" "-//Novell//DTD NovDoc XML" \
	  "file://$(NOVDOC_SCHEMA)/catalog.xml" $@
	xmlcatalog --noout --add "delegateSystem" "novdocx.dtd" \
	  "file://$(NOVDOC_SCHEMA)/catalog.xml" $@
	sed -i '/^<!DOCTYPE .*>$$/d' $@
	sed -i '/<catalog/a\ <group id="$(DTDNAME)-$(DTDVERSION)">' $@
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
	  bin/daps --debug --dtdroot=$(shell pwd) --basedir=$(shell pwd)/doc \
	    --envfile=ENV-$$BOOK --color=0 dist-html; \
	done
