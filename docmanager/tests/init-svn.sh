#!/bin/sh

# Root directory where SVN repository and working directory are located:
TEMPDIR=/var/tmp
# The name of our SVN repository:
SVNREPO=/var/tmp/docmanagersvn
# The name of our SVN working directory:
WORKINGREPO=/var/tmp/docmanager
# Contains all the structures/files which are exported to $WORKINGREPO
TESTROOT=ROOT
# Make it less verbose
QUIET=

# ---------
# Usage of help
#
function usage() {
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
ARGS=$(getopt -o hq -l help,quiet,svnrepo:,workingrepo:,testroot: -n $0 -- "$@")
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
    -q|--quiet)
      QUIET=yes
      shift
      ;;
    --) shift ; break ;;
    *)
      printf "Unknown option $1\n"
      exit 10
      ;;
   esac
done

# message SVNREPO=$SVNREPO, WORKINGREPO=$WORKINGREPO, TESTROOT=$TESTROOT, QUIET=$QUIET\n


if [ ! -d ${SVNREPO} ]; then
  message "Creating SVN repository ${SVNREPO}\n"

# Change directory:
# pushd ${TEMPDIR}

# Create a test SVN repository
svnadmin create ${SVNREPO}

# Export our test structure into our working directory:
svn export ${TESTROOT} ${WORKINGREPO}.tmp

# Import our test structure into 
svn import ${WORKINGREPO}.tmp file://${SVNREPO} -m"Initial import"

# Remove obsolete temporary structure and checkout freshly:
rm -rf ${WORKINGREPO}.tmp
else
  message "SVN repository already there. Using '$SVNREPO'\n"
fi


if [ ! -d ${WORKINGREPO} ]; then
  svn co file://${SVNREPO} ${WORKINGREPO}
else
  message "SVN working directory already there. Using '$WORKINGREPO'\n"
fi

#popd


# EOF