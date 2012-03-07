#!/bin/bash
#
# This is a testing framework for DAPS (DocBook Authoring and Publishing Suite)
# It tests several issues regarding document creation 
#
# Needs the shunit2 package
#
# (C) 2012 Thomas Schraitle <toms@opensuse.org>
#

# ----------------------------------------------------------------------------
# Global Variables
DELTEMP=0
DAPS="/local/doc/daps/bin/daps"
DAPS_INIT="/local/doc/daps/bin/daps-init"
LOGFILE="/tmp/daps-testing.log"
LOGGING=1

usage() {
cat << EOF
${0##*/} [-h|--help] [-i|--dapsinit DAPS_INIT] [-l|--logfile LOGFILE]
DAPS Testing Framework

-h, --help         Shows this help
-i, --dapsinit     Absolute path to the daps-init program
-l, --logfile      Save result in LOGFILE (default $LOGFILE)
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
# Logs a message ($1) in $LOGFILE only when $LOGGING is != 0
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

    DATE=$(date +"[%d-%m-%YT%M:%S]")
    if [[ $RESULT -eq 0 ]]; then
      echo "$DATE: $MSG" >> $LOGFILE
    else
      echo "$DATE: [ERROR] $MSG" >> $LOGFILE
    fi
  fi
}

# ---------
# Short test 
[[ -f /usr/share/shunit2/src/shunit2 ]] || exit_on_error "No shunit2 package found! :-(("


# ---------
# Parsing Command Line Options
if ! options=$(getopt -o h,i:,l: -l help,dapsinit:,logfile: -- "$@"); then
    exit 1
fi

eval set -- "$options"
while [ $# -gt 0  ]; do
  case "$1" in                                                    
    -h|--help) usage;;
    -i|--dapsinit)
        if [[ ! -f $1 ]]; then
           exit_on_error "$1 does not exist"
        fi
        DAPS_INIT=$2
        shift
        ;;
    -l|--logfile)
       # Make *absolute* filename to avoid problems when 
       # switching to other directories
       LOGFILE=$(readlink -f $2)
       shift
       ;;
    (--) shift; break;;                                           
    (-*) exit_on_error "${0##*/}: error - unrecognized option $1" ;; 
    (*)  break;;
  esac
 shift
done

# ---------
# Creating temporary directory
TEMPDIR=$(mktemp -d /tmp/daps-testing_XXXXXX)


# ----------------------------------------------------------------------------
# Creating DAPS Testing Environment
#
oneTimeSetUp() {
  echo "--- Setting up DAPS Testing Framework..."
  assertTrue "Could not find temporary directory $TEMPDIR" "[ -d $TEMPDIR ]"
  logging "Starting ${0##*/}"
}

oneTimeTearDown() {
  echo "--- Tearing down DAPS Testing Framework ..."
  if [[ -d $TEMPDIR ]]; then
    [[ 0 -ne $DELTEMP ]] && rm -rf $TEMPDIR
  fi
  if [[ $LOGGING -ne 0 ]]; then
    echo "Find the logging output in $LOGFILE"
  fi
}


# ----------------------------------------------------------------------------
# DAPS Testing Function
#
# Test functions are executed in the given order

testDAPS_Init() {
  logging "<<< testDAPS_Init:Start"
  cd $TEMPDIR
  CONTENTS=$(ls)
  assertNull "The temp dir contains something which was not expected" "$CONTENTS"

  $DAPS_INIT  -d . -r book
  assertTrue "daps-init returned != 0 (was $?)" "[[ $? -eq 0 ]]"
  logging $? "daps-init was successful"

  # Enable export, to make it "sourceable":
  sed -i 's/^#export DOCCONF_NAME/export DOCCONF_NAME/g' DC-daps-example

  assertTrue "Could not find file DC-daps-example" "[[ -f DC-daps-example ]]"
  logging $? "Found DC-daps-example file"

  assertTrue "Could not find xml directory" "[[ -d xml ]]"
  logging $? "Found xml directory"

  assertTrue "Could not find images directory" "[[ -d images ]]"
  logging $? "Found images directory"

  assertTrue "Could not find images/src directory" "[[ -d images/src ]]"
  logging $? "Found images/src directory"

  assertTrue "Could not find images/src directory" "[[ -d images/src/dia ]]"
  logging $? "Found images/src/dia directory"

  assertTrue "Could not find images/src directory" "[[ -d images/src/eps ]]"
  logging $? "Found images/src/eps directory"

  assertTrue "Could not find images/src directory" "[[ -d images/src/fig ]]"
  logging $? "Found images/src/fig directory"

  assertTrue "Could not find images/src directory" "[[ -d images/src/pdf ]]"
  logging $? "Found images/src/pdf directory"

  assertTrue "Could not find images/src directory" "[[ -d images/src/png ]]"
  logging $? "Found images/src/png directory"

  assertTrue "Could not find images/src directory" "[[ -d images/src/svg ]]"
  logging $? "Found images/src/svg directory"

  logging ">>> testDAPS_Init:End"
}

testDAPS_Validate() {
  logging "<<< testDAPS_Validate:Start"
  source DC-daps-example
  $DAPS validate
  assertTrue "daps validate returned != 0 (was $?)" "[[ $? -eq 0 ]]"
  logging $? "Validation successful"

  assertTrue "Could not find build directory" "[[ -d build ]]"
  logging $? "Found build directory"

  logging ">>> testDAPS_Validate:End"
}


testDAPS_html_chunk() {
  logging "<<< testDAPS_html_chunk:Start"
  source DC-daps-example
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
  logging "<<< testDAPS_htmlsingle:Start"
  source DC-daps-example
  $DAPS htmlsingle
  assertTrue "daps htmlsingle returned != 0 (was $?)" "[[ $? -eq 0 ]]"
  logging $? "Creation of HTML single"

  logging ">>> testDAPS_htmlsingle:End"
}

# ALWAYS source it last:
source /usr/share/shunit2/src/shunit2

# EOF