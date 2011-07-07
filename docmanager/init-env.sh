#!/bin/sh

ENV=env
DIR=$PWD

manualinstall() {
pushd $ENV
# Create link in bin
pushd bin
 ln -s ../../bin/docmanager2.py
popd

sitepackages=$(bin/python -c "from distutils.sysconfig import get_python_lib; print(get_python_lib())")

# Create link for dm modules
pushd $sitepackages/../
ln -s ../../../dm
popd

source bin/activate
popd
}

# Check --clear option for virtualenv:
virtualenv --no-site-packages $ENV
source $ENV/bin/activate
$ENV/bin/easy_install york
$ENV/bin/python setup.py install --root $ENV --record installed-files.txt

