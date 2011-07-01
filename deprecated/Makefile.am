AUTOMAKE_OPTIONS = dist-bzip2 foreign

SUFFIXES = .ac .am .in
.SILENT:

# SUBDIRS = bin etc schema xslt
SUBDIRS = bin etc make schema xslt

nocdocdir = $(DESTDIR)$(datadir)/novdoc

install-xep:
	$(MAKE) -C make install-xep

install-data-local:
	$(mkinstalldirs) $(nocdocdir)
	for dir in bin etc mak ; do \
	  cp -a $$dir $(nocdocdir) ; \
	done
