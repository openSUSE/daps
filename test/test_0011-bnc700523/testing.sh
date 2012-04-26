#!/bin/bash
#
# Testing guimenu inside titles
# Required: package xmlstarlet (/usr/bin/xml)
# (C) 2012 Thomas Schraitle <toms@opensuse.org>
#
# set -x

MAIN=${0%%/*}
PROG=${0##*/}
PROGPATH=$(readlink -m "$PROG")

ABSPATH=$(dirname "$PROGPATH")
COMMON=$(readlink -m "$ABSPATH/../common.sh")


if [[ -f $COMMON ]]; then
  source $COMMON
fi

DC="DC-guimenu"
DAPSROOT="../.."
DAPS="${DAPSROOT}/bin/daps"



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
 -D,--daps PATH_TO_DAPS
     path and scriptname to daps tool 
 -k, --keeptemp
     Do not delete the TEMPDIR directory, default ${DELTEMP}
EOF
exit 0
}

if ! options=$(getopt -o h,t:,k,d:  -l help,tempdir:,keeptemp,daps: -- "$@"); then
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
  logging "pwd=$PWD"
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

test_guimenu_in_title() {
  logging "> pwd=$PWD"
  FILE=$($DAPS --color=0 --dapsroot "$DAPSROOT" -d $DC htmlsingle)
  logging "> file=$FILE"
  assertNotNull "Expected file" "$FILE"
  RES=$(xml sel -N h=http://www.w3.org/1999/xhtml -t \
    -v "//h:a[@href='#chap.guimenu']/h:span[@class='guimenu'][1]" \
    $FILE )
   logging "> result=$RES"
   assertEquals "Expected 'File' in guimenu" "File" "$X"
}

# ALWAYS source it last:
source $SHUNIT2SRC

# EOF
