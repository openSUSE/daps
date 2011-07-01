#!/bin/bash

SUSESVN=https://svn.suse.de/svn/doc

usage() 
{
 printf "${0##*/}\nCheck out the structure of SVN documentation\n"
 exit 0
}

case $1 in
  -h|--help|-?)
   usage
   ;;
esac



# Get the exact version string from the installed Subversion package
ver=$(rpm -q --queryformat '%{VERSION}' subversion)

# Put it in a shell array
ARRAY=($(echo $VER | tr '.' ' '))

# Check 1.4 version string accordingly:
if [ "${ARRAY[1]}" = "4" ]; then
 # Subversion 1.4 uses the -N/--non-recursive
OPTION="-N"
else 
 # After version 1.5, -N is replaced by --depth
OPTION="--depth=empty"
fi


svn co $OPTION $SUSESVN/
pushd doc
svn up $OPTION trunk branches
 pushd trunk
  svn up $OPTION books
  pushd books
   svn up en
  popd
  svn up novdoc
 popd
popd 1>/dev/null

echo
echo -e "Branches\n Currently, the branches directory is empty due to its size."
echo -e " However, you can get some directories from the SVN server (ATM $SUSESVN)"
echo -e " Listing of contents from $SUSESVN/branches:\n"
svn ls $SUSESVN/branches

echo -e "\n To get a certain directory, use the following commands:"
echo -e "   ( cd doc/branches ; svn up SLE_111 )"
exit 0

# EOF