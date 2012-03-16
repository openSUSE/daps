#!/bin/bash
#
# Testing 
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

testCatalogs() {
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

testDAPS_Init() {
# Purpose:
#  Tests daps-init and checks, if DC file and all directories are available

  logging "<<< $MAIN::testDAPS_Init:Start"
  logging " TEMPDIR=$TEMPDIR"
  cd $TEMPDIR
  CONTENTS=$(ls)
  assertNull "The temp dir contains something which was not expected" "$CONTENTS"

  $DAPS_INIT  -d . -r book 2>/dev/null
  assertTrue "daps-init returned != 0 (was $?)" "[[ $? -eq 0 ]]"
  logging $? "daps-init"

  # Enable export, to make it "sourceable":
  sed -i 's/^#export DOCCONF_NAME/export DOCCONF_NAME/g' DC-daps-example

  assertTrue "Could not find file DC-daps-example" "[[ -f DC-daps-example ]]"
  logging $? "File DC-daps-example"

  DIRECTORIES="xml images images/src images/src/dia images/src/eps images/src/fig 
               images/src/pdf images/src/png images/src/svg"
  for d in $DIRECTORIES; do
    assertTrue "Could not find $d directory" "[[ -d $d ]]"
    logging $? "Directory $d"
  done

  logging ">>> $MAIN::testDAPS_Init:End"
}

testDAPS_Validate() {
# Purpose:
#  Runs daps validate, checks return value and if build directory is available
  logging "<<< $MAIN::testDAPS_Validate:Start"
  # source DC-daps-example
  $DAPS validate
  assertTrue "daps validate returned != 0 (was $?)" "[[ $? -eq 0 ]]"
  logging $? "Validation"

  assertTrue "Could not find build directory" "[[ -d build ]]"
  logging $? "Directory build "

  logging ">>> $MAIN::testDAPS_Validate:End"
}


testDAPS_html_chunk() {
# Purpose:
#  Runs daps html, checks return value and checks several files
  logging "<<< $MAIN::testDAPS_html_chunk:Start"
  # source DC-daps-example
  $DAPS html
  assertTrue "daps html returned != 0 (was $?)" "[[ $? -eq 0 ]]"
  logging $? "HTML creation successful"

  assertTrue "Could not find build/daps-example/html/daps-example/ directory" "[[ -d build/daps-example/html/daps-example/ ]]"
  logging $? "Directory build/daps-example/html/daps-example/"

  assertTrue "Could not find build/daps-example/html/daps-example/index.html directory" "[[ -f build/daps-example/html/daps-example/index.html ]]"
  logging $? "File build/daps-example/html/daps-example/index.html"

  logging ">>> $MAIN::testDAPS_html_chunk:End"
}

testDAPS_htmlsingle() {
# Purpose:
#  Runs daps htmlsingle, checks return value and checks several files
  logging "<<< $MAIN::testDAPS_htmlsingle:Start"
  # source DC-daps-example
  $DAPS htmlsingle
  assertTrue "daps htmlsingle returned != 0 (was $?)" "[[ $? -eq 0 ]]"
  logging $? "Creation of HTML single"

  logging ">>> $MAIN::testDAPS_htmlsingle:End"
}


# ALWAYS source it last:
source $SHUNIT2SRC

# EOF