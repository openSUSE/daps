#
# Makefile for image processing
#
# Overview
# DAPS uses images in $DOC_DIR/images/src/<FORMAT>/
# Supported image formats are .dia, .eps, .fig, .png, .pdf, and .svg
# - When creating HTML manuals all formats are converted to PNG
# - When creating PDF manuals all formats are converted to
#   either PNG, PDF, SVG depending on the "format" attribute in the
#   <imagedata> tag of the XMl source
# The format attribute may take the following values
#
# SOURCE | ROLE HTML | ROLE FOP
# -----------------------------
#  DIA   |   PNG     | SVG,PDF
#........|...........|..........
#  EPS   |   PNG     |   PDF
#........|...........|..........
#  FIG   |   PNG     | SVG,PDF
#........|...........|..........
#  PNG   |   PNG     |   PNG
#........|...........|..........
#  PDF   |   PNG     |   PDF
#........|...........|..........
#  SVG   |   PNG     | SVG,PDF
#........|...........|..........
#
# $DOC_DIR/images/src/<FORMAT>/ is _never_ used for manual creation, the
# images are rather created or linked into $IMG_GENDIR/online/ (color images)
# or into $IMG_GENDIR/print/ (grayscale). If image creation/conversion requires
# generating intermediate files, these files are created in
# $IMG_GENDIR/gen/<FORMAT>
# We assume all images are color images, grayscale images are always created
#
# Image creation itself is triggered by the phony targets
# provide-images and provide-*-images


#------------------------------------------------------------------------
# We want to keep the following files
#

.PRECIOUS: $(IMG_GENDIR)/gen/png/%.png
.PRECIOUS: $(IMG_GENDIR)/gen/pdf/%.pdf
.PRECIOUS: $(IMG_GENDIR)/gen/svg/%.svg
#------------------------------------------------------------------------
# The following directories might not be present and therefore might have to
# be created
#

IMG_DIRECTORIES := $(IMG_SRCDIR)/dia $(IMG_SRCDIR)/eps $(IMG_SRCDIR)/fig \
                   $(IMG_SRCDIR)/pdf $(IMG_SRCDIR)/png $(IMG_SRCDIR)/svg \
                   $(IMG_GENDIR)/gen/png $(IMG_GENDIR)/gen/pdf \
                   $(IMG_GENDIR)/gen/svg \
                   $(IMG_GENDIR)/online $(IMG_GENDIR)/print

$(IMG_DIRECTORIES):
	mkdir -p $@

#------------------------------------------------------------------------
# xslt stylsheets
#
STYLEGFX       := $(DAPSROOT)/daps-xslt/common/get-graphics.xsl
STYLESVG       := $(DAPSROOT)/daps-xslt/common/fixsvg.xsl
STYLESVG2GRAY  := $(DAPSROOT)/daps-xslt/common/svg.color2grayscale.xsl

#------------------------------------------------------------------------
# Image lists
#

# generate lists of all images in color and gray
SRCDIA      := $(wildcard $(IMG_SRCDIR)/dia/*.dia)
SRCEPS      := $(wildcard $(IMG_SRCDIR)/eps/*.eps)
SRCFIG      := $(wildcard $(IMG_SRCDIR)/fig/*.fig)
SRCPDF      := $(wildcard $(IMG_SRCDIR)/pdf/*.pdf)
SRCPNG      := $(wildcard $(IMG_SRCDIR)/png/*.png)
SRCSVG      := $(wildcard $(IMG_SRCDIR)/svg/*.svg)

# get all images used in the current Document
#
USED        := $(sort $(shell echo "$(SETFILES)" | xsltproc $(ROOTSTRING) \
		  --stringparam xml.or.img img \
		  $(DAPSROOT)/daps-xslt/common/extract-files-and-images.xsl - ))

# PNG and PDF can be directly taken from the USED list - the filter function
# generates lists of all PNG common to USED and SCRPNG
#
USED_PNG := $(filter $(addprefix $(IMG_SRCDIR)/png/,$(USED)), $(SRCPNG))
USED_PDF := $(filter $(addprefix $(IMG_SRCDIR)/png/,$(USED)), $(SRCPDF))

# For HTML builds SVG and EPS are not directly used, but rather converted to PNG
# DIA and FIG are never directly used in the XML sources, but converted
# to SVG/PNG first. So we pretend all files in USED are SVG/FIG/DIA files
# and then generate a list of files common to the fake USED and SRCFIG/SRCDIA
#
USED_DIA := $(filter \
	$(addprefix $(IMG_SRCDIR)/dia/,$(addsuffix .dia,$(basename $(USED)))), \
	$(SRCDIA))
USED_EPS := $(filter \
	$(addprefix $(IMG_SRCDIR)/eps/,$(addsuffix .eps,$(basename $(USED)))), \
	$(SRCEPS))
USED_FIG := $(filter \
	$(addprefix $(IMG_SRCDIR)/fig/,$(addsuffix .fig,$(basename $(USED)))), \
	$(SRCFIG))
USED_SVG := $(filter \
	$(addprefix $(IMG_SRCDIR)/svg/,$(addsuffix .svg,$(basename $(USED)))), \
	$(SRCSVG))

# generated images
#
GEN_PDF := $(subst .dia,.pdf,$(notdir $(USED_DIA))) \
		$(subst .eps,.pdf,$(notdir $(USED_EPS))) \
		$(subst .fig,.pdf,$(notdir $(USED_FIG))) \
		$(subst .svg,.pdf,$(notdir $(USED_SVG)))
GEN_PNG := $(subst .dia,.png,$(notdir $(USED_DIA))) \
		$(subst .eps,.png,$(notdir $(USED_EPS))) \
		$(subst .fig,.png,$(notdir $(USED_FIG))) \
		$(subst .svg,.png,$(notdir $(USED_SVG)))
GEN_SVG := $(subst .dia,.svg,$(notdir $(USED_DIA))) \
		$(subst .fig,.svg,$(notdir $(USED_FIG)))

# color images (used for manual creation)
#
PDFONLINE := $(sort $(addprefix $(IMG_GENDIR)/online/, \
		$(notdir $(USED_PDF)) $(GEN_PDF)))
PNGONLINE := $(sort $(addprefix $(IMG_GENDIR)/online/, \
		$(notdir $(USED_PNG)) $(GEN_PNG)))
SVGONLINE := $(sort $(addprefix $(IMG_GENDIR)/online/, \
		$(notdir $(USED_SVG)) $(GEN_SVG)))

# grayscale images (used for manual creation)
#
PDFPRINT := $(addprefix $(IMG_GENDIR)/print/, $(notdir $(USED_PDF)) $(GEN_PDF))
PNGPRINT := $(addprefix $(IMG_GENDIR)/print/, $(notdir $(USED_PNG)) $(GEN_PNG))
SVGPRINT := $(addprefix $(IMG_GENDIR)/print/, $(notdir $(USED_SVG)) $(GEN_SVG))

# images with the same basename will cause problems because the image that
# is generated last will win. Since we use -j with make, this may be a
# different image on different machines
#
DOUBLEIMG   := $(sort $(filter $(notdir $(basename $(SRCDIA))), \
		$(notdir $(basename $(SRCEPS))) \
		$(notdir $(basename $(SRCFIG))) \
		$(notdir $(basename $(SRCPDF))) \
		$(notdir $(basename $(SRCPNG))) \
		$(notdir $(basename $(SRCSVG)))))

# images referenced in the XML sources that cannot be found in
# $(IMG_SRCDIR)
#
MISSING     := $(sort $(filter-out $(notdir $(basename $(SRCSVG))) \
                $(notdir $(basename $(SRCPNG))) \
                $(notdir $(basename $(SRCFIG))) \
                $(notdir $(basename $(SRCEPS))) \
                $(notdir $(basename $(SRCPDF))) \
                $(notdir $(basename $(SRCDIA))), \
                $(basename $(USED))))

#------------------------------------------------------------------------
# PHONY targets for image creation
#
#
# This works as follows:
# o images in this Makefile are generally generated by running one of the
#   targets provide-images, provide-color-images, or (EPUB only)
#   provide-epub-images.
# o the tmp directory is needed when converting svg to svg to png. svg to svg
#   is done to improve the xml of svg or to create grayscale svg.
#
.PHONY: provide-images
provide-images: | $(IMG_DIRECTORIES)
provide-images: $(SVGPRINT) $(PNGPRINT) $(PDFPRINT)

.PHONY: provide-color-images
provide-color-images: | $(IMG_DIRECTORIES)
provide-color-images: $(SVGONLINE) $(PNGONLINE) $(PDFONLINE)

.PHONY: provide-epub-images
provide-epub-images: provide-color-images $(EPUB_TMP_DIR)
	ln -sf $(IMG_GENDIR)/online $(EPUB_TMP_DIR)/images

.PHONY: missing-images
missing-images:
ifdef MISSING
	@ccecho "warn" "The following graphics are missing: $(MISSING)" >&2
endif

#---------------
# Optimize (size-wise) PNGs
#
.PHONY: optipng
optipng:
	exiftool -Comment=optipng -overwrite_original -P \
	$(shell for i in $(USED_PNG); do  \
		exiftool -Comment $$i  | grep optipng > /dev/null || \
		optipng -o2 $$i > /dev/null; \
		echo "$$i "; \
		done )

#---------------
# Warnings
#
warn-images:
ifdef DOUBLEIMG
	@ccecho "warn" "Image names not unique, multiple sources available for the following images:\n$(DOUBLEIMG)" >&2
endif
#
# This warning is solely for publishing stuff on novell.com/documentation,
# therefore we make it dependend on HTMLROOT which also is only used
# for novell.com/documentation publishing
#
ifdef HTMLROOT
  ifdef WRONG_CAP
	@ccecho "warn" "Not all image file names are lower case. This will make problems when creating online docs:\n$(WRONG_CAP)" >&2
  endif
endif

#------------------------------------------------------------------------
# The "real" image generation 
#
# While PDFs support EPSs, SVGs and PNGs, all other output formats need PNG
# (Browser support for SVG is still not common enough). So we convert
# EPS and SVGs to PNG. FIG and DIA files are also converted to SVG (and from
# there to PNG), because they are unsupported in the output formats.
#
# We assume source images are generally color images, regardless of the format.
# Since b/w PDFs (for the print shop) need grayscale images, we transfer
# PNGs and SVGs to grayscale as well.
#
# All conversions are done via $IMAGES_GENDIR/gen/
# Color images are placed in $IMAGES_GENDIR/online/
# Grayscale images are placed in $IMAGES_GENDIR/print/

#------------------------------------------------------------------------
# PNG
#

#---------------
# Link images that are used in the manuals
#
# existing color PNGs
$(IMG_GENDIR)/online/%.png: $(IMG_SRCDIR)/png/%.png
	@exiftool -Comment $< | grep optipng > /dev/null || \
	  ccecho "warn" " $< not optimized." >&2
	ln -sf $< $@

# created PNGs
$(IMG_GENDIR)/online/%.png: $(IMG_GENDIR)/gen/png/%.png
	ln -sf $< $@

#---------------
# Create grayscale PNGs used in the manuals
#
# from existing color PNGs
$(IMG_GENDIR)/print/%.png: $(IMG_SRCDIR)/png/%.png
ifeq ($(VERBOSITY),1)
	@echo "   Converting $(notdir $<) to grayscale"
endif
	convert $< $(CONVERT_OPTS) $@ $(DEVNULL)

# from generated color PNGs
$(IMG_GENDIR)/print/%.png: $(IMG_GENDIR)/gen/png/%.png
ifeq ($(VERBOSITY),1)
	@echo "   Converting $(notdir $<) to grayscale"
endif
	convert $< $(CONVERT_OPTS) $@ $(DEVNULL)

#---------------
# Create color PNGs from other formats

# remove_link and the optipng call are used more than once, so 
# let's define them here

# A note on inkscape:
# Inkscape always returns 0, even when it fails to create an image
# in order to exit properly, if an inkscape command has failed, we
# need to work around this by testing if the result file exists
# inkscape && (test -f $< || false )
define remove_link
if test -L $@; then \
rm -f $@; \
fi
endef

define run_optipng
optipng -o2 $@ >& /dev/null
endef

# SVG -> PNG
# create color PNGs from SVGs
$(IMG_GENDIR)/gen/png/%.png: $(IMG_GENDIR)/gen/svg/%.svg
ifeq ($(VERBOSITY),1)
	@echo "   Converting $(notdir $<) to PNG"
endif
	$(remove_link)
	inkscape $(INK_OPTIONS) -e $@ -f $< $(DEVNULL) && \
	  ( test -f $< || false )
	$(run_optipng)

# EPS -> PNG
# create color PNGs from EPS
$(IMG_GENDIR)/gen/png/%.png: $(IMG_SRCDIR)/eps/%.eps
ifeq ($(VERBOSITY),1)
	@echo "   Converting $(notdir $<) to PNG"
endif
	$(remove_link)
	convert $< $@ $(DEVNULL)
	$(run_optipng)

# PDF -> PNG
# create color PNGs from EPS
$(IMG_GENDIR)/gen/png/%.png: $(IMG_SRCDIR)/pdf/%.pdf
ifeq ($(VERBOSITY),1)
	@echo "   Converting $(notdir $<) to PNG"
endif
	$(remove_link)
	convert $< $@ $(DEVNULL)
	$(run_optipng)

$(IMG_GENDIR)/gen/png/%.png: $(IMG_GENDIR)/gen/pdf/%.pdf
ifeq ($(VERBOSITY),1)
	@echo "   Converting $(notdir $<) to PNG"
endif
	$(remove_link)
	convert $< $@ $(DEVNULL)
	$(run_optipng)

#------------------------------------------------------------------------
# SVGs
#

#---------------
# Link images that are used in the manuals
#

# SVGs are never used directly from source, since they are all generated
# Color SVGs are transformed via stylesheet in order to wipe out
# some tags that cause trouble with xep or fop

$(IMG_GENDIR)/online/%.svg: $(IMG_GENDIR)/gen/svg/%.svg
ifeq ($(VERBOSITY),1)
	@echo "   Fixing $(notdir $<)"
endif
	xsltproc $(STYLESVG) $< > $@

#---------------
# Create grayscale SVGs used in the manuals
#
$(IMG_GENDIR)/print/%.svg: $(IMG_GENDIR)/gen/svg/%.svg
ifeq ($(VERBOSITY),1)
	@echo "   Converting $(notdir $<) to grayscale"
endif
	xsltproc $(STYLESVG) $< | \
	xsltproc $(STYLESVG2GRAY) - > $@

#---------------
# Create color SVGs from other formats

# DIA -> SVG
#
$(IMG_GENDIR)/gen/svg/%.svg: $(IMG_SRCDIR)/dia/%.dia
ifeq ($(VERBOSITY),1)
	@echo "   Converting $(notdir $<) to SVG"
endif
	LANG=C dia $(DIA_OPTIONS) --export=$@ $< $(DEVNULL)

# FIG -> SVG
#
$(IMG_GENDIR)/gen/svg/%.svg: $(IMG_SRCDIR)/fig/%.fig
ifeq ($(VERBOSITY),1)
	@echo "   Converting $(notdir $<) to SVG"
endif
	fig2dev -L svg $< $@ $(DEVNULL)

# SVG -> SVG
#
# source SVGs are linked to gen/svg and are processed from there into
# online/ and print/
$(IMG_GENDIR)/gen/svg/%.svg: $(IMG_SRCDIR)/svg/%.svg
	ln -sf $< $@



#------------------------------------------------------------------------
# PDFs
#
#---------------
# Link images that are used in the manuals
#
# existing color PDFs
$(IMG_GENDIR)/online/%.pdf: $(IMG_SRCDIR)/pdf/%.pdf
	ln -sf $< $@

# created PDFs
$(IMG_GENDIR)/online/%.pdf: $(IMG_GENDIR)/gen/pdf/%.pdf
	ln -sf $< $@

#---------------
# Create grayscale PDFs used in the manuals
#
# from existing color PDFs
$(IMG_GENDIR)/print/%.pdf: $(IMG_SRCDIR)/pdf/%.pdf
ifeq ($(VERBOSITY),1)
	@echo "   Converting $(notdir $<) to grayscale"
endif
	gs -sOutputFile=$@ -sDEVICE=pdfwrite \
	  -sColorConversionStrategy=Gray -dProcessColorModel=/DeviceGray \
	  -dCompatibilityLevel=1.4 -dNOPAUSE -dBATCH $< $(DEVNULL)

# from generated color PDFs
$(IMG_GENDIR)/print/%.pdf: $(IMG_GENDIR)/gen/pdf/%.pdf
ifeq ($(VERBOSITY),1)
	@echo "   Converting $(notdir $<) to grayscale"
endif
	gs -sOutputFile=$@ -sDEVICE=pdfwrite \
	  -sColorConversionStrategy=Gray -dProcessColorModel=/DeviceGray \
	  -dCompatibilityLevel=1.4 -dNOPAUSE -dBATCH $< $(DEVNULL)

#---------------
# Create color PDFs from other formats

# EPS -> PDF
$(IMG_GENDIR)/gen/pdf/%.pdf: $(IMG_SRCDIR)/eps/%.eps
ifeq ($(VERBOSITY),1)
	@echo "   Converting $(notdir $<) to PDF"
endif
	gs -sOutputFile=$@ -sDEVICE=pdfwrite -dEPSCrop \
	  -dCompatibilityLevel=1.4 -dBATCH -dNOPAUSE $< $(DEVNULL)

# SVG -> PDF
# Color SVGs from are transformed via stylesheet in order to wipe out
# some tags that cause trouble with xep or fop
$(IMG_GENDIR)/gen/pdf/%.pdf: $(IMG_GENDIR)/gen/svg/%.svg
ifeq ($(VERBOSITY),1)
	@echo "   Converting $(notdir $<) to PDF"
endif
	inkscape $(INK_OPTIONS) --export-pdf=$@ -f $< $(DEVNULL) && \
	  ( test -f $< || false )
