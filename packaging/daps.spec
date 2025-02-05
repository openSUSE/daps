#
# spec file for package daps
#
# Copyright (c) 2024 SUSE LLC
#
# All modifications and additions to the file contributed by third parties
# remain the property of their copyright owners, unless otherwise agreed
# upon. The license for this file, and modifications and additions to the
# file, is the same license as for the pristine package itself (unless the
# license for the pristine package is not an Open Source License, in which
# case the license is the MIT License). An "Open Source License" is a
# license that conforms to the Open Source Definition (Version 1.9)
# published by the Open Source Initiative.

# Please submit bugfixes or comments via https://bugs.opensuse.org/
#


Name:           daps
Version:        4.0~beta7
Release:        0

%define pkg_version 4.0beta7
%define docbuilddir %{_datadir}/daps

Summary:        DocBook Authoring and Publishing Suite
License:        GPL-2.0-only OR GPL-3.0-only
Group:          Productivity/Publishing/XML
URL:            https://github.com/openSUSE/daps
Source0:        %{name}-%{pkg_version}.tar.bz2
Source1:        %{name}.rpmlintrc
BuildRoot:      %{_tmppath}/%{name}-%{pkg_version}-build

BuildArch:      noarch

BuildRequires:  ImageMagick
BuildRequires:  automake
BuildRequires:  bash >= 4
BuildRequires:  dia
BuildRequires:  docbook-xsl-stylesheets >= 1.77
BuildRequires:  docbook_4
BuildRequires:  docbook_5
BuildRequires:  fdupes
BuildRequires:  jing
BuildRequires:  libxml2-tools
BuildRequires:  libxslt
BuildRequires:  libxslt-tools
BuildRequires:  python3-lxml
%if 0%{?suse_version} >= 1600
BuildRequires:  rsvg-convert
%else
BuildRequires:  inkscape
%endif
BuildRequires:  suse-xsl-stylesheets
BuildRequires:  svg-dtd
BuildRequires:  xerces-j2
BuildRequires:  xml-apis
BuildRequires:  xmlgraphics-fop >= 0.94
BuildRequires:  xmlstarlet
BuildRequires:  rubygem(%{rb_default_ruby_abi}:asciidoctor)

# In order to keep the requirements list as short as possible, only packages
# needed to build EPUB, HTML and PDF are really required
# All other packages required for editing or more exotic output formats
# are recommended rather than required

PreReq:         libxml2
PreReq:         sgml-skel

Requires:       ImageMagick
Requires:       bash >= 4
Requires:       dia
Requires:       docbook-xsl-stylesheets >= 1.77
Requires:       docbook5-xsl-stylesheets >= 1.77
Requires:       docbook_4
Requires:       docbook_5
Requires:       java >= 1.8.0
Requires:       jing
Requires:       libxslt
Requires:       make
Requires:       python3-lxml
%if 0%{?suse_version} >= 1600
Requires:  rsvg-convert
%else
Requires:  inkscape
%endif
Requires:       suse-xsl-stylesheets
Requires:       svg-schema
Requires:       xerces-j2
Requires:       xml-apis
Requires:       xmlgraphics-fop >= 0.94
Requires:       xmlstarlet
Requires:       zip
Requires:       rubygem(%{rb_default_ruby_abi}:asciidoctor)

Recommends:     aspell-en
Recommends:     calibre
Recommends:     ditaa
Recommends:     epubcheck
%ifarch aarch64 %{ix86} x86_64
Recommends:     libreoffice-draw
%endif
Recommends:     optipng
Recommends:     perl-checkbot
Recommends:     poppler-tools
Recommends:     remake
Recommends:     suse-doc-style-checker
Recommends:     suse-documentation-dicts-en
Recommends:     w3m
Recommends:     xmlformat

# Internal XEP package:
Suggests:       xep

%description
DocBook Authoring and Publishing Suite (DAPS)

DAPS contains a set of stylesheets, scripts and makefiles that enable
you to create HTML, PDF, EPUB and other formats from DocBook XML with a
single command. It also contains tools to generate profiled source
tarballs for distributing your XML sources for translation or review.

DAPS also includes tools that assist you when writing DocBook XML:
validator, link checker, spellchecker, editor macros and stylesheets for
converting DocBook XML.














#--------------------------------------------------------------------------

%prep
%setup -q -n %{name}-%{pkg_version}

# Correct shebang line as suggested in
# https://lists.opensuse.org/opensuse-packaging/2018-03/msg00017.html
sed -i '1 s|/usr/bin/env python|/usr/bin/python|' libexec/daps-xmlwellformed \
  libexec/getentityname.py \
  libexec/validate-tables.py

#--------------------------------------------------------------------------
%build
%configure --docdir=%{_defaultdocdir}/%{name} --disable-edit-rootcatalog
%__make %{?_smp_mflags}

#--------------------------------------------------------------------------
%install
make install DESTDIR=$RPM_BUILD_ROOT

# create symlinks:
%fdupes -s $RPM_BUILD_ROOT/%{_datadir}

%if 0%{?suse_version} >= 1550
%python3_fix_shebang_path %{buildroot}%{_datadir}/%{name}/libexec/*
%endif

#----------------------
%post
update-xml-catalog
exit 0

#----------------------
%postun
update-xml-catalog
exit 0

#----------------------
%posttrans

#----------------------
%files
%defattr(-,root,root)

%dir %{_datadir}/%{name}
%dir %{_sysconfdir}/%{name}
%dir %{_defaultdocdir}/%{name}

%dir %{_datadir}/bash-completion
%dir %{_datadir}/bash-completion/completions
%dir %{_datadir}/%{name}
%dir %{_datadir}/xml/%{name}
%dir %{_datadir}/xml/%{name}/schema

# Catalogs
%config %{_sysconfdir}/xml/catalog.d/%{name}.xml

# Config files
%config %{_sysconfdir}/%{name}/*

# Man/Doc
%doc %{_mandir}/man1/*.1%{ext_man}
%doc %{_defaultdocdir}/%{name}/*

%{_bindir}/*
%{_datadir}/bash-completion/completions/%{name}
%{_datadir}/emacs/site-lisp/docbook_macros.el
%{_datadir}/xml/daps/schema/*
%{docbuilddir}
#----------------------

%changelog
