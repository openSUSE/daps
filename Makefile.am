# Copyright (C) 2012-2015 SUSE Linux GmbH
#
# Author:
# Frank Sundermeyer <fsundermeyer at opensuse dot org>
#
# Makefile.am for DocBook Authoring and Publishing Suite (daps)
# Generate catalogs and install daps
#
#
# TODO: 
# Stylesheets for building xhtml need to be packaged in src tar

#------------------------
AUTOMAKE_OPTIONS = 1.10 foreign dist-bzip2 no-dist-gzip no-installinfo \
			-Wall -Werror -Wno-portability
ACLOCAL_AMFLAGS = -I m4
SUBDIRS = 

# additional files to add to the tarball
EXTRA_DIST := COPYING-2.0 COPYING-3.0 packaging/daps.spec

#------------------------
REPL_PATH = sed \
             -e 's|@sysconfdir[@]|$(sysconfdir)|g' \
             -e 's|@bindir[@]|$(bindir)|g' \
             -e 's|@pkgdatadir[@]|$(pkgdatadir)|g' \
             -e 's|@datadir[@]|$(datadir)|g' \
             -e 's|@prefix[@]|$(prefix)|g' \
             -e 's|@PACKAGE_VERSION[@]|$(PACKAGE_VERSION)|g'

DAPS_CATALOG := catalogs/for-catalog-$(PACKAGE).xml
DAPSROOT     := $(abs_top_srcdir)

# fop config
#
FOP_CONFIG   := etc/fop/fop-daps.xml
FOP_CONFIG_DEFAULT := etc/fop/fop-daps.generic

if DIST_SUSE
  FOP_CONFIG_SRC := etc/fop/fop-daps.suse
endif
if DIST_SUSEBS
  FOP_CONFIG_SRC := etc/fop/fop-daps.suse
endif
if DIST_REDHAT
  FOP_CONFIG_SRC := etc/fop/fop-daps.redhat
endif
if DIST_UBUNTU
  FOP_CONFIG_SRC := etc/fop/fop-daps.generic
endif

# stylesheets
if HAS_DAPS_XSL
  STYLEROOT := $(daps_xsl)
else
  STYLEROOT := $(subst file://,,$(shell $(XMLCATALOG) $(root_catalog) $(db4_xslt_url)))
endif


# Man pages
DC_MANPAGES    := DC-daps-manpages
MAN_PAGE_DIR   := $(subst DC-,,$(DC_MANPAGES))
MAN_PAGES      := daps.1 ccecho.1 daps_init.1 daps-susespell.1 daps-envconvert.1 daps_autobuild.1
MAN_BUILD_PATH := $(srcdir)/man/build/$(MAN_PAGE_DIR)/man/

# Manuals
DC_USERGUIDE    = $(srcdir)/doc/DC-daps-user
DC_QUICKSTART   = $(srcdir)/doc/DC-daps-quick
USERGUIDE_NAME  =  daps-user
QUICKSTART_NAME = daps-quick
USERGUIDE       = $(srcdir)/doc/build/$(USERGUIDE_NAME)/single-html/$(USERGUIDE_NAME)/$(USERGUIDE_NAME).html
QUICKSTART      = $(srcdir)/doc/build/$(QUICKSTART_NAME)/single-html/$(QUICKSTART_NAME)/$(QUICKSTART_NAME).html
MANUALS         = $(dir $(USERGUIDE)) $(dir $(QUICKSTART)) 


#------------------------
# Installation hooks
#
dapsconfdir    = @sysconfdir@/daps
fopconfdir     = $(dapsconfdir)/fop
xepconfdir     = $(dapsconfdir)/xep
hyphendir      = $(xepconfdir)/hyphen

catalogdir     = @sysconfdir@/xml

dapslibdir     = $(pkgdatadir)/lib
dapslibexecdir = $(pkgdatadir)/libexec
dapsmakedir    = $(pkgdatadir)/make
emacssitedir   = @datadir@/emacs/site-lisp
templatedir    = $(pkgdatadir)/init_templates

htmldocdir     = @docdir@/html

xsltdir          = $(pkgdatadir)/daps-xslt
xsltcommondir    = $(xsltdir)/common
xsltcontribdir   = $(xsltdir)/contrib
xsltdesktopdir   = $(xsltdir)/desktop
xsltepubdir      = $(xsltdir)/epub
xsltindexdir     = $(xsltdir)/index
xsltjspdir       = $(xsltdir)/jsp
xsltlibdir       = $(xsltdir)/lib
xsltmallarddir   = $(xsltdir)/mallard
xsltmigratedir   = $(xsltdir)/migrate
xsltprofilingdir = $(xsltdir)/profiling
xsltrelnotesdir  = $(xsltdir)/relnotes
xsltxhtmldir     = $(xsltdir)/xhtml
xsltyelpdir      = $(xsltdir)/yelp

#------------------------
# Automake primaries

# BIN
dist_bin_SCRIPTS         = $(wildcard bin/*[^.in])
dist_dapslibexec_SCRIPTS = $(wildcard libexec/*)

if !CATALOG_EDIT
# CATALOG files
dist_catalog_DATA   = $(DAPS_CATALOG)
endif

# CONFIG files
dist_dapsconf_DATA    = etc/config etc/docbook-xmlformat.conf \
			etc/CatalogManager.properties
dist_fopconf_DATA     = etc/fop/fop-daps.xml
dist_xepconf_DATA     = etc/xep/xep-daps.xml
dist_hyphen_DATA      = $(wildcard etc/xep/hyphen/*.tex) \
			$(wildcard etc/xep/hyphen/*.il2)

# DATA
dist_dapslib_DATA       = $(wildcard lib/*)
dist_emacssite_DATA     = misc/docbook_macros.el
dist_dapsmake_DATA      = $(wildcard make/*.mk)
dist_template_DATA      = $(wildcard init_templates/*)
dist_xsltcommon_DATA    = $(wildcard daps-xslt/common/*.xsl) \
			   $(wildcard daps-xslt/common/*.xml) \
			   $(wildcard daps-xslt/common/*.svg)
dist_xsltcontrib_DATA   = $(wildcard daps-xslt/contrib/*.xsl)
dist_xsltdesktop_DATA   = $(wildcard daps-xslt/desktop/*.xsl)
dist_xsltepub_DATA      = $(wildcard daps-xslt/epub/*.xsl)
dist_xsltindex_DATA     = $(wildcard daps-xslt/index/*.xsl)
dist_xsltjsp_DATA       = $(wildcard daps-xslt/jsp/*.xsl)
dist_xsltlib_DATA       = $(wildcard daps-xslt/lib/*.xsl)
dist_xsltmallard_DATA   = $(wildcard daps-xslt/mallard/*.xsl)
dist_xsltmigrate_DATA   = $(wildcard daps-xslt/migrate/*.xsl)
dist_xsltprofiling_DATA = $(wildcard daps-xslt/profiling/*.xsl)
dist_xsltrelnotes_DATA  = $(wildcard daps-xslt/relnotes/*.xsl)
dist_xsltxhtml_DATA     = $(wildcard daps-xslt/xhtml/*.xsl)
dist_xsltyelp_DATA      = $(wildcard daps-xslt/yelp/*.xsl)

# DOCUMENTATION
dist_doc_DATA      = BUGS COPYING COPYING-2.0 COPYING-3.0 INSTALL.adoc \
			README.adoc README.quickstart.adoc
dist_man1_MANS      = $(addprefix $(MAN_BUILD_PATH), $(MAN_PAGES))

#---------------------------Local TARGETS--------------------------------------

#
# These targets need to be build _after_ the guides have been build, to make sure
# the local config, as provided by the repo, is used. Otherwise we have a mixture
# of system and repo setup and that will not work

bin/daps etc/config $(FOP_CONFIG): $(USERGUIDE) $(QUICKSTART) $(dist_man1_MANS)

all-local: $(USERGUIDE) $(QUICKSTART) $(dist_man1_MANS) $(DAPS_CATALOG)


#---------------------------Local INSTALLATION--------------------------------

INSTALLDIRS = $(DESTDIR)$(docdir)/html $(DESTDIR)$(pkgdatadir) \
	$(DESTDIR)$(datadir)/xml/$(PACKAGE)/schema/ \
	$(DESTDIR)$(templatedir)

$(INSTALLDIRS):
	test -z "$@" || $(MKDIR_P) $@

install-data-local: $(INSTALLDIRS) autobuild/daps_autobuild
install-data-local: TMP_CATALOG := $(shell mktemp -q catalogs/catalog.XXXXX)
install-data-local:
	for BOOK in $(MANUALS); do \
	  tar c --mode=u+w,go+r-w,a-s -C $$BOOK . | \
		(cd $(DESTDIR)$(docdir)/html; tar xp); \
	done
	install -m755 autobuild/daps_autobuild $(DESTDIR)$(bindir)
	install -m644 autobuild/daps_autobuild.rnc $(DESTDIR)$(datadir)/xml/$(PACKAGE)/schema/
	install -m644 autobuild/daps_autobuild.xml $(DESTDIR)$(templatedir)
if CATALOG_EDIT
# create entry in xml root catalog
	{ \
	  sed '/<\/catalog>/d' $(root_catalog); \
	  $(XMLLINT) --nocatalogs --format $(DAPS_CATALOG) | \
	    awk '/<\/catalog>/{next} s == 1 {print} /<catalog/{s=1} \
	      END{print "</catalog>"}'; \
	} >$(TMP_CATALOG)
	chmod --reference=$(root_catalog) $(TMP_CATALOG)
	mv $(TMP_CATALOG) $(root_catalog)
endif

#---------------------------Local UNINSTALL-----------------------------------
if CATALOG_EDIT
uninstall-local: TMP_CATALOG := $(shell mktemp -q catalogs/catalog.XXXXX)
uninstall-local:
	$(XMLLINT) --nocatalogs --format $(root_catalog) | \
	  awk "/<\/group>/ && s == 1 {s=0;next} s == 1 {next} /<group id=\"$(PACKAGE)\">/{s=1;next} {print}" > $(TMP_CATALOG)
	chmod --reference=$(root_catalog) $(TMP_CATALOG)
	mv $(TMP_CATALOG) $(root_catalog)
endif
#-----------------------------CLEAN--------------------------------------------
clean-local:
	rm -rf $(srcdir)/man/build/ $(srcdir)/doc/build/ \
	  $(srcdir)/.firstbuild $(dir $(DAPS_CATALOG)) $(srcdir)/bin/daps \
	  $(srcdir)/etc/config $(srcdir)/etc/fop/fop-daps.xml \
	  $(srcdir)/doc/xml/entity-decl.ent
	(cd $(srcdir)/etc && ln -sf config.in config)
	(cd $(srcdir)/bin && ln -sf daps.in daps)
	(cd $(srcdir)/autobuild && ln -sf daps_autobuild.in daps_autobuild)
	(cd $(srcdir)/etc/fop && ln -sf fop-daps.suse fop-daps.xml)
	(cd doc/xml && ln -sf entity-decl.ent.in entity-decl.ent)

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
	$(Q)$(XMLCATALOG) --noout --add "rewriteSystem" \
	  "http://daps.sourceforge.net/release/daps-xsl/current/" \
	  "file://$(pkgdatadir)/daps-xslt/" $@
	$(Q)$(XMLCATALOG) --noout --add "rewriteSystem" \
	  "https://opensuse.github.io/daps/release/daps-xsl/current/" \
	  "file://$(pkgdatadir)/daps-xslt/" $@
	$(Q)$(SED) -i '/^<!DOCTYPE .*>$$/d' $@
	$(Q)$(SED) -i '/<catalog/a\ <group id="$(PACKAGE)">' $@
	$(Q)$(SED) -i '/<\/catalog/i\ </group>' $@
	$(Q)$(srcdir)/bin/ccecho "result" "Created $@"

# the SVN sources contain links bin/daps, etc/config and $(FOP_CONFIG)
# These need to be replaced by real files/different links created by
# the respective targets below.
# To make sure they are rebuild at least once when make is called for
# the first time, we make them depend on a file we create first
# This file will be newer than the existing links and thus the targets
# will be rebuild.
# This helps to avoid PHONY targets which would be called with every single
# make call (even make clean) - something we definetely would like to avoid

.firstbuild:
	touch $@

# see http://www.gnu.org/software/autoconf/manual/autoconf.html#Installation-Directory-Variables
bin/daps: .firstbuild
	if [ -L $@ ]; then rm -f $@; fi
	$(REPL_PATH) $@.in > $@
	chmod +x $@

etc/config: .firstbuild
	if [ -L $@ ]; then rm -f $@; fi
	$(REPL_PATH) $@.in > $@

autobuild/daps_autobuild: .firstbuild
	if [ -L $@ ]; then rm -f $@; fi
	$(REPL_PATH) $@.in > $@
	chmod +x $@

# Create the FOP config file. RedHat and SUSE require a special version
# (see FOP_CONFIG_SRC definitions above)
$(FOP_CONFIG): $(FOP_CONFIG_SRC) $(FOP_CONFIG_DEFAULT) .firstbuild
	if test -n "$(FOP_CONFIG_SRC)"; then \
	  ln -sf $(notdir $(FOP_CONFIG_SRC)) $@; \
	else \
	  ln -sf $(notdir $(FOP_CONFIG_DEFAULT)) $@; \
	fi

$(USERGUIDE):
	$(Q)bin/daps $(DEBUG) --dapsroot=$(DAPSROOT) --styleroot=$(STYLEROOT) \
	    --docconfig=$(DC_USERGUIDE) html --single --name=$(USERGUIDE_NAME)
	$(Q)$(srcdir)/bin/ccecho "result" "Created $@"

$(QUICKSTART):
	$(Q)bin/daps $(DEBUG) --dapsroot=$(DAPSROOT)  --styleroot=$(STYLEROOT) \
	    --docconfig=$(DC_QUICKSTART) html --single --name=$(QUICKSTART_NAME)
	$(Q)$(srcdir)/bin/ccecho "result" "Created $@"

# Generate man pages on the fly
$(dist_man1_MANS):
	$(Q)bin/daps $(DEBUG) --dapsroot=$(DAPSROOT) --color=0 \
	  --docconfig=$(DAPSROOT)/man/$(DC_MANPAGES) man --nogzip
	$(Q)$(srcdir)/bin/ccecho "result" "Created man pages $@"
