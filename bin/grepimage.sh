#!/bin/bash
#
# Create a branch or a tag from trunk or branch in the doc SVN.
#
# 1.0 by Frank Sundermeyer <fs@suse.de>, 2009-10-22
# 1.01 by Frank Sundermeyer <fs@suse.de>, 2010-03-23
#
#

IMAGEDIR="images/src/"
SORTCMD=""
declare -a FILELIST

#----------
# Functions
#----------

# help
function usage {
    echo "Print a list of images contained in the profiled version of <FILE>"
    echo
    echo "usage: $0 [options] xml/<FILE1> xml/<FILE2> ..."
    echo
    echo "where options are:"
    echo "--view=<VIEWER> : specify application to view images"
    echo "-m/--modified   : print image file time stamps"
    echo
    echo "You can use this script for three different use-cases:"
    echo "   1.) List the image filenames on separate lines:"
    echo "       $0 xml/<FILE>"
    echo "       Example: $0 xml/foo.xml xml/bar.xml"
    echo "   2.) Call <VIEWER> with the list of images files:"
    echo "       $0 --view=<VIEWER> xml/<FILE>"
    echo "       Example $0 --view=gwenview xml/foo.xml xml/bar.xml"
    echo "   3.) List all image filenames space-separated on one line:"
    echo "       $0 --view xml/<FILE>"
    echo "       Example: xv \$($0 xml/foo.xml xml/bar.xml)"
    echo "       (do not use -m/--modified with this use case)"
    echo
    exit 0
}

# exit on error
function exit_on_error {
    echo -e "$1"
    exit 1
}

# -----------------------
# Command line arguments
# -----------------------

if  [ "$1" = "" ]; then usage; fi

#using getopt (rather than the shell built-in getopts)
OPTIONS=$(getopt -o h,m -l help,modified,view:: -n $0 -- "$@")

eval set -- "$OPTIONS"

while true ; do
    case "$1" in
        -h|--help)
	    usage
	    ;;
        --view)
            VIEW=1
	    if [ "$2" != "" ]; then
		VIEWAPP=$(which $2) || exit_on_error "Cannot find $2"
	    fi
	    shift 2 ;;
	-m|--modified)
	    TIMESTAMPS=1
	    shift ;;
	--) 
	    shift
	    break ;;
	 *) echo "Internal error!" ; exit 1 ;;
    esac
done

# $* holds the XML files (hopefully ;-))
FILES=${*}
if [ "${FILES[0]}" = "" ]; then
    exit_on_error "Please specify at least one XML file"
fi

# get the directory with the profiled 
PROFDIR=profiled/$(make VARIABLE=PROFILEDIR showvariable 2>/dev/null)

# get the list of images
for FILE in ${FILES[@]}; do
    # allowing xml/ for convenience only, it needs to be removed
    if [ ${FILE:0:4} = "xml/" ]; then
	FILE=${FILE:4};
    fi
    if [ -s $PROFDIR/$FILE ]; then
	# add the filelist to the existing one
	# the xml command produces a list of filenames from the imagedata tags
        # the sed part generates the path to the image
        # awk removes the duplicates wihout the need to sort it
        # and tr removes the newline statements
	FILELIST=( "${FILELIST[@]}" $(xml sel -t -m "//imagedata" -v "concat(@fileref, '&#x0a;')" $PROFDIR/$FILE | sed -e "s:\(.*\.\(.*\)\):${IMAGEDIR}\2/\1:g" | awk '!x[$0]++' | tr '\n' ' ') )
    else
	exit_on_error "Please call make validate first!"
    fi
done

# When using "${ARRAY[*]}" instead of ${ARRAY[@]}, IFS is used to
# separate the entries

for IMAGE in ${FILELIST[@]}; do
    if [ "$TIMESTAMPS" = "1" ]; then
	MODIFIED=$(stat -c %y ${IMAGE} | cut -d '.' -f1)
	echo "${IMAGE} (${MODIFIED})"
    else
	echo "${IMAGE}"
    fi	
done  | column -t
if [ "$VIEWAPP" != "" ]; then
    eval $VIEWAPP ${FILELIST[@]} &
fi

exit 0;
