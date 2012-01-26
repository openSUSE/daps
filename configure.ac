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

# Checks for programs.
AC_PROG_LN_S
AC_PROG_SED
AC_PROG_GREP

AC_MSG_NOTICE([**** Checking XML tools ****])

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

for XML_DTD in "-//OASIS//DTD DocBook XML V4.2//EN" \
               "-//OASIS//DTD DocBook XML V4.3//EN" \
               "-//OASIS//DTD DocBook XML V4.4//EN" \
               "-//OASIS//DTD DocBook XML V4.5//EN" ; do
  AC_MSG_CHECKING([for $XML_DTD])
  if AC_RUN_LOG([$XMLCATALOG --noout "${CATALOG_FILE}" "$XML_DTD" >&2]); then
    AC_MSG_RESULT([found])
  else
    AC_MSG_ERROR([not found])
  fi
done


AC_OUTPUT
