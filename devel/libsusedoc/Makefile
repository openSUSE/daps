#

DESTDIR=/usr
BINDIR=$(DESTDIR)/bin
LIBDIR=$(DESTDIR)/share/libsusedoc

.PHONY: dist

dist:
	./mkdist.pl libsusedoc.spec "../../bin/project_files.pl -h"

all:
	test -e lib || ln -s ../../lib .
	test -e bin || ln -s ../../bin .

install: all
	mkdir -p $(BINDIR) $(LIBDIR)/lib $(LIBDIR)/bin
	-cp -a lib/* $(LIBDIR)/lib
	-cp -a bin/* $(LIBDIR)/bin
	-cp bin/project_files.pl $(BINDIR)/project_files
	-test -f $(BINDIR)/projectfiles || ln -s project_files $(BINDIR)/projectfiles
