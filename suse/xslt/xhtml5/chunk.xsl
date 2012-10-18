<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE xsl:stylesheet
[
  <!ENTITY www "http://docbook.sourceforge.net/release/xsl/current/">
]>
<xsl:stylesheet version="1.0"
  xmlns="http://www.w3.org/1999/xhtml"
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
  
  <xsl:import href="docbook.xsl"/>
  <xsl:import href="&www;/xhtml/chunk-common.xsl"/>
  <xsl:include href="&www;/xhtml/chunk-code.xsl"/>
  
  <xsl:include href="&www;/xhtml5/html5-chunk-mods.xsl"/>
</xsl:stylesheet>