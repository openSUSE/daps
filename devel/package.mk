#--------------
#
# OBSOLETE??
# package
#
#  * HTML tarball
#  * Graphics tarball (set)
#  * Source tarball (book only)
#  * Color PDF
#  * desktop files (for KDE)
#  * yelp files HTML/PDF (for GNOME)
#
.PHONY: package
package: $(DISTPROFILE)
package: INCLUDED=$(addprefix $(PROFILE_PARENT_DIR)/dist/,\
		$(shell xsltproc --nonet --xinclude $(ROOTSTRING) \
		$(STYLESEARCH) $(PROFILE_PARENT_DIR)/dist/$(MAIN)) $(MAIN))
package: PACKDIR := $(RESULT_DIR)/package/all
package: dist-html color-pdf dist-graphics dist-book document-files-pdf
package: document-files-html desktop-files
	# remove old stuff
	rm -rf $(PACKDIR) && mkdir -p $(PACKDIR)
ifdef USED
	# copy graphics
	cp $(RESULT_DIR)/$(TMP_BOOK)_$(LL)-graphics.tar.bz2 \
		$(PACKDIR)/$(BOOK)_$(LL)-graphics.tar.bz2
else
	@ccecho "info" "Selected book/set contains no graphics"
endif
	# copy HTML tarball
	cp $(RESULT_DIR)/$(TMP_BOOK)_$(LL)-html.tar.bz2 \
	  $(PACKDIR)/$(BOOK)_$(LL)-html.tar.bz2
	# copy color PDF
	cp  $(RESULT_DIR)/$(TMP_BOOK)-$(FOPTYPE)-online.pdf \
	  $(PACKDIR)/$(BOOK)_$(LL).pdf
	# copying desktop files for KDE
	if test -f $(RESULT_DIR)/$(TMP_BOOK)_$(LL)-desktop.tar.bz2; then \
	  cp $(RESULT_DIR)/$(TMP_BOOK)_$(LL)-desktop.tar.bz2 \
	    $(PACKDIR)/$(BOOK)_$(LL)-desktop.tar.bz2; \
	else \
	  ccecho "info" "No desktop files for KDE helpcenter available"; \
	fi
	# copy document files for GNOME
	if test -f $(RESULT_DIR)/$(TMP_BOOK)_$(LL)-yelp.tar.bz2; then \
	  cp $(RESULT_DIR)/$(TMP_BOOK)_$(LL)-yelp.tar.bz2 \
	    $(PACKDIR)/$(BOOK)_$(LL)-yelp.tar.bz2; \
	else \
	  ccecho "info" "No document files for GNOME yelp available"; \
	fi
	if test -f $(RESULT_DIR)/$(TMP_BOOK)_$(LL)-pdf-yelp.tar.bz2; then \
	  cp $(RESULT_DIR)/$(TMP_BOOK)_$(LL)-pdf-yelp.tar.bz2 \
	    $(PACKDIR)/$(BOOK)_$(LL)-pdf-yelp.tar.bz2; \
	else \
	  ccecho "info" "No PDF document files for GNOME yelp available"; \
	fi
	# copy source files tarball (dist-book)
	cp $(RESULT_DIR)/$(BOOK)_$(LL).tar.bz2 $(PACKDIR)/$(BOOK)_$(LL).tar.bz2
	@ccecho "result" "Find the package results at:\n$(PACKDIR)"
