#!/bin/sh

ENV=env
DIR=$PWD
CLEAR=
STEP=0

# Root directory where SVN repository and working directory are located:
TEMPDIR=/var/tmp
# The name of our SVN repository:
SVNREPO=docmanagersvn
# The name of our SVN working directory:
WORKINGREPO=docmanager
# Contains all the structures/files which are exported to $WORKINGREPO
TESTROOT=${PWD}/dm/tests/ROOT

usage() {
   printf "$0 --temppath | --svnrepo | --workingrepo | --absworkingrepo\n\n"
   printf "Just print some paths, nothing can be changed.\n"   
}


# Taken from the example getopt-parse.bash
#export LC_ALL=C
TEMP=$(getopt -o h -l "help,temppath,svnrepo,workingrepo,absworkingrepo,abssvnrepo,clear" -n "$0" -- "$@")
eval set -- "$TEMP"

while true
do
   # printf "Option: $1 \n"
   case $1 in
    -h|--help)
      usage 
      exit 0
      ;;
    --clear)
      CLEAR=--clear
      ;;
    --temppath)
      printf "${TEMPDIR}\n"
      exit 0
      ;;
    --svnrepo)
      printf "${SVNREPO}\n"
      exit 0
      ;;
    --workingrepo)
      printf "${WORKINGREPO}\n"
      exit 0
      ;;
    --absworkingrepo)
      printf "${TEMPDIR}/${WORKINGREPO}\n"
      exit 0
      ;;
    --abssvnrepo)
      printf "${TEMPDIR}/${SVNREPO}\n"
      exit 0
      ;;
    --) shift ; break ;;
    *)
      printf "Unknown option $1\n"
      exit 10
      ;;
   esac
   shift
done

printf "TEMPDIR=$TEMPDIR\nSVNREPO=$SVNREPO\nWORKINGREPO=$WORKINGREPO\n\n"

# Save our environment:
cat > .env-config << EOF
TEMPDIR="$TEMPDIR"
SVNREPO="$SVNREPO"
WORKINGREPO="$WORKINGREPO"
EOF

#
# Start
#

if [ ! -d ${TEMPDIR}/${SVNREPO} -a ! -d ${TEMPDIR}/${WORKINGREPO} ]; then
# Change directory:
pushd ${TEMPDIR}

# Create a test SVN repository
svnadmin create ${TEMPDIR}/${SVNREPO}

# Export our test structure into our working directory:
svn export ${TESTROOT} ${TEMPDIR}/${WORKINGREPO}.tmp

# Import our test structure into 
svn import ${TEMPDIR}/${WORKINGREPO} file://${TEMPDIR}/${SVNREPO} -m"Initial import"

# Remove obsolete temporary structure and checkout freshly:
rm -rf ${TEMPDIR}/${WORKINGREPO}.tmp
svn co file://${TEMPDIR}/${SVNREPO} ${WORKINGREPO}

popd

else
 printf "SVN and Working directory already there.
  => Using SVNREPO=\"${TEMPDIR}/$SVNREPO\" WORKINGREPO=\"${TEMPDIR}/$WORKINGREPO\"\n\n"
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