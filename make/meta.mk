# Copyright (C) 2012 SUSE Linux Products GmbH
#
# Author: Frank Sundermeyer
#
# METAFILE generation for DAPS
#
# Please submit feedback or patches to
# <fsundermeyer at opensuse dot org>
#
# for targets html, pdf, color-pdf
#
STYLEMETA := $(DAPSROOT)/daps-xslt/common/svn2docproperties.xsl

ifeq ($(META),1)
  ifdef USESVN
    # meta information (author, last changed, etc)
    METASTRING   := --param "use.meta=1"

    $(PROFILEDIR)/METAFILE: $(TMP_DIR)/.$(DOCNAME)_docprops.xml
      ifeq ($(VERBOSITY),2)
	@ccecho "info"  "Generating $@ ..."
      endif
	$(XSLTPROC) -o $@ --stylesheet $(STYLEMETA) --file $< $(XSLTPROCESSOR)
  endif
endif

#-----
# Using PHONY here to make sure this file is generated every time, because
# there is no way to tell if the SVN properties have changed since
# last generating this file
#
PHONY: $(TMP_DIR)/.$(DOCNAME)_docprops.xml
$(TMP_DIR)/.$(DOCNAME)_docprops.xml: | $(TMP_DIR)
$(TMP_DIR)/.$(DOCNAME)_docprops.xml: $(DOCFILES)
	svn pl -v --xml $(DOCFILES) > $@
