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

#-----
# Using PHNOY here to make sure this file is generated every time, because
# there is no way to tell if the SVN properties have changed since
# last generating this file
#
ifeq ($(META),1)
  ifdef USESVN
    # meta information (author, last changed, etc)
    METASTRING   := --param "use.meta=1"

    $(PROFILEDIR)/METAFILE: | $(TMP_DIR)
    $(PROFILEDIR)/METAFILE: $(SRCFILES)
      ifeq ($(VERBOSITY),2)
	@ccecho "info"  "Generating $@ ..."
      endif
	svn pl -v --xml $(SRCFILES) > $(TMP_DIR)/.docprops.xml
	$(XSLTPROC) -o $@ --stylesheet $(STYLEMETA) \
	  --file $(TMP_DIR)/.docprops.xml $(XSLTPROCESSOR)
  endif
endif
