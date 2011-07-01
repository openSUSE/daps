<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0">

<xsl:import href="rootid.xsl"/>
<xsl:output method="text"/>

<xsl:template match="*|text()"/>


<xsl:template name="rootid.process">
  <xsl:choose>
    <xsl:when test="key('id', $rootid)//index">Yes&#10;</xsl:when>
    <xsl:otherwise>No&#10;</xsl:otherwise>
  </xsl:choose>
</xsl:template>
 
<xsl:template name="normal.process">
  <xsl:choose>
    <xsl:when test="//index">Yes&#10;</xsl:when>
    <xsl:otherwise>No&#10;</xsl:otherwise>
  </xsl:choose>
</xsl:template>
 
</xsl:stylesheet>
