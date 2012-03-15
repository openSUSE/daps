#!/bin/bash
#
#
# (C) 2012 Thomas Schraitle <toms@opensuse.org>
#

source ../common.sh

test_X() {
  assertTrue "Not equal" "[[ 1 -eq 1 ]]"
}

# ALWAYS source it last:
source $SHUNIT2SRC

# EOF