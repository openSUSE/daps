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
# DAPS uses images in $PRJ_DIR/$IMG_SRC_DIR/<FORMAT>/
# or alternatively $PRJ_DIR/$IMG_SRC_DIR/
# Supported image formats are .dia, .ditaa, .odg, .png, and .svg
# - When creating HTML manuals all formats are converted to PNG
# - When creating PDF manuals all formats are converted to
#   either PNG, or SVG depending on the "format" attribute in the
#   <imagedata> tag of the XML source
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
# Check for optipng
#
HAVE_OPTIPNG  := $(shell which optipng 2>/dev/null)

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
         --stylesheet $(DAPSROOT)/daps-xslt/common/extract-files-and-images.xsl $(XSLTPROCESSOR) $(ERR_DEVNULL)))

# JPG and PNG can be directly taken from the USED list - the filter
# function generates lists of all PNG common to USED and SCRPNG
#
USED_JPG := $(filter $(addprefix $(IMG_SRC_DIR)/jpg/,$(USED)) $(addprefix $(IMG_SRC_DIR)/,$(USED)), $(SRCJPG))
USED_PNG := $(filter $(addprefix $(IMG_SRC_DIR)/png/,$(USED)) $(addprefix $(IMG_SRC_DIR)/,$(USED)), $(SRCPNG))

# For HTML builds SVG are not directly used, but rather converted to PNG.
# DIA, ODG, SVG and DITAA are never directly used in the XML sources, but
# converted to SVG/PNG first. So we pretend all files in USED are
# ODG/SVG/DITAA/DIA files and then generate a list of files common to the
# fake USED and SRCSVG/SRCODG/SRCDITAA/SRCDIA. The result is a list of files
# in the 4 formats that need to be converted to SVG and PNG
#
USED_DIA := $(filter \
	$(addprefix $(IMG_SRC_DIR)/dia/,$(addsuffix .dia,$(basename $(USED)))) \
	$(addprefix $(IMG_SRC_DIR)/,$(addsuffix .dia,$(basename $(USED)))), \
	$(SRCDIA))
USED_DITAA := $(filter \
	$(addprefix $(IMG_SRC_DIR)/ditaa/,$(addsuffix .ditaa,$(basename $(USED)))) \
	$(addprefix $(IMG_SRC_DIR)/,$(addsuffix .ditaa,$(basename $(USED)))), \
	$(SRCDITAA))
USED_ODG := $(filter \
	$(addprefix $(IMG_SRC_DIR)/odg/,$(addsuffix .odg,$(basename $(USED)))) \
	$(addprefix $(IMG_SRC_DIR)/,$(addsuffix .odg,$(basename $(USED)))), \
	$(SRCODG))
USED_SVG := $(filter \
	$(addprefix $(IMG_SRC_DIR)/svg/,$(addsuffix .svg,$(basename $(USED)))) \
	$(addprefix $(IMG_SRC_DIR)/,$(addsuffix .svg,$(basename $(USED)))), \
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

DUPLICATES := $(shell echo "$(basename $(notdir $(SRC_IMG_ALL)) 2>/dev/null)" | \
		tr " " "\n" | sort |uniq -d 2>/dev/null)

DOUBLE_IMG := $(sort $(wildcard $(addsuffix .*,$(addprefix $(IMG_SRC_DIR)/*/,$(DUPLICATES))) $(addsuffix .*,$(addprefix $(IMG_SRC_DIR)/,$(DUPLICATES))))) 

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

COLOR_IMAGES     := $(addprefix $(IMG_GENDIR)/color/,$(USED))
GRAYSCALE_IMAGES := $(addprefix $(IMG_GENDIR)/grayscale/,$(USED))

# This list has all PNG/SVG images created from DIA/DITAA/ODG. Since all
# SVGs source images are parsed as well, it also includes USED_SVG
#
GEN_IMAGES       := $(addprefix $(IMG_GENDIR)/color/,$(GEN_PNG)) $(addprefix $(IMG_GENDIR)/gen/,$(GEN_SVG)) \
  $(addprefix $(IMG_GENDIR)/gen/,$(notdir $(USED_SVG)))

# ----------------------------
# Generating SVG/PNG from ODG
#
# lodraw is not capable of being executed in parallel, therfore the image
# creation via pattern targets is not possible. We use an empty target instead
# and make it a dependenc of $(GEN_IMAGES) $(COLOR_IMAGES)
#

# Only run the .odg_gen target if there are ODG files!!
#
ifneq "$(strip $(USED_ODG))" ""
  $(GEN_IMAGES) $(COLOR_IMAGES): $(IMG_GENDIR)/gen/.odg_gen
endif

# The ODG stuff is an ugly hack anyway, so this probably does not matter
# any further (although it significantly increases the uglyness)
#
# In case an SVG has been replaced by an ODG or in case there are dual source
# images (svg+odg) a link to the SVG/PNG is present in
# $(IMG_GENDIR)/gen/
# If that is the case, lodraw follows this link and overwrites the source
# file
# Therefore we need to remove the links first
#
.PHONY: clean_links_for_odg
clean_links_for_odg: $(USED_ODG)
	for _IMG in  $(notdir $(subst .odg,,$(USED_ODG))); do \
	  if [ -h $(IMG_GENDIR)/color/$${_IMG}.png ]; then \
	    rm $(IMG_GENDIR)/color/$${_IMG}.png; \
	  fi; \
	  if [ -h $(IMG_GENDIR)/gen/$${_IMG}.svg ]; then \
	    rm $(IMG_GENDIR)/gen/$${_IMG}.svg; \
	  fi; \
	done

$(IMG_GENDIR)/gen/.odg_gen: $(USED_ODG) clean_links_for_odg
ifeq "$(VERBOSITY)" "2"
	@echo "   Converting *.odg to PNG"
endif
	lodraw  --headless --convert-to png --outdir $(IMG_GENDIR)/color/ $(USED_ODG) > /dev/null
ifeq "$(VERBOSITY)" "2"
	@echo "   Converting *.odg to SVG"
endif
	lodraw  --headless --convert-to svg --outdir $(IMG_GENDIR)/gen/ $(USED_ODG) >/dev/null
	touch $@


# Image target for testing and debugging
#
PHONY: images
images:
  ifeq "$(IMAGES_ALL)" "1"
  images: $(COLOR_IMAGES) $(GRAYSCALE_IMAGES)
	@ccecho "result" "Images generated in $(IMG_GENDIR)/color/ and $(IMG_GENDIR)/grayscale/"
  else
    ifeq "$(GRAYSCALE)" "1"
      images: $(GRAYSCALE_IMAGES)
	@ccecho "result" "Images generated in $(IMG_GENDIR)/grayscale/"
    endif
    ifeq "$(IMAGES_GEN)" "1"
      images: $(GEN_IMAGES)
	@ccecho "result" "Images generated in $(IMG_GENDIR)/gen/ (SVGs) and in $(IMG_GENDIR)/color( (PNGs)"
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

#---------------
# Optimize (size-wise) PNGs
#
.PHONY: optipng
optipng:
  ifdef USED_PNG
	optipng -o2 -fix -preserve $(USED_PNG) $(DEVNULL) $(ERR_DEVNULL)
	ccecho "result" "All PNGs for $(BOOK) are optimized"
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
  ifneq "$(strip $(MISSING_IMG))" ""
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
  ifneq "$(strip $(DOUBLE_IMG))" "" 
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

#------------------------------------------------------------------------
# PNG
#

#---------------
# Link existing source images that are used in the manuals
#
$(IMG_GENDIR)/color/%.png: $(IMG_SRC_DIR)/png/%.png | $(IMG_GEN_DIRECTORIES)
  ifdef HAVE_OPTIPNG
	optipng -o0 -simulate $< 2>&1 | grep -q "already optimized"  || \
	  ccecho "warn" " $< not optimized." >&2
  endif
	ln -sf $< $@

$(IMG_GENDIR)/color/%.png: $(IMG_SRC_DIR)/%.png | $(IMG_GEN_DIRECTORIES)
  ifdef HAVE_OPTIPNG
	optipng -o0 -simulate $< 2>&1 | grep -q "already optimized"  || \
	  ccecho "warn" " $< not optimized." >&2
  endif
	ln -sf $< $@

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
optipng -o2 -fix -preserve $@ >/dev/null 2>&1
  endef
endif

# DIA -> PNG
# create color PNGs from DIA
$(IMG_GENDIR)/color/%.png: $(IMG_SRC_DIR)/dia/%.dia | $(IMG_GEN_DIRECTORIES)
ifeq "$(VERBOSITY)" "2"
	@echo "   Converting $(notdir $<) to PNG"
endif
	$(remove_link)
	LANG=C dia -t png --export=$@ $< $(DEVNULL) $(ERR_DEVNULL)
	$(run_optipng)

$(IMG_GENDIR)/color/%.png: $(IMG_SRC_DIR)/%.dia | $(IMG_GEN_DIRECTORIES)
ifeq "$(VERBOSITY)" "2"
	@echo "   Converting $(notdir $<) to PNG"
endif
	$(remove_link)
	LANG=C dia -t png --export=$@ $< $(DEVNULL) $(ERR_DEVNULL)
	$(run_optipng)

# DITAA -> PNG
# create color PNGs from DITAA
$(IMG_GENDIR)/color/%.png: $(IMG_SRC_DIR)/ditaa/%.ditaa | $(IMG_GEN_DIRECTORIES)
ifeq "$(VERBOSITY)" "2"
	@echo "   Converting $(notdir $<) to PNG"
endif
	$(remove_link)
	ditaa $< $@ --transparent --overwrite --scale 2.5 --no-shadows $(DEVNULL) $(ERR_DEVNULL)
	$(run_optipng)

$(IMG_GENDIR)/color/%.png: $(IMG_SRC_DIR)/%.ditaa | $(IMG_GEN_DIRECTORIES)
ifeq "$(VERBOSITY)" "2"
	@echo "   Converting $(notdir $<) to PNG"
endif
	$(remove_link)
	ditaa $< $@ --transparent --overwrite --scale 2.5 --no-shadows $(DEVNULL) $(ERR_DEVNULL)
	$(run_optipng)

# SVG -> PNG
# create color PNGs from SVGs
$(IMG_GENDIR)/color/%.png: $(IMG_GENDIR)/gen/%.svg | $(IMG_GEN_DIRECTORIES)
ifeq "$(VERBOSITY)" "2"
	@echo "   Converting $(notdir $<) to PNG"
endif
	$(remove_link)

# Check for rsvg-convert
HAVE_RSVG_CONVERT := $(shell which rsvg-convert 2>/dev/null)

# Ensure rsvg-convert is available
ifeq ($(HAVE_RSVG_CONVERT),)
$(error rsvg-convert not found. Please install librsvg.)
endif

# Convert SVG to PNG using rsvg-convert
$(IMG_GENDIR)/color/%.png: $(IMG_SRC_DIR)/svg/%.svg | $(IMG_GEN_DIRECTORIES)
	@echo "Converting $< to $@ using rsvg-convert"
	rsvg-convert -o $@ $<
	$(run_optipng)

# Create grayscale PNGs
#
# all PNGs we need are in $(IMG_GENDIR)/color, generate from there
#
$(IMG_GENDIR)/grayscale/%.png: $(IMG_GENDIR)/color/%.png | $(IMG_GEN_DIRECTORIES)
ifeq "$(VERBOSITY)" "2"
	@echo "   Converting $(notdir $<) to grayscale"
endif
	convert $< $(CONVERT_OPTS_PNG) $@ $(DEVNULL)


#------------------------------------------------------------------------
# SVGs
#

# SVGs are never used directly from source, since they are all generated
# Even existing SVGs are transformed via stylesheet in order to wipe out
# some tags that cause trouble with xep or fop
# All SVGs are generated to $(IMG_GENDIR)/gen/ and then linked/generated
# to $(IMG_GENDIR)/color/ and $(IMG_GENDIR)/grayscale/

# Wipe troublesome tags
#
$(IMG_GENDIR)/gen/%.svg: $(IMG_SRC_DIR)/svg/%.svg | $(IMG_GEN_DIRECTORIES)
ifeq "$(VERBOSITY)" "2"
	@echo "   Fixing $(notdir $<)"
endif
	$(XSLTPROC) --stylesheet $(STYLESVG) --file $< \
	  --output $@ --xsltproc_args "--novalid" $(XSLTPROCESSOR) $(DEVNULL)

$(IMG_GENDIR)/gen/%.svg: $(IMG_SRC_DIR)/%.svg | $(IMG_GEN_DIRECTORIES)
ifeq "$(VERBOSITY)" "2"
	@echo "   Fixing $(notdir $<)"
endif
	$(XSLTPROC) --stylesheet $(STYLESVG) --file $< \
	  --output $@ --xsltproc_args "--novalid" $(XSLTPROCESSOR) $(DEVNULL)

#---------------
# Create color SVGs from other formats

# DIA -> SVG
#
$(IMG_GENDIR)/gen/%.svg: $(IMG_SRC_DIR)/dia/%.dia | $(IMG_GEN_DIRECTORIES)
ifeq "$(VERBOSITY)" "2"
	@echo "   Converting $(notdir $<) to SVG"
endif
	LANG=C dia -t svg --export=$@ $< $(DEVNULL) $(ERR_DEVNULL)

$(IMG_GENDIR)/gen/%.svg: $(IMG_SRC_DIR)/%.dia | $(IMG_GEN_DIRECTORIES)
ifeq "$(VERBOSITY)" "2"
	@echo "   Converting $(notdir $<) to SVG"
endif
	LANG=C dia -t svg --export=$@ $< $(DEVNULL) $(ERR_DEVNULL)

#---------------
# Link generated SVGs to $(IMG_GENDIR)/color
#

$(IMG_GENDIR)/color/%.svg: $(IMG_GENDIR)/gen/%.svg | $(IMG_GEN_DIRECTORIES)
	ln -sf $< $@

#---------------
# Create grayscale SVGs used in the manuals
#
# Simply convert all generated SVG images in $(IMG_GENDIR)/color/
#
$(IMG_GENDIR)/grayscale/%.svg: $(IMG_GENDIR)/color/%.svg | $(IMG_GEN_DIRECTORIES)
ifeq "$(VERBOSITY)" "2"
	@echo "   Converting $(notdir $<) to grayscale"
endif
	$(XSLTPROC) --stylesheet $(STYLESVG2GRAY) --file $< \
	  --output $@ --xsltproc_args "--novalid" $(XSLTPROCESSOR) $(DEVNULL)


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

$(IMG_GENDIR)/color/%.jpg: $(IMG_SRC_DIR)/%.jpg | $(IMG_GEN_DIRECTORIES)
	ln -sf $< $@

#---------------
# Create grayscale JPGs
#
# Like with the PNGs, we use the links in $(IMG_SRC_DIR)/color/ to
# create the grayscale JPGs with a single target
#

$(IMG_GENDIR)/grayscale/%.jpg: $(IMG_GENDIR)/color/%.jpg | $(IMG_GEN_DIRECTORIES)
ifeq "$(VERBOSITY)" "2"
	@echo "   Converting $(notdir $<) to grayscale"
endif
	convert $< $(CONVERT_OPTS_JPG) $@ $(DEVNULL)
