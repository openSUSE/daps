#
# spec file for package daps
#
# Copyright (c) 2011 SUSE LINUX Products GmbH, Nuernberg, Germany.
# This file and all modifications and additions to the pristine
# package are under the same license as the package itself.
#
# Please submit bugfixes or comments via http://bugs.opensuse.org/
#
#
# norootforbuild
%define dtdversion     1.0
%define dtdname        novdoc
%define docbuilddir    %{_datadir}/daps
%define regcat         %{_bindir}/sgml-register-catalog
%define fontdir        %{_datadir}/fonts/truetype
%define dbstyles       %{_datadir}/xml/docbook/stylesheet/nwalsh/current

Name:           daps
Version:        0.9beta1
%define root_catalog   for-catalog-%{dtdname}-%{dtdversion}.xml
%define daps_catalog   for-catalog-%{name}-%{version}.xml

Release:        1
Summary:        DocBook Authoring and Publishing Suite
License:        GPL
Group:          Productivity/Publishing/XML
URL:            http://svn.berlios.de/viewvc/opensuse-doc/trunk/tools/daps/
Source0:        %{name}-%{version}.tar.bz2
Source1:        %{name}.rpmlintrc
BuildRoot:      %{_tmppath}/%{name}-%{version}-build
BuildArch:      noarch

BuildRequires:  dia
BuildRequires:  docbook_4
BuildRequires:  docbook-xsl-stylesheets >= 1.75
BuildRequires:  exiftool
BuildRequires:  fam
BuildRequires:  fdupes
BuildRequires:  ImageMagick
BuildRequires:  inkscape
BuildRequires:  libxslt
BuildRequires:  optipng
BuildRequires:  python-xml
BuildRequires:  sgml-skel
BuildRequires:  svg-dtd
BuildRequires:  trang
BuildRequires:  transfig
BuildRequires:  unzip
BuildRequires:  xorg-x11-devel

# the following requirements are not really needed for building, but we add
# them nevertheless in order to see if the build target is able to fullfill
# the requirements for installation
BuildRequires:  dejavu
BuildRequires:  freefont
BuildRequires:  java
BuildRequires:  liberation-fonts
BuildRequires:  LinuxLibertine
BuildRequires:  mplus-fonts
BuildRequires:  python-optcomplete
BuildRequires:  opensp
BuildRequires:  subversion
BuildRequires:  xalan-j2
BuildRequires:  xml-commons-resolver
BuildRequires:  xmlformat
BuildRequires:  xmlstarlet
BuildRequires:  zip
%if %{suse_version} < 1140
BuildRequires:  checkbot
BuildRequires:  fop >= 0.94
BuildRequires:  xerces-j2
BuildRequires:  xml-commons-jaxp-1.3-apis
%else
BuildRequires:  perl-checkbot
BuildRequires:  xmlgraphics-fop >= 0.94
%endif

PreReq:         libxml2
PreReq:         sgml-skel

Requires:       dejavu
Requires:       dia
Requires:       docbook_4
Requires:       docbook-xsl-stylesheets >= 1.75
Requires:       exiftool
Requires:       freefont
Requires:       ImageMagick
Requires:       inkscape
Requires:       java
Requires:       libxslt
Requires:       liberation-fonts
Requires:       LinuxLibertine
Requires:       make
Requires:       mplus-fonts
Requires:       python-optcomplete
Requires:       opensp
Requires:       optipng
Requires:       python-xml
Requires:       sgml-skel
Requires:       subversion
Requires:       svg-dtd
Requires:       transfig
Requires:       unzip
Requires:       xalan-j2
Requires:       xml-commons-resolver
Requires:       xmlformat
Requires:       xmlstarlet
Requires:       zip
%if %{suse_version} < 1140
Requires:       checkbot
Requires:       fop >= 0.94
Requires:       xerces-j2
Requires:       xml-commons-jaxp-1.3-apis
%else
Requires:       xmlgraphics-fop >= 0.94
Requires:       perl-checkbot
%endif

Recommends:     agfa-fonts
Recommends:     emacs psgml
# Split of ttf-founder-simplified and ttf-founder-traditional
Recommends:     FZFangSong FZHeiTi FZSongTi
Recommends:     fifth-leg-font
Recommends:     remake
# Japanese Fonts:
Recommends:     sazanami-fonts
# Chinese
Recommends:     ttf-arphic
# Korean Fonts:
Recommends:     unfonts
# Internal XEP package:
Recommends:     xep

Provides:       susedoc


%description
DocBook Authoring and Publishing Suite (daps)

daps contains a set of stylesheets, scripts and makefiles that enable
you to create HTML, PDF, EPUB and other formats from DocBook XML with a
single command. It also contains tools to generate profiled source
tarballs for distributing your XML sources for translation or review.

daps also includes tools that assist you when writing DocBook XML:
linkchecker, validator, spellchecker, editor macros and stylesheets for
converting DocBook XML.

daps is the successor of susedoc. See
/usr/share/doc/packages/daps/README.upgrade_from_susedoc_4.x
for upgrade instructions.


Authors:
--------
    Frank Sundermeyer <fsundermeyer AT suse DOT de>
    Thomas Schraitle  <toms AT suse DOT de>
    Berthold Gunreben
    Curtis Graham
    Berthold Gunreben
    Jana Jaeger

#--------------------------------------------------------------------------
%prep
%setup -q -n %{name}
#%%patch1 -p1

#--------------------------------------------------------------------------
%build
# specifying VERSION is manadatory!! 
%__make VERSION=%{version}

#--------------------------------------------------------------------------
%install
# specifying VERSION is manadatory!! 
%make_install VERSION=%{version}

# create symlinks:
%fdupes -s $RPM_BUILD_ROOT/%{_datadir}

#----------------------
%post
# SGM CATALOG
#
if [ -x %{regcat} ]; then
  for CATALOG in CATALOG.%{dtdname}-%{dtdversion}; do
    %{regcat} -a %{_datadir}/sgml/$CATALOG >/dev/null 2>&1 || true
  done
fi
# XML Catalog
#
# remove existing entries first (if existing) - needed for
# zypper in, since it does not call postun
#
# The first two ones are only there for campatibility reasons and
# can be removed in the future
#
edit-xml-catalog --group --catalog /etc/xml/suse-catalog.xml \
  --del %{dtdname}-%{version}
edit-xml-catalog --group --catalog /etc/xml/suse-catalog.xml \
  --del %{dtdname}xslt-%{version}
#
# These two entries need to stay
edit-xml-catalog --group --catalog /etc/xml/suse-catalog.xml \
  --del %{dtdname}-%{dtdversion}
edit-xml-catalog --group --catalog /etc/xml/suse-catalog.xml \
  --del %{name}-%{version}
#
# now add new entries
edit-xml-catalog --group --catalog /etc/xml/suse-catalog.xml \
  --add /etc/xml/%{root_catalog}
edit-xml-catalog --group --catalog /etc/xml/suse-catalog.xml \
  --add /etc/xml/%{daps_catalog}

%run_suseconfig_fonts
exit 0

#----------------------
%postun
if [ ! -f %{_sysconfdir}/xml/%{root_catalog} -a -x /usr/bin/edit-xml-catalog ] ; then
  for c in CATALOG.%{dtdname}-%{dtdversion}; do
    %{regcat} -r %{_datadir}/sgml/$c >/dev/null 2>&1
  done
# XML Catalog
#
# The first two ones are only there for campatibility reasons and
# can be removed in the future
#
edit-xml-catalog --group --catalog /etc/xml/suse-catalog.xml \
  --del %{dtdname}-%{version}
edit-xml-catalog --group --catalog /etc/xml/suse-catalog.xml \
  --del %{dtdname}xslt-%{version}
#
# These two entries need to stay
edit-xml-catalog --group --catalog /etc/xml/suse-catalog.xml \
  --del %{dtdname}-%{dtdversion}
edit-xml-catalog --group --catalog /etc/xml/suse-catalog.xml \
  --del %{name}-%{version}
fi

%run_suseconfig_fonts
exit 0


#----------------------
%clean
%__make clean
%{__rm} -rf $RPM_BUILD_ROOT


#----------------------
%files
%defattr(-,root,root)

%dir %{fontdir}
%dir %{_sysconfdir}/%{name}
%dir %{_datadir}/xml/%{dtdname}
%dir %{_datadir}/xml/%{dtdname}/schema
%dir %{_datadir}/xml/%{dtdname}/schema/*
%dir %{_datadir}/xml/%{dtdname}/schema/*/1.0
%dir %{_defaultdocdir}/%{name}

%config /var/lib/sgml/CATALOG.*
%config %{_sysconfdir}/xml/*.xml
%config %{_sysconfdir}/%{name}/*

%doc %{_mandir}/man1/*.1.gz
%doc %{_defaultdocdir}/%{name}/*

%{_bindir}/*
%{_datadir}/sgml/CATALOG.*
%{_datadir}/emacs/site-lisp/docbook_macros.el
%{fontdir}/*
%{docbuilddir}
%{_datadir}/xml/%{dtdname}/schema/dtd/%{dtdversion}/*
%{_datadir}/xml/%{dtdname}/schema/rng/%{dtdversion}/*

#----------------------
%changelog
