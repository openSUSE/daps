#!/bin/bash
#
#

echo -ne "\n*** Generating configure and Makefiles... *** \n\n"

# Creating files which is expected by GNU projects:
touch NEWS README AUTHORS ChangeLog
aclocal -I m4 && autoconf && automake --force-missing --add-missing --copy

echo -ne "\n\nFinished. Now type ./configure && make\n\n"
