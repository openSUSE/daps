#!/bin/bash
# helper script to change ids in several xml files

usage () {
  echo "usage: `basename $0` [-h] [-o id] [-n id] XML-File(s)" >&2
  echo "       -h: print this help" >&2
  echo "       -o: old value of id"  >&2
  echo "       -n: new value of id" >&2
  echo "       -s: don't do anything if only one id" >&2
  exit 1
}

if [ -z "$1" ] ; then
    usage
fi

TEMP=`getopt -o n:ho:s -- "$@"`
eval set -- "$TEMP"

while [ $# -gt 0 ] ; do
    case $1 in
      -n)
         NEWID=$2
         shift 2
         ;;
      -o)
         OLDID=$2
         shift 2
         ;;
      -h|--help)
         usage
         ;;
      -s)
         SKIP=1
	 shift
	 ;;
      --)
         shift
         ;;
      *)
         FILELIST="$FILELIST $1"
         shift
         ;;
      esac
done

if [ -z "$FILELIST" ] ; then
  echo "Need some files to work on, exiting."
  exit 1
fi

if [ -z "$NEWID" ] ; then
  echo "No replacement id (-n) supplied, exiting."
  exit 1
fi

if [ -z "$OLDID" ] ; then
  echo "No original id (-o) supplied, exiting."
  exit 1
fi

# test if new ID is already in existing files
NO=$(grep -F \"$NEWID\" $FILELIST | wc -l )
if [ $NO -gt 0 ] ; then
  echo "NEWID already present in:"
  echo "$(grep -l \"$NEWID\" $FILELIST)"
  exit 1
fi

# reduce filelist to affected files
FILELIST=$(grep -l \"$OLDID\" $FILELIST)

echo "Affected files:"
echo "$FILELIST"

if test ${SKIP} ; then
  NR=$(grep $OLDID $FILELIST | wc -l)
  if [ $NR -lt 2 ] ; then
    echo "Only one id present in $FILELIST, exiting."
    exit 0
  fi
fi

# test if a valid prefix is used
case ${NEWID%%.*} in
  app|book|cha|ex|fig|glo|gt|il|it|idx|ol|part|pro|sec|set|st|tab|vl|vle)
    ;;
  *)
    echo "The prefix ${NEWID%%.*} is not defined in the styleguide"
    exit 1
    ;;
esac

# now, do the work. Also added quotation in sed to be sure to change
# only the affected ids.
for f in $FILELIST; do
  mv $f $f.bak
  sed "s:\"${OLDID}\":\"${NEWID}\":" < $f.bak > $f
  rm $f.bak
done
