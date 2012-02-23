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
DAPS_CATALOG := catalogs/for-catalog-$(PACKAGE).xml
DAPSROOT     := $(abs_top_srcdir)

# stylesheets with which to build the documentation
STYLEROOT    := $(DAPSROOT)/suse-xslt

# Man pages
DC_MANPAGES    := DC-daps-manpages
MAN_PAGE_DIR   := $(subst DC-,,$(DC_MANPAGES))
MAN_PAGES      := daps.1 ccecho.1
MAN_BUILD_PATH := $(srcdir)/man/build/$(MAN_PAGE_DIR)/man/

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
dapsconfdir    = @sysconfdir@/daps
fopconfdir     = $(dapsconfdir)/fop
xepconfdir     = $(dapsconfdir)/xep
hyphendir      = $(xepconfdir)/hyphen

aspelldir      = @datadir@/aspell
dapslibdir     = $(pkgdatadir)/lib
dapslibexecdir = $(pkgdatadir)/libexec
dapsmakedir    = $(pkgdatadir)/make
emacssitedir   = @datadir@/emacs/site-lisp
templatedir    = $(pkgdatadir)/init_templates
ttfontsdir     = @datadir@/fonts/truetype

htmldocdir     = @docdir@/html



#------------------------
# Automake primaries

# BIN
dist_bin_SCRIPTS         = $(srcdir)/$(wildcard bin/*)
dist_dapslibexec_SCRIPTS = $(srcdir)/$(wildcard libexec/*)

# CONFIG files
dist_dapsconf_DATA  = $(srcdir)/etc/config
dist_fopconf_DATA   = $(srcdir)/etc/fop/fop-daps.xml
dist_xepconf_DATA   = $(srcdir)/etc/xep/xep-daps.xml
dist_hyphen_DATA    = $(wildcard $(srcdir)/etc/xep/hyphen/*.tex) \
			$(wildcard $(srcdir)/etc/xep/hyphen/*.il2)

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
man_MANS = $(addprefix $(MAN_BUILD_PATH), $(MAN_PAGES))

#---------------------------Local TARGETS--------------------------------------
all-local: $(USERGUIDE) $(QUICKSTART) $(man_MANS) $(DAPS_CATALOG)

#---------------------------Local INSTALLATION--------------------------------

INSTALLDIRS = $(DESTDIR)$(docdir)/html $(DESTDIR)$(pkgdatadir)

$(INSTALLDIRS):
	test -z "$@" || $(MKDIR_P) $@

install-data-local: $(INSTALLDIRS)
install-data-local: TMP_CATALOG := $(shell mktemp -q catalog.XXXXX)
install-data-local:
	for BOOK in $(MANUALS); do \
	  cp -a $$BOOK/* $(DESTDIR)$(docdir)/html; \
	done
	cp -a $(srcdir)/daps-xslt/ $(DESTDIR)$(pkgdatadir)
	find {$(DESTDIR)$(docdir)/html,$(DESTDIR)$(pkgdatadir)/daps-xslt} \
		-type d -exec chmod -R u=rwx,go=rx,a-s {} \;; \
	find {$(DESTDIR)$(docdir)/html,$(DESTDIR)$(pkgdatadir)/daps-xslt} \
		-type f -exec chmod -R u=rw,go=r,a-s {} \;;
# create entry in xml root catalog
	{ \
	  sed '/<\/catalog>/d' $(ROOT_CATALOG); \
	  $(XMLLINT) --nocatalogs --format $(DAPS_CATALOG) | \
	    awk '/<\/catalog>/{next} s == 1 {print} /<catalog/{s=1} \
	      END{print "</catalog>"}'; \
	} >$(TMP_CATALOG)
	chmod --reference=$(ROOT_CATALOG) $(TMP_CATALOG)
	$(XMLLINT) --nocatalogs --noout $(TMP_CATALOG) && \
	  mv $(TMP_CATALOG) $(ROOT_CATALOG)

#---------------------------Local UNINSTALL-----------------------------------
uninstall-local: TMP_CATALOG := $(shell mktemp -q catalog.XXXXX)
uninstall-local:
	$(XMLLINT) --nocatalogs --format $(ROOT_CATALOG) | \
	  awk "/<\/group>/ && s == 1 {s=0;next} s == 1 {next} /<group id="$(PACKAGE)">/{s=1;next} {print}" > $(TMP_CATALOG)
	chmod --reference=$(ROOT_CATALOG) $(TMP_CATALOG)
	$(XMLLINT) --nocatalogs --noout $(TMP_CATALOG) && \
	  mv $(TMP_CATALOG) $(ROOT_CATALOG)

#-----------------------------CLEAN--------------------------------------------
clean-local:
	rm -rf $(srcdir)/man/build/ $(srcdir)/doc/build/ $(dir $(DAPS_CATALOG)) 

#-----------------------------DAPS--------------------------------------------

# create temporary DAPS catalog entries file
$(DAPS_CATALOG): DAPS_PROFDIR := $(pkgdatadir)/daps-xslt/profiling
$(DAPS_CATALOG): URN_SUSE     := urn:x-suse:xslt:profiling
$(DAPS_CATALOG): URN_DAPS     := urn:x-daps:xslt:profiling
$(DAPS_CATALOG): DB_VERSIONS  := 41 42 43 44 45 50 51
$(DAPS_CATALOG):
	$(Q)test -z "$(dir $@)" || $(MKDIR_P) $(dir $@)
	$(Q)$(XMLCATALOG) --noout --create $@
	$(Q)for VERS in $(DB_VERSIONS); do \
	  $(XMLCATALOG) --noout --add \
	  "system" "$(URN_DAPS):docbook$${VERS}-profile.xsl" \
	  "file://$(DAPS_PROFDIR)/docbook$${VERS}-profile.xsl" $@; \
	  $(XMLCATALOG) --noout --add \
	  "system" "$(URN_SUSE):docbook$${VERS}-profile.xsl" \
	  "file://$(DAPS_PROFDIR)/docbook$${VERS}-profile.xsl" $@; \
	done
	$(Q)$(XMLCATALOG) --noout --add \
	  "system" "$(URN_DAPS):novdoc-profile.xsl" \
	  "file://$(DAPS_PROFDIR)/novdoc-profile.xsl" $@
	$(Q)$(XMLCATALOG) --noout --add \
	  "system" "$(URN_SUSE):novdoc-profile.xsl" \
	  "file://$(DAPS_PROFDIR)/novdoc-profile.xsl" $@
	$(Q)$(SED) -i '/^<!DOCTYPE .*>$$/d' $@
	$(Q)$(SED) -i '/<catalog/a\ <group id="$(PACKAGE)">' $@
	$(Q)$(SED) -i '/<\/catalog/i\ </group>' $@
	$(Q)$(srcdir)/bin/ccecho "result" "Created $@"

$(USERGUIDE):
	$(Q)$(srcdir)/bin/daps $(DEBUG) --dapsroot=$(DAPSROOT) \
	    --docconfig=$(DC_USERGUIDE) \
	    --styleroot=$(STYLEROOT) html-single --static \
	    --css=$(STYLEROOT)/html/susebooks.css --name=$(USERGUIDE_NAME)
	$(Q)$(srcdir)/bin/ccecho "result" "Created $@"

$(QUICKSTART):
	$(Q)$(srcdir)/bin/daps $(DEBUG) --dapsroot=$(DAPSROOT) \
	    --docconfig=$(DC_QUICKSTART) \
	    --styleroot=$(STYLEROOT) html-single --static \
	    --css=$(STYLEROOT)/html/susebooks.css --name=$(QUICKSTART_NAME)
	$(Q)$(srcdir)/bin/ccecho "result" "Created $@"

# Generate man pages on the fly
$(man_MANS):
	$(Q)$(srcdir)/bin/daps $(DEBUG) --dapsroot=$(DAPSROOT) --color=0 \
	  --docconfig=$(DAPSROOT)/man/$(DC_MANPAGES) man --nogzip
	$(Q)$(srcdir)/bin/ccecho "result" "Created man pages $@"
