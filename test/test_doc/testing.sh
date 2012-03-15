#!/bin/bash
#
#
#

test_XYZ() {
  assertTrue "Not equal" "[[ 1 -eq 1 ]]"
}


# ALWAYS source it last:
source /usr/share/shunit2/src/shunit2

# EOF