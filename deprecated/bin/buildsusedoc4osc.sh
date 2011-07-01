#!/bin/sh
#
# Script for checking out and building RPM package in osc
#
# (C) 2010, suse-doc-team, Novell Inc.
# Distributable under GPLv2 or GPLv3
#
# upstream patches to https://svn.berlios.de/svnroot/repos/opensuse-doc/tools/docmaker/bin/buildsusedoc4osc.sh

echo "This script is no longer maintained. Use buildsusedoc4osc.py instead"
sleep 5

# Default values:
# TODO: Maybe we should move it into a config file:

DEBUG=yes

OBS_PROJECT="home:thomas-schraitle"
OBS_PACKAGE="susedoc"
OBS_USER="thomas-schraitle"
OBS_ARCH=$(uname -m)
OBS_OS=""
OBS_VERSION=""

DATE=$(date +%Y%m%d)
BERLIOS_URL="https://svn.berlios.de/svnroot/repos/opensuse-doc/"
BERLIOS_susedoc="trunk/tools/docmaker"
BERLIOS_susedoc_tags="tags/tools/docmaker"
PACKAGEVERSION="4.2"
MESSAGE=""
COMMIT=0
BUILD=no
KEEPTEMP=no
NOTAG=no

# Get OBS_OS and OBS_VERSION from /etc/SuSE-release
# cat /etc/SuSE-release:
# <PRODUCT> (<ARCHITECTURE>)
# VERSION = <VERSION>
# PATCHLEVEL = 1
#
# Ignoring the patchlevel Part (aka SP) for now, since there are no
# build targets ATM

# SET IFS to newline, so each line (rather than each word) becomes an
# array element

declare -a RELEASE
OIFS="$IFS" # remember the original value
IFS=$'\n' # IFS = newline
RELEASE=( $(head -n2 /etc/SuSE-release) )
IFS="$OIFS" #restore original value
OBS_OS=${RELEASE[0]%% [0-9]*}
OBS_VERSION=${RELEASE[1]#* = }

debug()
{
  [ "$DEBUG" = "yes" ] && echo -e "\033[32m"$*"\033[m\017"
}

usage()
{
  PROC=$(basename $0)
  cat << EOF
Usage: $PROC [OPTIONS...]

OBS = OpenSUSE Build Server

This script creates a RPM package from the BerliOS SVN and builds it in OBS.
It makes the following steps:
 
 1. Exports the trunk from BerliOS SVN.
 2. Creates an archive (.tar.bz2) and exclude some files which are not wanted
    in our RPM.
 3. Checks out the susedoc project from OBS
 4. Copy the new tarball from step 2 into the OBS working copy.
 5. Builds the RPM and commits a successful build, if wanted.

Options:
  -h, --help     Prints this output
  -d, --debug    Switch on debug options
  -t, --temp DIR
      Use existing temp directory in DIR from previous call
  -p, --project PROJECTNAME
      Specifies the OBS project (default is '$OBS_PROJECT')
  -a, --package PACKAGENAME
      Specifies the OBS package (default is '$OBS_PACKAGE')
  -u, --user USERNAME
      Specifies the OBS user (default is '$OBS_USER')
  -m, --message TEXT
      Specifies the message for the .changes file (don't open an editor)
      also used as log message
  -s, --suppress-tag
      Suppress any generation of a tag
  -c, --commit
      Activates the commit command after finished a successful build.
      It also creates a tag with the message given with -m/--message
  -k, --keep-temp
      Keeps the temp directory (useful for debugging)
  -b, --build
      Use this option to build the package
      Combine it with -m, -c or both.
EOF
  exit 1
}

error()
{
  echo -e "\033[31m"$*"\033[m\017"
}

question()
{
while true; do
 echo -e "$1 [y|n]"
 read answer
 case "$answer" in
 [jJ]a|[yY]es|[yY])
   answer=y
   break ;;
 [nN]|[nN]o)
   answer=n
   break ;;
 esac
done
}


TEMP=$(getopt \
      -o hp:a:u:m:t:ckb \
  --long help,project:,package:,user:,message:,temp:,commit,keep-temp,build \
  -n "$0" -- "$@")
# Note the quotes around `$TEMP': they are essential!
eval set -- "$TEMP"


while true ; do
  case "$1" in
    -d|--debug)  DEBUG=yes ; shift ;;
    -p|--project) OBS_PROJECT=$2 ; shift 2 ;;
    -u|--user) OBS_USER=$2 ; shift 2;;
    -a|--package) OBS_PACKAGE=$2 ; shift 2;;
    -m|--message) MESSAGE=$2 ; shift 2;;
    -t|--temp) TEMPDIR=$2 ; shift 2;;
    -c|--commit) COMMIT=1 ; shift ;;
    -s|--suppress-tag) NOTAG=yes ; shift ;;
    -k|--keep-temp) KEEPTEMP=yes; shift 1 ;;
    -b|--build) BUILD=yes ; shift ;;
    -h|--help) usage ;;
    --)
      [ "$BUILD" = "no" ] && usage
      break
     ;;
    *) echo "Invalid Option ${1}"; break ;;
  esac
done

debug "OBS Project : $OBS_PROJECT"
debug "OBS Package : $OBS_PACKAGE"
debug "OBS User    : $OBS_USER"
debug "Keep Temp   : $KEEPTEMP"
debug "Message: $MESSAGE"
debug "INFO: Detected the following Operating System:\n" \
      "_           OS: ${OBS_OS:?"<Empty>"}\n" \
      "_ Architecture: ${OBS_ARCH:?"<Empty>"}\n" \
      "_      Release: ${OBS_VERSION:?"<Empty>"}\n" \
      "---------------------------------------------------\n"

if [ "$TEMPDIR" = "" ]; then
TEMPDIR=$(mktemp --quiet -d /tmp/build-${OBS_PACKAGE}-XXXX )
fi

FILENAME=${OBS_PACKAGE}-${PACKAGEVERSION}_${DATE}.tar.bz2

##
pushd $TEMPDIR

## Step 1:
# We don't want to get .svn directories, therefor we use export:
debug "INFO: Exporting URL '$BERLIOS_URL/$BERLIOS_susedoc'..."
debug "INFO: Using temp directory '$TEMPDIR'"
svn export --quiet $BERLIOS_URL/$BERLIOS_susedoc ${OBS_PACKAGE}

## Step 2:
debug "INFO: Creating archive ..."
BZIP2=--best tar cjhf ${FILENAME} \
    --exclude-from=${OBS_PACKAGE}/bin/exclude-files.txt  ${OBS_PACKAGE}
rm -rf ${OBS_PACKAGE}

## Step 3:
debug "INFO: Checking out from OBS..."
osc co $OBS_PROJECT $OBS_PACKAGE

if [ $? -ne 0 ]; then
  res=$?
  error "osc checkout reported an error. Please check"
  exit $res
fi

# Check, if the option "checkout_no_colon" is set, directories
# are changed from home:USER to home/USER
COLON=$(grep "^checkout_no_colon" ~/.oscrc )
if [ "x$COLON" != "x" -a ${COLON/*=/} -eq 1 ]; then
OBS_PROJECT="home/$OBS_USER"
fi

# Memorize existing packages:
TARBZ=$(echo $OBS_PROJECT/$OBS_PACKAGE/*.tar.bz2)
# Needed to protect an new tarball from overwriting with an old one
for i in $TARBZ; do
  x=${i##*/}
  if [ "$x" != "$FILENAME" ]; then
    mv -v $i .
  fi
done
# Copy the new tarball into the OBS working copy:
cp -v ${FILENAME} $OBS_PROJECT/$OBS_PACKAGE


###
pushd $OBS_PROJECT/$OBS_PACKAGE

# Update to the new version:
sed -i "/^\%define _version/{s/\(.* \).*/\1$DATE/}" ${OBS_PACKAGE}.spec

if [ "$MESSAGE" = '' ]; then
  TEMPFILE=$(mktemp /tmp/susedoc-msg.XXXX)
  echo "Enter your message and finish with Ctrl+D"
  cat > $TEMPFILE
  MESSAGE=$(cat $TEMPFILE)
  rm $TEMPFILE
fi

debug "INFO: Modifying .changes file"
osc vc --message "$MESSAGE"  ${OBS_PACKAGE}.changes
debug "INFO: Building for ${OBS_OS}_${OBS_VERSION}..."
#
osc build ${OBS_OS}_${OBS_VERSION}

if [ $? -ne 0 ]; then
  res=$?
  error "osc reported an error. Please check"
  exit $res
else
  debug "INFO: Build was successful."
fi


if [ $COMMIT -gt 0 ]; then
  question "Would you like to commit it?"
  if [ "$answer" = "y" ]; then
    debug 'INFO: Removing old tarball(s)...'
    for t in $TARBZ; do
        x=${t##*/}
        if [ "$x" != "$FILENAME" ]; then
          osc rm $x
        fi
    done
    osc add "${FILENAME}"
    debug "INFO: Committing..."
    osc ci --message "$MESSAGE"
    osc status
    TIME=$(date +%H%M%S)
    # Create a tag in the corresponding directory:
    if [ "$NOTAG" = "no"  ]; then
    debug "INFO: Tagging ${OBS_PACKAGE}-${PACKAGEVERSION}_${DATE}T${TIME}..."
    svn copy --message "$MESSAGE" \
      $BERLIOS_URL/$BERLIOS_susedoc \
      $BERLIOS_URL/$BERLIOS_susedoc_tags/obs/${OBS_PACKAGE}-${PACKAGEVERSION}_${DATE}T${TIME}
    else
     debug "INFO: Skipped tag creation"
    fi
  fi
else
 debug "INFO: Changes NOT committed."
fi

popd # from $OBS_PROJECT/$OBS_PACKAGE
popd # from $TEMPDIR


if [ "$KEEPTEMP" = "no" -a "$TEMPDIR" != '' ]; then
debug "INFO: Removing temp directory '$TEMPDIR'..."
rm -rf $TEMPDIR
else
debug "INFO: Using the directory '$TEMPDIR'"
fi

debug "*** Finished. ***"

## EOF
