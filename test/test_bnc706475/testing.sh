#!/bin/bash
#
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

oneTimeSetUp() {
  logging "--- Setting up DAPS Testing Framework ($MAIN)..."
  mkdir -vp $TEMPDIR
  assertTrue "Could not find temporary directory $TEMPDIR" "[ -d $TEMPDIR ]"
  logging "Starting ${PROG}"
}

oneTimeTearDown() {
  # TODO: Distinguish between running alone and from runtests.sh
  # Delete temporary directory, when DELTEMP is enabled
  # [[ -d $TEMPDIR && 0 -ne $DELTEMP ]] && rm -rf $TEMPDIR

  if [[ $LOGGING -ne 0 ]]; then
    echo "Find the logging output in $LOGFILE"
  fi
  logging "--- Tearing down DAPS Testing Framework ($MAIN)..."
}


# ----------------------------------------------------------------------------
# Test functions
#

test_X() {
  assertTrue "Not equal" "[[ 1 -eq 1 ]]"
}

# ALWAYS source it last:
source $SHUNIT2SRC

# EOF