# Copyright (C) 2012-2020 SUSE Software Solutions Germany GmbH
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
# exit and display the error message
# Works for both, DocBook4 and DocBook5 since we are only checking for
# well-formdness and not for validity (a DocBook5 validity check would
# require jing)

CHECK_WELLFORMED := $(shell PYTHONWARNINGS="ignore" $(LIBEXEC_DIR)/daps-xmlwellformed --xinclude $(MAIN) 2>&1 )

ifdef CHECK_WELLFORMED
  $(error Fatal error:$(\n)$(CHECK_WELLFORMED))
endif

ifeq "$(strip $(SRC_FORMAT))" "xml"
  XML_SRC_PATH := $(DOC_DIR)/xml/
endif
ifeq "$(strip $(SRC_FORMAT))" "adoc"
  XML_SRC_PATH := $(ADOC_DIR)/
endif

SETFILES := $(shell $(XSLTPROC) $(PROFSTRINGS) \
	      --output $(SETFILES_TMP) \
	      --stringparam "xml.src.path=$(XML_SRC_PATH)" \
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
  ROOTELEMENT := $(shell $(XMLSTARLET) sel -t -v "//div[@id='$(ROOTID)'][1]/@remap" $(SETFILES_TMP) 2>/dev/null)
  # check whether there is only a single root element (fixes issue #390)
  #
  ifeq "$(ROOTELEMENT)" ""
    $(error Fatal error: ROOTID "$(ROOTID)" does not exist!)
  endif
  ifneq "$(words $(ROOTELEMENT))" "1"
    $(error Fatal error: ROOTID "$(ROOTID)" has been defined multiple times!)
  endif
  # check if ROOTID is a valid root element
  #
  ifneq "$(ROOTELEMENT)" "$(filter $(ROOTELEMENT),$(VALID_ROOTELEMENTS))"
    # rootid restriction should not apply to list file targets, because
    # this is rather a stylesheet restriction for output formats
    ifneq "$(MAKECMDGOALS)" "$(filter $(MAKECMDGOALS),$(LISTTARGETS))"
      $(error Fatal error: ROOTID belongs to an unsupported root element ($(ROOTELEMENT)). Must be one of $(VALID_ROOTELEMENTS) )
    endif
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
ENTITIES_DOC := $(shell $(LIBEXEC_DIR)/getentityname.py $(DOCFILES) 2>/dev/null)


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
