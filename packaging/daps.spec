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


%define pkg_version 4.0beta16
%define ourpython %{?primary_python}%{!?primary_python:python3}

Name:           daps
Version:        4.0~beta16
Release:        0
Summary:        DocBook Authoring and Publishing Suite
License:        GPL-2.0-only OR GPL-3.0-only
Group:          Productivity/Publishing/XML
URL:            https://github.com/openSUSE/daps
Source0:        %{name}-%{pkg_version}.tar.bz2
BuildArch:      noarch
BuildRequires:  %{ourpython}-base
BuildRequires:  %{ourpython}-lxml
BuildRequires:  ImageMagick
BuildRequires:  dia
BuildRequires:  docbook-xsl-stylesheets >= 1.77
BuildRequires:  docbook_4
BuildRequires:  fdupes
BuildRequires:  jing
BuildRequires:  libxml2-tools
BuildRequires:  libxslt-tools
BuildRequires:  sgml-skel
BuildRequires:  suse-xsl-stylesheets
BuildRequires:  svg-dtd
BuildRequires:  xmlgraphics-fop >= 0.94
BuildRequires:  xmlstarlet
BuildRequires:  rubygem(%{rb_default_ruby_abi}:asciidoctor)

%if 0%{?suse_version} >= 1600
BuildRequires:  rsvg-convert
%else
BuildRequires:  inkscape
%endif

# In order to keep the requirements list as short as possible, only packages
# needed to build EPUB, HTML and PDF are really required
# All other packages required for editing or more exotic output formats
# are recommended rather than required

Requires:       %{ourpython}-base
Requires:       %{ourpython}-lxml
Requires:       ImageMagick
Requires:       docbook-xsl-stylesheets >= 1.77
Requires:       docbook5-xsl-stylesheets >= 1.77
Requires:       docbook_4
Requires:       docbook_5
Requires:       java >= 1.8.0
Requires:       jing
Requires:       (remake or make)
# Prefer rsvg-convert if available
Requires:       (rsvg-convert or inkscape)
Requires:       suse-xsl-stylesheets
Requires:       svg-dtd
Requires:       svg-schema
Requires:       xmlgraphics-fop >= 0.94
Requires:       xmlstarlet
Requires:       zip
Requires:       rubygem(%{rb_default_ruby_abi}:asciidoctor)
Requires(post): sgml-skel

Recommends:     calibre
Recommends:     dia
Recommends:     libreoffice-draw
Recommends:     optipng
Recommends:     poppler-tools
Recommends:     w3m
Recommends:     xmlformat
Recommends:     (aspell-en or hunspell)

# Only in the Documentation:Tools project
Recommends:     ditaa
Recommends:     epubcheck
Recommends:     perl-checkbot
Recommends:     suse-documentation-dicts-en

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
%autosetup -n %{name}-%{pkg_version}

%build
%configure --docdir=%{_defaultdocdir}/%{name} --disable-edit-rootcatalog
%make_build

%install
%make_install
rm -v %{buildroot}%{_defaultdocdir}/%{name}/{COPYING*,INSTALL.adoc}

%python3_fix_shebang_path %{buildroot}/%{_datadir}/%{name}/libexec/*

# create symlinks:
%fdupes %{buildroot}/%{_datadir}
%fdupes -s %{buildroot}/%{_sysconfdir}

%post
update-xml-catalog || :

%postun
update-xml-catalog || :

%files
%doc BUGS README* html
%license COPYING*

%config %{_sysconfdir}/%{name}
%config %{_sysconfdir}/xml/catalog.d/%{name}.xml

%{_bindir}/ccecho
%{_bindir}/daps
%{_bindir}/daps-autobuild
%{_bindir}/daps-check-deps
%{_bindir}/daps-init
%{_bindir}/daps-xmlformat

%{_datadir}/bash-completion/completions/%{name}
%{_datadir}/emacs/site-lisp/docbook_macros.el
%{_datadir}/%{name}
%{_datadir}/xml/%{name}

%{_mandir}/man1/*.1%{?ext_man}

%changelog
