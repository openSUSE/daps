# this make file contains targets that were requested and are used by the
# open Book Builder (oBB) project.


STYLEBOOKSTRUCTURE := $(DAPSROOT)/daps-xslt/common/get-bookstructure.xsl
STYLEBOOKTITLE     := $(DAPSROOT)/daps-xslt/common/get-booktitle.xsl

rootids structure: QUIET=@
rootids structure: QUIET2=>& /dev/null
rootids structure: $(PROFILES)
	@xsltproc $(ROOTSTRING) --xinclude $(STYLEBOOKSTRUCTURE) $(PROFILED_MAIN)

booktitle: QUIET=@
booktitle: QUIET2=>& /dev/null
booktitle: $(PROFILES)
	xsltproc --xinclude $(ROOTSTRING) \
		--stringparam projectfile PROJECTFILE.$(BOOK) \
		$(STYLEBOOKTITLE) $(PROFILED_MAIN)

obb_data: QUIET=@
obb_data: QUIET2=>& /dev/null
obb_data: $(PROFILES)
	@xsltproc --xinclude $(ROOTSTRING) \
		--stringparam projectfile PROJECTFILE.$(BOOK) \
		$(STYLEBOOKTITLE) $(PROFILED_MAIN)
	@xsltproc $(ROOTSTRING) --xinclude \
		$(STYLEBOOKSTRUCTURE) $(PROFILED_MAIN)

