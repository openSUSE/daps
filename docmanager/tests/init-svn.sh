#!/bin/sh

# Root directory where SVN repository and working directory are located:
TEMPDIR=/var/tmp
# The name of our SVN repository:
SVNREPO=/var/tmp/docmanagersvn
# The name of our SVN working directory:
WORKINGREPO=/var/tmp/docmanager
# Contains all the structures/files which are exported to $WORKINGREPO
TESTROOT=ROOT

usage() {
   cat << EOF
$0 --svnrepo | --workingrepo --testroot
Initalize the test environment
EOF
}


# Taken from the example getopt-parse.bash
#export LC_ALL=C
ARGS=$(getopt -o h -l help,svnrepo:,workingrepo:,testroot: -n $0 -- "$@")
eval set -- "$ARGS"

while true; do
   # printf "Option: $1 \n"
   case $1 in
    -h|--help)
      usage 
      exit 0
      ;;
    --svnrepo)
      SVNREPO=$2
      shift 2
      ;;
    --workingrepo)
      WORKINGREPO=$2
      shift 2
      ;;
    --testroot)
      TESTROOT=$2
      shift 2
      ;;
    --) shift ; break ;;
    *)
      printf "Unknown option $1\n"
      exit 10
      ;;
   esac
done

echo SVNREPO=$SVNREPO, WORKINGREPO=$WORKINGREPO, TESTROOT=$TESTROOT


exit 10

if [ ! -d ${SVNREPO} ]; then
 printf "Creating SVN repository ${SVNREPO}"

# Change directory:
# pushd ${TEMPDIR}

# Create a test SVN repository
svnadmin create ${SVNREPO}

# Export our test structure into our working directory:
svn export ${TESTROOT} ${WORKINGREPO}.tmp

# Import our test structure into 
svn import ${WORKINGREPO} file://${SVNREPO} -m"Initial import"

# Remove obsolete temporary structure and checkout freshly:
rm -rf ${WORKINGREPO}.tmp
else
  printf "SVN repository already there. Using '$SVNREPO'"
fi

if [ ! -d ${WORKINGREPO} ]; then
  svn co file://${SVNREPO} ${WORKINGREPO}
else
  printf "SVN working directory already there. Using '$WORKINGREPO'"
fi

#popd


# EOF