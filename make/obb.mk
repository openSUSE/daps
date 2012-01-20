# this make file contains targets that were requested and are used by the
# open Book Builder (oBB) project.


STYLEBOOKSTRUCTURE := $(DTDROOT)/daps-xslt/common/get-bookstructure.xsl
STYLEBOOKTITLE     := $(DTDROOT)/daps-xslt/common/get-booktitle.xsl

rootids structure: QUIET=@
rootids structure: QUIET2=>& /dev/null
rootids structure: $(PROFILES)
	@xsltproc $(ROOTSTRING) --xinclude $(STYLEBOOKSTRUCTURE) profiled/$(PROFILEDIR)/$(MAIN)

booktitle: QUIET=@
booktitle: QUIET2=>& /dev/null
booktitle: $(PROFILES)
	xsltproc --xinclude $(ROOTSTRING) \
		--stringparam projectfile PROJECTFILE.$(BOOK) \
		$(STYLEBOOKTITLE) \
		profiled/$(PROFILEDIR)/$(MAIN)

obb_data: QUIET=@
obb_data: QUIET2=>& /dev/null
obb_data: $(PROFILES)
	@xsltproc --xinclude $(ROOTSTRING) \
		--stringparam projectfile PROJECTFILE.$(BOOK) \
		$(STYLEBOOKTITLE) \
		profiled/$(PROFILEDIR)/$(MAIN)
	@xsltproc $(ROOTSTRING) --xinclude \
		$(STYLEBOOKSTRUCTURE) \
		profiled/$(PROFILEDIR)/$(MAIN)

