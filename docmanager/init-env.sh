#!/bin/sh

ENV=env
DIR=$PWD

CLEAR=

if [ "$1" = "--clear" ]; then
 CLEAR="--clear"
fi

# Check --clear option for virtualenv:
virtualenv --no-site-packages $CLEAR $ENV
source $ENV/bin/activate
# $ENV/bin/easy_install york
$ENV/bin/python setup.py install --single-version-externally-managed --record installed-files.txt

