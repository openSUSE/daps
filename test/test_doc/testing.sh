#!/bin/bash
#
# Testing 
#
# (C) 2012 Thomas Schraitle <toms@opensuse.org>
#

if [[ -f common.sh ]]; then
  source common.sh
elif [[ -f ../common.sh ]]; then
  source ../common.sh
fi


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


test_XYZ() {
  assertTrue "Not equal" "[[ 1 -eq 1 ]]"
}


# ALWAYS source it last:
source $SHUNIT2SRC

# EOF