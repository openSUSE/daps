<?xml version="1.0" encoding="UTF-8"?>
<!-- $Id: novdoc-profile.xsl 40777 2009-04-06 07:11:42Z toms $ -->
<!DOCTYPE xsl:stylesheet
[
  <!ENTITY db "http://docbook.sourceforge.net/release/xsl/current">
]>
<xsl:stylesheet
	version="1.0"
	xmlns:p="urn:x-suse:xmlns:docproperties"
	xmlns:exsl="http://exslt.org/common"
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	exclude-result-prefixes="p exsl">

<xsl:import href="base-profile.xsl"/>

<xsl:output method="xml"
            encoding="UTF-8"
            doctype-public="-//Novell//DTD NovDoc XML V1.0//EN"
            doctype-system="novdocx.dtd"/>


</xsl:stylesheet>
