#
# spec file for package daps
#
# Copyright (c) 2026 SUSE LLC and contributors
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


%define pkg_version 4.0beta15
%define docbuilddir %{_datadir}/daps
%define ourpython %{?primary_python}%{!?primary_python:python3}
Name:           daps
Version:        4.0beta15
Release:        0
Summary:        DocBook Authoring and Publishing Suite
License:        GPL-2.0-only OR GPL-3.0-only
Group:          Productivity/Publishing/XML
URL:            https://github.com/openSUSE/daps
Source0:        %{name}-%{pkg_version}.tar.bz2
Source1:        %{name}.rpmlintrc
BuildRequires:  %{ourpython}-base
BuildRequires:  %{ourpython}-lxml
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
BuildRequires:  suse-xsl-stylesheets
BuildRequires:  svg-dtd
BuildRequires:  xerces-j2
BuildRequires:  xml-apis
BuildRequires:  xmlgraphics-fop >= 0.94
BuildRequires:  xmlstarlet
BuildRequires:  rubygem(%{rb_default_ruby_abi}:asciidoctor)
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
Requires:       suse-xsl-stylesheets
Requires:       svg-schema
Requires:       xerces-j2
Requires:       xml-apis
Requires:       xmlgraphics-fop >= 0.94
Requires:       xmlstarlet
Requires:       zip
Requires:       rubygem(%{rb_default_ruby_abi}:asciidoctor)
# FIXME: use proper Requires(pre/post/preun/...)
# In order to keep the requirements list as short as possible, only packages
# needed to build EPUB, HTML and PDF are really required
# All other packages required for editing or more exotic output formats
# are recommended rather than required
PreReq:         libxml2
PreReq:         sgml-skel
Recommends:     aspell-en
Recommends:     calibre
Recommends:     ditaa
Recommends:     epubcheck
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
BuildArch:      noarch
%if 0%{?suse_version} >= 1600
BuildRequires:  rsvg-convert
%else
BuildRequires:  inkscape
%endif
%if 0%{?suse_version} >= 1600
Requires:       rsvg-convert
%else
Requires:       inkscape
%endif
%ifarch aarch64 %{ix86} x86_64
Recommends:     libreoffice-draw
%endif

%description
DocBook Authoring and Publishing Suite (DAPS)

DAPS contains a set of stylesheets, scripts and makefiles that enable
you to create HTML, PDF, EPUB and other formats from DocBook XML with a
single command. It also contains tools to generate profiled source
tarballs for distributing your XML sources for translation or review.

DAPS also includes tools that assist you when writing DocBook XML:
validator, link checker, spellchecker, editor macros and stylesheets for
converting DocBook XML.

%prep
%setup -q -n %{name}-%{pkg_version}

# Use the versioned primary Python interpreter in executable scripts.
%python3_fix_shebang_path libexec/daps-xmlwellformed
%python3_fix_shebang_path libexec/getentityname.py
%python3_fix_shebang_path libexec/validate-tables.py
%python3_fix_shebang_path python-scripts/daps-xmlwellformed/bin/daps-xmlwellformed
%python3_fix_shebang_path python-scripts/getentityname/bin/getentityname.py
%python3_fix_shebang_path python-scripts/validate-tables/bin/validate-tables.py

%build
%configure --docdir=%{_defaultdocdir}/%{name} --disable-edit-rootcatalog
%make_build

%install
%make_install
rm -v %{buildroot}%{_defaultdocdir}/%{name}/{COPYING*,INSTALL.adoc}

# create symlinks:
%fdupes -s %{buildroot}/%{_datadir} %{buildroot}/%{_sysconfdir}/%{name}

%if 0%{?suse_version} >= 1550
%python3_fix_shebang_path %{buildroot}%{_datadir}/%{name}/libexec/*
%endif

%post
update-xml-catalog
exit 0

%postun
update-xml-catalog
exit 0

%posttrans

%files
%doc BUGS README* html
%license COPYING*

# Catalogs
%config %{_sysconfdir}/xml/catalog.d/%{name}.xml

# Config files
%config %{_sysconfdir}/%{name}

# Man/Doc
%{_mandir}/man1/*.1%{?ext_man}

%{_bindir}/ccecho
%{_bindir}/daps
%{_bindir}/daps-autobuild
%{_bindir}/daps-check-deps
%{_bindir}/daps-init
%{_bindir}/daps-xmlformat
%{_datadir}/bash-completion/completions/%{name}
%{_datadir}/emacs/site-lisp/docbook_macros.el
%{_datadir}/xml/daps
%{docbuilddir}

%changelog
