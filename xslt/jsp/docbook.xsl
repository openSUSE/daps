<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0"
  xmlns="http://www.w3.org/1999/xhtml"
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
  <!-- 
  IMPORTANT:
  If you want to structure the JSP output, use the dbjsp processing
  instruction like the HTML stylesheets recognize dbhtml.
  
  DO NOT USE A TRAILING SLASH!
  
  This is ok:  <?dbjsp dir="foo/en-US" ?>
  This is not: <?dbjsp dir="foo/en-US/" ?>
  -->
  
  <xsl:import href="http://docbook.sourceforge.net/release/xsl/current/xhtml/docbook.xsl"/>
  
  <xsl:output method="xml" 
    encoding="UTF-8" 
    indent="no"
    omit-xml-declaration="yes"
    doctype-public="-//W3C//DTD XHTML 1.0 Strict//EN" 
    doctype-system="http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd"/>
  
  <xsl:include href="param.xsl"/>
  <xsl:include href="pi.xsl"/>
  <xsl:include href="permalinks.xsl"/>
  <xsl:include href="sections.xsl"/>
  
  <xsl:template name="user.preroot">
    <xsl:if test="$generate.jsp.marker != 0">
      <xsl:text disable-output-escaping="yes"
        >&lt;%@ page contentType="text/html; charset=UTF-8"%>&#10;</xsl:text>
      <xsl:text disable-output-escaping="yes"
        >&lt;?xml version="1.0" encoding="</xsl:text>
      <xsl:value-of select="$chunker.output.encoding"/>
      <xsl:text disable-output-escaping="yes">" standalone="no"?>&#10;</xsl:text>
    </xsl:if>
  </xsl:template>


</xsl:stylesheet>
