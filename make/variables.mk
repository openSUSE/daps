# DAPSROOT must be present.
variables	= "DAPSROOT='$(DAPSROOT)'"
# XML_CATALOG_FILES may be from $DAPSROOT or unset (system)
ifdef XML_CATALOG_FILES
variables	+= "XML_CATALOG_FILES='$(XML_CATALOG_FILES)'"
endif
ifdef FORMATTER
variables	+= "FORMATTER='$(FORMATTER)'"
endif
ifdef FOP_CONFIG
variables	+= "FOP_CONFIG='$(FOP_CONFIG)'"
endif
ifdef FOP_OPTIONS
variables	+= "FOP_OPTIONS='$(FOP_OPTIONS)'"
endif
ifdef FOP_WRAPPER
variables	+= "FOP_WRAPPER='$(FOP_WRAPPER)'"
endif
ifdef COMMENTS
variables	+= "COMMENTS='$(COMMENTS)'"
endif
ifdef REMARKS
variables	+= "REMARKS='$(REMARKS)'"
endif
ifdef PROFOS
variables	+= "PROFOS='$(PROFOS)'"
endif
ifdef PROFARCH
variables	+= "PROFARCH='$(PROFARCH)'"
endif
ifdef PROFCONDITION
variables	+= "PROFCONDITION='$(PROFCONDITION)'"
endif
ifdef PROFILE_URN 
variables	+= "PROFILE_URN='$(PROFILE_URN)'"
endif
ifdef STYLEFO
variables	+= "STYLEFO='$(STYLEFO)'"
endif
ifdef STYLEH
variables	+= "STYLEH='$(STYLEH)'"
endif
ifdef STYLEJ
variables       += "STYLEJ='$(STYLEJ)'"
endif
ifdef ROOTID
variables	+= "ROOTID='$(ROOTID)'"
endif
ifdef PDFNAME
variables	+= "PDFNAME='$(PDFNAME)'"
endif
ifdef FOP
variables	+= "FOP='$(FOP)'"
endif
ifdef LAYOUT
variables	+= "LAYOUT='$(LAYOUT)'"
endif
ifdef BOOK
variables	+= "BOOK='$(BOOK)'"
endif
ifdef XMLFORMAT_CONF
variables	+= "XMLFORMAT_CONF='$(XMLFORMAT_CONF)'"
endif
#ifdef DOC_RELEASE
#variables	+= "DOC_RELEASE='$(DOC_RELEASE)'"
#endif
ifdef PATH
variables	+= "PATH='$(PATH)'"
endif
#ifdef COMMON
#variables	+= "COMMON='$(COMMON)'"
#endif
ifdef EXIFTOOL
variables	+= "EXIFTOOL='$(EXIFTOOL)'"
endif
ifdef MAIN
variables	+= "MAIN='$(MAIN)'"
endif
ifdef PRODUCTNAME
variables	+= "PRODUCTNAME='$(PRODUCTNAME)'"
endif
ifdef PRODUCTNAMEREG
variables	+= "PRODUCTNAMEREG='$(PRODUCTNAMEREG)'"
endif
ifdef PRODUCTNUMBER
variables	+= "PRODUCTNUMBER='$(PRODUCTNUMBER)'"
endif
ifdef DISTVER
variables	+= "DISTVER='$(DISTVER)'"
endif
ifdef DB2EPUB
variables	+= "DB2EPUB='$(DB2EPUB)'"
endif
ifdef XEP_CONFIG
variables	+= "XEP_CONFIG='$(XEP_CONFIG)'"
endif
ifdef XEP_OPTIONS
variables	+= "XEP_OPTIONS='$(XEP_OPTIONS)'"
endif
ifdef XEP_WRAPPER
variables	+= "XEP_WRAPPER='$(XEP_WRAPPER)'"
endif

# print out the variables that are used from the environment
.PHONY: environment
environment:
	@echo $(variables)
