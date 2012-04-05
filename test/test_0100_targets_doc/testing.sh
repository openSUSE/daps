#!/bin/bash

declare -a DOC_TARGETS=( color-pdf pdf html htmlsingle webhelp jsp txt epub wiki)

SHUNIT2SRC="/usr/share/shunit2/src/shunit2"
DAPSROOT="../.."
DAPS="${DAPSROOT}/bin/daps"
DC="../docs_to_test/DC-booktest"

# clean results
rclean() {
    $DAPS -d $DC --dapsroot $DAPSROOT --builddir $SHUNIT_TMPDIR \
        clean-results > /dev/null
}

get_htmldir() {
    $DAPS -d $DC --builddir $SHUNIT_TMPDIR --dapsroot $DAPSROOT \
        html-dir-name "$@"
}
#
# ------------------------- TESTING --------------------------------------
#

# clean results
test_clean() {
    rclean
    assertTrue "Result cleaning does not work" "[[ $? -eq 0 ]]"
}


# Get HTML result directory
test_HTML_dir() {
    local DIR DIRNAME NAME PARAM 
    #-----------
    # Check basic functionality
    #
    get_htmldir
    assertTrue "Getting the HTML result directory failed" "[[ $? -eq 0 ]]"
    #-----------
    # Check --name parameter
    #
    NAME="testname"
    DIR=$(get_htmldir "--name $NAME")
    DIRNAME=$(basename $DIR)
    assertEquals "The result directory naming does not adhere to the --name parameter" "$NAME" "$DIRNAME"
    #-----------
    # Check --comments, --draft and --remarks parameter
    #
    for PARAM in comments draft remarks; do
        DIR=$(get_htmldir "--$PARAM")
        expr match "$DIR" ".*\(_$PARAM\)" >/dev/null 2>&1
        assertTrue "The result directory naming ($DIR) does not adhere to the --$PARAM parameter" "[[ $? -eq 0 ]]"
    done
}

# HTML
test_HTML() {
    local FILE
    rclean
    FILE=$($DAPS -d $DC --builddir $SHUNIT_TMPDIR --dapsroot $DAPSROOT html)
    assertTrue "Regular HTML build failed" "[[ $? -eq 0 ]]"
    assertTrue "Regular HTML result file $FILE does not exist" \
        "[[ -f ${FILE#file://} ]]"
}

test_distHTML() {
    local FILE
    rclean
    FILE=$($DAPS -d $DC --builddir $SHUNIT_TMPDIR --dapsroot $DAPSROOT \
        dist-html)
    assertTrue "dist-html build failed" "[[ $? -eq 0 ]]"
    assertTrue "dist-html result file $FILE does not exist" \
        "[[ -f $FILE ]]"
}

# HTML main
test_HTMLmain() {
    rclean
    $DAPS --main ${DAPSROOT}/doc/xml/MAIN.DAPS.xml \
        --builddir $SHUNIT_TMPDIR --dapsroot $DAPSROOT html
    assertTrue "Regular HTML build from MAIN failed" "[[ $? -eq 0 ]]"
}

# HTML static
test_HTML_options() {
    local DIR FILE LINKS
    DIR=$(get_htmldir)
    #-----------
    # check static mode
    #
    rclean
    FILE=$($DAPS -d $DC --builddir $SHUNIT_TMPDIR --dapsroot $DAPSROOT \
        html --static)
    assertTrue "Static HTML build failed" "[[ $? -eq 0 ]]"
    # check if result dir contains links
    LINKS=$(find $DIR -type l 2>/dev/null) # should only contain index.html
    FILE=${FILE#file://}
    LINKS=${LINKS#$FILE} # remove index.html
    assertNull "A static HTML result dir must not contain links ($LINKS)" \
        "$LINKS"
    #-----------
    # check draft mode
    #
    rclean
    FILE=$($DAPS -d $DC --builddir $SHUNIT_TMPDIR --dapsroot $DAPSROOT \
        html --draft)
    egrep "background-image: url\('style_images/draft(_html)?\.png'\)" ${FILE#file://} >/dev/null 2>&1
    assertTrue "Draft build does not contain watermark image" "[[ $? -eq 0 ]]"
    #-----------
    # check if remarks are displayed
    #
    rclean
    DIR=$(get_htmldir --remarks --comments)
    $DAPS -d $DC --builddir $SHUNIT_TMPDIR --dapsroot $DAPSROOT \
        html --remarks --comments
    grep "Remark [12]" ${DIR}/*.html >/dev/null 2>&1
    assertTrue "Remarks build does not contain remarks" "[[ $? -eq 0 ]]"
}

test_HTML_name() {
    local DIR NAME DIRNAME
    NAME="testname"
    DIR=$(get_htmldir "--name $NAME")
    DIRNAME=$(basename $DIR)
    assertEquals "The result directory naming does not adhere to the --name parameter" "$NAME" "$DIRNAME"
}


# ALWAYS source it last:
source $SHUNIT2SRC

# EOF
