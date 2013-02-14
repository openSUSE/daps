# Copyright (C) 2012 SUSE Linux Products GmbH
#
# Author: Frank Sundermeyer
#
# Stuff for DAPS that did not fit anywhere else
#
# Please submit feedback or patches to
# <fsundermeyer at opensuse dot org>
#

#--------------
# Bigfile
#

BIGFILE := $(TMP_DIR)/$(DOCNAME)_bigfile.xml

.PHONY: bigfile
bigfile: $(BIGFILE)
	@ccecho "result" "Find the bigfile at:\n$(BIGFILE)"


# Creates one big XML file from a profiled MAIN by following the xincludes
# considering the rootid. If no rootid is given, a bigfile for the whole set
# is created
# If xref's to non existing locations are found, they are resolved to text
# links
#
$(BIGFILE): | $(TMP_DIR)
$(BIGFILE): $(PROFILES) $(PROFILEDIR)/.validate
  ifeq ($(VERBOSITY),2)
	@echo "   Creating bigfile"
  endif
	$(XSLTPROC) --xinclude --output $(BIGFILE) $(ROOTSTRING) \
	  --stylesheet $(STYLEBIGFILE) --file $(PROFILED_MAIN) \
	  $(XSLTPROCESSOR) $(ERR_DEVNULL)

#--------------
# checklink
#
STYLELINKS := $(DAPSROOT)/daps-xslt/common/get-links.xsl
TESTPAGE   := $(TMP_DIR)/$(DOCNAME)-links.html

ifeq ($(VERBOSITY),2)
  CB_VERBOSITY := --verbose
endif

.PHONY: checklink
checklink: | $(TMP_DIR)
checklink: $(PROFILEDIR)/.validate 
checklink:
  ifeq ($(VERBOSITY),2)
	@echo "   Running linkchecker"
  endif
	$(XSLTPROC) --xinclude $(ROOTSTRING) -o $(TESTPAGE) \
	  --stylesheet $(STYLELINKS) --file $(PROFILED_MAIN) $(XSLTPROCESSOR)
	checkbot --url file://localhost$(TESTPAGE) $(CB_VERBOSITY) \
	  $(CB_OPTIONS) --file $(TMP_DIR)/$(BOOK)-checkbot.html $(DEVNULL)
	@ccecho "result" "Find the link check report at:\nfile://$(TMP_DIR)/$(BOOK)-checkbot-localhost.html"


#--------------
# Productname/Productversion
#

.PHONY: productinfo
productinfo: $(BIGFILE) 
  ifdef ROOTID
	@echo -n "PRODUCTNAME=\"$(shell xml sel -t -v "//*[@id='$(ROOTID)']/*/productname" $< 2>/dev/null)\" "
	@echo -n "PRODUCTNUMBER=\"$(shell xml sel -t -v "//*[@id='$(ROOTID)']/*/productnumber" $< 2>/dev/null)\""
  else
	@echo -n "PRODUCTNAME=\"$(shell xml sel -t -v "(/*/*/productname)[1]" $< 2>/dev/null)\" "
	@echo -n "PRODUCTNUMBER=\"$(shell xml sel -t -v "(/*/*/productnumber)[1]" $< 2>/dev/null)\""
  endif


