# Copyright (C) 2012-2015 SUSE Linux GmbH
#
# Author:
# Frank Sundermeyer <fsundermeyer at opensuse dot org>
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

# Stringparams for the profiling attributes are set in common_variables.mk
ifdef PROFILE_URN
  PROFSTRINGS   += --param "show.comments=$(REMARKS)"
endif

#--------------------------------------------------
# SETFILES is set to an XML file with a list of all xml and image files
# and their corresponding ids for the whole set taking profiling into account.
# Generating this list is very time consuming and is the main time factor
# when parsing the Makefile.  Therefor we absolutely want to make sure it is
# only called once! We achieve this by writing thresult to a
# temporary file that is deleted when exiting DAPS.
#
# This file can be used as an input source for the actual file list generating
# stylesheet (extract-files-and-images.xsl).
# That stylesheet only takes a few miliseconds to execute, so we can afford to
# run it multiple times (SRCFILES, USED, projectfiles).


# Check whether the documents are _well-formed_ (not if valid) - if not,
# exit and display the xmllint error message
#
# Works for both, DocBook4 and DocBook5 since we are only checking for
# well-formdness and not for validity (a DocBook5 validity check would
# require jing)
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
	      --file $(MAIN) $(XSLTPROCESSOR) && echo 1)

# $(shell) does not cause make to exit in case it fails, so we need to
# check manually
ifndef SETFILES
  $(error Fatal error: Could not compute the list of setfiles)
endif

# XML source files for the whole set
#
SRCFILES := $(sort $(shell $(XSLTPROC) --stringparam "filetype=xml" \
	      --file $(SETFILES_TMP) \
	      --stylesheet $(DAPSROOT)/daps-xslt/common/extract-files-and-images.xsl $(XSLTPROCESSOR) 2>/dev/null))

# check
ifndef SRCFILES
  $(error Fatal error: Could not compute the list of XML source files)
endif

# XML source files for the currently used document (defined by the rootid)
#
ifdef ROOTSTRING
  # check if ROOTID is a valid root element
  #
  ROOTELEMENT := $(shell $(XMLSTARLET) sel -t -v "//div[@id='$(ROOTID)'][1]/@remap" $(SETFILES_TMP) 2>/dev/null)
  ifneq "$(ROOTELEMENT)" "$(filter $(ROOTELEMENT),$(VALID_ROOTELEMENTS))"
    $(error Fatal error: ROOTID belongs to an unsupported root element ($(ROOTELEMENT)). Must be one of $(VALID_ROOTELEMENTS) )
  endif


  DOCFILES := $(sort $(shell $(XSLTPROC) --stringparam "filetype=xml" \
	      $(ROOTSTRING) --file $(SETFILES_TMP) \
	      --stylesheet $(DAPSROOT)/daps-xslt/common/extract-files-and-images.xsl $(XSLTPROCESSOR) 2>/dev/null))

  # check
  ifndef DOCFILES
    $(error Fatal error: Could not compute the list of XML source files for "$(ROOTID)")
  endif
  # MAIN needs to be part of the DOCFILES - we add it here to be able to
  # perform the test above
  DOCFILES  += $(MAIN)
else
  DOCFILES  := $(SRCFILES)
endif

# Entity files
#
ENTITIES_DOC := $(addprefix $(DOC_DIR)/xml/,\
	      $(shell $(LIBEXEC_DIR)/getentityname.py $(DOCFILES) 2>/dev/null))


# files xi:included with parse="text"
#
# SRCFILES and DOCFILES only include regular XML files. To also support
# xi:includes of text files via parse="text", extract-files-and-images.xsl
# also returns a list of files included that way. The paths returned are
# relative to the xml/ directory
#
# These files need to be copied to the profiling directory
# (see profiling.mk
#
TEXTFILES := $(sort $(shell $(XSLTPROC) --stringparam "filetype=text" \
	      --file $(SETFILES_TMP) \
	      --stylesheet $(DAPSROOT)/daps-xslt/common/extract-files-and-images.xsl $(XSLTPROCESSOR) 2>/dev/null))
