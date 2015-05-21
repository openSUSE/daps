#!/bin/bash
#
# Copyright (C) 2012-2015 SUSE Linux GmbH
#
# Author:
# Berthold Gunreben
# Frank Sundermeyer <fsundermeyer at opensuse dot org >
#

if [[ -d "$DAPSROOT" ]] ; then
    TMP=$DAPSROOT
else
    TMP=$(pwd)
fi

function usage {
    cat <<EOF_helptext
usage: $(basename "$0") [-h] [-s] [-r] [-d MFS] XML-File(s)
       -h: print this help
       -s: save original files
       -r: replace files by saved original files
       -d MFS: use sed.\$MFS
       -o dir: output to directory dir

       All rules are in the novdoc/etc directory in a file
       entities.\$MFS.sed and depend either on the directory
       you are in right now, or on the -d parameter.
EOF_helptext
    exit
}

if [ -z "$1" ] ; then
    usage
fi

TEMP=$(getopt -o srd:ho: -- "$@")
eval set -- "$TEMP"

while [ $# -gt 0 ] ; do
    case $1 in
        -s)
            SAVE="true"
            shift
            ;;
        -r)
            REVERT="true"
            shift
            ;;
        -d)
            MFS=$2
            shift 2
            ;;
        -o)
            OUTPUT=$2
            shift 2
            ;;
        -h|--help)
            usage
            ;;
        --)
            shift
            ;;
        *)
            PACKAGE="$PACKAGE $1"
            shift
            ;;
    esac
done

if [ -z "$MFS" ] ; then
    LA=${TMP%%/xml*}
    LA=${LA##*/}
else
    LA=$MFS
fi

TOOLS=${TMP}
#TOOLS=${TMP%%trunk*}trunk/novdoc
#if [ ! -d $TOOLS ] ; then
#    BN=${TMP##*branches/}
#    BN=${BN%%/*}
#    TOOLS=${TMP%%branches*}branches/$BN/novdoc
#fi

# echo "TOOLS:   $TOOLS"
# echo "MFS:     $MFS"
# echo "LA:      $LA"
# echo "SAVE:    $SAVE"
# echo "REVERT:  $REVERT"
# echo "PACKAGE: $PACKAGE"
# echo "entities: ${TOOLS}/etc/entities.$LA.sed"


test -r "${TOOLS}/lib/entities.${LA}.sed"  || {
    echo "File ${TOOLS}/lib/entities.$LA.sed is missing (exiting)."; exit 1;
}


if [ "$REVERT" != "true" ] ; then
    for f in $PACKAGE; do
        if [[ 2 = "$VERBOSITY" ]]; then
            echo -n " Converting $f ... "
        fi
        test -f "$f"  || ccecho "warn" "$f does not exist";
        if [ "z$OUTPUT" = "z" ] ; then
            cp "$f" "${f}.${LA}"
            sed -f "${TOOLS}/lib/entities.$LA.sed" "${f}.${LA}" > "$f"
        else
            sed -f "${TOOLS}/lib/entities.$LA.sed" "${f}" > "${OUTPUT}/$(basename "$f")"
        fi
        if [ "$SAVE" != "true" ] ; then
            rm "${f}.${LA}"
        fi
    done
    if [[ 2 = "$VERBOSITY" ]]; then
        echo "done."
    fi
fi

if [ "$REVERT" = "true" ] ; then
    for f in $PACKAGE; do
        if [[ 2 = "$VERBOSITY" ]]; then
            echo "${f}..."
        fi
        test -f "$f" || echo "warning: $f does not exist";
        mv "${f}.${LA}" "${f}"
    done
fi
