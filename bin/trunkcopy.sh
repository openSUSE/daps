#!/bin/bash
#
# Copyright (C) 2012-2015 SUSE Linux GmbH
#
# Author:
# Frank Sundermeyer <fsundermeyer at opensuse dot org>
#
# Create a branch or a tag from trunk or branch in the doc SVN.
#
# Version 1.0 2009-06-05
#
#

echo

#------------
# Environment
#------------

# set the language to default
export LANG=C

# used for temporary files and the $ORIGIN checkout
TEMPDIR="/tmp"  

# SVN server root
SVNROOT="https://svn.suse.de/svn/doc"
VALID_TARGETS=(branches tags)

# the SVN directories
ORIGIN=""
ORIGINSUFFIX="books/en"
TARGET=""
LOCALTARGET=""

# the tmp files/dirs
FILELIST=""
TMPFILELIST=""
CHECKOUTDIR=""
declare -a DEFFILES  # array with all DEF- Files

# Additional directories that need to be copied
EXTRA=""

#MISC
declare -a  TARGETPATH # array with all targetpath elements
LOCAL_CHECKOUT="" # path to checkout dir 
LOCAL_CHECKOUT_DIR="" # drirectory that will be checked out
LOCAL_DIR="" # directory that will be created
NONOVDOC=0
PRESERVE=0
REVISION="HEAD"
declare -a SVNUPDIRS # array with directories that have been SVN upped

#----------
# Functions
#----------

# help
function usage {
    echo "Create a branch or a tag from trunk or branch in the doc SVN and"
    echo "set reasonable svn:ignore properties. Make sure the newly created"
    echo "set builds properly before submitting. All SVN operations are done"
    echo "locally in a temporary directory that will be submitted to the"
    echo "server using \$SVNROOT=$SVNROOT"
    echo
    echo "usage: $0 -o <ORIGIN> -t <TARGET>  [options] <LIST OF ENVFILES>"
    echo
    echo "Mandatory arguments:"
    echo "--------------------"
    echo "   -o|--origin <ORIGIN>: path to the local directory _from_ which the files are"
    echo "                         copied (normally <LOCAL PATH>/trunk"
    echo "                         or  <LOCAL PATH>/branches). Please do not specify a"
    echo "                         deeper than in the above examples, also see the"
    echo "                         --osuffix option"
    echo "   -t|--target <TARGET>: path to directory on the SVN server (relative to"
    echo "                         \$SVNROOT)  _to_ which the files are copied"
    echo "                         (normally branches/MYDIR or tags/MYDIR)."
    echo "                         If the directory does not exist, you will be prompted"
    echo "                         to create it."
    echo "   <LIST OF ENV FILES>:  complete list of ENV files (relative to <ORIGIN>)"
    echo "                         for the set that is to be copied. No wildcards."
    echo
    echo "Optional arguments:"
    echo "--------------------"
    echo "   -h|--help:      This help text."
    echo "   --extra:        Add entries to the list of additional files and directories"
    echo "                   that are to be copied. Default values:"
    echo "                   \"\$ORIGINSUFFIX/images/src/dia \$ORIGINSUFFIX/images/src/fig \$ORIGINSUFFIX/images/src/svg \$ORIGINSUFFIX/README-MAKING-AUTOBUILD-PACKAGES \$ORIGINSUFFIX/xml/book_quickstarts.xml novdoc"
    echo "                   Enter space separated list. Entries need to be specified"
    echo "                   relative to <ORIGIN>. No wildcards are allowed."
    echo "   --nonovdoc:     Do not tag/branch the novdoc directory"
    echo "   --revision:     Overwrite the revision number that is to be used with the svn up"
    echo "                   commands that are run in ORIGIN. _Only_ use this option if"
    echo "                   you want to branch or tag a revision other than HEAD."
    echo "                   \$ORIGIN/\$ORIGINSUFFIX and all directories specified in"
    echo "                   EXTRA will automatically be \"updatd\" to the specified revision."
    echo "                   Default is: \"$REVISION\"."
    echo "   --osuffix:      Overwrite the ORIGIN suffix. Default is \"$ORIGINSUFFIX\"."
    echo "   --svnroot:      Overwrite the SVNROOT, Default is:"
    echo "                   \"$SVNROOT\". Use with care"
    echo "   --preserve:     Do not delete the temporary copy of the working directory in \"$TEMPDIR\""
    echo "                   when exiting upon an error (it is deleted by default)."
    echo "   --tmpdir:       Overwrite directory for temporary files. Default is \"$TEMPDIR\""
    echo "   --validtargets: Override the valid target directories. By default the path to"
    echo "                   the target directory has to start with: \"$(echo ${VALID_TARGETS[*]})\"."
    echo "                   Overwrite with space separated list."
    echo
    exit 0
}

function chk_svnpath {
    svn info $1 2>/dev/null | egrep "^Path" >&/dev/null || return 1
    return 0
} 

#delete tmp files
function del_tmp {
    if [[ $TMPFILELIST && -f "$TMPFILELIST" ]]; then 
	rm -f $TMPFILELIST
    elif [[ $FILELIST && -f "$FILELIST" ]]; then 
	rm -f $FILELIST
    elif [[ $CHECKOUTDIR  && -d "$CHECKOUTDIR" ]]; then 
	if [ "$PRESERVE" == 0 ]; then
	    rm -rf $CHECKOUTDIR
	fi
    fi
}

function restore_head {
    MAKEHEAD=""
    if [ $REVISION != "HEAD" ]; then
	echo
	echo "You have specified a revision number when calling the script."
	echo "Therefore the following directories have been \"downgraded\" to"
	echo "Revision $REVISION:"
	echo "$SVNUPDIRS[*]"
	echo "Do you want me to update these directories to HEAD again? (y/n) [y]"
	read MAKEHEAD
	if [[ "$MAKEHEAD" = "y" || "$MAKEHEAD" = "Y" ]]; then
	    for DIR in ${SVNUPDIRS[@]}; do
		svn up $DIR >&/dev/null || echo "Warning: Failed to update $DIR"
	    done
	else
	    echo "No revision changes performed"
	fi
    fi
}

# exit on error
function exit_on_error {
    echo -e "$1, exiting!"
    del_tmp
    restore_head
    exit 1
}

# check for local modifications
function local_mods {
    MOD_FILES=$(svn st $1 | egrep "^( |M)M?" 2>/dev/null)
    if [ $? -eq 0 ]; then
	echo "There are locally modified files in $1. Please submit/revert them"
	echo "before proceeding:"
	echo $MOD_FILES
#	del_tmp
#	exit 1;
    fi
}

# enable interruption/abortion via Ctrl-Z/Ctrl-C
trap "exit_on_error '\nCaught SIGTERM/SIGINT'" SIGTERM SIGINT

# -----------------------
# Command line arguments
# -----------------------

if  [ "$1" = "" ]; then usage; fi

#using getopt (rather than the shell built-in getopts)
OPTIONS=$(getopt -o ho:t: -l extra:,help,nonovdoc,origin:,osuffix:,preserve,svnroot:,revision:,target:,tmpdir:,validtargets: -n $0 -- "$@")

eval set -- "$OPTIONS"

while true ; do
    case "$1" in
        -h|--help)
	    usage
	    ;;
        -o|--origin)
	    ORIGIN=$2
	    ORIGIN=${ORIGIN%*/} # cut trailing /
	    if [ "$ORIGIN" = "" ]; then
		exit_on_error "Please specify an ORIGIN directory"
	    fi
	    shift 2 ;;
	-t|--target)
	    TARGET=$2
	    TARGET=${TARGET%*/} # cut trailing /
	    TARGET=${TARGET#/*} # cut leading /
	    if [ "$TARGET" = "" ]; then 
		exit_on_error "Please specify a TARGET path relative to $SVNROOT"
	    fi
	    shift 2 ;;
	--extra)
	    EXTRA=( ${EXTRA[@]} $2 )
	    shift 2 ;;
        --nonovdoc)
            NONOVDOC=1
            shift ;;
	--osuffix)
	    ORIGINSUFFIX=$2
	    ORIGINSUFFIX=${ORIGINSUFFIX%*/} # cut trailing /
	    ORIGINSUFFIX=${ORIGINSUFFIX#/*} # cut leading /
	    CHECK_ORIGINSUFFIX=1
	    shift 2 ;;
        --preserve)
            PRESERVE=1
	    shift ;;
	--revision)
	    [ $2 -eq $2 >&/dev/null ] || exit_on_error "Please specify an integer value for the revision"
	    REVISION="$2"
	    shift 2 ;;
	--svnroot)
	    SVNROOT=$2
	    CHECK_SVNROOT=1
	    shift 2 ;;
	--tmpdir)
	    TEMPDIR=$2
	    CHECK_TEMPDIR=1
	    shift 2 ;;
        --validtargets)
	    VALID_TARGETS=($2)
	    CHECK_VALID_TARGETS=1
	    shift 2 ;;
	--) 
	    shift
	    break ;;
	 *) echo "Internal error!" ; exit 1 ;;
    esac
done

# $* holds the ENV files (hopefully ;-))
ENV_FILES=${*}
if [ "${ENV_FILES[0]}" = "" ]; then
    exit_on_error "Please specify at least one ENV-file"
fi

# Additional directories that need to be copied
# need to set this after the parameters have been evaluated, because
# $ORIGINSUFFIX is customizable
EXTRA=( ${EXTRA[@]} $ORIGINSUFFIX/images/src/dia $ORIGINSUFFIX/images/src/fig $ORIGINSUFFIX/images/src/svg $ORIGINSUFFIX/README-MAKING-AUTOBUILD-PACKAGES $ORIGINSUFFIX/xml/book_quickstarts.xml )
# only add novdoc dir when --nonovdoc is not used
if [ "$NONOVDOC" == 0 ]; then
    EXTRA=( ${EXTRA[@]} novdoc )
fi 

#----------------
# Check arguments
#---------------
# do not change the order of the checks

chk_svnpath $ORIGIN || exit_on_error "ORIGIN \"$ORIGIN\" is not a valid SVN directory"

if [ "$CHECK_ORIGINSUFFIX" = "1" ]; then
    chk_svnpath $ORIGIN/$ORIGINSUFFIX || exit_on_error "$ORIGINSUFFIX does not exist under $ORIGIN or is not SVN controlled"
fi
if [ "$CHECK_SVNROOT" = "1" ]; then
    chk_svnpath $SVNROOT || exit_on_error "SVNROOT $SVNROOT is not a valid SVN directory"
fi

# ENV files
#
# file must exist and begin with "ENV-"
for ENV_FILE in ${ENV_FILES[@]}; do
    # must exist and must begin with "ENV-"
    if [[ ! ( -s "$ORIGIN/$ORIGINSUFFIX/$ENV_FILE" ) || ${ENV_FILE:0:4} != "ENV-" ]]; then
	exit_on_error "$ENV_FILE is not a valid ENV file"
    fi
done

# ORIGIN is a bit more work
#
# check whether it is a local SVN copy, the SVN update and check
# for local modifications
# SVN update $ORIGIN 
svn up -r$REVISION $ORIGIN/$ORIGINSUFFIX >&/dev/null || exit_on_error "SVN update in $ORIGIN/$ORIGINSUFFIX failed"
SVNUPDIRS[0]=$ORIGIN/$ORIGINSUFFIX
# check for local modifications
local_mods "$ORIGIN/$ORIGINSUFFIX"

# The optional parameters
#

# check whether directory is valid. If not, issue warning
# and remove entry from EXTRA array.
# If directories/files outside of $ORIGINSUFFIX are specified
# svn update them and check for local modifications
I=0
for DIR in ${EXTRA[@]}; do
    chk_svnpath $ORIGIN/$DIR
    if [ $? -eq 1 ]; then
	echo "Warning: Extra Directory $ORIGIN/$DIR is not a valid SVN directory"
	unset EXTRA[$I]
    elif echo $DIR | grep -v $ORIGINSUFFIX >&/dev/null; then
	svn up -r$REVISION $ORIGIN/$DIR  >&/dev/null || exit_on_error "SVN update in $ORIGIN/$DIR failed"
	SVNUPDIRS=( ${SVNUPDIRS[@]} $ORIGIN/$DIR )
	local_mods "$ORIGIN/$DIR"
    fi
    let I++
done
if [ "$CHECK_TEMPDIR" = "1" ]; then
    if [ ! -d "$TEMPDIR" ]; then
	exit_on_error "TEMPDIR $TEMPDIR does not exist"
    fi
fi
if [ "$CHECK_VALID_TARGETS" = "1" ]; then
    for DIR in ${VALID_TARGETS[@]}; do
	 chk_svnpath $SVNROOT/$DIR || exit_on_error "VALID_TARGET $SVNROOT/$DIR is not a valid SVN directory"
    done
fi   

# TARGET requires a lot more work, too
#
# split $TARGET at "/", test each path element and get check-in root and dir
# if $TARGET does not exist, create it, if it exists, exit when not empty

TARGETPATH=($(echo $TARGET | tr '/' ' ')) # split $TARGET at "/"

# check whether the first element is in $VALID_TARGETS and whether
# a second argument exists
TARGET_IS_VALID=0
for DIR in ${VALID_TARGETS[@]}; do
    if [[ $DIR = "${TARGETPATH[0]}" && ${TARGETPATH[1]} != "" ]]; then
	TARGET_IS_VALID=1
    fi
done
if [ "$TARGET_IS_VALID" = "0" ]; then
    exit_on_error "\"$TARGET\" is not a valid root directory for the TARGET"
fi
# test each path element and get the directories that are already
# present on the server (LOCAL_CHECKOUT) and the ones that need to be created
# (LOCAL_DIR)
#
# This is a bit tricky:
# -If a path element is available on the server, add it to LOCAL_CHECKOUT
#  and remove the element from the array (unset TARGETPATH[$I])
# -If a path element is _not_ available on the server, set LOCAL_DIR to the
#  remaining part of $TARGETPATH. When using "${TARGETPATH[*]}" instead
#  of ${TARGETPATH[@]}, IFS is used to separate the entries
I=0
for TPATH in ${TARGETPATH[@]}; do
    if ! chk_svnpath $SVNROOT/$LOCAL_CHECKOUT/$TPATH; then
	IFS="/"
	LOCAL_DIR="${TARGETPATH[*]}"
	unset IFS
	break
    fi
    LOCAL_CHECKOUT="${LOCAL_CHECKOUT}${TPATH}/"
    unset TARGETPATH[$I]
    let I++;
done

#----------------------
# Create the file lists
#----------------------

# Create tmp files for the filelists
TMPFILELIST=$(mktemp -q $TEMPDIR/trunkcopy_XXXXX) || exit_on_error "Failed to create the filelist"
LOGFILE="$TEMPDIR/trunkcopy.log"
FILELIST=$(mktemp -q $TEMPDIR/trunkcopy_XXXXX) || exit_on_error "Failed to create the filelist"

cd $ORIGIN/$ORIGINSUFFIX >&/dev/null || exit_on_error "Failed to cd into $ORIGIN/$ORIGINSUFFIX"

echo "Processing ..."
for ENV_FILE in ${ENV_FILES[@]}; do
    tput el1
    echo -en "\r   $ENV_FILE"
    source $ENV_FILE >&/dev/null || exit_on_error "An error occured while sourcing $ENV_FILE"
    make validate >&$LOGFILE || eval '
      echo "$ENV_FILE does not validate"
      echo "--------------------<LOGFILE>--------------------
      tail -n 15 $LOGFILE
      echo "--------------------</LOGFILE>--------------------
      exit_on_error "exiting"'
    make projectfiles | sed -e 's/ /\n/g' >> $TMPFILELIST || eval '
      echo "An error occured during make projectfiles"
      echo "--------------------<LOGFILE>--------------------
      tail -n 15 $TMPFILELIST
      echo "--------------------</LOGFILE>--------------------
      exit_on_error "exiting"'      
    make projectgraphics | sed -e 's/ /\n/g' | sed '/\/gen\//d' >> $TMPFILELIST || eval '
      echo "An error occured during make projectgraphics"
      echo "--------------------<LOGFILE>--------------------
      tail -n 15 $TMPFILELIST
      echo "--------------------</LOGFILE>--------------------
      exit_on_error "exiting"'
done
echo -e "\n... done"

sort -u -o $FILELIST $TMPFILELIST || exit_on_error "$0: Failed to create the filelist"
rm -Rf $TMPFILELIST # no longer needed

# DEF files
I=0
PATTERN="DEF-*"
for DEF in $PATTERN; do
    if [ $DEF != "$PATTERN" ]; then # if equal, files matching $PATTERN do not exist
	DEFFILES[$I]="$DEF"
	let I++
    fi
done

#--------------------------
# Set up the local SVN tree
#--------------------------

# create a temporary directory in which the TARGET will be created
CHECKOUTDIR=$(mktemp -qd $TEMPDIR/trunkcopy_XXXXX) || exit_on_error "$0: Failed to create the checkout directory"

# create/checkout main directory

if [ $LOCAL_DIR ]; then # directory does not exist on SVN server => create it
    LOCAL_CHECKOUT_DIR=$(basename $LOCAL_CHECKOUT) # the directory that exists on the server will be checked out
    svn co --depth=empty $SVNROOT/$LOCAL_CHECKOUT $CHECKOUTDIR/$LOCAL_CHECKOUT_DIR >&/dev/null || exit_on_error "Checking out $SVNROOT/$LOCAL_CHECKOUT failed"
    svn mkdir --parents $CHECKOUTDIR/$LOCAL_CHECKOUT_DIR/$LOCAL_DIR >&/dev/null || exit_on_error "Creating $CHECKOUTDIR/$LOCAL_DIR failed"
    LOCALTARGET="$CHECKOUTDIR/$LOCAL_CHECKOUT_DIR/$LOCAL_DIR"
else # directory already exists on SVN server => check it out
#    if svn ls $SVNROOT/$LOCAL_CHECKOUT/$CI 2>/dev/null | grep "" >&/dev/null; then
#	exit_on_error "$SVNROOT/$LOCAL_CHECKOUT is not an empty directory"
#    else
	svn co $SVNROOT/$LOCAL_CHECKOUT $CHECKOUTDIR/${TARGETPATH[@]: -1} # ${ARRY[@]: -1} is the last array element
	LOCALTARGET="$CHECKOUTDIR/${TARGETPATH[@]: -1}"
	LOCAL_CHECKOUT_DIR="${TARGETPATH[@]: -1}"
#    fi
fi

# create $ORIGINSUFFIX in main directory
svn mkdir --parents $LOCALTARGET/$ORIGINSUFFIX >&/dev/null || exit_on_error "$0: Failed to create the ORIGINSUFFIX directories"

# get all directories from $FILELIST and create them
LISTDIRECTORIES='for LINE in $(cat $FILELIST); do if [ -d "$ORIGIN/$ORIGINSUFFIX/${LINE%/*}" ]; then echo "${LINE%/*}"; fi done'
for DIRECTORY in $(eval $LISTDIRECTORIES | sort -u); do
    svn mkdir --parents $LOCALTARGET/$ORIGINSUFFIX/$DIRECTORY >&/dev/null || exit_on_error "Failed to create the $DIRECTORY directory"
done

#---------------
# Copy the files
#---------------

echo "SVN Copying files to $LOCALTARGET ... " 
# files from the filelist
for FILE in $(cat $FILELIST); do
    DIRECTORY=$(dirname $FILE);
    if [ "$DIRECTORY" = "." ]; then
	DIRECTORY=""
    fi
    tput el1
    echo -en "\r   $FILE" 
    svn copy $ORIGIN/$ORIGINSUFFIX/$FILE $LOCALTARGET/$ORIGINSUFFIX/$DIRECTORY >&/dev/null || echo "\nWarning: Copying $FILE to $LOCALTARGET/$ORIGINSUFFIX/$DIRECTORY failed!"
done
rm -Rf $FILELIST # no longer needed
# EXTRA stuff
for ENTRY in ${EXTRA[@]}; do
    LOCALSUBDIR=$(dirname $ENTRY)
    if [[ $LOCALSUBDIR != "." && ! ( -d "$LOCALTARGET/$LOCALSUBDIR" ) ]]; then
	svn mkdir --parents $LOCALTARGET/$LOCALSUBDIR >&/dev/null || exit_on_error "\nFailed to create the $LOCALTARGET/$LOCALSUBDIR directory"
    fi
    tput el1
    echo -en "\r   $ENTRY" 
    svn copy $ORIGIN/$ENTRY $LOCALTARGET/$ENTRY >&/dev/null || echo "\nWarning: Copying $ENTRY to $LOCALTARGET/$ENTRY failed!"
done
# the DEF files (if any)
if [ ${DEFFILES[0]} != "" ]; then
    for ENTRY in ${DEFFILES[@]}; do
	tput el1
	echo -en "\r   $ENTRY" 
	svn copy $ORIGIN/$ORIGINSUFFIX/$ENTRY $LOCALTARGET/$ORIGINSUFFIX >&/dev/null || echo "\nWarning: Copying $ENTRY to $LOCALTARGET failed!"
    done
fi
echo -e "\n... done"

#-------------------
# svn:ignores setzen
#-------------------

echo -n "Setting the svn:ignore properties ... "
svn ps svn:ignore "autobuild
profiled
tmp
*.pdf
*.fo
*.xml
*.html
*.ps
*.bak
svn-commit*.tmp
*.tar.bz2
*.tar.gz
*.zip
.directory
HTML.manifest
*.diff
wiki" $LOCALTARGET/$ORIGINSUFFIX >&/dev/null || echo -e "\nWarning: Failed to set the svn:ignore property on $LOCALTARGET/$ORIGINSUFFIX"

if [ -d "$LOCALTARGET/$ORIGINSUFFIX/xml" ]; then
  svn ps svn:ignore "*.pdf
*.fo
*.bak" $LOCALTARGET/$ORIGINSUFFIX/xml >&/dev/null || echo -e "\nWarning: Failed to set the svn:ignore property on $LOCALTARGET/$ORIGINSUFFIX/xml"
fi

if [ -d "$LOCALTARGET/$ORIGINSUFFIX/images" ]; then
    svn ps svn:ignore "online
print
gen" $LOCALTARGET/$ORIGINSUFFIX/images >&/dev/null || echo -e "\nWarning: Failed to set the svn:ignore property on $LOCALTARGET/$ORIGINSUFFIX/images"
fi
echo "done"

#-----------
# Validating
#-----------

echo "Validating ..."
cd $LOCALTARGET/$ORIGINSUFFIX || exit_on_error "Failed to cd into $LOCALTARGET/$ORIGINSUFFIX"
for ENV_FILE in ${ENV_FILES[@]}; do
    tput el1
    echo -en "\r   $ENV_FILE ... "
    source $ENV_FILE >&/dev/null || exit_on_error "An error occured while sourcing $ENV_FILE"
    make validate | tail -n1 | grep "Validating done" >&/dev/null
    if [ $? -eq 1 ]; then
	exit_on_error "\n$ENV_FILE does not validate"
    fi
done
echo -e "\n... done"

#-----------
# Submitting
#-----------

MESSAGE=""
echo "Successfully created a local copy of the set in"
echo "$LOCALTARGET"
echo "Do you want to submit ${LOCALTARGET##*/} to the SVN server? (y/n) [n]"
read SUBMIT
if [ "$SUBMIT" = "y" ]; then
    echo "Please enter a submit message!"
    read MESSAGE
    svn ci -m "$MESSAGE" $CHECKOUTDIR/$LOCAL_CHECKOUT_DIR >&/dev/null || exit_on_error "Failed to submit $CHECKOUTDIR/$LOCAL_CHECKOUT_DIR"
    echo
    echo "Successfully submitted to $SVNROOT/$TARGET"
    echo
    del_tmp;
else
    echo "$TARGET will _not_ be copied to the SVN server."
    echo "See $CHECKOUTDIR/$LOCAL_CHECKOUT_DIR for the local copy."
fi

restore_head;

exit 0




