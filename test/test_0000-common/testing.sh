#!/bin/bash
#
# Testing for common functions (needs no XML)
#
# (C) 2012 Thomas Schraitle <toms@opensuse.org>
#

MAIN=${0%%/*}
PROG=${0##*/}

if [[ -f common.sh ]]; then
  source common.sh
elif [[ -f ../common.sh ]]; then
  source ../common.sh
fi

# If TEMPDIR variable is not set, use current directory
TEMPDIR=${TEMPDIR:-"."}


usage() {
cat << EOF
${PROG} [OPTIONS...]
DAPS Testing Framework

Available Options:
 -h, --help
     Shows this help
 -t, --tempdir TEMPDIR
     Absolute path to temporary directory 
 -k, --keeptemp
     Do not delete the TEMPDIR directory, default ${DELTEMP}
EOF
exit 0
}

if ! options=$(getopt -o h,t:,k  -l help,tempdir:,keeptemp -- "$@"); then
    exit 1
fi

eval set -- "$options"

while [ $# -gt 0  ]; do
  case "$1" in                                                    
    -h|--help) usage;;
    -t|--tempdir)
       TEMPDIR=$2
       shift
       ;;
    -D|--daps)
       [[ -f $2 ]] || exit_on_error "$2 does not exist"
       DAPS=$(readlink -f $2)
       shift
       ;;
    -k|--keeptemp)
       DELTEMP=0
       ;;
    (--) shift; break;;                                           
    (-*) exit_on_error "${0##*/}: error - unrecognized option $1" ;; 
    (*)  break;;
  esac
 shift
done


# ----------------------------------------------------------------------------
# DAPS Testing Functions
#
# Test functions are executed in the given order

test_Programs() {
# Purpose:
#  Tests for several programs that daps needs
  logging "<<< $MAIN::test_Programs:Start"
  assertTrue "No /usr/bin/fop" "[[ -f /usr/bin/fop ]] && [[ -x /usr/bin/fop ]]"
  logging $? "/usr/bin/fop"
  
  PROGRAMS="fop dia inkscape convert xmllint xmlcatalog xsltproc make bzip2 tar ruby python w3m"
  for p in $PROGRAMS; do
    p=$(which $p 2>/dev/null)
    assertTrue "Program $p not found" $?
    logging $? "Program $p"
    assertTrue "No executable $p" "[[ -x $p ]]"
    logging $? "Executable $p"
  done

  logging ">>> $MAIN::test_Programs:End"
}

test_Catalogs() {
# Purpose:
#  Tests catalog

logging "<<< $MAIN::test_Catalogs:Start"

CATALOGS='urn:x-suse:xslt:profiling:novdoc-profile.xsl
          urn:x-suse:xslt:profiling:docbook45-profile.xsl
          urn:x-daps:xslt:profiling:novdoc-profile.xsl
          urn:x-daps:xslt:profiling:docbook45-profile.xsl
          http://docbook.sourceforge.net/release/xsl/current/fo/docbook.xsl
          http://docbook.sourceforge.net/release/xsl/current/xhtml/docbook.xsl'

for i in $CATALOGS; do
 xmlcatalog /etc/xml/catalog $i > $TEMPDIR/catalog-output
 assertTrue "Catalog entry $i not found" "[[  $? -eq 0 ]]"
 logging $? "Catalog file $i"
done

logging "<<< $MAIN::test_Catalogs:End"
}


# ALWAYS source it last:
source $SHUNIT2SRC

# EOF