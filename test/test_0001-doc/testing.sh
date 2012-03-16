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

# If TEMPDIR variable is not set, use current directory
TEMPDIR=${TEMPDIR:-"."}

DCFILE="DC-daps-user"

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

test_Userguide_validate() {
# Purpose:
#  Validate DAPS user guide
  logging "<<< $MAIN::test_userguide-validate:Start"
  $DAPS -d $DCFILE validate
  assertTrue "daps validate returned != 0 (was $?)" "[[ $? -eq 0 ]]"
  logging $? "Validated DAPS User Guide"
  logging "<<< $MAIN::test_userguide-validate:End"
}

test_Userguide_htmlsingle() {
# Purpose:
#   Create single HTML
  logging "<<< $MAIN::test_userguide-htmlsingle:Start"
  # pushd $TEMPDIR
  $DAPS htmlsingle
  # popd
  assertTrue "daps htmlsingle returned != 0 (was $?)" "[[ $? -eq 0 ]]"
  logging $? "Create single HTML DAPS User Guide"
  
  logging "<<< $MAIN::test_userguide-htmlsingle:End"
}

# ALWAYS source it last:
source $SHUNIT2SRC

# EOF