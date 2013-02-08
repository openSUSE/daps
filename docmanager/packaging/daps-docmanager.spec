#
# spec file for package daps-docmanager
#
# Copyright (c) 2011 SUSE LINUX Products GmbH, Nuernberg, Germany.
# This file and all modifications and additions to the pristine
# package are under the same license as the package itself.
#
# Please submit bugfixes or comments via http://bugs.opensuse.org/
#
#

%{!?python_sitelib:  %global python_sitelib  %(%{__python} -c "from distutils.sysconfig import get_python_lib; print(get_python_lib())")}
%{!?python_sitearch: %global python_sitearch %(%{__python} -c "from distutils.sysconfig import get_python_lib; print(get_python_lib(1))")}

Summary:      Manages Doc Files through SVN Properties
Name:         daps-docmanager
Version:      1.0.1
Release:      0 
Source0:      %{name}-%{version}.tar.bz2
Source1:      %{name}-rpmlintrc
License:      LGPL
Group:        Development/Libraries/Python
Url:          https://svn.berlios.de/svnroot/repos/opensuse-doc/trunk/tools/daps/docmanager
BuildRoot:    %{_tmppath}/%{name}-%{version}-%{release}-buildroot
%if 0%{?suse_version} >= 1120
BuildArch:               noarch
%endif
BuildRequires: python-setuptools
BuildRequires: python-devel
BuildRequires: libxml2 libxslt
BuildRequires: docbook-xsl-stylesheets
BuildRequires: python-optcomplete
BuildRequires: python-lxml
# BuildRequires: daps
# For testcases
# BuildRequires: subversion
# BuildRequires: python-virtualenv
# BuildRequires: python-nose
# BuildRequires: python-unittest2

#-----------------------------------
Requires:      daps
Requires:      python-optcomplete
Requires:      python-lxml
Requires:      subversion
%py_requires


%description
Docmanager is a command line tool for managing documentation
projects in SVN that are based on Novdoc or DocBook 4.x.
Preferably, use Docmanager in conjunction with daps (DocBook Authoring
and Publishing Suite). 

Docmanager allows you to view or set doc-related properties to
files in SVN, such as the properties "doc:status", "doc:maintainer",
"doc:trans", "doc:deadline", or "doc:priority". They are especially
helpful for managing larger documentation projects with multiple
authors (maintainers), deadlines and priorities.
 
The "doc:status" property reflects the workflow status of each file.
The status can change several times throughout the documentation
process. Whereas the initial state of each file is usually "editing", a
proofreader can search for all files of a project that are already set
to "edited", can set them to "proofing" and to "proofed" afterwards (or
to the status "comments" if the author needs to check some of the
proofreader's remarks in the file). With the "doc:trans" property you
can keep track of the files that need to be translated. 

Author
------
  Thomas Schraitle <toms@opensuse.org>


%prep
%setup -n %{name}

%build
python setup.py build

DB=$(xmlcatalog /etc/xml/catalog http://docbook.sourceforge.net/release/xsl/current/manpages/docbook.xsl)
xsltproc --stringparam man.output.base.dir 'doc/' \
         --stringparam man.output.subdirs.enabled 0 \
         --stringparam man.output.in.separate.dir 1 \
         $DB doc/docmanager.xml

%install
python setup.py install \
    --prefix="%{_prefix}" \
    --root="%{buildroot}" \
    --record-rpm=INSTALLED_FILES
mkdir -p $RPM_BUILD_ROOT%_mandir/man1
cp doc/*.1 $RPM_BUILD_ROOT%_mandir/man1

pushd $RPM_BUILD_ROOT%_mandir/man1
ln -s docmanager.1.gz dm.1.gz
popd


# %%check
# ./init-env.sh --rootdir $RPM_BUILD_ROOT
# source env/bin/activate
# env/bin/python setup.py install 
# nosetests -vv


%clean
rm -rf $RPM_BUILD_ROOT

%files -f INSTALLED_FILES
%defattr(-,root,root)
%_mandir/man1/*


%changelog
