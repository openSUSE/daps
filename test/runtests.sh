#!/bin/bash
#
# This is the wrapper script to call each test function individually
#
# See file:///usr/share/doc/packages/shunit2/shunit2.html
# Needs the shunit2 package
#
# (C) 2012 Thomas Schraitle <toms@opensuse.org>
#

## TODO:
## - Better error handling: 
##


# Source common functions
source common.sh

MAIN=${0%%/*}
PROG=${0##*/}


# ----------------------------------------------------------------------------
# Global Variables
#
# Remove temporary directory? 0=no, 1=yes
DELTEMP=1
# Logging actions to $LOGFILE? 0=no, 1=yes
LOGGING=1
# Default path to daps script:
DAPS="/usr/bin/daps"
# Default path to daps-init script:
DAPS_INIT="/usr/bin/daps-init"
# We only consider directories with "test_*" which are our test suite
TESTSUITE=$(ls -d test_*)
# Verbose flag, 0=no, 1=yes
VERBOSE=0

usage() {
cat << EOF
${PROG} [OPTIONS...]
DAPS Testing Framework

Available Options:
 -h, --help
     Shows this help
 -q, --quite
     Suppress output (default)
 -v, --verbose
     Be more noisy
 -t, --base-temp TEMPDIR
     Use TEMPDIR (no default set); useful if you do not want to create a
     temporary directory again and want to use it from the last run.
     Combine it with -k.
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
# Parsing Command Line Options
if ! options=$(getopt -o h,v,q,t:,i:,l:,D:,k  -l help,verbose,quiet,base-temp:,dapsinit:,logfile:,daps:,keeptemp -- "$@"); then
    exit 1
fi

eval set -- "$options"

# TODO: Add --dapsroot to overwrite some it?
while [ $# -gt 0  ]; do
  case "$1" in                                                    
    -h|--help) usage;;
    -v|--verbose)
        VERBOSE=1
        ;;
    -q|--quiet)
        VERBOSE=0
        ;;
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
    -t|--base-temp)
       T=$2
       [[ -d $T ]] || mkdir -p $T
       TEMPDIR=$T
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

# If TEMPDIR is set, use it and don't create a temp directory
if [[ ! "$TEMPDIR" ]]; then
TEMPDIR=$(mktemp -d /tmp/daps-testing_XXXXXX)
fi

# Copy our common functions
cp common.sh $TEMPDIR

# Iterate through our "testsuite" and rsync it
for i in $TESTSUITE; do
  message $VERBOSE -e "******************
     Calling test: $i
******************"
  # mkdir -vp $TEMPDIR/$i
  # We use rsync here to dereference any symbolic links:
  opt="-azL"
  [[ 0 -ne $VERBOSE ]] && opt="$opt -v"
  rsync $opt --exclude=.svn --exclude=\*.~ $i $TEMPDIR
  pushd $TEMPDIR/$i
  ./testing.sh --tempdir $TEMPDIR/$i
  RESULT=$?
  logging $VERBOSE "Result from $i/testing.sh: $RESULT"
  [[ 0 -ne $RESULT ]] && exit_on_error "Test suite failed"
  popd
done

# Delete temporary directory, when DELTEMP is enabled
[[ -d $TEMPDIR && 0 -ne $DELTEMP ]] && rm -rf $TEMPDIR


# EOF