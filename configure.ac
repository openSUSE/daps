dnl                               -*- Autoconf -*-
dnl Process this file with autoconf to produce a configure script
dnl or use autogen.sh (recommended)
dnl
dnl Authors:
dnl   Thomas Schraitle  <toms@opensuse.org>
dnl   Frank Sundermeyer <fs@suse.de>
dnl
dnl TODO
dnl
dnl determine aspell directory

m4_define(daps_version_major, 0)
m4_define(daps_version_minor, 9)
m4_define(daps_version_micro, 9dev)

AC_PREREQ([2.68])
AC_INIT([DAPS], [0.9.9], [https://sourceforge.net/p/daps/tickets/], [daps], [http://daps.sf.net])
AC_CONFIG_MACRO_DIR([m4])


AC_MSG_NOTICE([

 Configuring DAPS, the DocBook Authoring and Publishing Suite...

])

AC_CONFIG_SRCDIR([Makefile.am])
AM_INIT_AUTOMAKE([1.10])


#AC_CONFIG_FILES([
#Makefile
#])

# Command-line arguments
## AC_ARG_WITH(stuff, [  --with-stuff            enable stuff])

AC_PREFIX_DEFAULT(/usr)

# Some constants
CATALOG_FILE="/etc/xml/catalog"
DB4_XSLT_URL="http://docbook.sourceforge.net/release/xsl/current/"
FONT_DIR="/usr/share/fonts"

# Checks for programs.
AC_PROG_MKDIR_P
AC_PROG_LN_S
AC_PROG_SED
AC_PROG_GREP
AC_PROG_INSTALL

# make
AC_PATH_PROG([MAKE], [make])
if test -z "$MAKE"; then
   AC_MSG_ERROR([make not found]) 
fi

# tar
AC_PATH_PROG([TAR], [tar] )
if test -z "$TAR"; then
   AC_MSG_ERROR([tar not found]) 
fi

# perl
#AC_PATH_PROG([PERL], [perl] )
#if test -z "$PERL"; then
#  HAVE_PERL='no'
#else
#  HAVE_PERL='yes'
#fi
#AC_SUBST(HAVE_PERL)

# (files, [action-if-found], [action-if-not-found])
# AC_CHECK_FILES

#--------------------------------------------------------------------------
AC_MSG_NOTICE([===== Checking for XML tools... ])

# Syntax: AC_PATH_PROG([VARIABLE], [binary])
AC_PATH_PROG([XMLLINT], [xmllint])
if test -z "$XMLLINT"; then
   AC_MSG_ERROR([xmllint not found])
fi

AC_PATH_PROG([XSLTPROC], [xsltproc])
if test -z "$XSLTPROC"; then
   AC_MSG_ERROR([xsltproc (libxslt) not found]) 
fi

AC_PATH_PROG([XMLCATALOG], [xmlcatalog])
if test -z "$XMLCATALOG"; then
   AC_MSG_ERROR([xmlcatalog not found]) 
fi

AC_PATH_PROG([FOP], [fop])
if test -z "$FOP"; then
   AC_MSG_ERROR([fop not found]) 
fi

# recommendation, only needed for Docbook5
AC_PATH_PROG([JING], [jing] )
if test -z "$JING"; then
  AC_MSG_WARN([jing not found => no DocBook 5 support]) 
fi

AC_CHECK_FILE([${CATALOG_FILE}], [CATALOG=yes], [CATALOG=no])
if test -z "$CATALOG"; then
  AC_MSG_ERROR([Catalog ${CATALOG_FILE} not found])
fi

#--------------------------------------------------------------------------
AC_MSG_NOTICE([===== Checking for Image conversion tools...])

# convert (ImageMagick)
AC_PATH_PROG([CONVERT], [convert] )
if test -z "$CONVERT"; then
   AC_MSG_ERROR([convert (ImageMagick) not found]) 
fi

# dia
AC_PATH_PROG([DIA], [dia] )
if test -z "$DIA"; then
   AC_MSG_WARN([dia not found => no support for .dia images])
fi

# inkscape
AC_PATH_PROG([INKSCAPE], [inkscape] )
if test -z "$INKSCAPE"; then
   AC_MSG_WARN([inkscape not found => no support for .svg images])
fi

# optipng
AC_PATH_PROG([OPTIPNG], [optipng] )
if test -z "$OPTIPNG"; then
  AC_MSG_WARN([optipng not found => no support for size reduction of .png images])
fi
# exiftool
AC_PATH_PROG([EXIFTOOL], [exiftool])
if test -z "$EXIFTOOL"; then
   AC_MSG_WARN([exiftool not found => no support for size reduction of .png images])
fi

# transfig
AC_PATH_PROG([XFIG], [xfig] )
if test -z "$XFIG"; then
  AC_MSG_WARN([xfig (transfig) not found => no support of .fig images])
fi

# svg DTD
for SVG_DTD in "-//W3C//DTD SVG 1.0//EN" \
               "-//W3C//DTD SVG 1.1 Basic//EN" ; do
  AC_MSG_CHECKING([for $SVG_DTD])
  if AC_RUN_LOG([$XMLCATALOG --noout "${CATALOG_FILE}" "$SVG_DTD" >&2]); then
    AC_MSG_RESULT([yes])
    HAVE_SVGDTD="yes"
  else
    AC_MSG_RESULT([no])
  fi
done
if test -z "$HAVE_SVGDTD"; then
   AC_MSG_WARN([SVG DTD not found => no support for .svg images])
fi               

#--------------------------------------------------------------------------
AC_MSG_NOTICE([===== Checking for Python modules...])
# python
dnl We require Python >= 2.6
AM_PATH_PYTHON([2.6])

# Variables HAVE_PYMOD_* are filled with "yes" or "no"
AC_PYTHON_MODULE([xml], [fatal])
AC_SUBST(HAVE_PYMOD_XML)

# only needed fo daps-docmanager
#AC_PYTHON_MODULE([lxml], [fatal])
#AC_SUBST(HAVE_PYMOD_LXML)
#AC_PYTHON_MODULE([optparse], [fatal])
#AC_SUBST(HAVE_PYMOD_OPTPARSE)

#--------------------------------------------------------------------------
AC_MSG_NOTICE([===== Checking for DocBook 4...])

#DOCBOOKDTDS=""
for XML_DTD in "-//OASIS//DTD DocBook XML V4.1.2//EN" \
               "-//OASIS//DTD DocBook XML V4.2//EN" \
               "-//OASIS//DTD DocBook XML V4.3//EN" \
               "-//OASIS//DTD DocBook XML V4.4//EN" \
               "-//OASIS//DTD DocBook XML V4.5//EN" ; do
  AC_MSG_CHECKING([for $XML_DTD])
  if AC_RUN_LOG([$XMLCATALOG --noout "${CATALOG_FILE}" "$XML_DTD" >&2]); then
    AC_MSG_RESULT([yes])
#    ## Extract version from public identifier
#    x=${XML_DTD##*XML V}    
#    DOCBOOKDTDS="$DOCBOOKDTDS${x%%//*} "
     HAVE_DOCBOOK="yes"
  else
    AC_MSG_RESULT([no])
  fi
done
#AC_SUBST(DOCBOOKDTDS)
if test -z "$HAVE_DOCBOOK"; then
  AC_MSG_ERROR([DocBook 4 not found])
fi

dnl AC_MSG_NOTICE([===== Checking for System Identifier...])
dnl 
dnl for XML_DTD in "http://www.oasis-open.org/docbook/xml/4.1.2/docbookx.dtd" \
dnl               "http://www.oasis-open.org/docbook/xml/4.2/docbookx.dtd" \
dnl               "http://www.oasis-open.org/docbook/xml/4.3/docbookx.dtd" \
dnl               "http://www.oasis-open.org/docbook/xml/4.4/docbookx.dtd" \
dnl               "http://www.oasis-open.org/docbook/xml/4.5/docbookx.dtd" ; do
dnl  AC_MSG_CHECKING([for $XML_DTD])
dnl  if AC_RUN_LOG([$XMLCATALOG --noout "${CATALOG_FILE}" "$XML_DTD" >&2]); then
dnl    AC_MSG_RESULT([yes])
dnl  else
dnl    AC_MSG_RESULT([no])
dnl  fi
dnl done

#--------------------------------------------------------------------------
AC_MSG_NOTICE([===== Checking for DocBook 4 XSL Stylesheets...])

for XSLT in "${DB4_XSLT_URL}xhtml/docbook.xsl" \
            "${DB4_XSLT_URL}xhtml/chunk.xsl" \
            "${DB4_XSLT_URL}html/docbook.xsl" \
            "${DB4_XSLT_URL}html/chunk.xsl" \
            "${DB4_XSLT_URL}fo/docbook.xsl" \
            "${DB4_XSLT_URL}manpages/docbook.xsl" \
            "${DB4_XSLT_URL}epub/docbook.xsl" \
            "${DB4_XSLT_URL}profiling/profile.xsl"; do
  AC_MSG_CHECKING([for $XSLT])
  if AC_RUN_LOG([$XMLCATALOG --noout "${CATALOG_FILE}" "$XSLT" >&2]); then
    AC_MSG_RESULT([yes])
    HAVE_DOCBOOK_STYLESHEETS="yes"
  else
    AC_MSG_RESULT([no])
  fi
done
if test -z "$HAVE_DOCBOOK_STYLESHEETS"; then
  AC_MSG_ERROR([DocBook 4 stylesheets not found])
fi


AC_OUTPUT([Makefile])
