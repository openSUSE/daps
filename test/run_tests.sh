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
_DAPSCMD="${_DAPSROOT}/bin/daps --dapsroot=\"${_DAPSROOT}\""

# XSLT Processors
declare -a _XSLT_PROCESSORS

# XML sources
export _DOC_DIR="documents"
export _DCFILE="${_DOC_DIR}/DC-booktest"
export _MAIN="book.xml"
export _MAINPATH="${_DOC_DIR}/xml/$_MAIN"
export _MAIN_NOPROF="book_noprofile.xml"
export _MAINPATH_NOPROF="${_DOC_DIR}/xml/$_MAIN_NOPROF"

# arrays cannot be exported in bash (yet) ;-((
export _XML_FILES="appendix.xml part_blocks.xml part_inlines.xml part_profiling.xml"
export _SET_FILES="$_XML_FILES $_MAIN"
export _NO_SET_FILE="not_in_set.xml"

# Tests
declare -a _TESTS=( "lib/000_source-validation" )

# Script
_ME=$(basename $0)

# shUnit2
export _SHUNIT2SRC="/usr/share/shunit2/src/shunit2"

# Statistics
_TEST_COUNT=0
_TEST_PASSED=0
_TEST_FAILED=0


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

_ARGS=$(getopt -o h -l all,pdf,profiling,xsltprocessors: -n "$_ME" -- "$@")
eval set -- "$_ARGS"

while true ; do
    case "$1" in
	--all)
	    _TESTS=( "${_TESTS[@]}" "lib/005_profiling" "lib/020_color-pdf" )
	    shift
	    ;;
	-h)
	    usage
	    exit 0
	    ;;
	--pdf)
	    _TESTS=( "${_TESTS[@]}" "lib/020_color-pdf" )
	    shift
	    ;;
	--profiling)
	    _TESTS=( "${_TESTS[@]}" "lib/005_profiling" )
	    shift
	    ;;
	--xsltprocessors)
	    _XSLTPROCS=( $2 )
	    shift 2
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

# check _XSLT_PROCESSORS
#
if [[ -n "${_XSLTPROCS[@]}" ]]; then
    for _PROC in "${_XSLTPROCS[@]}"; do
	which --skip-alias --skip-functions $_PROC >/dev/null 2>&1 
	if [ $? -eq 0 ]; then
	    _XSLT_PROCESSORS=( "${_XSLT_PROCESSORS[@]}" "$_PROC" )
	else
	    echo "Warning: Did not found xslt processor $_PROC"
	fi
    done
else
    _XSLT_PROCESSORS=( "/usr/bin/xsltproc" )
    which --skip-alias --skip-functions /usr/bin/saxon6 >/dev/null 2>&1
    if [ $? -eq 0 ]; then
	_XSLT_PROCESSORS=( "${_XSLT_PROCESSORS[@]}" "/usr/bin/saxon6" )
    fi    
fi

if [[ -z "${_XSLT_PROCESSORS[@]}" ]]; then
    exit_on_error "Fatal: No valid xslt processor found/specified"
else
    echo "############################################################"
    echo "#       Testing DAPS $(date)         #"
    echo "############################################################"
    echo "#"
    echo "# XSLT Processors: ${_XSLT_PROCESSORS[@]}"
    echo "#"
fi

# run tests

# Sort tests since it makes sense to execute them in a given order
# http://stackoverflow.com/questions/7442417/how-to-sort-an-array-in-bash
#
declare -a _TESTS_SORTED=( $(printf '%s\0' "${_TESTS[@]}" | sort -z | xargs -0) )

for _PROC in "${_XSLT_PROCESSORS[@]}"; do
    echo
    echo "==========================================================="
    echo "= $_PROC "
    echo "==========================================================="
    export _DAPSEXEC="$_DAPSCMD --xsltprocessor=${_PROC}"
    for _TEST in "${_TESTS_SORTED[@]}"; do

        # TODO:
        # Check return state of tests and act - if e.g. profiling fails it 
        # does not make sense to run the majority of other tests
        #
	case "$_TEST" in
	    *_source-validation)
		eval "$_TEST"
		if [ $? -ne 0 ]; then
		    exit_on_error "Fatal: Test documents do not validate, exiting Tests"
		fi
		;;
	    *_profiling)
		for _MAINFILE_PATH in "$_MAINPATH" "$_MAINPATH_NOPROF"; do
		    export _MAINFILE_PATH
		    if [[ "$_MAINFILE_PATH" =~ _noprofile ]]; then
			export _NOPROFILE=1
                        # when running the noprofile tests, MAIN is replaced
                        # by MAIN_NOPROF
			export _SET_FILES="$_XML_FILES $_MAIN_NOPROF"
		    else
			export _NOPROFILE=0
		    fi
		    eval "$_TEST"
		done
		;;
	    *)
		eval "$_TEST"
		;;
	esac
	echo "...................."
    done
    echo
done
