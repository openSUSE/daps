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
DC_USERGUIDE    = $(srcdir)/doc/DC-daps-user
DC_QUICKSTART   = $(srcdir)/doc/DC-daps-quick
USERGUIDE_NAME  =  daps-user
QUICKSTART_NAME = daps-quick
USERGUIDE       = $(srcdir)/doc/build/$(USERGUIDE_NAME)/html/$(USERGUIDE_NAME)/$(USERGUIDE_NAME).html
QUICKSTART      = $(srcdir)/doc/build/$(QUICKSTART_NAME)/html/$(QUICKSTART_NAME)/$(QUICKSTART_NAME).html
MANUALS         = $(dir $(USERGUIDE)) $(dir $(QUICKSTART)) 


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

all-local: $(USERGUIDE) $(QUICKSTART) etc/xml/$(DAPS_CATALOG)

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
	  cp -a $$BOOK/* $(DESTDIR)$(docdir)/html; \
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
etc/xml/$(DAPS_CATALOG): DB_VERSIONS  := 41 42 43 44 45 50 51
etc/xml/$(DAPS_CATALOG):
	@test -z "$(srcdir)/etc/xml" || $(MKDIR_P) $(srcdir)/etc/xml
	@$(XMLCATALOG) --noout --create $@
	@for VERS in $(DB_VERSIONS); do \
	  $(XMLCATALOG) --noout --add \
	  "system" "$(URN_DAPS):docbook$${VERS}-profile.xsl" \
	  "file://$(DAPS_PROFDIR)/docbook$${VERS}-profile.xsl" $@; \
	  $(XMLCATALOG) --noout --add \
	  "system" "$(URN_SUSE):docbook$${VERS}-profile.xsl" \
	  "file://$(DAPS_PROFDIR)/docbook$${VERS}-profile.xsl" $@; \
	done
	@$(XMLCATALOG) --noout --add \
	  "system" "$(URN_DAPS):novdoc-profile.xsl" \
	  "file://$(DAPS_PROFDIR)/novdoc-profile.xsl" $@
	@$(XMLCATALOG) --noout --add \
	  "system" "$(URN_SUSE):novdoc-profile.xsl" \
	  "file://$(DAPS_PROFDIR)/novdoc-profile.xsl" $@
	@$(SED) -i '/^<!DOCTYPE .*>$$/d' $@
	@$(SED) -i '/<catalog/a\ <group id="$(PACKAGE)">' $@
	@$(SED) -i '/<\/catalog/i\ </group>' $@
	@$(srcdir)/bin/ccecho "result" "Created $@"

$(USERGUIDE):
	@$(srcdir)/bin/daps -v --dapsroot=$(DAPSROOT) --docconfig=$(DC_USERGUIDE) \
	    --styleroot=$(STYLEROOT) html-single --static \
	    --css=$(STYLEROOT)/html/susebooks.css --name=$(USERGUIDE_NAME)

$(QUICKSTART):
	@$(srcdir)/bin/daps -v --dapsroot=$(DAPSROOT) --docconfig=$(DC_QUICKSTART) \
	    --styleroot=$(STYLEROOT) html-single --static \
	    --css=$(STYLEROOT)/html/susebooks.css --name=$(QUICKSTART_NAME)

# Generate man pages on the fly
$(man_MANS):
	@$(srcdir)/bin/daps -v --dapsroot=$(DAPSROOT) --color=0 \
	  --docconfig=$(DAPSROOT)/man/$(DC_MANPAGES) man --nogzip
