#!/bin/sh
#
# $Id: ddiff.sh 11000 2006-08-04 05:48:49Z toms $
#

# Creates a diff between two directories
#  $1 old directory
#  $2 new directory
#
# Output
#  statistics.txt : Contains the statistical output of wdiff
#  diffdir/       : Directory contains PS files from pdiff and text files from wdiff

PDIFF_OPT='-w' # this is the default
DIFFDIR=diffdir
WDIFF_OPT="--no-common --statistics"
STATTEXT=statistics.txt


echo $0 $#

if [ $# -lt 2 ]; then
   echo "I need two directories"
   exit 10
else
   echo "$1 $2"
fi

OLDDIR=$1
NEWDIR=$2

#ls -1 $1 > $1.txt
#ls -l $2 > $2.txt

xx=$(ls -1 $OLDDIR | wc)
yy=$(ls -1 $NEWDIR | wc)

echo "Comparing directories $OLDDIR ($xx) and $NEWDIR ($yy)"

if [ ! -e $DIFFDIR ]; then
  mkdir $DIFFDIR
fi

if [ $# -gt 2 ]; then
  shift
  shift
  XMLFILES=$*
else
  XMLFILES=$OLDDIR/*.xml
fi

touch $STATTEXT
for i in $XMLFILES; do
   x=$(basename $i)
   PSNAME=$x--diff.ps
   DIFFNAME=$x-diff.txt
   # Check, if this file exists in the other directory:
   if [ ! -e $NEWDIR/$x ]; then
      echo "File $x does not exists in $NEWDIR"
   else
      LC_CTYPE=en_US pdiff ${PDIFF_OPT} $i $NEWDIR/$x -- \
         -o ${DIFFDIR}/${PSNAME} --line-numbers=1
      wdiff $WDIFF_OPT $i $NEWDIR/$x  2>> $STATTEXT > ${DIFFDIR}/$DIFFNAME
      echo "--------------------------------" >> $STATTEXT
   fi

done

