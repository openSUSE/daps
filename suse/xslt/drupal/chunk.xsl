<?xml version="1.0" encoding="UTF-8"?>
<!-- 
  
  Run it as follows:

  $ xsltproc -xinclude chunk.xsl YOUR_XML_FILE.xml

-->

<!DOCTYPE xsl:stylesheet
[
  <!ENTITY www "http://docbook.sourceforge.net/release/xsl/current/xhtml">
]>
<xsl:stylesheet version="1.0"
  xmlns:exsl="http://exslt.org/common"
  xmlns="http://www.w3.org/1999/xhtml"
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  exclude-result-prefixes="exsl">
  
  <xsl:import href="&www;/chunk.xsl"/>
  <!--<xsl:import href="&www;/chunk-common.xsl"/>
  <xsl:include href="&www;/manifest.xsl"/>
  <xsl:include href="&www;/chunk-code.xsl"/>-->

  <xsl:include href="param.xsl"/>
  
  <xsl:template name="chunk-element-content">
  <xsl:param name="prev"/>
  <xsl:param name="next"/>
  <xsl:param name="nav.context"/>
  <xsl:param name="content">
    <xsl:apply-imports/>
  </xsl:param>

  <!--<xsl:message>chunk-element-content: <xsl:value-of select="local-name()"/></xsl:message>-->
  <xsl:copy-of select="$content"/>
</xsl:template>

  
</xsl:stylesheet>