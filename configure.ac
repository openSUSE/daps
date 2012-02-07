dnl                                               -*- Autoconf -*-
dnl Process this file with autoconf to produce a configure script or use autogen.sh
dnl
dnl Authors:
dnl   Thomas Schraitle  <toms@opensuse.org>
dnl   Frank Sundermeyer <fs@suse.de>

m4_define(daps_version_major, 0)
m4_define(daps_version_minor, 9)
m4_define(daps_version_micro, 9dev)

AC_PREREQ([2.68])
AC_INIT([daps], [0.9.2], [fs@suse.de, toms@suse.de], [daps], [http://daps.sf.net])
AC_CONFIG_MACRO_DIR([m4])


AC_MSG_NOTICE([

 Configuring DAPS, the DocBook Authoring and Publishing Suite...

])

AC_CONFIG_SRCDIR([Makefile.am])
# Turn on all warnings, report warnings as errors:
AM_INIT_AUTOMAKE([1.10 no-define -Wall -Werror])


AC_CONFIG_FILES([
Makefile
])

# Command-line arguments
## AC_ARG_WITH(stuff, [  --with-stuff            enable stuff])

AC_PREFIX_DEFAULT(/usr)

# Some constants
CATALOG_FILE="/etc/xml/catalog"
DB_XSLT_URL="http://docbook.sourceforge.net/release/xsl/current/"
FONT_DIR="/usr/share/fonts"

# Checks for programs.
AC_PROG_MKDIR_P
AC_PROG_LN_S
AC_PROG_SED
AC_PROG_GREP
AC_PROG_INSTALL


AC_PATH_PROG(PERL, [perl] )
if test -z "$PERL"; then
  HAVE_PERL='no'
else
  HAVE_PERL='yes'
fi
AC_SUBST(HAVE_PERL)


dnl We require Python >= 2.6
AM_PATH_PYTHON([2.6])


AC_PATH_PROG([INKSCAPE], [inkscape] )
if test -z "$INKSCAPE"; then
  HAVE_INKSCAPE='no'
else
  HAVE_INKSCAPE='yes'
fi
AC_SUBST(HAVE_INKSCAPE)


AC_PATH_PROG([OPTIPNG], [optipng] )
if test -z "$OPTIPNG"; then
  HAVE_OPTIPNG='no'
else
  HAVE_OPTIPNG='yes'
fi
AC_SUBST(HAVE_OPTIPNG)


AC_PATH_PROG([TRANSFIG], [transfig] )
if test -z "$TRANSFIG"; then
  HAVE_TRANSFIG='no'
else
  HAVE_TRANSFIG='yes'
fi
AC_SUBST(HAVE_TRANSFIG)

AC_PATH_PROG([XMLLINT], [xmllint])
if test -z "$XMLLINT"; then
   AC_MSG_ERROR([xmllint not found])
fi

AC_PATH_PROG([EXIFTOOL], [exiftool])
if test -z "$"; then
   AC_MSG_ERROR([exiftool not found]) 
fi


# (files, [action-if-found], [action-if-not-found])
# AC_CHECK_FILES

AC_MSG_NOTICE([===== Checking for XML tools... ])

# Syntax: AC_PATH_PROG([VARIABLE], [binary])
AC_PATH_PROG([XMLLINT], [xmllint])
if test -z "$XMLLINT"; then
   AC_MSG_ERROR([xmllint not found])
fi

AC_PATH_PROG([XSLTPROC], [xsltproc])
if test -z "$XSLTPROC"; then
   AC_MSG_ERROR([xsltproc not found]) 
fi

AC_PATH_PROG([XMLCATALOG], [xmlcatalog])
if test -z "$XMLCATALOG"; then
   AC_MSG_ERROR([xmlcatalog not found]) 
fi

AC_PATH_PROG([FOP], [fop])
if test -z "$FOP"; then
   AC_MSG_ERROR([fop not found]) 
fi

AC_PATH_PROG([TRANG], [trang] )
if test -z "$TRANG"; then
  AC_MSG_ERROR([trang not found]) 
fi

AC_PATH_PROG([JING], [jing] )
if test -z "$JING"; then
  AC_MSG_ERROR([jing not found]) 
fi

AC_CHECK_FILE([${CATALOG_FILE}], [CATALOG=yes], [CATALOG=no])
if test -z "$CATALOG"; then
  AC_MSG_ERROR([Catalog ${CATALOG_FILE} not found])
fi

AC_PATH_PROG([XMLSTARLET], [xml])
if test -z "$XMLSTARLET"; then
   AC_MSG_WARN([xmlstarlet (xml) not found]) 
fi

AC_PATH_PROG([XMLFORMAT], [xmlformat])
if test -z "$XMLFORMAT"; then
   AC_PATH_PROG([XMLFORMAT], [xmlformat.pl])
   if test -z "$XMLFORMAT"; then
     AC_MSG_WARN([xmlformat not found]) 
   fi
fi

AC_MSG_NOTICE([===== Checking for Python modules...])
# Variables HAVE_PYMOD_* are filled with "yes" or "no"
AC_PYTHON_MODULE([lxml], [fatal])
AC_SUBST(HAVE_PYMOD_LXML)
AC_PYTHON_MODULE([optparse], [fatal])
AC_SUBST(HAVE_PYMOD_OPTPARSE)


AC_MSG_NOTICE([===== Checking for Public Identifiers...])

DOCBOOKDTDS=""
for XML_DTD in "-//OASIS//DTD DocBook XML V4.1.2//EN" \
               "-//OASIS//DTD DocBook XML V4.2//EN" \
               "-//OASIS//DTD DocBook XML V4.3//EN" \
               "-//OASIS//DTD DocBook XML V4.4//EN" \
               "-//OASIS//DTD DocBook XML V4.5//EN" ; do
  AC_MSG_CHECKING([for $XML_DTD])
  if AC_RUN_LOG([$XMLCATALOG --noout "${CATALOG_FILE}" "$XML_DTD" >&2]); then
    AC_MSG_RESULT([found])
    ## Extract version from public identifier
    x=${XML_DTD##*XML V}    
    DOCBOOKDTDS="$DOCBOOKDTDS${x%%//*} "
  else
    AC_MSG_WARN([not found])
  fi
done
AC_SUBST(DOCBOOKDTDS)


AC_MSG_NOTICE([===== Checking for System Identifier...])

for XML_DTD in "http://www.oasis-open.org/docbook/xml/4.1.2/docbookx.dtd" \
               "http://www.oasis-open.org/docbook/xml/4.2/docbookx.dtd" \
               "http://www.oasis-open.org/docbook/xml/4.3/docbookx.dtd" \
               "http://www.oasis-open.org/docbook/xml/4.4/docbookx.dtd" \
               "http://www.oasis-open.org/docbook/xml/4.5/docbookx.dtd" ; do
  AC_MSG_CHECKING([for $XML_DTD])
  if AC_RUN_LOG([$XMLCATALOG --noout "${CATALOG_FILE}" "$XML_DTD" >&2]); then
    AC_MSG_RESULT([found])
  else
    AC_MSG_WARN([not found])
  fi
done

AC_MSG_NOTICE([===== Checking for Canonical URL (DocBook XSL Stylesheets)...])

for XSLT in "${DB_XSLT_URL}xhtml/docbook.xsl" \
            "${DB_XSLT_URL}xhtml/chunk.xsl" \
            "${DB_XSLT_URL}html/docbook.xsl" \
            "${DB_XSLT_URL}html/chunk.xsl" \
            "${DB_XSLT_URL}fo/docbook.xsl" \
            "${DB_XSLT_URL}manpages/docbook.xsl" \
            "${DB_XSLT_URL}epub/docbook.xsl" \
            "${DB_XSLT_URL}profiling/profile.xsl"; do
  AC_MSG_CHECKING([for $XSLT])
  if AC_RUN_LOG([$XMLCATALOG --noout "${CATALOG_FILE}" "$XSLT" >&2]); then
    AC_MSG_RESULT([found])
  else
    AC_MSG_WARN([not found])
  fi
done



AC_OUTPUT
