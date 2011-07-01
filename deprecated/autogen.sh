#!/bin/sh

echo -ne "\n*** Generating configure and Makefiles... *** \n\n"

# (echo " Calling aclocal  ..." ;
# aclocal ) &&
# (echo " Calling automake ..." ;
# automake -c -a ) &&
# (echo " Calling autoconf ..." ;
# autoconf) &&
autoreconf -i &&
echo -ne "\n\nFinished. Now type ./configure && make\n\n"
