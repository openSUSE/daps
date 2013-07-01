# Copyright (C) 2012 SUSE Linux Products GmbH
#
# Author: Frank Sundermeyer
#
# Debugging for DAPS
#
# Please submit feedback or patches to
# <fsundermeyer at opensuse dot org>
#

#---------------
# Compute and print the value of a given variable
#
.PHONY: showvariable
showvariable:
  ifndef VARIABLE
	@echo "Usage: daps showvariable VARIABLE=some_variable";
  else
    ifeq ("$($(VARIABLE))", "")
	@ccecho "result" "undef";
    else	
	@ccecho -- "result" "$($(VARIABLE))"
    endif
  endif

#---------------
# Show the daps environment 
#

define DAPSENVLIST
@echo -e "\
General\n\
-------\n\
SHELL     = $(SHELL)\n\
VERBOSITY = $(VERBOSITY)\n\
\n\
Files & Directories\n\
--------------------\n\
BUILD_DIR          = $(BUILD_DIR)\n\
DOC_DIR            = $(DOC_DIR)\n\
IMG_GENDIR         = $(IMG_GENDIR)\n\
IMG_SRCDIR         = $(IMG_SRCDIR)\n\
MAIN               = $(MAIN)\n\
PACK_DIR           = $(PACK_DIR)\n\
RESULT_DIR         = $(RESULT_DIR)\n\
TMP_DIR            = $(TMP_DIR)\n\
\n\
Document specifics\n\
------------------\n\
DOCNAME            = $(DOCNAME)\n\
FALLBACK_STYLEROOT = $(FALLBACK_STYLEROOT)\n\
HTML_CSS           = $(HTML_CSS)\n\
LL                 = $(LL)\n\
PDFNAME            = $(PDFNAME)\n\
ROOTID             = $(ROOTID)\n\
STYLEIMG           = $(STYLEIMG)\n\
STYLEROOT          = $(STYLEROOT)\n\
\n\
Profiling\n\
---------\n\
PROFILE_URN        = $(PROFILE_URN)\n\
PROFILED_MAIN      = $(PROFILED_MAIN)\n\
PROFILEDIR         = $(PROFILEDIR)\n\
PROFILE_PARENT_DIR = $(PROFILE_PARENT_DIR)\n\
\n\
ePUB\n\
----\n\
EPUB_CSS          = $(EPUB_CSS)\n\
STYLEEPUB         = $(STYLEEPUB)\n\
STYLEEPUB_BIGFILE = $(STYLEEPUB_BIGFILE)\n\
\n\
HTML / SINGLE-HTML / JSP\n\
------------------------\n\
HTML_DIR  = $(HTML_DIR)\n\
HTML_CSS  = $(HTML_CSS)\n\
STYLEHTML = $(STYLEHTML)\n\
META       = $(META)\n\
\n\
Man pages\n\
---------\n\
MAN_DIR  = $(MAN_DIR)\n\
STYLEMAN = $(STYLEMAN)\n\
\n\
PDFs\n\
----\n\
FOFILE     = $(FOFILE)\n\
FORMATTER  = $(FORMATTER)\n\
PDF_RESULT = $(PDF_RESULT)\n\
STYLEFO    = $(STYLEFO)\n\
META       = $(META)\n\
\n\
Webhelp\n\
-------\n\
STYLEWEBHELP = $(STYLEWEBHELP)\n\
WEBHELP_DIR  = $(WEBHELP_DIR)\n\
\n\
Packaging\n\
--------\n\
DESKTOP_FILE_DIR = $(DESKTOP_FILE_DIR)\n\
PACK_DIR         = $(PACK_DIR)\n\
"
endef


.PHONY: dapsenv
dapsenv:
	$(DAPSENVLIST)


#-------------------------------
#
# measuring the time it takes to parse the makefiles
#
.PHONY: nothing
nothing:
	@ccecho "result" "Done doing nothing"
