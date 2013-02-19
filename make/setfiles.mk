# Copyright (C) 2012 SUSE Linux Products GmbH
#
# Author: Frank Sundermeyer
#
# DAPS makefile
# Determining the list of files belonging to a set
#
# Please submit feedback or patches to
# <fsundermeyer at opensuse dot org>
#

#--------------------------------------------------
# Profiling stringparams
#
ifdef PROFILE_URN
  PROFSTRINGS   := --param "show.comments=$(REMARKS)"
  ifdef PROFARCH
    PROFSTRINGS += --stringparam "profile.arch=$(PROFARCH)"
  endif
  ifdef PROFCONDITION
    PROFSTRINGS += --stringparam "profile.condition=$(PROFCONDITION)"
  endif
  ifdef PROFOS
    PROFSTRINGS += --stringparam "profile.os=$(PROFOS)"
  endif
  ifdef PROFVENDOR
    PROFSTRINGS += --stringparam "profile.vendor=$(PROFVENDOR)"
  endif
endif

#--------------------------------------------------
# SETFILES is set to an XML file with a list of all xml and image files
# and their corresponding ids for the whole set taking profiling into account.
# Generating this list is very time consuming and is the main time factor
# when parsing the Makefile.
#
# Therefor we absolutely want to make sure it is only called once!
# We achieve this by writing this XML "file" to a variable that can be used
# as an input source for the actual file list generating stylesheet
# (extract-files-and-images.xsl).
# That stylesheet only takes a few miliseconds to execute, so we can afford to
# run it multiple times (SRCFILES, USED, projectfiles).
#
# In order to be able to pipe SETFILES via echo to extract-files-and-images.xsl
# we need to replace double quotes by single quotes (cannot be done with
# xsltproc)


# Check whether the documents are well-formed - if not, exit and display the
# xmllint error message
#
# If there is a PROFILE URN defined, we do not check for xinclude errors for
# the following reason
#
# If you have a common source for different documents with profiled
# xi:includes you may want to create branches or tags in you VCS that only
# contain the source files actually used in a certain document (ignoring the
# files that will not be included because the xi:include is profiled for
# a different version).
# This set of sources is not well-formed. However, after having profiled
# these documents (which is possible!!!) the resulting profiled sources
# _are_ well-formed. And DAPS only works on profiled sources...
#
ifdef PROFILE_URN
  CHECK_WELLFORMED := $(shell xmllint --nonet --noout --nowarning --xinclude --loaddtd $(MAIN) 2>&1 | grep -v "XInclude error")
else
  CHECK_WELLFORMED := $(shell xmllint --nonet --noout --nowarning --xinclude --loaddtd $(MAIN) 2>&1)
endif
ifdef CHECK_WELLFORMED
  $(error Fatal error:$(\n)$(CHECK_WELLFORMED))
endif

SETFILES := $(shell $(XSLTPROC) $(PROFSTRINGS) \
	      --output $(SETFILES_TMP) \
	      --stringparam "xml.src.path=$(DOC_DIR)/xml/" \
	      --stringparam "mainfile=$(notdir $(MAIN))" \
	      --stylesheet $(DAPSROOT)/daps-xslt/common/get-all-used-files.xsl \
	      --file $(MAIN) $(XSLTPROCESSOR) | tr \" \' > $(SETFILES_TMP) && \
	      echo 1)

# $(shell) does not cause make to exit in case it fails, so we need to
# check manually
ifndef SETFILES
  $(error Fatal error: Could not compute the list of setfiles)
endif

# XML source files for the whole set
#
SRCFILES := $(sort $(shell $(XSLTPROC) --stringparam "xml.or.img=xml" \
	      --file $(SETFILES_TMP) \
	      --stylesheet $(DAPSROOT)/daps-xslt/common/extract-files-and-images.xsl $(XSLTPROCESSOR) ))

# check
ifndef SRCFILES
  $(error Fatal error: Could not compute the list of XML source files)
endif

# XML source files for the currently used document (defined by the rootid)
#
ifdef ROOTSTRING
  DOCFILES := $(sort $(shell $(XSLTPROC) --stringparam "xml.or.img=xml" \
	      --stringparam "$(ROOTSTRING)" --file $(SETFILES_TMP) \
	      --stylesheet $(DAPSROOT)/daps-xslt/common/extract-files-and-images.xsl $(XSLTPROCESSOR) ))

  # check
  ifndef DOCFILES
    $(error Fatal error: Could not compute the list of XML source files for "$(ROOTID)")
  endif
else
  DOCFILES  := $(SRCFILES)
endif
