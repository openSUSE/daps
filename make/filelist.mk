# Copyright (C) 2012-2015 SUSE Linux GmbH
#
# Author:
# Frank Sundermeyer <fsundermeyer at opensuse dot org>
#
# filelist generation for DAPS
#
# Please submit feedback or patches to
# <fsundermeyer at opensuse dot org>
#

# includes are set in selector.mk
# include $(DAPSROOT)/make/setfiles.mk
# include $(DAPSROOT)/make/images.mk

USED_FILES    := $(ENTITIES_DOC) $(DOCCONF) $(DOCFILES) $(USED_ALL)

# Using tar is the easiest way to search for files excluding versioning system
# files and directories. A simple tar cv >/dev/null does not work, because
# it does not let you pipe the output, so we are using two tar calls
#
UNUSED_IMAGES := $(shell tar cP --exclude-vcs \
		    $(IMG_SRCDIR) 2>/dev/null | tar tP 2>/dev/null |\
		    sed '/\/$$/d' 2>/dev/null | tr '\n' ' ' 2>/dev/null)
UNUSED_XML    := $(shell tar cP --exclude-vcs \
		    $(DOC_DIR)/xml  2>/dev/null | tar tP 2>/dev/null |\
		    sed '/\/$$/d' 2>/dev/null | tr '\n' ' ' 2>/dev/null)
UNUSED_FILES := $(filter-out $(USED_FILES), $(UNUSED_IMAGES) $(UNUSED_XML))

ifeq "$(LIST_NOIMG)" "1"
  USED_FILES   := $(filter-out $(USED_ALL),$(USED_FILES))
  UNUSED_FILES := $(filter-out $(UNUSED_IMAGES),$(UNUSED_FILES))
endif
ifeq "$(LIST_NOENT)" "1"
  USED_FILES := $(filter-out $(ENTITIES_DOC),$(USED_FILES))
endif
ifeq "$(LIST_NODC)" "1"
  USED_FILES := $(filter-out $(DOCCONF),$(USED_FILES))
endif
ifeq "$(LIST_NOXML)" "1"
  USED_FILES   := $(filter-out $(DOCFILES),$(USED_FILES))
  UNUSED_FILES := $(filter-out $(UNUSED_XML),$(UNUSED_FILES))
endif

# List filename for given ROOTID
#
.PHONY: list-file
list-file: FILE4ID := $(shell $(XSLTPROC) --stringparam "filetype=xml" \
	      --param "show.first=1" \
             $(ROOTSTRING) --file $(SETFILES_TMP) \
	      --stylesheet $(DAPSROOT)/daps-xslt/common/extract-files-and-images.xsl $(XSLTPROCESSOR) )
list-file:
  ifneq "$(VERBOSITY)" "0"
	@ccecho "result" "The ID \"$(ROOTID)\" appears in:"
  endif
	@ccecho "result" "$(FILE4ID)"

# List files from xml and images/src referenced by $DOCFILE or $MAIN
#
.PHONY: list-srcfiles
list-srcfiles: 
	$(call print_list,$(USED_FILES))


# List files from xml and images/src _not_ referenced by $DOCFILE or $MAIN
#
.PHONY: list-srcfiles-unused
list-srcfiles-unused:
	$(call print_list,$(UNUSED_FILES))

# The targets
#
# list-images-missing
# list-images-multisrc
#
# can be found in images.mk
