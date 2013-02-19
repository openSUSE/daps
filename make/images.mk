# Copyright (C) 2012 SUSE Linux Products GmbH
#
# Author: Frank Sundermeyer
#
# Image generation for DAPS
#
# Please submit feedback or patches to
# <fsundermeyer at opensuse dot org>
#
# for targets html, pdf, color-pdf
#
# Copyright (C) 2012 SUSE Linux Products GmbH
#
# Author: Frank Sundermeyer
#
# METAFILE generation for DAPS
#
# Please submit to feedback or patches to
# <fsundermeyer at opensuse dot org>
#
# for targets html, pdf, color-pdf
#

# TODO fs 2012-11-30:
# * general review
# * Variable names
# * making use of make's patsubst function?


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
# Check for optipng
#
HAVE_OPTIPNG := $(shell which --skip-alias --skip-functions optipng 2>/dev/null)

#------------------------------------------------------------------------
# xslt stylsheets
#
STYLEGFX       := $(DAPSROOT)/daps-xslt/common/get-graphics.xsl
STYLESVG       := $(DAPSROOT)/daps-xslt/common/fixsvg.xsl
STYLESVG2GRAY  := $(DAPSROOT)/daps-xslt/common/svg.color2grayscale.xsl

#------------------------------------------------------------------------
# Image lists
#

# generate lists of all existing images
SRCDIA     := $(wildcard $(IMG_SRCDIR)/dia/*.dia)
SRCEPS     := $(wildcard $(IMG_SRCDIR)/eps/*.eps)
SRCFIG     := $(wildcard $(IMG_SRCDIR)/fig/*.fig)
SRCPDF     := $(wildcard $(IMG_SRCDIR)/pdf/*.pdf)
SRCPNG     := $(wildcard $(IMG_SRCDIR)/png/*.png)
SRCSVG     := $(wildcard $(IMG_SRCDIR)/svg/*.svg)
SRCALL     := $(SRCDIA) $(SRCEPS) $(SRCFIG) $(SRCPDF) $(SRCPNG) $(SRCSVG)
IMGDIRS    := $(sort $(dir $(SRCALL)))
IMGFORMATS := dia eps fig pdf png svg


# get all images used in the current Document
#

USED := $(sort $(shell $(XSLTPROC) --stringparam "xml.or.img=img" \
	 --stringparam "$(ROOTSTRING)" --file $(SETFILES_TMP) \
         --stylesheet $(DAPSROOT)/daps-xslt/common/extract-files-and-images.xsl $(XSLTPROCESSOR) ))

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
USED_ALL := $(USED_DIA) $(USED_EPS) $(USED_FIG) $(USED_PNG) $(USED_PDF) $(USED_SVG)

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
# SRCALL has all source images:
# 1a. $(shell echo $(basename ...
#  - separate values by newline
#  - sort string
#  - let uniq print all duplicates
#   => returns double1 double2 ...
# 1b. filter
#   => returns only images that are currently used
# 2a addprefix, addsuffix
#  - adds prefix IMGDIR and suffix .* to values returned from 1
# 2b. foreach
#  - iterates over all image source directories currently used
#   => together with 2. returns
#      images/src/dia/double1.*
#      images/src/dia/double2.*
#      ...
#      images/src/svg/double1.*
#      images/src/svg/double2.*
# 2c. wildcard
#   => returns all existing files from the list generated by 3

DUPLICATES := $(filter \
		$(shell echo $(basename $(notdir $(SRCALL))) | tr " " "\n" | sort |uniq -d), \
		$(basename $(USED)))

DOUBLEIMG := $(sort \
	       $(wildcard \
		 $(foreach IMGDIR, $(IMGDIRS), \
	  	   $(addprefix $(IMGDIR), \
		     $(foreach SUFFIX, $(IMGFORMATS), \
		       $(addsuffix .$(SUFFIX), $(DUPLICATES)))))))

# images referenced in the currently used XML sources that cannot be found in
# $(IMG_SRCDIR)

MISSING     := $(sort $(filter-out $(notdir $(basename $(SRCALL))), \
                $(basename $(USED))))

#------------------------------------------------------------------------
# Image creation "targets"
#
# PRINT_IMAGES and ONLINE_IMAGES contain all images that need to be created
# for the current document and are to be used as a dependency in
# html, pdf, etc.
#

PRINT_IMAGES  := $(SVGPRINT) $(PNGPRINT) $(PDFPRINT)
ONLINE_IMAGES := $(SVGONLINE) $(PNGONLINE) $(PDFONLINE)

$(ONLINE_IMAGES): | $(IMG_DIRECTORIES)
$(PRINT_IMAGES): | $(IMG_DIRECTORIES)

#---------------
# Optimize (size-wise) PNGs
#
.PHONY: optipng
optipng:
  ifndef HAVE_OPTIPNG
	@ccecho "error" "Error: optipng is not installed" && false
  else
    ifdef USED_PNG
	( j=0; \
	for i in $(USED_PNG); do  \
	  if [[ -z $$(exiftool -Comment $$i | grep optipng) ]]; then \
	    let "j += 1"; \
	    optipng -o2 $$i >/dev/null 2>&1; \
	    exiftool -Comment=optipng -overwrite_original -P $$i >/dev/null || true; \
	  fi \
	done; \
	if [ 0 == $$j ]; then \
	  ccecho "result" "No files needed optimization"; \
	else \
	  ccecho "result" "$$j files have been optimized."; \
	fi )
    else
	@ccecho "warn" "Warning: This document does not contain any PNGs to optimize."
    endif
  endif

#---------------
# Warnings
#

# This warning is solely for publishing stuff on novell.com/documentation,
# therefore we make it dependend on HTMLROOT which also is only used
# for novell.com/documentation publishing
ifdef HTMLROOT
  warn-cap: USED_LC := $(shell echo $(USED) | tr [:upper:] [:lower:] )
  warn-cap: WRONG_CAP := $(filter-out $(USED_LC), $(USED))
  warn-cap:
    ifdef WRONG_CAP
      ifneq ($(VERBOSITY),0)
	@ccecho "warn" "Not all image file names are lower case. This will make problems when creating online docs:\n$(WRONG_CAP)" >2
      endif
    endif
endif

# List missing images 
#
.PHONY: list-images-missing
list-images-missing:
  ifdef MISSING
	@ccecho "warn" "The following images are missing:"
    ifeq ($(PRETTY_FILELIST), 1)
	@echo -e "$(subst $(SPACE),\n,$(sort $(MISSING)))"
    else
	@echo "$(MISSING)"
    endif
  else
    ifeq ($(MAKECMDGOALS),list-images-missing)
	@ccecho "info" "All images for document \"$(DOCNAME)\" exist."
    endif
  endif

# List images with non-unique names
#
.PHONY: list-images-multisrc warn-images
list-images-multisrc warn-images:
  ifdef DOUBLEIMG
	@ccecho "warn" "Image names not unique, multiple sources available for the following images:"
    ifeq ($(PRETTY_FILELIST), 1)
	@echo -e "$(subst $(SPACE),\n,$(sort $(DOUBLEIMG)))"
    else
	@echo "$(DOUBLEIMG)"
    endif
  else
	@ccecho "info" "All images for document \"$(DOCNAME)\" exist."
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
#
# TODO: remove static exiftool dependency
#

$(IMG_GENDIR)/online/%.png: $(IMG_SRCDIR)/png/%.png
  ifdef HAVE_OPTIPNG
	@exiftool -Comment $< | grep optipng > /dev/null || \
	  ccecho "warn" " $< not optimized." >&2
  endif
	ln -sf $< $@

# generated PNGs
$(IMG_GENDIR)/online/%.png: $(IMG_GENDIR)/gen/png/%.png
	ln -sf $< $@

#---------------
# Create grayscale PNGs used in the manuals
#
# from existing color PNGs
$(IMG_GENDIR)/print/%.png: $(IMG_SRCDIR)/png/%.png
ifeq ($(VERBOSITY),2)
	@echo "   Converting $(notdir $<) to grayscale"
endif
	convert $< $(CONVERT_OPTS) $@ $(DEVNULL)

# from generated color PNGs
$(IMG_GENDIR)/print/%.png: $(IMG_GENDIR)/gen/png/%.png
ifeq ($(VERBOSITY),2)
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

ifdef HAVE_OPTIPNG
  define run_optipng
optipng -o2 $@ >/dev/null 2>&1
  endef
endif

# SVG -> PNG
# create color PNGs from SVGs
$(IMG_GENDIR)/gen/png/%.png: $(IMG_GENDIR)/gen/svg/%.svg
ifeq ($(VERBOSITY),2)
	@echo "   Converting $(notdir $<) to PNG"
endif
	$(remove_link)
	inkscape $(INK_OPTIONS) -e $@ -f $< $(DEVNULL) && \
	  ( test -f $< || false )
	$(run_optipng)

# EPS -> PNG
# create color PNGs from EPS
$(IMG_GENDIR)/gen/png/%.png: $(IMG_SRCDIR)/eps/%.eps
ifeq ($(VERBOSITY),2)
	@echo "   Converting $(notdir $<) to PNG"
endif
	$(remove_link)
	convert $< $@ $(DEVNULL)
	$(run_optipng)

# PDF -> PNG
# create color PNGs from EPS
$(IMG_GENDIR)/gen/png/%.png: $(IMG_SRCDIR)/pdf/%.pdf
ifeq ($(VERBOSITY),2)
	@echo "   Converting $(notdir $<) to PNG"
endif
	$(remove_link)
	convert $< $@ $(DEVNULL)
	$(run_optipng)

$(IMG_GENDIR)/gen/png/%.png: $(IMG_GENDIR)/gen/pdf/%.pdf
ifeq ($(VERBOSITY),2)
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
ifeq ($(VERBOSITY),2)
	@echo "   Fixing $(notdir $<)"
endif
	xsltproc --novalid $(STYLESVG) $< > $@

#---------------
# Create grayscale SVGs used in the manuals
#
$(IMG_GENDIR)/print/%.svg: $(IMG_GENDIR)/gen/svg/%.svg
ifeq ($(VERBOSITY),2)
	@echo "   Converting $(notdir $<) to grayscale"
endif
	xsltproc --novalid $(STYLESVG) $< | \
	xsltproc --novalid $(STYLESVG2GRAY) - > $@

#---------------
# Create color SVGs from other formats

# DIA -> SVG
#
$(IMG_GENDIR)/gen/svg/%.svg: $(IMG_SRCDIR)/dia/%.dia
ifeq ($(VERBOSITY),2)
	@echo "   Converting $(notdir $<) to SVG"
endif
	LANG=C dia $(DIA_OPTIONS) --export=$@ $< $(DEVNULL) $(ERR_DEVNULL)

# FIG -> SVG
#
$(IMG_GENDIR)/gen/svg/%.svg: $(IMG_SRCDIR)/fig/%.fig
ifeq ($(VERBOSITY),2)
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
ifeq ($(VERBOSITY),2)
	@echo "   Converting $(notdir $<) to grayscale"
endif
	gs -sOutputFile=$@ -sDEVICE=pdfwrite \
	  -sColorConversionStrategy=Gray -dProcessColorModel=/DeviceGray \
	  -dCompatibilityLevel=1.4 -dNOPAUSE -dBATCH $< $(DEVNULL)

# from generated color PDFs
$(IMG_GENDIR)/print/%.pdf: $(IMG_GENDIR)/gen/pdf/%.pdf
ifeq ($(VERBOSITY),2)
	@echo "   Converting $(notdir $<) to grayscale"
endif
	gs -sOutputFile=$@ -sDEVICE=pdfwrite \
	  -sColorConversionStrategy=Gray -dProcessColorModel=/DeviceGray \
	  -dCompatibilityLevel=1.4 -dNOPAUSE -dBATCH $< $(DEVNULL)

#---------------
# Create color PDFs from other formats

# EPS -> PDF
$(IMG_GENDIR)/gen/pdf/%.pdf: $(IMG_SRCDIR)/eps/%.eps
ifeq ($(VERBOSITY),2)
	@echo "   Converting $(notdir $<) to PDF"
endif
	gs -sOutputFile=$@ -sDEVICE=pdfwrite -dEPSCrop \
	  -dCompatibilityLevel=1.4 -dBATCH -dNOPAUSE $< $(DEVNULL)

# SVG -> PDF
# Color SVGs from are transformed via stylesheet in order to wipe out
# some tags that cause trouble with xep or fop
$(IMG_GENDIR)/gen/pdf/%.pdf: $(IMG_GENDIR)/gen/svg/%.svg
ifeq ($(VERBOSITY),2)
	@echo "   Converting $(notdir $<) to PDF"
endif
	inkscape $(INK_OPTIONS) --export-pdf=$@ -f $< $(DEVNULL) && \
	  ( test -f $< || false )



