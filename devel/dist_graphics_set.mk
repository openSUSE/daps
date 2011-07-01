#--------------
# dist-graphics
# always packs the colour images provided by provide-color-images. It generates
# them in $IMG_GENDIR/{png,svg}. However, in the tarball we need to rewrite
# this directory to images/src/{png,svg}, because this is the place graphics
# need to be when starting a project 
#
# In order to properly calculate the USED* variables from the original XML
# sources, we need to have an up-to-date profiled version of these sources.
# This requires a "make profile" run before make dist-graphics! The susedoc
# wrapper script automatically takes care of it
#
.PHONY: dist-graphics
dist-graphics: TARBALL := $(RESULT_DIR)/$(TMP_BOOK)_$(LL)-set-graphics.tar
dist-graphics: SET_IMG := $(sort $(shell xsltproc $(PROFSTRINGS) \
		--stringparam xml.or.graphics img \
		--stringparam img.source.dir $(IMG_SRCDIR) \
		$(DTDROOT)/xslt/misc/get-included-files.xsl \
		$(BASE_DIR)/xml/$(MAIN)))
dist-graphics: SET_PNG := $(filter $(addprefix $(IMG_SRCDIR)/png/,$(SET_IMG)), \
		$(SRCPNG))
dist-graphics: SET_SVG := $(filter $(addprefix $(IMG_SRCDIR)/svg/,$(SET_IMG)), \
		$(SRCSVG))
dist-graphics: SET_DIA := $(filter \
		$(addprefix $(IMG_SRCDIR)/dia/,$(addsuffix .dia, \
		$(basename $(SET_IMG)))), $(SRCDIA))
dist-graphics: SET_FIG := $(filter \
		$(addprefix $(IMG_SRCDIR)/fig/,$(addsuffix .fig, \
		$(basename $(SET_IMG)))), $(SRCFIG))
dist-graphics: SET_SVGONLINE := $(addprefix $(IMG_GENDIR)/online/, \
		$(notdir $(SET_SVG)) \
		$(subst .dia,.svg,$(notdir $(SET_DIA))) \
		$(subst .fig,.svg,$(notdir $(SET_FIG))))
dist-graphics: SET_PNGONLINE := $(addprefix $(IMG_GENDIR)/online/, \
		$(notdir $(SET_PNG)))
#		$(subst .svg,.png,$(notdir $(SET_SVG))) \
#		$(subst .dia,.png,$(notdir $(SET_DIA))) \
#		$(subst .fig,.png,$(notdir $(SET_FIG))))
dist-graphics: $(SET_SVGONLINE) $(SET_PNGONLINE)
dist-graphics:
	if test -n "$(SET_IMG)"; then \
	  if test -n "$(SET_PNGONLINE)"; then \
	    tar chf $(TARBALL) --exclude=.svn --ignore-failed-read \
	      --absolute-names --xform=s%$(IMG_GENDIR)/online%images/src/png% \
	     $(SET_PNGONLINE); \
	    if test -n "$(SET_SVGONLINE)"; then \
	      tar rhf $(TARBALL) --exclude=.svn --ignore-failed-read \
	        --absolute-names --xform=s%$(IMG_GENDIR)/online%images/src% \
	        $(SET_SVGONLINE); \
	    fi; \
	  else \
	    tar chf $(TARBALL) --exclude=.svn --ignore-failed-read \
	      --absolute-names --xform=s%$(IMG_GENDIR)/online%images/src% \
	      $(SET_SVGONLINE); \
	  fi; \
	  bzip2 -9f $(TARBALL); \
	  ccecho "result" "Find the tarball at:\n$(TARBALL).bz2"; \
	else \
	  ccecho "info" "Selected book contains no graphics"; \
	fi
