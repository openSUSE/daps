#!/bin/sh
#
# Creates from a PDF file a PostScript file that
# is in a "booklet" format which can be folded
#
# Code by Matthias Eckermann
#
# $1 = Name of the PDF file
#

if [ ! -e $1 ]; then
   echo "ERROR: File $1 not found."
   exit 10
fi

# Only extract the filename, not the path (similar to "basename")
FILENAME=${1##*/}
PAPER=A3

pdftops -level2 -paper $PAPER $1 && \
psbook ${1%.*}.ps /tmp/${FILENAME%.*}.ps && \
psnup -2 -p$PAPER /tmp/${FILENAME%.*}.ps ${1%.*}-booklet.ps && \
ps2pdf12 ${1%.*}-booklet.ps
rm /tmp/${FILENAME%.*}.ps
