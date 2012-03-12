#!/bin/bash
#
# This is a testing framework for DAPS (DocBook Authoring and Publishing Suite)
# It tests several issues regarding existing files, document creation etc.
#
# Needs the shunit2 package
#
# (C) 2012 Thomas Schraitle <toms@opensuse.org>
#

# ----------------------------------------------------------------------------
# Global Variables

# Remove temporary directory? 0=no, 1=yes
DELTEMP=1
# Logging actions to $LOGFILE? 0=no, 1=yes
LOGGING=1

# Default path to daps script:
DAPS="/usr/bin/daps"
# Default path to daps-init script:
DAPS_INIT="/usr/bin/daps-init"
# Default path to logfile:
LOGFILE="/tmp/daps-testing.log"


usage() {
cat << EOF
${0##*/} [OPTIONS...]
DAPS Testing Framework

Available Options:
 -h, --help
     Shows this help
 -i, --dapsinit DAPSINIT
     Absolute filename, points to the daps-init program
 -D, --daps DAPS
     Absolute filename, points to the daps script
 -l, --logfile LOGFILE
     Save result in LOGFILE (default $LOGFILE)
 -k, --keeptemp
     Do not delete the TEMPDIR directory, default ${DELTEMP}
EOF
exit 0
}

# ---------
# Verbose error handling
#
exit_on_error () {
    echo "ERROR: ${1}" 1>&2
    exit 1;
}

# ---------
# Logs a message in $LOGFILE when $LOGGING is != 0
#
logging() {
# Examples:
#   logging 0 "Found x"
#   logging "Hello World"
# Synopsis:
#   $1 optional result from assert* functions
#   $2 message
# Returns:
#   Nothing, but writes message in $LOGFILE
#
  if [[ $LOGGING -ne 0 ]]; then
   if [[ $# -eq 2 ]]; then
     local RESULT=$1
     local MSG=$2
   elif [[ $# -eq 1 ]]; then
     local RESULT=0
     local MSG=$1
   else
     exit_on_error "Wrong number of arguments in logging()"
   fi

    DATE=$(date +"[%d-%m-%YT%H:%M:%S]")
    if [[ $RESULT -eq 0 ]]; then
      echo "$DATE: $MSG" >> $LOGFILE
    else
      echo "$DATE: [ERROR] $MSG" >> $LOGFILE
    fi
  fi
}

# ---------
# Short test, if shunit2 is available
[[ -f /usr/share/shunit2/src/shunit2 ]] || exit_on_error "No shunit2 package found! :-(("


# ---------
# Parsing Command Line Options
if ! options=$(getopt -o h,i:,l:,D:,k  -l help,dapsinit:,logfile:,daps:,keeptemp -- "$@"); then
    exit 1
fi


eval set -- "$options"

while [ $# -gt 0  ]; do
  case "$1" in                                                    
    -h|--help) usage;;
    -i|--dapsinit)
        D=$(readlink -f $2)
        [[ -f $D ]] || exit_on_error "$D does not exist"
        DAPS_INIT=$D
        shift
        ;;
    -l|--logfile)
       # Make an *absolute* filename to avoid problems when 
       # switching to other directories
       LOGFILE=$(readlink -f $2)
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

# ---------
# Create temporary directory were we store 
TEMPDIR=$(mktemp -d /tmp/daps-testing_XXXXXX)


# ----------------------------------------------------------------------------
# Creating DAPS Testing Environment
#
oneTimeSetUp() {
  logging "--- Setting up DAPS Testing Framework..."
  assertTrue "Could not find temporary directory $TEMPDIR" "[ -d $TEMPDIR ]"
  logging "Starting ${0##*/}"
}

oneTimeTearDown() {
  # Delete temporary directory, when DELTEMP is enabled
  [[ -d $TEMPDIR && 0 -ne $DELTEMP ]] && rm -rf $TEMPDIR

  if [[ $LOGGING -ne 0 ]]; then
    echo "Find the logging output in $LOGFILE"
  fi
  logging "--- Tearing down DAPS Testing Framework ..."
}


# ----------------------------------------------------------------------------
# DAPS Testing Functions
#
# Test functions are executed in the given order

test_Programs() {
# Purpose:
#  Tests for several programs that daps needs
  logging "<<< test_Programs:Start"
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

  logging ">>> test_Programs:End"
}

testCatalogs() {
# Purpose:
#  Tests catalog

logging "<<< test_Catalogs:Start"

CATALOGS='urn:x-suse:xslt:profiling:docbook45-profile.xsl 
          http://docbook.sourceforge.net/release/xsl/current/fo/docbook.xsl
          http://docbook.sourceforge.net/release/xsl/current/xhtml/docbook.xsl'

for i in $CATALOGS; do
 xmlcatalog /etc/xml/catalog $i > catalog-output
 assertTrue "Catalog entry $i not found" "[[  $? -eq 0 ]]"
 logging $? "Catalog file $i"
done

logging "<<< test_Catalogs:End"
}

testDAPS_Init() {
# Purpose:
#  Tests daps-init and checks, if DC file and all directories are available

  logging "<<< testDAPS_Init:Start"
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

  logging ">>> testDAPS_Init:End"
}

testDAPS_Validate() {
# Purpose:
#  Runs daps validate, checks return value and if build directory is available
  logging "<<< testDAPS_Validate:Start"
  # source DC-daps-example
  $DAPS validate
  assertTrue "daps validate returned != 0 (was $?)" "[[ $? -eq 0 ]]"
  logging $? "Validation"

  assertTrue "Could not find build directory" "[[ -d build ]]"
  logging $? "Directory build "

  logging ">>> testDAPS_Validate:End"
}


testDAPS_html_chunk() {
# Purpose:
#  Runs daps html, checks return value and checks several files
  logging "<<< testDAPS_html_chunk:Start"
  # source DC-daps-example
  $DAPS html
  assertTrue "daps html returned != 0 (was $?)" "[[ $? -eq 0 ]]"
  logging $? "HTML creation successful"

  assertTrue "Could not find build/daps-example/html/daps-example/ directory" "[[ -d build/daps-example/html/daps-example/ ]]"
  logging $? "Directory build/daps-example/html/daps-example/"

  assertTrue "Could not find build/daps-example/html/daps-example/index.html directory" "[[ -f build/daps-example/html/daps-example/index.html ]]"
  logging $? "File build/daps-example/html/daps-example/index.html"

  logging ">>> testDAPS_html_chunk:End"
}

testDAPS_htmlsingle() {
# Purpose:
#  Runs daps htmlsingle, checks return value and checks several files
  logging "<<< testDAPS_htmlsingle:Start"
  # source DC-daps-example
  $DAPS htmlsingle
  assertTrue "daps htmlsingle returned != 0 (was $?)" "[[ $? -eq 0 ]]"
  logging $? "Creation of HTML single"

  logging ">>> testDAPS_htmlsingle:End"
}


# ALWAYS source it last:
source /usr/share/shunit2/src/shunit2

# EOF