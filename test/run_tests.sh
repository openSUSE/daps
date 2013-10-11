#!/bin/bash
#
# Copyright (C) 2013 Frank Sundermeyer <fsundermeyer@opensuse.org>
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
_DAPSCMD="${_DAPSROOT}/bin/daps --dapsroot=${_DAPSROOT}"

# XSLT Processors
declare -a _XSLT_PROCESSORS

# XML sources
export _DOC_DIR="documents"
export _DCFILE="${_DOC_DIR}/DC-booktest_docbook"
export _MAIN="book.xml"
export _MAINPATH="${_DOC_DIR}/xml/$_MAIN"
export _MAIN_NOPROF="book_noprofile.xml"
export _MAINPATH_NOPROF="${_DOC_DIR}/xml/$_MAIN_NOPROF"

# Stylesheet directories
export _DB_STYLES=$(readlink -e "/usr/share/xml/docbook/stylesheet/nwalsh/current")
export _STANDARD_STYLES="${_DOC_DIR}/styles/standard"
export _STATIC_STYLES="${_DOC_DIR}/styles/statdir"

# arrays cannot be exported in bash (yet) ;-((
export _XML_FILES="appendix.xml part_blocks.xml part_inlines.xml part_profiling.xml"
export _SET_FILES="$_XML_FILES $_MAIN"
export _NO_SET_FILE="not_in_set.xml"

export _SET_IMAGES="dia/dia_example.dia eps/eps_example.eps fig/fig_example.fig jpg/jpg_example.jpg pdf/pdf_example.pdf png/png_example.png svg/svg_example.svg"
export _NO_SET_IMAGE="png/z_not_included.png"

# Tests
declare -a _TESTS=( "lib/000_source-validation" )

# shUnit2
export _SHUNIT2SRC="/usr/share/shunit2/src/shunit2"

# Statistics
_TOTAL=0
_FAILED=0
_SKIPPED=0
export _TEMPDIR=$(mktemp -d /tmp/daps-testing-stats_XXXXXX)

#----------
# local

# Script
_ME=$(basename $0)

# XSL-FO Processors to test
declare -a _FO_PROCS=( "fop" "xep" )


#--------------------------------
# Helper functions
#

# ---------
# Verbose error handling
#
function exit_on_error () {
    echo -e "ERROR: ${1}" >&2
    rm -rf "${_DOC_DIR}/build" "$_TEMPDIR"
    exit 1;
}

# ---------
# Handle Ctrl-Z Ctrl-C
#
trap "exit_on_error '\nCaught SIGTERM/SIGINT'" SIGTERM SIGINT


#########################################
# Checking requirements
#

declare -a _REQUIREMENTS
_REQUIREMENTS=( "epubcheck" "lynx" "pdfinfo" "xmllint" )

for _REQ in "${_REQUIREMENTS[@]}"; do
    which --skip-alias --skip-functions $_REQ >/dev/null 2>&1 || exit_on_error "Requirement $_REQ is not installed, exiting"
done


#########################################
# MAIN                                  #
#########################################

# I don't know a better approach than to store the stats in files
# because exporting variable in bash only works top down, not
# bottom up
for _STATFILE in failed skipped total; do
    echo 0 > ${_TEMPDIR}/$_STATFILE
done


_ARGS=$(getopt -o h -l all,builddir,epub,html,images,package-src,pdf,profiling,text,xsltprocessors: -n "$_ME" -- "$@")
eval set -- "$_ARGS"

# Exit when getopt returns errors
#
GETOPT_RETURN_CODE=$?
[[ 0 != $GETOPT_RETURN_CODE ]] && exit_on_error "Getopt returned the following error: $GETOPT_RETURN_CODE"

while true ; do
    case "$1" in
	--all)
	    _TESTS=( "${_TESTS[@]}" "lib/005_profiling" "lib/007_images" "lib/009_builddir" "lib/020_pdf" "lib/022_html")
	    shift
	    ;;
	--builddir)
	    _TESTS=( "${_TESTS[@]}" "lib/009_builddir" )
	    shift
	    ;;
	--epub)
	    _TESTS=( "${_TESTS[@]}" "lib/025_epub" )
	    shift
	    ;;
	-h)
	    usage
	    rm -rf "$_TEMPDIR"
	    exit 0
	    ;;
	--html)
	    _TESTS=( "${_TESTS[@]}" "lib/022_html" )
	    shift
	    ;;
	--images)
	    _TESTS=( "${_TESTS[@]}" "lib/007_images" )
	    shift
	    ;;
	--package-src)
	    _TESTS=( "${_TESTS[@]}" "lib/030_package-src" )
	    shift
	    ;;
	--pdf)
	    _TESTS=( "${_TESTS[@]}" "lib/020_pdf" )
	    shift
	    ;;
	--profiling)
	    _TESTS=( "${_TESTS[@]}" "lib/005_profiling" )
	    shift
	    ;;
	--text)
	    _TESTS=( "${_TESTS[@]}" "lib/023_text" )
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
	    *_html)
		for _HTMLCMD in "html" "single-html"; do
		    export _HTMLCMD
		    eval "$_TEST"
		done
		;;
	    *_pdf)
		for _FOPROC in "${_FO_PROCS[@]}"; do
		    which --skip-alias --skip-functions $_FOPROC >/dev/null 2>&1
		    # skip if XSL-FO processor does not exist
		    [ $? -ne 0 ] && continue
		    export _FOPROC
		    for _PDFCMD in "pdf" "color-pdf"; do
			export _PDFCMD
			eval "$_TEST"
		    done
		done
		;;
	    *_profiling)
		for _MAIN_PROFILING in "$_MAINPATH" "$_MAINPATH_NOPROF"; do
		    export _MAIN_PROFILING
		    if [[ "$_MAIN_PROFILING" =~ _noprofile ]]; then
			export _NOPROFILE=1
                        # when running the noprofile tests, MAIN is replaced
                        # by MAIN_NOPROF
			export _SET_FILES="$_XML_FILES $_MAIN_NOPROF"
		    else
			export _NOPROFILE=0
			export _SET_FILES="$_XML_FILES $_MAIN"
		    fi
		    eval "$_TEST"
		done
		;;
	    *_source-validation)
		eval "$_TEST"
		if [ $? -ne 0 ]; then
		    exit_on_error "Fatal: Test documents do not validate, exiting Tests"
		fi
		;;
	    *)
		eval "$_TEST"
		;;
	esac
	echo "...................."
    done
    echo
done

_FAILED=$(cat ${_TEMPDIR}/failed)
_SKIPPED=$(cat ${_TEMPDIR}/skipped)
_TOTAL=$(cat ${_TEMPDIR}/total)

_PASSED=$((_TOTAL - $((_FAILED + _SKIPPED)) ))

echo "--------------------------------------------------"
echo "Overall Statistics"
echo
echo "Tests Total:   $_TOTAL"
echo "Tests Passed:  $_PASSED"
echo "Tests Skipped: $_SKIPPED"
if [ 0 -ne $_FAILED ]; then
    ccecho "error" "Tests Failed:  $_FAILED"
else
    echo "Tests Failed:  $_FAILED"
fi


rm -rf "${_DOC_DIR}/build" "$_TEMPDIR"
