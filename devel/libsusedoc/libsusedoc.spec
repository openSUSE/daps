#
# spec file for package libsusedoc (Version 0.1)
#
# Copyright (c) 2011 SUSE LINUX Products GmbH, Nuernberg, Germany.
# This file and all modifications and additions to the pristine
# package are under the same license as the package itself.
#
# Please submit bugfixes or comments via http://bugs.opensuse.org/
#

# norootforbuild


Name:           libsusedoc
Url:            svn://svn.berlios.de/svnroot/repos/opensuse-doc/trunk/tools/docmaker/lib/libsusedoc
License:        GPL-2 or GPL-3
Group:          Development/Tools/Other
AutoReqProv:    on
Version:        0.08
Release:        1
Summary:        Library modules for the susedoc build mechanics
Source:         http://svn.berlios.de/viewvc/opensuse-doc/trunk/tools/docmaker/lib/libsusedoc/dist/%{name}-%{version}.tar.bz2
BuildRoot:      %{_tmppath}/%{name}-%{version}-build
BuildArch:	noarch

%description
Library modules for the susedoc build mechanics. 
This contains re-usable code blocks extractedfrom the susedoc Makefiles.

Authors:
--------
    Juergen Weigert <jw@suse.de>

%prep
%setup

%build

%install
make install DESTDIR=$RPM_BUILD_ROOT/usr

%clean
rm -rf $RPM_BUILD_ROOT

%files
%defattr(-,root,root)   
/usr/bin/*
/usr/share/*

%changelog
