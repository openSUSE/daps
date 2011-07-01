# this make file contains targets that were requested and are used by the
# open Book Builder (oBB) project.


STYLEBOOKSTRUCTURE := $(DTDDIR)/xslt/misc/get-bookstructure.xsl
STYLEBOOKTITLE     := $(DTDDIR)/xslt/misc/get-booktitle.xsl

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

