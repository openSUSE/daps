# Copyright (C) 2012-2020 SUSE Software Solutions Germany GmbH
#
# Author:
# Frank Sundermeyer <fsundermeyer at opensuse dot org>
#
# Image generation for DAPS
#
# Please submit feedback or patches to
# <fsundermeyer at opensuse dot org>
#
# for targets html and pdf
#

# TODO fs 2012-11-30:
# * general review
# * Variable names
# * making use of make's patsubst function?


# Overview
# DAPS uses images in $PRJ_DIR/images/src/<FORMAT>/
# Supported image formats are .dia, .ditaa, .odg, .png, and .svg
# - When creating HTML manuals all formats are converted to PNG
# - When creating PDF manuals all formats are converted to
#   either PNG, or SVG depending on the "format" attribute in the
#   <imagedata> tag of the XMl source
# The format attribute may take the following values
#
# SOURCE | ROLE HTML | ROLE FOP
# -----------------------------
#  DIA   |   PNG     |   SVG
#........|...........|..........
#  DITAA |   PNG     |   PNG
#........|...........|..........
#  JPG   |   JPG     |   JPG
#........|...........|..........
#  ODG   |   PNG     |   SVG
#........|...........|..........
#  PNG   |   PNG     |   PNG
#........|...........|..........
#  SVG   |   PNG     |   SVG
#........|...........|..........
#
# NOTE on DITAA:
# Version 0.10 that is packaged for openSUSE does not support SVG output
# upstream 0.11 has SVG support (--svg)
#
#
# $PRJ_DIR/images/src/<FORMAT>/ is _never_ used for manual creation, the
# images are rather created or linked into $IMG_GENDIR/color/ (color images)
# or into $IMG_GENDIR/grayscale/ (grayscale). If image creation/conversion
# requires generating intermediate files, these files are created in
# $IMG_GENDIR/gen/<FORMAT>
# We assume all images are color images, grayscale images are always created
#
# Image creation itself is triggered by the phony targets
# provide-images and provide-*-images

#------------------------------------------------------------------------
# Check for optipng and exiftool
#
HAVE_OPTIPNG  := $(shell which optipng 2>/dev/null)
HAVE_EXIFTOOL := $(shell which exiftool 2>/dev/null)

#------------------------------------------------------------------------
# xslt stylsheets
#
STYLEGFX       := $(DAPSROOT)/daps-xslt/common/get-graphics.xsl
STYLESVG       := $(DAPSROOT)/daps-xslt/common/fixsvg.xsl
STYLESVG2GRAY  := $(DAPSROOT)/daps-xslt/common/svg.color2grayscale.xsl

#------------------------------------------------------------------------
# Image lists
#

# get all images used in the current Document
#

USED := $(sort $(shell $(XSLTPROC) --stringparam "filetype=img" \
	 $(ROOTSTRING) --file $(SETFILES_TMP) \
         --stylesheet $(DAPSROOT)/daps-xslt/common/extract-files-and-images.xsl $(XSLTPROCESSOR) 2>/dev/null))

# JPG and PNG can be directly taken from the USED list - the filter
# function generates lists of all PNG common to USED and SCRPNG
#
USED_JPG := $(filter $(addprefix $(IMG_SRC_DIR)/jpg/,$(USED)), $(SRCJPG))
USED_PNG := $(filter $(addprefix $(IMG_SRC_DIR)/png/,$(USED)), $(SRCPNG))

# For HTML builds SVG are not directly used, but rather converted to PNG
# DIA, and DITAA are never directly used in the XML sources, but converted
# to SVG/PNG first. So we pretend all files in USED are SVG/DITAA/DIA files
# and then generate a list of files common to the fake USED and
# SRCDITAA/SRCDIA
#
USED_DIA := $(filter \
	$(addprefix $(IMG_SRC_DIR)/dia/,$(addsuffix .dia,$(basename $(USED)))), \
	$(SRCDIA))
USED_DITAA := $(filter \
	$(addprefix $(IMG_SRC_DIR)/ditaa/,$(addsuffix .ditaa,$(basename $(USED)))), \
	$(SRCDITAA))
USED_ODG := $(filter \
	$(addprefix $(IMG_SRC_DIR)/odg/,$(addsuffix .odg,$(basename $(USED)))), \
	$(SRCODG))
USED_SVG := $(filter \
$(addprefix $(IMG_SRC_DIR)/svg/,$(addsuffix .svg,$(basename $(USED)))), \
	$(SRCSVG))
USED_ALL := $(USED_DIA) $(USED_DITAA) $(USED_JPG) \
                $(USED_ODG) $(USED_PNG) $(USED_SVG)

# generated images
#
GEN_PNG := $(subst .dia,.png,$(notdir $(USED_DIA))) \
		$(subst .ditaa,.png,$(notdir $(USED_DITAA))) \
		$(subst .odg,.png,$(notdir $(USED_ODG))) \
		$(subst .svg,.png,$(notdir $(USED_SVG)))
GEN_SVG := $(subst .dia,.svg,$(notdir $(USED_DIA))) \
		$(subst .odg,.svg,$(notdir $(USED_ODG)))


# color images (used for manual creation)
# (JPGs are never generated, but rather taken as are, therefore no
#  GEN_JPG
#
JPGONLINE := $(sort $(addprefix $(IMG_GENDIR)/color/, $(notdir $(USED_JPG))))
PNGONLINE := $(sort $(addprefix $(IMG_GENDIR)/color/, \
		$(notdir $(USED_PNG)) $(GEN_PNG)))
SVGONLINE := $(sort $(addprefix $(IMG_GENDIR)/color/, \
		$(notdir $(USED_SVG)) $(GEN_SVG)))

# grayscale images (used for manual creation)
#
JPGPRINT := $(addprefix $(IMG_GENDIR)/grayscale/, $(notdir $(USED_JPG)))
PNGPRINT := $(addprefix $(IMG_GENDIR)/grayscale/, $(notdir $(USED_PNG)) $(GEN_PNG))
SVGPRINT := $(addprefix $(IMG_GENDIR)/grayscale/, $(notdir $(USED_SVG)) $(GEN_SVG))

# images with the same basename will cause problems because the image that
# is generated last will win. Since we use -j with make, this may be a
# different image on different machines
#
# SRC_IMG_ALL has all source images:
# 1a. $(shell echo $(basename ...
#  - separate values by newline
#  - sort string
#  - let uniq print all duplicates
#   => returns double1 double2 ...
# 1b. filter
#   => returns only images that are currently used
# 2a addprefix, addsuffix
#  - adds prefix IMG_SRC_DIR/*/ and suffix .* to values returned from 1
# 2b. wildcard
#   => returns all existing files from the list generated by 3

DUPLICATES := $(filter \
		$(shell echo $(basename $(notdir $(SRC_IMG_ALL)) 2>/dev/null) | \
		tr " " "\n" | sort |uniq -d 2>/dev/null),$(basename $(USED) 2>/dev/null))

DOUBLE_IMG := $(sort $(wildcard $(addprefix $(IMG_SRC_DIR)/*/,$(addsuffix .*,$(DUPLICATES) ))))

# images referenced in the currently used XML sources that cannot be found in
# $(IMG_SRC_DIR)

MISSING_IMG := $(sort $(filter-out $(notdir $(basename $(SRC_IMG_ALL))), \
                $(basename $(USED))))

#------------------------------------------------------------------------
# Image creation "targets"
#
# GRAYSCALE_IMAGES and COLOR_IMAGES contain all images that need to be created
# for the current document and are to be used as a dependency in
# html, pdf, etc.
#

#COLOR_IMAGES     := $(JPGONLINE) $(PNGONLINE) $(SVGONLINE)
#GRAYSCALE_IMAGES := $(JPGPRINT) $(PNGPRINT) $(SVGPRINT)
#ONLINE_IMAGES    := $(JPGONLINE) $(PNGONLINE) $(SVGONLINE)

COLOR_IMAGES     := $(addprefix $(IMG_GENDIR)/color/,$(USED))
GRAYSCALE_IMAGES := $(addprefix $(IMG_GENDIR)/grayscale/,$(USED))
ONLINE_IMAGES    := $(addprefix $(IMG_GENDIR)/color/,$(USED))

GEN_IMAGES       := $(addprefix $(IMG_GENDIR)/gen/png/,$(GEN_PNG)) $(addprefix $(IMG_GENDIR)/gen/svg/,$(GEN_SVG))


# ----------------------------
# Generating SVG/PNG from ODG
#
# lodraw is not capable of being executed in parallel, therfore the image
# creation via pattern targets is not possible. We use an empty target instead
# and make it a dependenc of $(GEN_IMAGES) $(ONLINE_IMAGES) $(COLOR_IMAGES)
#

# Only run the .odg_gen target if there are ODG files!!
#
ifneq "$(strip $(USED_ODG))" ""
  $(GEN_IMAGES) (ONLINE_IMAGES) (COLOR_IMAGES): $(IMG_GENDIR)/gen/.odg_gen
endif

# The ODG stuff is an ugly hack anyway, so this probably does not matter
# any further (although it significantly increases the uglyness)
#
# In case an SVG has been replaced by an ODG or in case there are dual source
# images (svg+odg) a link to the SVG/PNG is present in
# $(IMG_GENDIR)/gen/svg|png/
# If that is the case, lodraw follows this link and overwrites the source
# file
# Therefore we need to remove the links first
#
.PHONY: clean_links_for_odg
clean_links_for_odg: $(USED_ODG)
	for _IMG in  $(notdir $(subst .odg,,$(USED_ODG))); do \
	  if [ -h $(IMG_GENDIR)/gen/png/$${_IMG}.png ]; then \
	    rm $(IMG_GENDIR)/gen/png/$$_IMG.png; \
	  fi; \
	  if [ -h $(IMG_GENDIR)/gen/svg/$$_IMG.svg ]; then \
	    rm $(IMG_GENDIR)/gen/svg/$$_IMG.svg; \
	  fi; \
	done

$(IMG_GENDIR)/gen/.odg_gen: $(USED_ODG) clean_links_for_odg
ifeq "$(VERBOSITY)" "2"
	@echo "   Converting *.odg to PNG"
endif
	lodraw  --headless --convert-to png --outdir $(IMG_GENDIR)/gen/png/ $(USED_ODG) > /dev/null
ifeq "$(VERBOSITY)" "2"
	@echo "   Converting *.odg to SVG"
endif
	lodraw  --headless --convert-to svg --outdir $(IMG_GENDIR)/gen/svg/ $(USED_ODG) >/dev/null
	touch $@


# Image target for testing and debugging
#
PHONY: images
images:
  ifeq "$(IMAGES_ALL)" "1"
  images: $(COLOR_IMAGES) $(GRAYSCALE_IMAGES) $(ONLINE_IMAGES)
	@ccecho "result" "Images generated in $(IMG_GENDIR)/color/ and $(IMG_GENDIR)/grayscale/"
  else
    ifeq "$(IMAGES_ONLINE)" "1"
      images: $(ONLINE_IMAGES)
	@ccecho "result" "Online images generated in $(IMG_GENDIR)/color/"
    endif
    ifeq "$(GRAYSCALE)" "1"
      images: $(GRAYSCALE_IMAGES)
	@ccecho "result" "Images generated in $(IMG_GENDIR)/grayscale/"
    endif
    ifeq "$(IMAGES_GEN)" "1"
      images: $(GEN_IMAGES)
	@ccecho "result" "Images generated in $(IMG_GENDIR)/gen/"
    endif
    ifeq "$(IMAGES_COLOR)" "1"
      images: $(COLOR_IMAGES)
	@ccecho "result" "Images generated in $(IMG_GENDIR)/color/"
    endif
  endif


#------------------------------------------------------------------------
# We want to keep the generated files
#
.PRECIOUS: $(COLOR_IMAGES) $(GRAYSCALE_IMAGES) $(GEN_IMAGES)
.PRECIOUS: $(addprefix $(IMG_GENDIR)/gen/svg/,$(notdir $(USED_SVG)))

#---------------
# Optimize (size-wise) PNGs
#
.PHONY: optipng
optipng:
  ifndef HAVE_OPTIPNG
	@ccecho "error" "Error: optipng is not installed" && false
  endif
  ifndef HAVE_EXIFTOOL
	@ccecho "error" "Error: exiftool is not installed" && false
  endif

  ifdef USED_PNG
	( j=0; \
	for i in $(USED_PNG); do  \
	  if [[ -z $$(exiftool -Comment $$i | grep optipng) ]]; then \
	    let "j += 1"; \
	    optipng -o2 $$i >/dev/null 2>&1; \
	    exiftool -Comment=optipng -overwrite_original -P $$i >/dev/null || true; \
			if [[ "$(VERBOSITY)" -gt "0" ]]; then \
	    	echo $$i; \
			fi \
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

#---------------
# Warnings
#

# List missing images
#
.PHONY: list-images-missing
list-images-missing:
  ifdef MISSING_IMG
	$(call print_info,warn,The following images are missing:)
	$(call print_list,$(MISSING_IMG))
  else
    ifeq "$(MAKECMDGOALS)" "list-images-missing"
	$(call print_info,info,All images for document \"$(DOCNAME)\" exist.)
    endif
  endif

# List images with non-unique names
#
.PHONY: list-images-multisrc
list-images-multisrc:
  ifdef DOUBLE_IMG
	$(call print_info,warn,Image names not unique$(COMMA) multiple sources available for the following images:)
	$(call print_list,$(DOUBLE_IMG))
  else
    ifeq "$(MAKECMDGOALS)" "list-images-multisrc"
	$(call print_info,info,All images for document \"$(DOCNAME)\" have unique names.)
    endif
  endif

#------------------------------------------------------------------------
# The "real" image generation
#
# While PDFs support SVGs and PNGs, all other output formats need PNG
# (Browser support for SVG is still not common enough). So we convert
# SVGs to PNG. DIA files are also converted to SVG
# because they are unsupported in the output formats.
#
# We assume source images are generally color images, regardless of the format.
# Since b/w PDFs (for the print shop) need grayscale images, we transfer
# JPGs, PNGs and SVGs to grayscale as well.
#
# ODG conversion to PNG/SVG needs to be handled differently, because
# lodraw does not support parallel execution (see above)
#
# All conversions are done via $IMAGES_GENDIR/gen/
# Color images are placed in $IMAGES_GENDIR/color/
# Grayscale images are placed in $IMAGES_GENDIR/grayscale/

#
# Inscape changed command line option in version 1.0
#
# Check whether we have inkscape >= 1.0 or the old version (<1.0)
#
_INKSCAPE_VERSION := 1.0
_INKSCAPE_TEST    := $(_INKSCAPE_VERSION)
_INKSCAPE_VERSION += $(shell inkscape --version 2>/dev/null | awk '{print $$2}')

#
# Nasty workaround to compare version strings. 
# We are creating a string with "1.0 <current>", e.g. "1.0 0.91" in $(_INKSCAPE_VERSION)
# Afterwards we are sorting it (lowest version first) in $(_INKSCAPE_VERSION_SORT)
# Afterwards both strings are compared. If both are the same, the inkscape version
# is >=1.0, otherwise it is lower than 1.0 (which means it requires the old
# command line switches)

_INKSCAPE_VERSION_SORT := $(shell echo "$(_INKSCAPE_VERSION)" | tr " " "\n" | sort -b --version-sort | head -n1)

_INKSCAPE_IS_NEW := $(shell if [[ "$(_INKSCAPE_TEST)" = "$(_INKSCAPE_VERSION_SORT)" ]]; then echo "yes"; else echo "no"; fi)

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

$(IMG_GENDIR)/color/%.png: $(IMG_SRC_DIR)/png/%.png | $(IMG_GEN_DIRECTORIES)
  ifdef HAVE_OPTIPNG
    ifdef HAVE_EXIFTOOL
	@exiftool -Comment $< | grep optipng > /dev/null || \
	  ccecho "warn" " $< not optimized." >&2
    endif
  endif
	ln -sf $< $@

# generated PNGs
$(IMG_GENDIR)/color/%.png: $(IMG_GENDIR)/gen/png/%.png | $(IMG_GEN_DIRECTORIES)
	ln -sf $< $@

#---------------
# Create grayscale PNGs used in the manuals
#
# from existing color PNGs
$(IMG_GENDIR)/grayscale/%.png: $(IMG_SRC_DIR)/png/%.png | $(IMG_GEN_DIRECTORIES)
ifeq "$(VERBOSITY)" "2"
	@echo "   Converting $(notdir $<) to grayscale"
endif
	convert $< $(CONVERT_OPTS_PNG) $@ $(DEVNULL)

# from generated color PNGs
$(IMG_GENDIR)/grayscale/%.png: $(IMG_GENDIR)/gen/png/%.png | $(IMG_GEN_DIRECTORIES)
ifeq "$(VERBOSITY)" "2"
	@echo "   Converting $(notdir $<) to grayscale"
endif
	convert $< $(CONVERT_OPTS_PNG) $@ $(DEVNULL)

#---------------
# Create color PNGs from other formats

# remove_link and the optipng call are used more than once, so
# let's define them here

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

# DIA -> PNG
# create color PNGs from DIA
$(IMG_GENDIR)/gen/png/%.png: $(IMG_SRC_DIR)/dia/%.dia | $(IMG_GEN_DIRECTORIES)
ifeq "$(VERBOSITY)" "2"
	@echo "   Converting $(notdir $<) to PNG"
endif
	$(remove_link)
	LANG=C dia -t png --export=$@ $< $(DEVNULL) $(ERR_DEVNULL)
	$(run_optipng)

# DITAA -> PNG
# create color PNGs from DITAA
$(IMG_GENDIR)/gen/png/%.png: $(IMG_SRC_DIR)/ditaa/%.ditaa | $(IMG_GEN_DIRECTORIES)
ifeq "$(VERBOSITY)" "2"
	@echo "   Converting $(notdir $<) to PNG"
endif
	$(remove_link)
	ditaa $< $@ --transparent --overwrite --scale 2.5 --no-shadows $(DEVNULL) $(ERR_DEVNULL)
	$(run_optipng)

# SVG -> PNG
# create color PNGs from SVGs
#$(IMG_GENDIR)/gen/png/%.png: $(IMG_GENDIR)/gen/svg/%.svg | $(IMG_GEN_DIRECTORIES)
$(IMG_GENDIR)/gen/png/%.png: $(IMG_SRC_DIR)/svg/%.svg | $(IMG_GEN_DIRECTORIES)
ifeq "$(VERBOSITY)" "2"
	@echo "   Converting $(notdir $<) to PNG"
endif
	$(remove_link)
ifeq "$(_INKSCAPE_IS_NEW)" "yes"
	inkscape $(INK_OPTIONS) --export-type="png" --export-filename $@ $< $(ERR_DEVNULL)
else
	inkscape -z -e $@ -f $< $(DEVNULL) && ( test -f $< || false )
endif
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
$(IMG_GENDIR)/color/%.svg: $(IMG_GENDIR)/gen/svg/%.svg | $(IMG_GEN_DIRECTORIES)
ifeq "$(VERBOSITY)" "2"
	@echo "   Fixing $(notdir $<)"
endif
	$(XSLTPROC) --stylesheet $(STYLESVG) --file $< \
	  --output $@ --xsltproc_args "--novalid" $(XSLTPROCESSOR) $(DEVNULL)

#---------------
# Create grayscale SVGs used in the manuals
#
# Before generating grayscale SVGs we need to fix the original using
# $(STYLESVG) - as is done for color SVGs as well (see above). Instead of
# generating it and piping the result to the grayscale conversion (as it was
# done in 1.x), generate and use the online version - it will probably be
# needed anyway
#
$(IMG_GENDIR)/grayscale/%.svg: $(IMG_GENDIR)/color/%.svg | $(IMG_GEN_DIRECTORIES)
ifeq "$(VERBOSITY)" "2"
	@echo "   Converting $(notdir $<) to grayscale"
endif
	$(XSLTPROC) --stylesheet $(STYLESVG2GRAY) --file $< \
	  --output $@ --xsltproc_args "--novalid" $(XSLTPROCESSOR) $(DEVNULL)

#---------------
# Create color SVGs from other formats

# DIA -> SVG
#
$(IMG_GENDIR)/gen/svg/%.svg: $(IMG_SRC_DIR)/dia/%.dia | $(IMG_GEN_DIRECTORIES)
ifeq "$(VERBOSITY)" "2"
	@echo "   Converting $(notdir $<) to SVG"
endif
	LANG=C dia -t svg --export=$@ $< $(DEVNULL) $(ERR_DEVNULL)

# SVG -> SVG
#
# source SVGs are linked to gen/svg and are processed from there into
# online/ and print/
$(IMG_GENDIR)/gen/svg/%.svg: $(IMG_SRC_DIR)/svg/%.svg | $(IMG_GEN_DIRECTORIES)
	ln -sf $< $@

#------------------------------------------------------------------------
# JPG
#
# JPGs are always taken as are and there is no conversion from another format
# into JPG
# Therefore we only need to create links to the online dir and convert to
# grayscale for b/w PDFs
#

#---------------
# Link JPGs
#

$(IMG_GENDIR)/color/%.jpg: $(IMG_SRC_DIR)/jpg/%.jpg | $(IMG_GEN_DIRECTORIES)
	ln -sf $< $@

#---------------
# Create grayscale JPGs
#
$(IMG_GENDIR)/grayscale/%.jpg: $(IMG_SRC_DIR)/jpg/%.jpg | $(IMG_GEN_DIRECTORIES)
ifeq "$(VERBOSITY)" "2"
	@echo "   Converting $(notdir $<) to grayscale"
endif
	convert $< $(CONVERT_OPTS_JPG) $@ $(DEVNULL)
