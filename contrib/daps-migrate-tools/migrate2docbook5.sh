#!/bin/bash
#
# Purpose:
#   Migrate old DocBook4 sources to DocBook5
#
# Synopsis:
#  migrate2docbook5.sh [OPTIONS] [INPUTDIR] [OUTPUTDIR]
#  migrate2docbook5.sh --help
#
# Author: Thomas Schraitle
# Date:   2019/2020

ME=$(basename "$0")
DAPSDIR="/local/repos/GH/opensuse/daps"
UPGRADEXSLT="${DAPSDIR}/daps-xslt/migrate/suse-upgrade.xsl"
GEEKODOCXSL="${DAPSDIR}/daps-xslt/migrate/db5togeekodoc.xsl"
#
#
XML_SOURCE=xml
XML_TARGET=xml5
DOCTYPE=1
XMLTMPDIR=$(mktemp -d -p /tmp xml.XXX)

ARGS=$(getopt -o h -l help,dapsdir:,without-int-doctype -n "$ME" -- "$@")

function exit_on_error {
    echo "ERROR: ${1}" >&2
    exit 1;
}

function usage {
    cat <<EOF_helptext
$ME [OPTIONS] [INPUTDIR] [OUTPUTDIR]

Migrate old DocBook4 sources to DocBook5. Protect entities.

Options:
   --dapsdir=<DIR>
       Path to the project directory under which the DAPS
       environment can be found.
   --without-int-doctype
       Suppress the internal subset of the DOCTYPE declaration.
       By default, it imports the "entity-decl.ent" file.
       With this option, it doesn't.

Arguments:
    INPUTDIR
       directory where all DocBook4 sources are located
       (default '$XML_SOURCE')
    OUTPUTDIR
       directory where all DocBook5 files are written
       (default '$XML_TARGET')
EOF_helptext
   exit 0
}

eval set -- "$ARGS"
while true; do
  case "$1" in
    --dapsdir)
        if [[ -d "$2" ]]; then
           DAPSDIR="$2"
        else
           exit_on_error "dapsdir \"$2\" is not a valid directory."
        fi
        shift 2
        ;;
    --without-int-doctype)
      DOCTYPE=0
      shift
      ;;
    --help|-h)
        usage
        ;;
    --) shift ; break ;;
    *) exit_on_error "Wrong parameter: $1" ;;
  esac
done

[[ -n "$1" ]] && XML_SOURCE="$1"
[[ -n "$2" ]] && XML_TARGET="$2"

[[ -e "$DAPSDIR/bin/daps" ]] || exit_on_error "Invalid DAPS directory."


#
# ---- Start of the script
#
echo "[STEP 0] Using source '$XML_SOURCE'"


echo "[STEP 1] Protect entities"
for x in $XML_SOURCE/*.xml; do
  xml=${x##*/}
  if [[ ! -L $x ]]; then
    cp $x $XMLTMPDIR/
     sed -i -f "${DAPSDIR}/lib/entities.preserve.sed" $XMLTMPDIR/$xml
  fi
done


echo "[STEP 2] Copy *.ent files in temporary xml directory"
for i in $PWD/$XML_SOURCE/*.ent; do
  cp -v $i $XMLTMPDIR
done


echo "[STEP 3] Convert to DocBook 5"
for x in $XMLTMPDIR/*.xml; do
 xml=${x##*/}
 # Apply these conversions only, if it is NOT a link
 if [[ ! -L $x ]]; then
 echo "> $xml"
 DOCTYPE_PARAM=""
 if [[ 0 -eq $DOCTYPE ]]; then
   DOCTYPE_PARAM="--stringparam doctype 0"
 fi
 xsltproc $DOCTYPE_PARAM --stringparam db5.version "5.1" --output ${XMLTMPDIR}/$xml.tmp $UPGRADEXSLT $x
 # We remove this old file:
 rm $x
 # Rename back to .xml
 mv ${XMLTMPDIR}/$xml.tmp ${XMLTMPDIR}/$xml
 fi
done


echo -n "[STEP 4] Copy schemas.xml "
# Special case for 'schemas.xml': this is not a DocBook file, so we just copy
# it from the source:
if [[ -e $XML_SOURCE/schemas.xml ]]; then
  echo "done"
  cp -v $XML_SOURCE/schemas.xml ${XMLTMPDIR}
else
  echo "skipped"
fi


echo "[STEP 5] Restore protected entities"
sed -i -f "${DAPSDIR}/lib/entities.recover.sed" ${XMLTMPDIR}/*.xml

[[ -d $XML_TARGET ]] && old $XML_TARGET
echo "[STEP 6] Find all files in $XML_TARGET"
mv ${XMLTMPDIR} $XML_TARGET
chmod go+rx $XML_TARGET
