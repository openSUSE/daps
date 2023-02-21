#!/bin/bash
#
# Copyright (C) 2012-2020 SUSE Software Solutions Germany GmbH
#
# Author:
# Frank Sundermeyer <fsundermeyer at opensuse dot org>
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
export _PRJ_DIR="documents"
export _DCFILE="${_PRJ_DIR}/DC-booktest_docbook"
export _MAIN="book.xml"
export _MAINPATH="${_PRJ_DIR}/xml/$_MAIN"
export _MAIN_NOPROF="book_noprofile.xml"
export _MAINPATH_NOPROF="${_PRJ_DIR}/xml/$_MAIN_NOPROF"
export _BOOKNAME=$(basename $_DCFILE)
export _BOOKNAME="${_BOOKNAME#DC-*}"

# Stylesheet directories
export _DB_STYLES="/usr/share/xml/docbook/stylesheet/nwalsh/current"
export _STANDARD_STYLES="${_PRJ_DIR}/styles/standard"
export _STATIC_STYLES="${_PRJ_DIR}/styles/statdir"
export _ALT_STATIC_STYLES="${_PRJ_DIR}/styles/alt_statdir/"

# arrays cannot be exported in bash (yet) ;-((
export _XML_FILES="appendix.xml part_blocks.xml part_inlines.xml part_profiling.xml"
export _SET_FILES="$_XML_FILES $_MAIN"
export _NO_SET_FILE="not_in_set.xml"

#export _SET_IMAGES="dia/dia_example.dia ditaa/ditaa_example.ditaa jpg/jpg_example.jpg odg/odg_example.odg png/png_example.png png/png_example2.png svg/svg_example.svg"
export _SET_IMAGES="dia/dia_example.dia jpg/jpg_example.jpg odg/odg_example.odg png/png_example.png png/png_example2.png svg/svg_example.svg"
export _NO_SET_IMAGE="png/z_not_included.png"
export _MULTISRC_IMAGE="${_PRJ_DIR}/images/src/svg/png_example.svg"


export _SET_ID="dblayouttest"


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
    if [[ 1 -ne $_DEBUG ]]; then
        rm -rf "${_PRJ_DIR}/build"
    fi
    rm -rf "$_TEMPDIR"
    [[ -f $_MULTISRC_IMAGE ]] && rm -f $_MULTISRC_IMAGE
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
_REQUIREMENTS=( "epubcheck" "lynx" "pdfinfo" "xmllint" "xmlstarlet" )

for _REQ in "${_REQUIREMENTS[@]}"; do
    which --skip-alias --skip-functions $_REQ >/dev/null 2>&1 || exit_on_error "Requirement $_REQ is not installed, exiting"
done


#########################################
# MAIN                                  #
#########################################

# I don't know a better approach than to store the stats in files
# because exporting a variable in bash only works top down, not
# bottom up
for _STATFILE in failed skipped total; do
    echo 0 > ${_TEMPDIR}/$_STATFILE
done


_ARGS=$(getopt -o h -l all,asciidoc,builddir,debug,epub,filelists,help,html,images,locdrop,package-html,package-pdf,package-src,pdf,profiling,script,text,xsltprocessors: -n "$_ME" -- "$@")

[[ 0 -ne $? ]] && exit_on_error "Argument parser error"

eval set -- "$_ARGS"

# Exit when getopt returns errors
#
GETOPT_RETURN_CODE=$?
[[ 0 != $GETOPT_RETURN_CODE ]] && exit_on_error "Getopt returned the following error: $GETOPT_RETURN_CODE"

while true ; do
    case "$1" in
        --all)
            # FIXME: locdrop was originally commented in 2015 when it still
            # had SVN dependencies, however, these dependencies are now gone
            # & we probably only need to update the test a little, then add
            # "lib/033_locdrop" here again
            _TESTS=( "${_TESTS[@]}" "lib/001_script" "lib/005_profiling" "lib/007_images" "lib/009_builddir" "lib/010_filelists" "lib/020_pdf" "lib/022_html" "lib/023_text" "lib/025_epub" "lib/030_package-src" "lib/036_package-html" "lib/037_package-pdf" "lib/040_asciidoc" )
            shift
            ;;
        --asciidoc)
            _TESTS=( "${_TESTS[@]}" "lib/040_asciidoc" )
            shift
            ;;
        --builddir)
            _TESTS=( "${_TESTS[@]}" "lib/009_builddir" )
            shift
            ;;
        --debug)
            _DEBUG=1
            _DAPSCMD="$_DAPSCMD --debug"
            shift
            ;;
        --epub)
            _TESTS=( "${_TESTS[@]}" "lib/025_epub" )
            shift
            ;;
        --filelists)
            _TESTS=( "${_TESTS[@]}" "lib/010_filelists" )
            shift
            ;;
        -h,--help)
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
        --locdrop)
            _TESTS=( "${_TESTS[@]}" "lib/033_locdrop" )
            shift
            ;;
        --package-html)
            _TESTS=( "${_TESTS[@]}" "lib/022_html" "lib/036_package-html" )
            shift
            ;;
        --package-pdf)
            _TESTS=( "${_TESTS[@]}" "lib/020_pdf" "lib/037_package-pdf" )
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
        --script)
            _TESTS=( "${_TESTS[@]}" "lib/001_script" )
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
# sort -u also removes double entries that may have been introduced
# by package-html or package-pdf (both also pull in the regular html/pdf
# tests
#
declare -a _TESTS_SORTED=( $(printf '%s\0' "${_TESTS[@]}" | sort -zu | xargs -0) )

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
            *[_-]pdf)
                for _FOPROC in "${_FO_PROCS[@]}"; do
                    which --skip-alias --skip-functions $_FOPROC >/dev/null 2>&1
                    # skip if XSL-FO processor does not exist
                    [ $? -ne 0 ] && continue
                    export _FOPROC
                    eval "$_TEST"
                done
                ;;
            *_profiling)
                for _MAIN_PROFILING in "$_MAINPATH" "$_MAINPATH_NOPROF"; do
                    export _MAIN_PROFILING
                    if [[ "$_MAIN_PROFILING" =~ _noprofile ]]; then
                        export _NOPROFILE=1
                        # when running the noprofile tests, MAIN is replaced
                        # by MAIN_NOPROF
                        export _PROF_SET_FILES="$_XML_FILES $_MAIN_NOPROF"
                    else
                        export _NOPROFILE=0
                        export _PROF_SET_FILES="$_XML_FILES $_MAIN"
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
echo "Tests Failed:  $_FAILED"
rm -rf "${_PRJ_DIR}/build" "$_TEMPDIR"
if [ 0 -ne $_FAILED ]; then
    exit 1
fi
