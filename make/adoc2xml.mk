# Copyright (C) 2012-2018 SUSE Linux GmbH
#
# Author:
# Frank Sundermeyer <fsundermeyer at opensuse dot org>
#
# Convert asciidoc to DocBook5
#
# Please submit feedback or patches to
# <fsundermeyer at opensuse dot org>
#

#--------------------------------------------------
# CHECKS
#

# Some variables need to be preset from the wrapper script
# Double-check whether they are set
#
ifndef BOOK
  $(error $(shell ccecho "error" "Fatal error: BOOK is not set"))
endif
ifndef BUILD_DIR
  $(error $(shell ccecho "error" "Fatal error: No path to build directory set"))
endif
ifndef DOC_DIR
  $(error $(shell ccecho "error" "Fatal error: No path to working directory set"))
endif
ifndef ADOC_MAIN
  $(error $(shell ccecho "error" "Fatal error: No MAIN file set"))
endif

# Get the adoc sourcefiles
#
# include statements always start at the begin of the line, no other
# characters (incl. space) are allowed before it
#
# If grep fails, we at least have ADOC_MAIN
#
ADOC_SRCFILES := $(ADOC_MAIN) $(wildcard $(addprefix \
 $(DOC_DIR)/adoc/,$(shell egrep '^include::' $(ADOC_MAIN) 2>/dev/null | sed 's/.*::\([^\[]*\).*/\1/g' 2>/dev/null)))
#ADOC_SRCFILES := $(wildcard $(DOC_DIR)/adoc/*.adoc)

#
# ADOC sources usually have images in a single directory. If ADOC_IMG_DIR
# is set (via --adocimgdir), we will set up the required image structure
# automatically

ifneq "$(strip $(ADOC_IMG_DIR))" ""
  IDIR :=  $(BUILD_DIR)/.adoc_images/src

  DIA_DIR := $(IDIR)/dia
  DIA     := $(subst $(ADOC_IMG_DIR)/,$(DIA_DIR)/,$(wildcard $(ADOC_IMG_DIR)/*.dia))
  EPS_DIR := $(IDIR)/eps
  EPS     := $(subst $(ADOC_IMG_DIR)/,$(EPS_DIR)/,$(wildcard $(ADOC_IMG_DIR)/*.eps))
  FIG_DIR := $(IDIR)/fig
  FIG     := $(subst $(ADOC_IMG_DIR)/,$(FIG_DIR)/,$(wildcard $(ADOC_IMG_DIR)/*.fig))
  JPG_DIR := $(IDIR)/jpg
  JPG     := $(subst $(ADOC_IMG_DIR)/,$(JPG_DIR)/,$(wildcard $(ADOC_IMG_DIR)/*.jpg))
  PDF_DIR := $(IDIR)/pdf
  PDF     := $(subst $(ADOC_IMG_DIR)/,$(PDF_DIR)/,$(wildcard $(ADOC_IMG_DIR)/*.pdf))
  PNG_DIR := $(IDIR)/png
  PNG     := $(subst $(ADOC_IMG_DIR)/,$(PNG_DIR)/,$(wildcard $(ADOC_IMG_DIR)/*.png))
  SVG_DIR := $(IDIR)/svg
  SVG     := $(subst $(ADOC_IMG_DIR)/,$(SVG_DIR)/,$(wildcard $(ADOC_IMG_DIR)/*.svg))

  NEW_IMAGES      := $(DIA) $(EPS) $(FIG) $(JPG) $(PDF) $(PNG) $(SVG)
  NEW_IMAGES_DIRS := $(DIA_DIR) $(EPS_DIR) $(FIG_DIR) $(JPG_DIR) $(PDF_DIR) $(PNG_DIR) $(SVG_DIR)
endif

all: $(MAIN)
ifneq "$(strip $(ADOC_IMG_DIR))" ""
  all: $(NEW_IMAGES)
endif

#all: $(MAIN)
$(MAIN): $(ADOC_SRCFILES) | $(ADOC_DIR)
  ifeq "$(VERBOSITY)" "2"
	@ccecho "info"  "   Creating XML from ASCIIDOC..."
  endif
	$(ASCIIDOC) --attribute=imagesdir! $(ADOC_ATTRIBUTES) \
          --backend=$(ADOC_BACKEND) --doctype=$(ADOC_TYPE) \
          --out-file=$@ $(ADOC_MAIN)
  ifeq "$(VERBOSITY)" "2"
	@ccecho "info" "Successfully created XML file $@"
  endif

### 	asciidoc --attribute=imagesdir! \
	  --doctype=$(ADOC_TYPE) --out-file=$@ $(ADOC_MAIN)


$(DIA_DIR)/%.dia: $(ADOC_IMG_DIR)/%.dia | $(DIA_DIR)
	(cd $(@D); ln -sf $<)

$(EPS_DIR)/%.eps: $(ADOC_IMG_DIR)/%.eps | $(EPS_DIR)
	(cd $(@D); ln -sf $<)

$(FIG_DIR)/%.fig: $(ADOC_IMG_DIR)/%.fig | $(FIG_DIR)
	(cd $(@D); ln -sf $<)

$(JPG_DIR)/%.jpg: $(ADOC_IMG_DIR)/%.jpg | $(JPG_DIR)
	(cd $(@D); ln -sf $<)

$(PDF_DIR)/%.pdf: $(ADOC_IMG_DIR)/%.pdf | $(PDF_DIR)
	(cd $(@D); ln -sf $<)

$(PNG_DIR)/%.png: $(ADOC_IMG_DIR)/%.png | $(PNG_DIR)
	(cd $(@D); ln -sf $<)

$(SVG_DIR)/%.svg: $(ADOC_IMG_DIR)/%.svg | $(SVG_DIR)
	(cd $(@D); ln -sf $<)

$(ADOC_DIR) $(NEW_IMAGES_DIRS):
	@mkdir -p $@
