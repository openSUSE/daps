#!/bin/sh

ENV=env
DIR=$PWD
CLEAR=
STEP=0

# Base directory for building in a RPM environment:
ROOTDIR=
# Root directory where SVN repository and working directory are located:
TEMPDIR=/var/tmp/
# The name of our SVN repository:
SVNREPO=docmanagersvn
# The name of our SVN working directory:
WORKINGREPO=docmanager
# Contains all the structures/files which are exported to $WORKINGREPO
TESTROOT=${PWD}/dm/tests/ROOT

# ---------
# Usage of help
#
function usage() {
   cat << EOF
$0 --tempdir | --svnrepo | --workingrepo | --rootdir | --clear
Initalize the testing environment

--tempdir      Temporary directory, default "$TEMPDIR"
--svnrepo      The name of our SVN repository, default "$SVNREPO"
--workingrepo  The name of our SVN working directory, default "$WORKINGREPO"
--rootdir      Prefix of tempdir, default is empty
EOF
}


# ---------
# Verbose error handling
#
function exit_on_error () {
    echo "error" "ERROR: ${1}"
    exit 1;
}

# ---------
# Print message, but observe QUIET
#
function message() {
  if [[ yes != $QUIET ]]; then
    printf "$1"
  fi
}


# Taken from the example getopt-parse.bash
#export LC_ALL=C
TEMP=$(getopt -o h -l "help,rootdir:,tempdir:,svnrepo:,workingrepo:,clear" -n "$0" -- "$@")
eval set -- "$TEMP"

while true; do
   # printf "Option: $1 \n"
   case $1 in
    -h|--help)
      usage 
      exit 0
      ;;
    --rootdir)
      ROOTDIR=$2
      shift 2
      ;;
    --tempdir)
      TEMPDIR=$2
      shift 2
      ;;
    --svnrepo)
      SVNREPO=$2
      shift 2
      ;;
    --workingrepo)
      WORKINGREPO=$2
      shift 2
      ;;
    --) shift ; break ;;
    *)
      printf "Unknown option $1\n"
      exit 10
      ;;
   esac
done


printf "ROOTDIR=$ROOTDIR\nTEMPDIR=$ROOTDIR$TEMPDIR\nSVNREPO=$ROOTDIR$TEMPDIR$SVNREPO\nWORKINGREPO=$ROOTDIR$TEMPDIR$WORKINGREPO\n\n"


# Save our environment:
cat > .env-config << EOF
ROOTDIR="$ROOTDIR"
TEMPDIR="$ROOTDIR$TEMPDIR"
SVNREPO="$ROOTDIR$SVNREPO"
WORKINGREPO="$ROOTDIR$WORKINGREPO"
EOF

#
# Start
#

if [ ! -d ${ROOTDIR}${TEMPDIR}/${SVNREPO} -a ! -d ${ROOTDIR}${TEMPDIR}/${WORKINGREPO} ]; then
# Change directory:
mkdir -p ${ROOTDIR}${TEMPDIR}
pushd ${ROOTDIR}${TEMPDIR}

# Create a test SVN repository
svnadmin create ${ROOTDIR}${TEMPDIR}/${SVNREPO}

# Export our test structure into our working directory:
svn export ${TESTROOT} ${ROOTDIR}${TEMPDIR}/${WORKINGREPO}.tmp

# Import our test structure into 
svn import ${ROOTDIR}${TEMPDIR}/${WORKINGREPO} file://${TEMPDIR}/${SVNREPO} -m"Initial import"

# Remove obsolete temporary structure and checkout freshly:
rm -rf ${ROOTDIR}${TEMPDIR}/${WORKINGREPO}.tmp
svn co file://${TEMPDIR}/${SVNREPO} ${WORKINGREPO}

popd

else
 printf "SVN and Working directory already there.
  => Using SVNREPO=\"${ROOTDIR}${TEMPDIR}/$SVNREPO\" WORKINGREPO=\"${ROOTDIR}${TEMPDIR}/$WORKINGREPO\"\n\n"
fi


# Create our virtualenv:
virtualenv --no-site-packages $CLEAR $ENV
source $ENV/bin/activate
# Install docmanager in the virtualenv
$ENV/bin/python setup.py install --single-version-externally-managed \
  --record installed-files.txt

# We want a _link_, not a copy as this is a evil trap:
pushd $ENV/bin
ln -sf ../bin/docmanager2.py
popd

# Patch our environment:
pushd $ENV/lib/python2.7/site-packages
ln -sf ../../../../dm
popd

# EOF