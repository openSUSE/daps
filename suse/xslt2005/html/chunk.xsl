<?xml version="1.0" encoding="ISO-8859-1"?>
<!-- $Id: chunk.xsl 10322 2006-06-27 08:17:07Z toms $ -->
<!DOCTYPE xsl:stylesheet
[
  <!ENTITY www "http://docbook.sourceforge.net/release/xsl/current/html">
]>
<xsl:stylesheet
    version="1.0"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:exsl="http://exslt.org/common"
    xmlns:t="http://nwalsh.com/docbook/xsl/template/1.0"
    xmlns:l="http://docbook.sourceforge.net/xmlns/l10n/1.0"
    exclude-result-prefixes="exsl l t">



<xsl:import href="docbook.xsl"/> 
<xsl:import href="&www;/chunk-common.xsl"/>
<xsl:include href="&www;/manifest.xsl"/>
<xsl:include href="&www;/chunk-code.xsl"/>

<xsl:include href="navig.header.footer.xsl"/><!-- include it again to avoid import precedence problems -->
  
</xsl:stylesheet>
