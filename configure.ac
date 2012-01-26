#                                               -*- Autoconf -*-
# Process this file with autoconf to produce a configure script or use autogen.sh
#
# Authors:
#   Thomas Schraitle  <toms@opensuse.org>
#   Frank Sundermeyer <fs@suse.de>

AC_PREREQ([2.68])
AC_INIT([daps], [0.9.2], [fs@suse.de, toms@suse.de], [daps], [http://daps.sf.net])

AC_MSG_NOTICE([

 Configuring DAPS, the DocBook Authoring and Publishing Suite...

])

AC_CONFIG_SRCDIR([Makefile.am])
# Turn on all warnings, report warnings as errors:
AM_INIT_AUTOMAKE([1.10 no-define -Wall -Werror])
#AC_CONFIG_MACRO_DIR([m4])


AC_CONFIG_FILES([
Makefile
])


# Set variables
CATALOG_FILE="/etc/xml/catalog"
DB_XSLT_URL="http://docbook.sourceforge.net/release/xsl/current/"

# Checks for programs.
AC_PROG_LN_S
AC_PROG_SED
AC_PROG_GREP

AC_MSG_NOTICE([**** Checking XML tools... ****])

# Syntax: AC_PATH_PROG([VARIABLE], [binary])
AC_PATH_PROG([XMLLINT], [xmllint])
if test -z "$XMLLINT"; then
   AC_MSG_ERROR([xmllint not found])
fi

AC_PATH_PROG([XSLTPROC], [xsltproc])
if test -z "$XSLTPROC"; then
   AC_MSG_ERROR([xsltproc not found]) 
fi

AC_PATH_PROG(XMLCATALOG, xmlcatalog, no)
if test -z "$XMLCATALOG"; then
   AC_MSG_ERROR([xmlcatalog not found]) 
fi

AC_PATH_PROG([FOP], [fop])
if test -z "$FOP"; then
   AC_MSG_ERROR([fop not found]) 
fi

AC_CHECK_FILES([${CATALOG_FILE}], [CATALOG=yes], [CATALOG=no])
if test -z "$CATALOG"; then
  AC_MSG_ERROR([Catalog ${CATALOG_FILE} not found])
fi

AC_MSG_NOTICE([**** Checking Public Identifier for DocBook DTD... ****])

for XML_DTD in "-//OASIS//DTD DocBook XML V4.1.2//EN" \
               "-//OASIS//DTD DocBook XML V4.2//EN" \
               "-//OASIS//DTD DocBook XML V4.3//EN" \
               "-//OASIS//DTD DocBook XML V4.4//EN" \
               "-//OASIS//DTD DocBook XML V4.5//EN" ; do
  AC_MSG_CHECKING([for $XML_DTD])
  if AC_RUN_LOG([$XMLCATALOG --noout "${CATALOG_FILE}" "$XML_DTD" >&2]); then
    AC_MSG_RESULT([found])
  else
    AC_MSG_WARN([not found])
  fi
done

AC_MSG_NOTICE([**** Checking System Identifier for DocBook DTD... ****])

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

AC_MSG_NOTICE([**** Checking Canonical URL for DocBook XSL Stylesheets... ****])


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
