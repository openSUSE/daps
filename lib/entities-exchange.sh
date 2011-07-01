#!/bin/bash

if [ -d $DTDROOT ] ; then
  TMP=$DTDROOT
else
  TMP=$(pwd)
fi

usage () {
  echo "usage: `basename $0` [-h] [-s] [-r] [-d MFS] XML-File(s)" >&2
  echo "       -h: print this help" >&2
  echo "       -s: save original files"  >&2
  echo "       -r: replace files by saved original files" >&2
  echo "       -d MFS: use sed.\$MFS" >&2
  echo "       -o dir: output to directory dir" >&2
  echo >&2
  echo "       All rules are in the novdoc/etc directory in a file " >&2
  echo "       entities.\$MFS.sed and depend either on the directory " >&2
  echo "       you are in right now, or on the -d parameter. " >&2
  exit 1
}

if [ -z "$1" ] ; then
    usage
fi

TEMP=`getopt -o srd:ho: -- "$@"`
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


test -r ${TOOLS}/lib/entities.${LA}.sed  || {
  echo "File ${TOOLS}/lib/entities.$LA.sed is missing (exiting)."; exit 1;
}


if [ "$REVERT" != "true" ] ; then
  echo "Converting files..."
  for f in $PACKAGE; do
    echo $f...
    test -f $f  || echo "warning: $f does not exist";
    if [ "z$OUTPUT" = "z" ] ; then
      cp $f ${f}.${LA}
      sed -f ${TOOLS}/lib/entities.$LA.sed ${f}.${LA} > $f 
    else
      sed -f ${TOOLS}/lib/entities.$LA.sed ${f} > ${OUTPUT}/$(basename $f) 
    fi  
    if [ "$SAVE" != "true" ] ; then
      rm ${f}.${LA} 
    fi
  done
  echo 'Done.'
fi

if [ "$REVERT" = "true" ] ; then
  for f in $PACKAGE; do
    echo $f...
    test -f $f || echo "warning: $f does not exist";
    mv ${f}.${LA} ${f}
  done
fi
