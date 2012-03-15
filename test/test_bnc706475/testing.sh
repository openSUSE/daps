#!/bin/bash
#
#
# (C) 2012 Thomas Schraitle <toms@opensuse.org>
#

if [[ -f common.sh ]]; then
  source common.sh
elif [[ -f ../common.sh ]]; then
  source ../common.sh
fi

test_X() {
  assertTrue "Not equal" "[[ 1 -eq 1 ]]"
}

# ALWAYS source it last:
source $SHUNIT2SRC

# EOF