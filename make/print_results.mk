# Copyright (C) 2012 SUSE Linux Products GmbH
#
# Author: Frank Sundermeyer
#
# List result names for DAPS
#
# Please submit feedback or patches to
# <fsundermeyer at opensuse dot org>
#

#---------------
# EPUB
#
.PHONY: epub-name
epub-name:
	@ccecho "result" "$(EPUB_RESULT)"

.PHONY: mobi-name
mobi-name:
	@ccecho "result" "$(MOBI_RESULT)"

#---------------
# HTML
#
.PHONY: html-dir-name
html-dir-name:
	@ccecho "result" "$(HTML_DIR)"

#---------------
# MAN
#
.PHONY: man-dir-name
man-dir-name:
	@ccecho "result" "$(MAN_DIR)"

#---------------
# Packaging
#
.PHONY: package-src-name
package-src-name:
	@ccecho "result" "$(PACKAGE_SRC_RESULT)"

.PHONY: package-html-dir-name
package-html-dir-name:
	@ccecho "result" "$(PACKAGE_HTML_DIR)/"

.PHONY: package-pdf-dir-name
package-pdf-dir-name:
	@ccecho "result" "$(PACKAGE_PDF_DIR)/"

#---------------
# PDF
#
.PHONY: pdf-name
pdf-name:
	@ccecho "result" "$(PDF_RESULT)"

#---------------
# TEXT
#
.PHONY: text-name
text-name:
	@ccecho "result" "$(TXT_RESULT)"

#---------------
# WEBHELP
#
.PHONY: webhelp-dir-name
 webhelp-dir-name:
	@ccecho "result" "$(WEBHELP_DIR)"

.PHONY: dist-webhelp-name
dist-webhelp-name:
	@ccecho "result" "$(RESULT_DIR)/$(DOCNAME)$(LANGSTRING)-webhelp.tar.bz2"
