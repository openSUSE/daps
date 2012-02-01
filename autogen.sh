#!/bin/bash
#
#

echo -ne "\n*** Generating configure and Makefiles... *** \n\n"

# Creating files which is expected by GNU projects:
touch NEWS README AUTHORS ChangeLog
aclocal && autoconf && automake --force-missing --add-missing

echo -ne "\n\nFinished. Now type ./configure && make\n\n"