#!/bin/sh

# set -x

export XSPEC_HOME="xspec"
export CLASSPATH=${CLASSPATH}:CatalogManager.properties


usage() {
    if test -n "$1"; then
        echo "$1"
        echo;
    fi
    echo "Usage: xspec [OPTIONS] filename [coverage]"
    echo
    echo "Options:"
    echo "  -t         test an XSLT stylesheet (the default)"
    echo "  -q         test an XQuery module (mutually exclusive with -t)"
    echo "  -c         output test coverage report"
    echo "  -h         display this help message"
    echo "  --catalogs=LIST"
    echo "             (semi)colon-separated list of XML catalog files"
    echo "  --catalog-verbose=INTEGER"
    echo "             Integer (0..99) to specify the verbosity of catalog messages"
    echo
    echo "  filename   the XSpec document"
    echo "  coverage   deprecated, use -c instead"
}

die() {
    echo
    echo "*** $@" >&2
    exit 1
}

xslt() {
   saxon9 $CATS $CATALOG_VERB "$@"
}
xquery() {
   saxon9q "$@"
}


##
## options ###################################################################
##
while [[ ${1:0:1} = '-' ]]; do
    case "$1" in
        # XSLT
        -t)
            if test -n "$XQUERY"; then
                usage "-t and -q are mutually exclusive"
                exit 1
            fi
            XSLT=1;;
        # XQuery
        -q)
            if test -n "$XSLT"; then
                usage "-t and -q are mutually exclusive"
                exit 1
            fi
            XQUERY=1;;
        # Coverage
        -c)
            COVERAGE=1;;
        # Help!
        -h)
            usage
            exit 0;;
        --catalogs=*)
           # All parsing is done in the saxon script, so delegate it
           CATS=$1          
           ;;
        --catalog-verbose=*)
           CATALOG_VERB=$1
           ;;
        --catalog-verbose)
          CATALOG_VERB="--catalog-verbose=3"
           ;;
        # Unknown option!
        -*)
            usage "Error: Unknown option: $1"
            exit 1;;
    esac
    shift;
done

# set XSLT if XQuery has not been set (that's the default)
if test -z "$XQUERY"; then
    XSLT=1;
fi
XSPEC=$1
if [ -n "$2" ]; then
    if [ "$2" != coverage ]; then
        usage "Error: Extra option: $2"
        exit 1
    fi
    echo "Long-form option 'coverage' deprecated, use '-c' instead."
    COVERAGE=1
    if [ -n "$3" ]; then
        usage "Error: Extra option: $3"
        exit 1
    fi
fi

##
## files and dirs ############################################################
##

TEST_DIR=./build/
TARGET_FILE_NAME=$(basename "$XSPEC" | sed 's:\...*$::')

COMPILED=$TEST_DIR/$TARGET_FILE_NAME.xsl
COVERAGE_XML=$TEST_DIR/$TARGET_FILE_NAME-coverage.xml
COVERAGE_HTML=$TEST_DIR/$TARGET_FILE_NAME-coverage.html
RESULT=$TEST_DIR/$TARGET_FILE_NAME-result.xml
HTML=$TEST_DIR/$TARGET_FILE_NAME-result.html
COVERAGE_CLASS=com.jenitennison.xslt.tests.XSLTCoverageTraceListener


if test -n "$XSLT"; then
    COMPILED=$TEST_DIR/$TARGET_FILE_NAME.xsl
else
    COMPILED=$TEST_DIR/$TARGET_FILE_NAME.xq
fi

if [ ! -d "$TEST_DIR" ]
then
    echo "---- Creating XSpec Directory at $TEST_DIR..."
    mkdir "$TEST_DIR"
    echo
fi 

##
## compile the suite #########################################################
##
if test -n "$XSLT"; then
    COMPILE_SHEET=generate-xspec-tests.xsl
else
    COMPILE_SHEET=generate-query-tests.xsl
fi
echo "---- Creating Test Stylesheet..."
xslt -o:"$COMPILED" -s:"$XSPEC" \
    -xsl:"$XSPEC_HOME/src/compiler/$COMPILE_SHEET" \
    || die "Error compiling the test suite"
echo

##
## run the suite #############################################################
##

echo "---- Running Tests..."
if test -n "$XSLT"; then
    # for XSLT
    if test -n "$COVERAGE"; then
        echo "Collecting test coverage data; suppressing progress report..."
        xslt -T:$COVERAGE_CLASS \
            -o:"$RESULT" -s:"$XSPEC" -xsl:"$COMPILED" \
            -it:{http://www.jenitennison.com/xslt/xspec}main 2> "$COVERAGE_XML" \
            || die "Error collecting test coverage data"
    else
        xslt -o:"$RESULT" -s:"$XSPEC" -xsl:"$COMPILED" \
            -it:{http://www.jenitennison.com/xslt/xspec}main \
            || die "Error running the test suite"
    fi
else
    # for XQuery
    if test -n "$COVERAGE"; then
        echo "Collecting test coverage data; suppressing progress report..."
        xquery -T:$COVERAGE_CLASS \
            -o:"$RESULT" -s:"$XSPEC" "$COMPILED" 2> "$COVERAGE_XML" \
            || die "Error collecting test coverage data"
    else
        xquery -o:"$RESULT" -s:"$XSPEC" "$COMPILED" \
            || die "Error running the test suite"
    fi
fi

##
## format the report #########################################################
##

echo
echo "---- Formatting Report..."
xslt -o:"$HTML" \
    -s:"$RESULT" \
    -xsl:"$XSPEC_HOME/src/reporter/format-xspec-report.xsl" \
    || die "Error formating the report"
if test -n "$COVERAGE"; then
    xslt -l:on \
        -o:"$COVERAGE_HTML" \
        -s:"$COVERAGE_XML" \
        -xsl:"$XSPEC_HOME/src/reporter/coverage-report.xsl" \
        "tests=$XSPEC" \
        "pwd=file:`pwd`/" \
        || die "Error formating the coverage report"
    echo "Report available at $COVERAGE_HTML"
    #$OPEN "$COVERAGE_HTML"
else
    echo "Report available at $HTML"
    #$OPEN "$HTML"
fi

echo "Done."

