#!/bin/sh

usage() {
cat << EOF
Used to simplify creation of susedoc RPM packages
This script creates under /tmp a directory novdoc.XXXX\n
with a tar.bz2 archive and a spec file.
You can build the RPM with:
  1. Copy the archive to /usr/src/packages/SOURCES
  2. rpmbuild -ba susedoc.spec
Find your RPM package under /usr/src/packages/RPM/noarch/

OR with the openSUSE build server:

  1. osc co Documentation susedoc
  2. cd susedoc
  3. osc build susedoc.spec
  4. If you have commit rights, check in your changes:
     osc ci -m"Your Log message"
EOF
}

PACKAGEVERSION="4.2"
TAG=''

DOCMAKER=$PWD
#SVNURL=https://svn.suse.de/svn/doc/trunk
#SVNPRJ=novdoc
SVNPRJ=opensuse-docmaker
SVNURL="https://svn.berlios.de/svnroot/repos/$SVNPRJ"

TEMP=$(getopt -o ht -l "help,tag" -n "$0" -- "$@")
eval set -- "$TEMP"

while true
do
   # printf "Option: $1 \n"
   case $1 in
    -h|--help)
      printf "$0 [OPTIONS]\n\n"
      usage
      cat << EOF

 -h, --help
    Prints this help text
 -t, --tag TAG
    Get the source from a tagged source instead from trunk
EOF
      exit 0
      ;;
    -t|--tag)
      echo "$1 $2 $3"
      shift
      TAG=$2
      printf "Using tag \"$TAG\"\n"
      break
      #exit 0
      ;;
    --) shift ; break ;;
    *)
      printf "Unknown option $1\n"
      exit 10
      ;;
   esac
   shift
done


BUILDDIR=$(mktemp -d /tmp/$SVNPRJ.XXXX)
pushd ${BUILDDIR}
DATE=$(date +%Y%m%d)

if [ "$TAG" = '' ]; then
test -z "$FILENAME" && FILENAME=susedoc-${PACKAGEVERSION}_${DATE}.tar.bz2
else
FILENAME=$TAG.tar.bz2
fi


# Insert here your files that are excluded from the archive


if [  "$TAG" = '' ]; then
svn export $SVNURL/trunk/ susedoc
DIR=susedoc
else
svn export $SVNURL/tags/$TAG
DIR=$TAG
fi

mv -vi $BUILDDIR/susedoc/bin/exclude-files.txt $BUILDDIR/

BZIP2=--best tar cjhf ${FILENAME} \
    --exclude-from=$BUILDDIR/exclude-files.txt \
	 $DIR 
sed -e "s/@SOURCE0@/${FILENAME}/" \
    -e "s/@RELEASE@/${DATE}/" \
    < $DIR/etc/susedoc.spec.in > susedoc.spec

echo "## package susedoc copied to ${BUILDDIR}"

# -----------------------------------
# Check out the doc too:
# -----------------------------------
# cat > $BUILDDIR/doc-exclude.txt << EOF
# .svn
# ENV-cvsdoc
# ENV-docmanager
# ENV-FATE
# ENV-gooddocu
# #ENV-makedoc
# ENV-styleguide
# ENV-styleguide.opensuse
# ENV-susedoc
# ENV-svndoc
# ENV-xen
# FAQ
# martina.txt
# button.png
# check.png
# combo.png
# lineedit.png
# listbox.png
# # miracle.png
# radio.png
# scrollbar.png
# slide.png
# spin.png
# EOF

# svn export §SVNURL/guides/en  susedoc-doc
# BZIP2=--best tar cjhf susedoc-doc-${PACKAGEVERSION}_${DATE}.tar.bz2 \
#     --exclude-from=$BUILDDIR/doc-exclude.txt \
# 	susedoc-doc
# sed -e "s/@SOURCE0@/susedoc-doc-${PACKAGEVERSION}_${DATE}.tar.bz2/" \
#     -e "s/@RELEASE@/${DATE}/" \
#     < $DIR/etc/susedoc-doc.spec.in > susedoc-doc.spec
# 
# echo "## package template copied to ${BUILDDIR}"

#cp -v ${FILENAME} /usr/src/packages/SOURCES
#echo "## Building RPM package..."
#rpmbuild -ba susedoc.spec

popd
