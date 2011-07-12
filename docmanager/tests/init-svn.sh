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


# ---------
# Verbose error handling
#
function exit_on_error () {
    echo "error" "ERROR: ${1}"
    exit 1;
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
      if [[ -d $2 ]]; then
        SVNREPO=$2
      else
        exit_on_error "No valid SVN repository path"
      fi
      shift 2
      ;;
    --workingrepo)
      if [[ -d $2 ]]; then
        WORKINGREPO=$2
      else
        exit_on_error "No valid SVN working directory"
      fi
      shift 2
      ;;
    --testroot)
      if [[ -d $2 ]]; then
        TESTROOT=$2
      else
        exit_on_error "No valid SVN working directory"
      fi
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