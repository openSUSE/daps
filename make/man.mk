# Copyright (C) 2012-2015 SUSE Linux GmbH
#
# Author:
# Frank Sundermeyer <fsundermeyer at opensuse dot org>
#
# ASCII generation for DAPS
#
# Please submit feedback or patches to
# <fsundermeyer at opensuse dot org>
#

# includes are set in selector.mk
# include $(DAPSROOT)/make/setfiles.mk
# include $(DAPSROOT)/make/profiling.mk
# include $(DAPSROOT)/make/validate.mk
# include $(DAPSROOT)/make/misc.mk
#

STYLEMAN      := $(firstword $(wildcard $(addsuffix \
			/manpages/docbook.xsl, $(STYLE_ROOTDIRS))))

MANSTRINGS := --stringparam "man.output.base.dir=$(MAN_DIR)/" \
	      --param "refentry.meta.get.quietly=1" \
	      --param "man.output.in.separate.dir=1"

ifeq "$(MAN_SUBDIRS)" "yes"
  MANSTRINGS  += --param "man.output.subdirs.enabled=1"
else
  MANSTRINGS  += --param "man.output.subdirs.enabled=0"
endif

MAN_RESULTS = $(shell $(XSLTPROC) $(MANSTRINGS) $(PARAMS) $(STRINGPARAMS) \
		 $(XSLTPARAM) \
	         --stylesheet $(DAPSROOT)/daps-xslt/common/get-manpage-filename.xsl \
		 --file $(BIGFILE) $(XSLTPROCESSOR))

#--------------
# MAN pages
#
# No need to do a file based generation of the man pages - $STYLEMAN
# generates all of them in one go
#
# The check on $MAN_RESULTS cannot be performed by make itself, because this
# variable is evaluated late. Therefore we test it within the recipe
#
.PHONY: man
man: | $(MAN_DIR)
man: $(PROFILES) $(PROFILEDIR)/.validate
man: $(BIGFILE)
        # only checking firstword, because if $MAN_RESULTS is very long,
        # the test expression will throw an error
	if [ -z $(firstword $(MAN_RESULTS)) ]; then \
	  ccecho "error" "Fatal error: Cannot create man pages, because the XML sources do not\ncontain refentry sections which define man pages." && false; \
	else \
	  $(XSLTPROC) $(ROOTSTRING) $(MANSTRINGS) --stylesheet $(STYLEMAN) \
	    --file $< $(XSLTPROCESSOR) $(ERR_DEVNULL); \
	fi
  ifneq "$(GZIP_MAN)" "no"
	for MANFILE in $$(find $(MAN_DIR) ! -name "*.gz" -type f); do \
	  gzip -f $$MANFILE; \
	done
  endif
	@ccecho "result" "Find the man page(s) at:\n$(MAN_DIR)"


$(MAN_DIR):
	mkdir -p $@
