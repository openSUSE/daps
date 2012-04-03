#!/bin/bash

declare -a DOC_TARGETS=( color-pdf pdf html htmlsingle webhelp jsp txt epub wiki)

SHUNIT2SRC="/usr/share/shunit2/src/shunit2"
DAPSROOT="../.."
DAPS="${DAPSROOT}/bin/daps"
DC="${DAPSROOT}/doc/DC-daps-user"



# clean results
rclean() {
    $DAPS -d $DC --dapsroot $DAPSROOT --builddir $SHUNIT_TMPDIR clean-results > /dev/null
}

get_htmldir() {
    $DAPS -d $DC --builddir $SHUNIT_TMPDIR --dapsroot $DAPSROOT html-dir-name
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
    get_htmldir
    assertTrue "Getting the HTML result directory failed" "[[ $? -eq 0 ]]"
}

# HTML
test_HTML() {
    local FILE
    FILE=$($DAPS -d $DC --builddir $SHUNIT_TMPDIR --dapsroot $DAPSROOT html)
    assertTrue "Regular HTML build failed" "[[ $? -eq 0 ]]"
    assertTrue "Regular HTML build result file $FILE does not exist" "[[ -f ${FILE#file://} ]]"
}

test_distHTML() {
    local FILE
    rclean
    FILE=$($DAPS -d $DC --builddir $SHUNIT_TMPDIR --dapsroot $DAPSROOT dist-html)
    assertTrue "dist-html build failed" "[[ $? -eq 0 ]]"
    assertTrue "dist-html build result file $FILE does not exist" "[[ -f $FILE ]]"
}

# HTML main
test_HTML_main() {
        rclean
        $DAPS --main ${DAPSROOT}/doc/xml/MAIN.DAPS.xml --builddir $SHUNIT_TMPDIR --dapsroot $DAPSROOT html
    assertTrue "Regular HTML build from MAIN failed" "[[ $? -eq 0 ]]"
}

# HTML static
test_HTML_static() {
    local DIR FILE LINKS
    DIR=$(get_htmldir)
    FILE=$($DAPS -d $DC --builddir $SHUNIT_TMPDIR --dapsroot $DAPSROOT html --static)
    assertTrue "Static HTML build failed" "[[ $? -eq 0 ]]"
    LINKS=$(find $DIR -type l 2>/dev/null) # should only contain index.html
    FILE=${FILE#file://}
    LINKS=${LINKS#$FILE} # remove index.html
    assertNull "A static HTML build result dir must not contain links ($LINKS)" "$LINKS"
}


# ALWAYS source it last:
source $SHUNIT2SRC

# EOF
