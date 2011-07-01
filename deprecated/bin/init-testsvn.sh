#!/bin/sh
#
# This script creates a "dummy" SVN repository with the same structure than the original.
# It is used by test scripts to perform unit test for docmanager

# Some names:
TEMPDIR=/var/tmp
SVNREPO=doctestsvn
WORKINGREPO=doctest
SUSEDOCPATH=/usr/share/susedoc
STEP=0
NOVDOCDIR="${PWD%/novdoc/*}/novdoc"
# Check, if we are in novdoc directory:
#if [ ${NOVDOCDIR} = ${NOVDOCDIR%/trunk/novdoc} ]; then
# echo "ERROR: It seems you are not in the novdoc directory"
# exit 10
#fi


# Taken from the example getopt-parse.bash
#export LC_ALL=C
TEMP=$(getopt -o h -l "help,temppath,svnrepo,workingrepo,absworkingrepo,abssvnrepo," -n "$0" -- "$@")
eval set -- "$TEMP"

while true
do
   # printf "Option: $1 \n"
   case $1 in
    -h|--help)
      printf "$0 --temppath | --svnrepo | --workingrepo | --absworkingrepo\n\n"
      printf "Just print some paths, nothing can be changed.\n"
      exit 0
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


#
# Start
#
pushd .

# Change directory into something temporary:
cd ${TEMPDIR}

# Create a test SVN repository
[ -d $PWD/${SVNREPO} ] || svnadmin create $PWD/${SVNREPO}

#
# Create our directory structure
#
STEP=$(( $STEP+1 ))
printf "\n*** Step $STEP: Creating directory structure...\n"
mkdir -p doc/{trunk/books/en/{tmp,xml,profiled},branches} \
         doc/trunk/books/en/images/{gen,online,print,src/{dia,fig,pdf,png,svg}} \
         doc/branches/OS_110/books/en/{tmp,xml,images/{gen,online,print,src/{dia,fig,pdf,png,svg}}}

#
# Create an ENV file:
#
STEP=$(( $STEP+1 ))
printf "\n*** Step $STEP: Creating ENV file...\n"
cat > doc/trunk/books/en/ENV-opensuse-startup << EOF
# -*- shell-script -*-

. .env-profile

export MAIN=MAIN.opensuse.xml
#export BOOK=SLPROF-print
export ROOTID="book.opensuse.startup"
export PROFARCH="x86;amd64;em64t"
export PROFOS="slprof"
export DISTVER="11.0"
EOF

#
# Create a .env-profile
#
STEP=$(( $STEP+1 ))
printf "\n*** Step $STEP: Creating .env-profile...\n"
cat > doc/trunk/books/en/.env-profile << 'EOF'
# -*- shell-script -*-
unset DTDROOT
export DTDROOT=$(make dtdroot)
echo "Using the DTDROOT ${DTDROOT}"
. $DTDROOT/etc/system-profile
EOF


#
# Create the Makefile
#
STEP=$(( $STEP+1 ))
printf "\n*** Step $STEP: Creating Makefile...\n"
# DO NOT insert a space between "<<" and "EOF".
# This notation is needed to interpret the ${...} variables
cat > doc/trunk/books/en/Makefile <<EOF
# .PHONY: default
# default: help

ifndef DTDROOT
DTDPATH1 = ${SUSEDOCPATH}
DTDPATH2 = \$(shell test -d ../../novdoc && (cd ../../novdoc; pwd))
DTDPATH3 = \$(shell test -d ../../../../trunk/novdoc && (cd ../../../../trunk/novdoc; pwd))
DTDPATH4 = ${NOVDOCDIR}

DTDROOT := \$(firstword \$(DTDPATH1) \$(DTDPATH4) \$(DTDPATH3) \$(DTDPATH2))
else
include \$(DTDROOT)/make/common.mk
endif

.PHONY: dtdroot
dtdroot:
	@echo \$(DTDROOT)

EOF

#
# MAIN file
#
STEP=$(( $STEP+1 ))
printf "\n*** Step $STEP: Creating example XML file...\n"
cat > doc/trunk/books/en/xml/MAIN.opensuse.xml << EOF
<?xml version="1.0" encoding="utf-8"?>
<?xml-stylesheet href="urn:x-suse:xslt:profiling:novdoc-profile.xsl"
                 type="text/xml"
                 title="Profiling step"?>
<!DOCTYPE set PUBLIC "-//Novell//DTD NovDoc XML V1.0//EN"
                      "novdocx.dtd"
[
  <!-- No entities to simplify the task -->
  <!-- Example file for testing environment -->
]>

<set lang="en">
  <title>SUSE Documentation</title>
  <?dbhtml filename="index.html"?>
  <book lang="en" id="book.opensuse.startup" role="print">
    <bookinfo>
      <title>Quickstart</title>
      <productname>product</productname>
      <productnumber>11.0</productnumber>
      <date><?dbtimestamp format="B d, Y"?></date>
      <legalnotice>
        <para>Bla bla bla</para>
      </legalnotice>
    </bookinfo> 
    
    <xi:include xmlns:xi="http://www.w3.org/2001/XInclude" 
                href="quickstart.xml"/>
  </book>
</set>
EOF


#
# Example file
#
STEP=$(( $STEP+1 ))
printf "\n*** Step $STEP: Creating example XML file...\n"
cat > doc/trunk/books/en/xml/quickstart.xml << EOF
<?xml version="1.0" encoding="UTF-8"?>
<?xml-stylesheet href="urn:x-suse:xslt:profiling:novdoc-profile.xsl"
                 type="text/xml"
                 title="Profiling step"?>

<!DOCTYPE article PUBLIC "-//Novell//DTD NovDoc XML V1.0//EN" "novdocx.dtd"
[
  <!-- No entities to simplify the task -->
  <!-- Example file for testing environment -->
]>
<article lang="en">
   <title>Quickstart</title>
   <abstract>
      <para>This is test abstract paragraph.</para>
   </abstract>

   <sect1 id="sec.kdequick.start">
      <title>Getting Started</title>
      <para>...</para>
      <figure id="fig.rect">
         <title>A Rectangle</title>
         <mediaobject>
            <imageobject role="html">
               <imagedata fileref="rect.png" width="80%"/>
            </imageobject>
            <imageobject role="fo">
               <imagedata fileref="rect.svg" width="80%"/>
            </imageobject>
         </mediaobject>
      </figure>
   </sect1>

   <sect1>
      <title>A Circle</title>
      <para>This is a circle</para>
      <figure>
         <title>A Circle</title>
         <mediaobject>
            <imageobject role="html">
               <imagedata fileref="circle.png" width="80%"/>
            </imageobject>
            <imageobject role="fo">
               <imagedata fileref="circle.svg" width="80%"/>
            </imageobject>
         </mediaobject>
      </figure>
   </sect1>

</article>
EOF


#
# Creating SVG images
#
STEP=$(( $STEP+1 ))
printf "\n*** Step $STEP: Creating SVG images...\n"
cat > doc/trunk/books/en/images/src/svg/rect.svg  << EOF
<?xml version="1.0" encoding="UTF-8" standalone="no"?>
<svg id="recht"
   xmlns="http://www.w3.org/2000/svg"
   width="500pt" height="500pt">
  
  <rect id="rect2282"
       style="fill:#008080;"
       x="80pt"
       y="150pt"
       width="300pt"
       height="300pt" />
</svg>
EOF
cat > doc/trunk/books/en/images/src/svg/circle.svg  << EOF
<?xml version="1.0" encoding="UTF-8" standalone="no"?>
<svg id="circle"
   xmlns="http://www.w3.org/2000/svg"
   width="500pt" height="500pt">

  <circle id="circle2198"
       cx="250" cy="250" r="100pt"
       style="fill:#008080" />
</svg>
EOF


#
# Import the generated structure
#
STEP=$(( $STEP+1 ))
printf "\n*** Step $STEP: Importing generated structure...\n"
svn import doc/ file://$PWD/${SVNREPO}/doc/ -m"Initial import"


# Rename it:
mv doc doc2import

#
# Check it out:
#
STEP=$(( $STEP+1 ))
printf "\n*** Step $STEP: Checking out from test SVN...\n"
svn checkout file:///$PWD/${SVNREPO}/doc ${WORKINGREPO}

pushd .
cd ${WORKINGREPO}/trunk/books/en/

#
# Set properties for MAIN.opensuse.xml, ENV*, and Makefile
#
STEP=$(( $STEP+1 ))
printf "\n*** Step $STEP: Setting SVN properties...\n"
svn ps doc:maintainer $USER     xml/*.xml ENV* Makefile .env-profile
svn ps doc:release "OS_110"     xml/*.xml ENV* Makefile .env-profile
svn ps doc:status "editing"     xml/*.xml ENV* Makefile .env-profile
svn ps doc:deadline 2008-04-30  xml/*.xml ENV* Makefile .env-profile
svn ps doc:trans "yes"          xml/*.xml ENV* Makefile .env-profile
svn ps doc:priority "1"         xml/*.xml ENV* Makefile .env-profile

# Set properties for quickstart.xml
svn ps doc:maintainer "tux"     xml/quickstart.xml
svn ps doc:priority "2"         xml/quickstart.xml

# Set properties for SVG files:
svn ps doc:maintainer $USER      images/src/svg/*.svg
svn ps doc:release    "OS_110"   images/src/svg/*.svg
svn ps doc:status     "editing"  images/src/svg/*.svg
svn ps doc:deadline   2008-04-30 images/src/svg/*.svg
svn ps doc:trans      no         images/src/svg/*.svg
svn ps doc:priority   4          images/src/svg/*.svg

# Commit everything
svn ci -m"New file, added doc properties" xml/*.xml ENV* Makefile .env-profile images/src/svg/*.svg

#
# Initialize the Working Directory
#
STEP=$(( $STEP+1 ))
printf "\n*** Step $STEP: Initialize the Working Directory...\n"
. ENV-opensuse-startup

popd

# Remove the structure as it is now obsolete and in SVN:
rm -rf doc2import


#
# Change SVN dir to make revision properties possible
#
STEP=$(( $STEP+1 ))
printf "\n*** Step $STEP: Change SVN dir to make revision properties possible...\n"

cd $TEMPDIR/$SVNREPO/hooks
cat > pre-revprop-change << EOF
#!/bin/sh
# We want to have revprops for all names, not only svn:log
echo "REPOS=\$REPOS, REV=\$REV, USER=\$USER, PROPNAME=\$PROPNAME, ACTION=\$ACTION"
exit 0
EOF
chmod 755 pre-revprop-change

#
popd


#
printf "\n===========================================\n"
printf "Find the Working Dir at:  ${TEMPDIR}/${WORKINGREPO}\n"
printf "Find the SVN Repo at:     ${TEMPDIR}/${SVNREPO}\n"
printf "===========================================\n"

printf "\n*** DONE ***\n"
exit 0
