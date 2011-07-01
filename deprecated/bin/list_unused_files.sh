#!/bin/bash

PROJECTFILES=$(mktemp)
SORTED_PROJECTFILES=$(mktemp)
GRAPHICS=$(mktemp)
SVNFILES=$(mktemp)
SORTED_SVNFILES=$(mktemp)

function clean_exit {
    rm -rf $PROJECTFILES $SORTED_PROJECTFILES $GRAPHICS $SVNFILES $SORTED_PROJECTFILES
}

trap clean_exit SIGTERM SIGINT

if test -z "$1" ; then
    echo -e "\nPlease specifiy a list of ENV files for _all_ books\n"
    exit
fi

#
# Iterate through all ENV files and create a list of all xml and png files

for ENV in $@; do
    if test -s $ENV; then
	source $ENV > /dev/null
         # needed in order to get freshly profiled files
        make validate 2>&1 > /dev/null | grep -v "^ HINT: Comments"
	make projectfiles | tr ' ' '\n' >> $PROJECTFILES
	make projectgraphics | tr ' ' '\n' >> $GRAPHICS
    else
	echo -e "$ENV is not a valid file, skipping"
    fi
done

#
# make projectgraphics only lists png files. Add all files from
# images/src/* that have the same basename as an already listed
# png file.

for FILE in $(cat $GRAPHICS); do
    BASENAME=${FILE##*/}    # cut path
    BASENAME=${BASENAME%.*} # cut file suffix
    find images/src/ -type d -name '.svn' -prune -o \( -name "$BASENAME.*" -print \) >> $PROJECTFILES
done

cat $PROJECTFILES | sort | uniq >> $SORTED_PROJECTFILES

find xml/ -name "*.xml" >> $SVNFILES
find images/src/ -path '*/.svn' -prune -o -type f -print >> $SVNFILES

cat $SVNFILES | sort | uniq >> $SORTED_SVNFILES

comm -1 -3 $SORTED_PROJECTFILES $SORTED_SVNFILES | tr '\n' ' '
#comm -1 -3 $SORTED_PROJECTFILES $SORTED_SVNFILES
echo -e

clean_exit
