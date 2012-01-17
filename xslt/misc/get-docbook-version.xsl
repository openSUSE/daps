<?xml version="1.0" encoding="UTF-8"?>
<!-- 
  Checks DocBook version and outputs 4 or 5
-->
<xsl:stylesheet version="1.0"
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
  
  <xsl:output method="text"/>
  
  <xsl:template match="/">
    <xsl:choose>
      <xsl:when test="namespace-uri(*) ='http://docbook.org/ns/docbook'">5</xsl:when>
      <xsl:otherwise>4</xsl:otherwise>
    </xsl:choose>
  </xsl:template> 
</xsl:stylesheet>