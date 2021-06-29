#!/bin/bash
#
# Purpose:
#   Returns all DC files which the given ID is available
#
# Optional packages:
#   * parallel (to run it on multiple CPU cores)
#
# Use cases:
# 1. Run it sequentially:
#   $ source get-dc-from-id.sh
#   $ get_dc_from_id <YOUR_SINGLE_ID>
#
# 2. Run it in parallel:
#    $ source get-dc-from-id.sh
#    $ shopt -s extglob
#    $ parallel show_dc_when_id_is_there {1} {2} ::: DC!(*-all|*-html) ::: <YOUR_MULTIPLE_IDS>
#
# Written by Tom Schraitle June 2021

shopt -s extglob
ME=${0##*/}

function show_dc_when_id_is_there() {
    local DC=${1:?Expected DC file as 1st argument}
    local ID=${2:?Expected ID as 2nd argument}
    local XSLT="/usr/share/daps/daps-xslt/common/get-all-xmlids.xsl"

    XML=$(daps -d $DC list-srcfiles --xmlonly)
    RESULT=$(xsltproc $XSLT $XML | sort | uniq | grep $ID)
    if [[ ${RESULT} != "" ]]; then
        echo "$DC (xml:id=$ID)"
    fi
}


function get_dc_from_ids() {
  local ID=${1:?ID not given}
  local DC

  for DC in DC!(*-all|*-html); do
    show_dc_when_id_is_there $DC $ID
  done  
}

export -f show_dc_when_id_is_there

if [[ $1 = "" ]]; then

cat << EOF
$ME <YOUR_IDS>

Returns all DC files where the given ID is available

If you want to run in parallel, use the following steps:

  $ sudo zypper in parallel
  $ source get-dc-from-id.sh
  $ shopt -s extglob
  $ parallel show_dc_when_id_is_there {1} {2} ::: DC!(*-all|*-html) ::: <YOUR_MULTIPLE_IDS>
EOF
else
  get_dc_from_ids $1
fi
