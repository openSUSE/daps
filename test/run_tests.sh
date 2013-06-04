#!/bin/bash
#
# Copyright (C) 2011-2013 Frank Sundermeyer <fsundermeyer@opensuse.org>
#
# Author:
# Frank Sundermeyer <fsundermeyer@opensuse.org>
#
# Testing DAPS: Main testing script
#

#--------------------------------
# Global Variable Definitions
#
# Use _VARNAME for variables that also might be used in DAPS itself to 
# avoid potential clashes. Just to be on the safe side.
#

# DAPS
export _DAPSROOT=".."
DAPSCMD="${_DAPSROOT}/bin/daps --dapsroot=\"${_DAPSROOT}\""

# XSLT Processors
declare -ax _XSLT_PROCESSORS=( "/usr/bin/xsltproc" )
which --skip-alias --skip-functions /usr/bin/saxon6 >/dev/null 2>&1
if [ $? -eq 0 ]; then
    _XSLT_PROCESSORS=( "${_XSLT_PROCESSORS[@]}" "/usr/bin/saxon6" )
else
    echo
    echo "Warning: Did not found saxon6, only testing xsltproc"
fi


# XML sources
export _DOC_DIR="documents"
export _MAIN="book.xml"
export _MAINPATH="${_DOC_DIR}/xml/$_MAIN"
export _MAIN_NOPROF="book_noprofile.xml"
export _MAINPATH_NOPROF="${_DOC_DIR}/xml/$_MAIN_NOPROF"
declare -ax _SET_FILES=( appendix.xml $_MAIN part_blocks.xml part_inlines.xml part_profiling.xml )
export _NO_SET_FILE="not_in_set.xml"

# Tests
declare -ax TESTS=( "lib/000_source-validation" )

# Script
ME=$(basename $0)

# shUnit2
export SHUNIT2SRC="/usr/share/shunit2/src/shunit2"

#--------------------------------
# Helper functions
#

# ---------
# Verbose error handling
#
function exit_on_error () {
    echo -e "ERROR: ${1}" >&2
    exit 1;
}

#########################################
# MAIN                                  #
#########################################

ARGS=$(getopt -o h -l all,profiling -n "$ME" -- "$@")
eval set -- "$ARGS"

while true ; do
    case "$1" in
	--all)
	    TESTS=( "${TESTS[@]}" "lib/005_profiling" )
	    shift
	    ;;
	-h)
	    usage
	    exit 0
	    ;;
	--profiling)
	    TESTS=( "${TESTS[@]}" "lib/005_profiling" )
	    shift
	    ;;
        --) 
	    shift
	    break
	    ;;
        *) 
	    exit_on_error "Internal error!"
	    ;;
    esac
done

echo

# run tests

# Sort tests since it makes sense to execute them in a given order
# http://stackoverflow.com/questions/7442417/how-to-sort-an-array-in-bash
#
declare -a TESTS_SORTED=( $(printf '%s\0' "${TESTS[@]}" | sort -z | xargs -0) )

for PROC in "${_XSLT_PROCESSORS[@]}"; do
    echo
    echo "###########################################################"
    echo "# $PROC "
    echo "###########################################################"
    export DAPSEXEC="$DAPSCMD --xsltprocessor=${PROC}"
    for TEST in "${TESTS_SORTED[@]}"; do

        # TODO:
        # Check return state of tests and act - if e.g. profiling fails it 
        # does not make sense to run the majority of other tests
        #
	case "$TEST" in
	    *_source-validation)
		eval "$TEST" ||
		if [ $? -ne 0 ]; then
		    exit_on_error "Fatal: Test documents do not validate, exiting Tests"
		fi
		;;
	    *_profiling)
		for MAINPATH in "$_MAINPATH" "$_MAINPATH_NOPROF"; do
		    export MAINPATH
		    if [[ "$MAINPATH" =~ _noprofile ]]; then
			export NOPROFILE=1
		    else
			export NOPROFILE=0
		    fi
		    eval "$TEST"
		done
		;;
	    *)
		eval "$TEST"
		;;
	esac
	echo "...................."
    done
    echo
done
