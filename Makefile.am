# Makefile.am for DocBook Authoring and Publishing Suite (daps)
# Generate catalogs and install daps
#
# Copyright (C) 2011,2012 Frank Sundermeyer <fsundermeyer@opensuse.org>
#
# Author:
# Frank Sundermeyer <fsundermeyer@opensuse.org>
#
# TODO: aspell location
# Stylesheets for building xhtml need to be packaged in src tar
# Replace PHONY manuals:

# Manuals
#DC_USERGUIDE  = $(srcdir)/doc/DC-daps-user
#DC_QUICKSTART = $(srcdir)/doc/DC-daps-quick
#USERGUIDE     = $(shell bin/daps -d $(DC_USERGUIDE) htmlsingle-name)
#QUICKSTART    = $(shell bin/daps -d $(DC_QUICKSTART) htmlsingle-name)

#------------------------
AUTOMAKE_OPTIONS = 1.10 foreign no-define no-dist no-installinfo \
			-Wall -Werror -Wno-portability
SUBDIRS=

#------------------------
DAPS_CATALOG := for-catalog-$(PACKAGE).xml
DAPSROOT     := $(abs_top_srcdir)
# stylesheets with which to build the documentation
STYLEROOT    := $(DAPSROOT)/suse-xslt
# Man pages
DC_MANPAGES := DC-daps-manpages
MAN_PAGE_DIR=$(subst DC-,,$(DC_MANPAGES))
# Manuals
MANUALS=$(subst doc/DC-,,$(wildcard doc/DC-*))

#------------------------
# Installation hooks
#
dapsconfdir  = @sysconfdir@/daps
fopconfdir   = @sysconfdir@/fop
xepconfdir   = @sysconfdir@/xep
hyphendir    = $(xepconfdir)/hyphen
xmlconfdir   = @sysconfdir@/xml

aspelldir    = @datadir@/aspell
dapslibdir   = $(pkgdatadir)/lib
dapsmakedir  = $(pkgdatadir)/make
emacssitedir = @datadir@/emacs/site-lisp
templatedir  = $(pkgdatadir)/init_templates
ttfontsdir   = @datadir@/fonts/truetype

htmldocdir   = @docdir@/html

#------------------------
# Automake primaries

all-local: manuals

# BIN
dist_bin_SCRIPTS    = $(srcdir)/$(wildcard bin/*)

# CONFIG files
dist_dapsconf_DATA  = $(srcdir)/etc/config
dist_fopconf_DATA   = $(srcdir)/etc/fop/fop-daps.xml
dist_xepconf_DATA   = $(srcdir)/etc/xep/xep-daps.xml
dist_hyphen_DATA    = $(wildcard $(srcdir)/etc/xep/hyphen/*.tex) \
			$(wildcard $(srcdir)/etc/xep/hyphen/*.il2)
dist_xmlconf_DATA   = $(srcdir)/etc/xml/$(DAPS_CATALOG)

# DATA
dist_aspell_DATA    = $(srcdir)/misc/suse_aspell.rws
dist_dapslib_DATA   = $(wildcard $(srcdir)/lib/*)
dist_emacssite_DATA = $(srcdir)/misc/docbook_macros.el
dist_dapsmake_DATA  = $(wildcard $(srcdir)/make/*.mk)
dist_template_DATA  = $(wildcard $(srcdir)/init_templates/*)
dist_ttfonts_DATA   = $(wildcard $(srcdir)/fonts/*.ttf)


# DOCUMENTATION
dist_doc_DATA      = $(addprefix, $(srcdir)/, BUGS COPYING COPYING-2.0 \
			COPYING-3.0 INSTALL README README.quickstart \
			README.upgrade_from_susedoc_4.x)

# MAN pages
man_MANS = $(wildcard $(srcdir)/man/build/$(MAN_PAGE_DIR)/man/*.1)

#---------------------------Manual INSTALLATION--------------------------------

INSTALLDIRS = $(DESTDIR)$(docdir)/html $(DESTDIR)$(pkgdatadir)

$(INSTALLDIRS):
	test -z "$@" || $(MKDIR_P) $@

install-data-local: $(INSTALLDIRS)
	for BOOK in $(MANUALS); do \
	  cp -a $(srcdir)/doc/build/$$BOOK/html/$$BOOK/* \
		$(DESTDIR)$(docdir)/html; \
	done
	cp -a $(srcdir)/daps-xslt/ $(DESTDIR)$(pkgdatadir)
	find {$(DESTDIR)$(docdir)/html,$(DESTDIR)$(pkgdatadir)/daps-xslt} \
		-type d -exec chmod -R u=rwx,go=rx,a-s {} \;; \
	find {$(DESTDIR)$(docdir)/html,$(DESTDIR)$(pkgdatadir)/daps-xslt} \
		-type f -exec chmod -R u=rw,go=r,a-s {} \;;

#-----------------------------CLEAN--------------------------------------------
clean-local:
	rm -rf $(srcdir)/etc/xml $(srcdir)/man/build/ $(srcdir)/doc/build/

#-----------------------------DAPS--------------------------------------------

# create DAPS catalog entries
etc/xml/$(DAPS_CATALOG): DAPS_PROFDIR := $(pkgdatadir)/daps-xslt/profiling
etc/xml/$(DAPS_CATALOG): URN_SUSE     := urn:x-suse:xslt:profiling
etc/xml/$(DAPS_CATALOG): URN_DAPS     := urn:x-daps:xslt:profiling
etc/xml/$(DAPS_CATALOG):
	test -z "$(srcdir)/etc/xml" || $(MKDIR_P) $(srcdir)/etc/xml
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

# Generate man pages on the fly
$(man_MANS):
	bin/daps --debug --dapsroot=$(DAPSROOT) --color=0 \
	  --docconfig=$(DAPSROOT)/man/$(DC_MANPAGES) man --nogzip
