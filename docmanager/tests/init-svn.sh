#!/bin/bash
#
# This script initializes a test SVN repository, checks out a
# working copy, and add some SVN properties
#

__version__="$Revision$"
__author__="Thomas Schraitle <toms AT opensuse DOT org>"


# Our predefinied properties:
declare -A PROPS=( [doc:maintainer]="toms" [doc:deadline]="2011-08-23" [doc:release]="DMTest"
[doc:status]="editing" [doc:trans]="no" )

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

### Create initial SVN repository:
if [ ! -d ${SVNREPO} ]; then
  message "Creating SVN repository ${SVNREPO}\n"

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

### Checkout a working copy:
if [ ! -d ${WORKINGREPO} ]; then
  svn co file://${SVNREPO} ${WORKINGREPO}
else
  message "SVN working directory already there. Using '$WORKINGREPO'\n"
fi

### Patch SVN directory to allow revision prop changes:
if [ ! -e ${SVNREPO}/hooks/pre-revprop-change ]; then
  cat > ${SVNREPO}/hooks/pre-revprop-change << EOF
#!/bin/sh
# Every revision property is allowed:
exit 0
EOF
  message "SVN repository patched.\n"
else
  message "SVN contains pre-revprop-change hook script already.\n"
fi

### Set some preliminary properties
pushd ${WORKINGREPO}

# Iterate through all XML files and set it to our standard doc properties:
q=${QUIET:+--quiet}
for i in xml/*.xml; do
 for p in "${!PROPS[@]}"; do
   svn ps $q $p ${PROPS[$p]} $i
 done
done

# Commit our change:
svn ci -m"Set standard doc properties"
popd

# EOF