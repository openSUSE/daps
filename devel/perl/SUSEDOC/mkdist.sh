#! /bin/sh

# can be called from make dist POSTOP, or directly.

version=`perl -MExtUtils::MM_Unix -e 'print ExtUtils::MM_Unix::parse_version(0, "SUSEDOC.pm")."\n"'`

if [ "x$MAKELEVEL" = x ]; then
 # we are called directly, prepare stuff..
 perl Makefile.PL
 make test
 make dist
fi
set -x
head Changes > dist/Changes.head
cp -f Changes SUSEDOC-$version.tar.* dist/
cd dist/
sed -i -e "s/^Version:.*/Version: $version/" *.spec
grep '^Version:' *.spec
echo "Press Enter for 'osc vc'"; read a
env mailaddr=$LOGNAME@suse.de osc vc *.changes Changes.head
rm -f Changes*
echo "Press Enter for 'osc ci'"; read a
osc ci

