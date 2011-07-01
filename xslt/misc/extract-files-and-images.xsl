<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  version="1.0">
 
  <xsl:import href="rootid.xsl"/>
  
  <xsl:output method="text" indent="no"/>
  

  <!-- xml or image? img=images files, xml=XML files-->
  <xsl:param name="xml.or.img" select="'xml'"/>


  <!-- Separator between each filename: -->
  <xsl:param name="separator">
    <xsl:text> </xsl:text>
  </xsl:param>
  
  <xsl:template match="text()"/>
  
  
  <xsl:template match="file">
    <xsl:if test="$xml.or.img = 'xml'">
      <xsl:value-of select="@href"/>
      <xsl:value-of select="$separator"/>
    </xsl:if>
    <xsl:apply-templates />
  </xsl:template>
  
  <xsl:template match="image">
    <xsl:if test="$xml.or.img = 'img'">
      <xsl:value-of select="@fileref"/>
      <xsl:value-of select="$separator"/>
    </xsl:if>
  </xsl:template>
  
</xsl:stylesheet>