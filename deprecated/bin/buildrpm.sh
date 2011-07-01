#!/bin/sh

TMP="/tmp/susedoc.$$"
pushd .
tar-up.sh | tee ${TMP}
DIR=$(head -n1 ${TMP} | cut -d' ' -f1)

if [ -e ${DIR} -a -d ${DIR} ]; then
  cd ${DIR}
else
  rm ${TMP}
  echo "ERROR: Could not find directory: ${DIR}"
  popd
  exit 10
fi

echo -e "\n\n## Copying archive...\n"
cp -v ${DIR}/*.tar.bz2 /usr/src/packages/SOURCES
echo -e "\n## Building RPM package...\n"
rpmbuild -ba susedoc.spec

rm ${TMP}
popd