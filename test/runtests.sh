#!/bin/bash
#
# This is the 
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
# We only consider directories with "test_*" which are our test suite
TESTSUITE=$(ls -d test_*)
#
SHUNIT2SRC="/usr/share/shunit2/src/shunit2"

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
# Synopsis:
#   $1 optional result from assert* functions
#   $2 message
# Examples:
#   logging 0 "Found x"
#   logging "Hello World"
# Returns:
#   Nothing, but writes message into $LOGFILE
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
[[ -f $SHUNIT2SRC ]] || exit_on_error "No shunit2 package found! :-(("


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

echo 

for i in $TESTSUITE; do
  echo -e "******************
     Calling test: $i 
******************"
  $i/testing.sh
done

# EOF