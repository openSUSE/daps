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
DAPSEXEC="${_DAPSROOT}/bin/daps --dapsroot=\"${_DAPSROOT}\""

# XSLT Processors
declare -ax _XSLT_PROCESSORS=( "/usr/bin/xsltproc" "/usr/bin/saxon6" )

# XML sources
export _DOC_DIR="documents/"
export _MAIN="book.xml"
export MAINPATH="${_DOC_DIR}/xml/$_MAIN"
declare -ax _SET_FILES=( appendix.xml book.xml part_blocks.xml part_inlines.xml part_profiling.xml )
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
    clean_daps
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
    export DAPSEXEC="$DAPSEXEC --xsltprocessor=${PROC}"
    for TEST in "${TESTS_SORTED[@]}"; do

        # TODO:
        # Check return state of tests and act - if e.g. profiling fails it 
        # does not make sense to runthe majority of other tests
        #
	eval "$TEST"
	echo "...................."
    done
    echo
done
