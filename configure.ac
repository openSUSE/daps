dnl                               -*- Autoconf -*-
dnl Process this file with autoconf to produce a configure script
dnl or use autogen.sh (recommended)
dnl
dnl Copyright (C) 2011,2012:
dnl   Thomas Schraitle  <toms@opensuse.org>
dnl   Frank Sundermeyer <fsundermeyer@opensuse.org>
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
AC_PREFIX_DEFAULT(/usr)

# Some constants
ROOT_CATALOG="/etc/xml/catalog"
AC_SUBST(ROOT_CATALOG)
DB4_XSLT_URL="http://docbook.sourceforge.net/release/xsl/current/"
DB5_XSLT_URL="http://docbook.sourceforge.net/release/xsl-ns/current/"
FONT_DIR="/usr/share/fonts"

#-------------------------
# Debug mode switch
# $DEBUG is used with bin/daps
# $Q is the quiet switch for the Makefile
#
AC_ARG_ENABLE([debug],
    [AC_HELP_STRING([--enable-debug], [Enable debug mode])],
      [debug="--debug"], [quiet="@"])
eval "eval DEBUG=$debug Q=$quiet"
AC_SUBST(DEBUG)
AC_SUBST(Q)

#-------------------------
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
    HAVE_TAR=0
fi

# bzip2
AC_PATH_PROG([BZIP], [bzip2] )
if test -z "$BZIP"; then
    HAVE_BZIP=0
fi

# epubcheck
AC_PATH_PROG([EPUBCHECK], [epubcheck] )
if test -z "$EPUBCHECK"; then
    HAVE_EPUBCHECK=0
fi

# checkbot
AC_PATH_PROG([CHECKBOT], [checkbot] )
if test -z "$CHECKBOT"; then
    HAVE_CHECKBOT=0
fi

#ruby
AC_PATH_PROG([RUBY], [ruby] )
if test -z "$RUBY"; then
    HAVE_RUBY=0
fi

# w3m
AC_PATH_PROG([W3M], [w3m] )
if test -z "$W3M"; then
    HAVE_W3M=0
fi

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
   HAVE_FOP=0
fi

AC_PATH_PROG([XEP], [xep])
if test -z "$XEP"; then
   HAVE_XEP=0
fi

# recommendation, only needed for Docbook5
AC_PATH_PROG([JING], [jing] )
if test -z "$JING"; then
  HAVE_JING=0
fi

AC_CHECK_FILE([$ROOT_CATALOG], [CATALOG=yes], [CATALOG=no])
if test -z "$CATALOG"; then
  AC_MSG_ERROR([Catalog $ROOT_CATALOG not found])
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
  HAVE_DIA=0
fi

# exiftool
AC_PATH_PROG([EXIFTOOL], [exiftool])
if test -z "$EXIFTOOL"; then
  HAVE_EXIFTOOL=0  
fi

# ghostscript
AC_PATH_PROG([GHOSTSCRIPT], [gs] )
if test -z "$GHOSTSCRIPT"; then
  HAVE_GHOSTSCRIPT=0
fi

# inkscape
AC_PATH_PROG([INKSCAPE], [inkscape] )
if test -z "$INKSCAPE"; then
  HAVE_INKSCAPE=0
fi

# optipng
AC_PATH_PROG([OPTIPNG], [optipng] )
if test -z "$OPTIPNG"; then
  HAVE_OPTIPNG=0
fi

# pdffonts
AC_PATH_PROG([PDFFONTS], [pdffonts] )
if test -z "$PDFFONTS"; then
  HAVE_PDFFONTS=0
fi

# xfig
AC_PATH_PROG([XFIG], [xfig] )
if test -z "$XFIG"; then
  HAVE_XFIG=0
fi

# svg DTD
for SVG_DTD in "-//W3C//DTD SVG 1.0//EN" \
               "-//W3C//DTD SVG 1.1 Basic//EN" ; do
  AC_MSG_CHECKING([for $SVG_DTD])
  if AC_RUN_LOG([$XMLCATALOG --noout "$ROOT_CATALOG" "$SVG_DTD" >&2]); then
    AC_MSG_RESULT([yes])
    HAVE_SVGDTD="yes"
  else
    AC_MSG_RESULT([no])
  fi
done
if test -z "$HAVE_SVGDTD"; then
  HAVE_SVGDTD=0
fi               

#--------------------------------------------------------------------------
AC_MSG_NOTICE([===== Checking for Python modules...])
# python
dnl We require Python >= 2.6
AM_PATH_PYTHON([2.6])

# Variables HAVE_PYMOD_* are filled with "yes" or "no"
AC_PYTHON_MODULE([xml], [fatal])
AC_SUBST(HAVE_PYMOD_XML)

# only needed for daps-docmanager
#AC_PYTHON_MODULE([lxml], [fatal])
#AC_SUBST(HAVE_PYMOD_LXML)
#AC_PYTHON_MODULE([optparse], [fatal])
#AC_SUBST(HAVE_PYMOD_OPTPARSE)

#--------------------------------------------------------------------------
AC_MSG_NOTICE([===== Checking for DocBook...])

for XML_DTD in "-//OASIS//DTD DocBook XML V4.1.2//EN" \
               "-//OASIS//DTD DocBook XML V4.2//EN" \
               "-//OASIS//DTD DocBook XML V4.3//EN" \
               "-//OASIS//DTD DocBook XML V4.4//EN" \
               "-//OASIS//DTD DocBook XML V4.5//EN" ; do
  AC_MSG_CHECKING([for $XML_DTD])
  if AC_RUN_LOG([$XMLCATALOG --noout "$ROOT_CATALOG" "$XML_DTD" >&2]); then
    AC_MSG_RESULT([yes])
    HAVE_DOCBOOK="yes"
  else
    AC_MSG_RESULT([no])
  fi
done
if test -z "$HAVE_DOCBOOK"; then
  AC_MSG_ERROR([No DocBook 4 DTD not found])
fi

# Docbook 5
for XML_SCHEMA in "http://docbook.org/xml/5.0/rng/docbookxi.rng" \
                  "http://docbook.org/xml/5.0/rng/docbookxi.rnc" \
                  "http://docbook.org/xml/5.0/rng/docbook.rng" \
                  "http://docbook.org/xml/5.0/rng/docbook.rnc" ; do
  AC_MSG_CHECKING([for $XML_SCHEMA])
  if AC_RUN_LOG([$XMLCATALOG --noout "$ROOT_CATALOG" "$XML_DTD" >&2]); then
    AC_MSG_RESULT([yes])
    HAVE_DOCBOOK_5=1
  else
    AC_MSG_RESULT([no])
  fi
done
if test -z "$HAVE_DOCBOOK_5"; then
  HAVE_DOCBOOK_5=0
fi

#--------------------------------------------------------------------------
AC_MSG_NOTICE([===== Checking for DocBook XSL Stylesheets...])

# DocBook4
for XSLT in "${DB4_XSLT_URL}xhtml/docbook.xsl" \
            "${DB4_XSLT_URL}xhtml/chunk.xsl" \
            "${DB4_XSLT_URL}html/docbook.xsl" \
            "${DB4_XSLT_URL}html/chunk.xsl" \
            "${DB4_XSLT_URL}fo/docbook.xsl" \
            "${DB4_XSLT_URL}manpages/docbook.xsl" \
            "${DB4_XSLT_URL}epub/docbook.xsl" \
            "${DB4_XSLT_URL}profiling/profile.xsl"; do
  AC_MSG_CHECKING([for $XSLT])
  if AC_RUN_LOG([$XMLCATALOG --noout "$ROOT_CATALOG" "$XSLT" >&2]); then
    AC_MSG_RESULT([yes])
    HAVE_DOCBOOK_STYLESHEETS="yes"
  else
    AC_MSG_RESULT([no])
  fi
done
if test -z "$HAVE_DOCBOOK_STYLESHEETS"; then
  AC_MSG_ERROR([DocBook 4 stylesheets not found])
fi

# DocBook 5
for XSLT in "${DB5_XSLT_URL}xhtml/docbook.xsl" \
            "${DB5_XSLT_URL}xhtml/chunk.xsl" \
            "${DB5_XSLT_URL}html/docbook.xsl" \
            "${DB5_XSLT_URL}html/chunk.xsl" \
            "${DB5_XSLT_URL}fo/docbook.xsl" \
            "${DB5_XSLT_URL}manpages/docbook.xsl" \
            "${DB5_XSLT_URL}epub/docbook.xsl" \
            "${DB5_XSLT_URL}profiling/profile.xsl"; do
  AC_MSG_CHECKING([for $XSLT])
  if AC_RUN_LOG([$XMLCATALOG --noout "$ROOT_CATALOG" "$XSLT" >&2]); then
    AC_MSG_RESULT([yes])
    HAVE_DOCBOOK_5_STYLESHEETS="yes"
  else
    AC_MSG_RESULT([no])
  fi
done
if test -z "$HAVE_DOCBOOK_5_STYLESHEETS"; then
  HAVE_DOCBOOK_5_STYLESHEETS=0
fi

AC_OUTPUT([Makefile])

AC_MSG_RESULT([
###############################################################################
DAPS is configured as follows.  Please verify that this configuration matches
your expectations.

Supported features
------------------
* HTML/single HTML output            * MediaWiki output (experimental)
* JSP output                         * support for .png images
* man pages output

Optional features
-----------------
Feature                          | Enabled | Action to enable
..............................................................................])
# Create ASCII (w3m)
if test 0 = "$HAVE_W3M"; then
  AC_MSG_RESULT([Create ASCII txt output          |    no   | install w3m])
else
  AC_MSG_RESULT([Create ASCII txt output          |   yes   |])
fi

# Create ePUBs (ruby)
if test 0 = "$HAVE_RUBY"; then
  AC_MSG_RESULT([Create ePUB output               |    no   | install ruby])
else
  AC_MSG_RESULT([Create ePUB output               |   yes   |])
fi

# Create PDFs (fop, xep)
if test 0 = "$HAVE_FOP" -o 0 = "$HAVE_XEP"; then
  AC_MSG_RESULT([Create PDF output                |    no   | install a formatter (fop or xep)
])
else
  AC_MSG_RESULT([Create PDF output                |   yes   |
])
fi

# DIA support
if test 0 = "$HAVE_DIA"; then
  AC_MSG_RESULT([Support for .dia images          |    no   | install dia])
else
  AC_MSG_RESULT([Support for .dia images          |   yes   |])
fi

# SVG support
if test 0 = "$HAVE_INKSCAPE" -o 0 = "$HAVE_SVGDTD"; then
  AC_MSG_RESULT([Support for .svg images          |    no   | install inkscape and/or the SVG DTD])
else
  AC_MSG_RESULT([Support for .svg images          |   yes   |])
fi

# XFIG support
if test 0 = "$HAVE_XFIG"; then
  AC_MSG_RESULT([Support for .fig images          |    no   | install xfig (transfig)])
else
  AC_MSG_RESULT([Support for .fig images          |   yes   |])
fi

# Optimize PNGs (optipng)
if test 0 = "$HAVE_OPTIPNG" -o 0 = "$HAVE_EXIFTOOL"; then
  AC_MSG_RESULT([Size optimization for .png       |    no   | install optipng and/or exiftool
])
else
  AC_MSG_RESULT([Size optimization for .png       |   yes   |
])
fi

# Linkchecker (checkbot)
if test 0 = "$HAVE_CHECKBOT"; then
  AC_MSG_RESULT([Check links in XML sources       |    no   | install checkbot])
else
  AC_MSG_RESULT([Check links in XML sources       |   yes   |])
fi

# Create archives (tar, bzip2)
if test 0 = "$HAVE_TAR" -o 0 = "$HAVE_BZIP"; then
  AC_MSG_RESULT([Create distributable archives    |    no   | install tar and/or bzip2])
else
  AC_MSG_RESULT([Create distributable archives    |   yes   |])
fi

# Validate ePUBs (epubcheck)
if test 0 = "$HAVE_EPUBCHECK"; then
  AC_MSG_RESULT([Validate generated ePUB files    |    no   | install epubcheck])
else
  AC_MSG_RESULT([Validate generated ePUB files    |   yes   |])
fi

# PDF font summary (pdffonts)
if test 0 = "$HAVE_PDFFONTS"; then
  AC_MSG_RESULT([Show fonts not embedded in PDFs  |    no   | install poppler utilities/tools])
else
  AC_MSG_RESULT([Show fonts not embedded in PDFs  |   yes   |])
fi


AC_MSG_RESULT([
Experimental features
---------------------
Feature                          | Enabled | Action to enable
..............................................................................])
# PDF/EPS images support(ghostscript (gs))
if test 0 = "$HAVE_XFIG"; then
  AC_MSG_RESULT([Support for .pdf and .eps images |    no   | install ghostscript])
else
  AC_MSG_RESULT([Support for .pdf and .eps images |   yes   |])
fi

# DocBook 5
test 0 = "$HAVE_DOCBOOK_5" && DB5=0
test 0 = "$HAVE_DOCBOOK_5_STYLESHEETS" && DB5=0
test 0 = "$HAVE_JING" && DB5=0

if test 0 = "$DB5"; then
  AC_MSG_RESULT([DocBook 5 support                |    no   | install DocBook 5, the
                                 |         | DocBook 5 XSL stylesheets,
                                 |         | and jing
])
else
  AC_MSG_RESULT([DocBook 5 support                |   yes   |
])
fi
