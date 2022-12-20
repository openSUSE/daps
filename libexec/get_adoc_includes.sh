#!/bin/bash
#
# Copyright (C) 2012-2022 SUSE Software Solutions Germany GmbH
#
# Author:
# Frank Sundermeyer <fsundermeyer at opensuse dot org>
#
# Recursively get include files from an asciidoc "main" file
#
# include statements always start at the begin of the line, no other
# characters (incl. space) are allowed before it, so a grep for
# /^include::/ seems to be a safe enough
#

main="$1"
includes=$(basename "$main")

function include_grep {
    local f
    f=$(grep -E '^include::' $@ 2>/dev/null | sed 's/.*::\.\/\([^\[]*\).*/\1/g' 2>/dev/null)
    if [[ -n $f ]]; then
        includes+=" $f"
        include_grep $f
    else
        return
    fi
}

include_grep $main

echo "${includes//$'\n'/ }"
