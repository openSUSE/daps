<?xml version="1.0" encoding="UTF-8"?>
<!--
   Purpose:
     Prints all used referenced images or XML files
     
   Parameters:
     * xml.or.img (default: 'xml')
       xml or image? img=images files, xml=XML files
     * separator (default: ' ')
       Separator between each filename
       
   Input:
     Output from get-all-used-files.xsl
     
   Output:
     List of filenames separated by $separator
   
   Author:    Thomas Schraitle <toms@opensuse.org>
   Copyright: 2012, Thomas Schraitle
   
-->

<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  version="1.0">
  <xsl:import href="rootid.xsl"/>  
  <xsl:output method="text" indent="no"/>  

  <xsl:param name="xml.or.img" select="'xml'"/>
  <xsl:param name="separator">
    <xsl:text> </xsl:text>
  </xsl:param>
  
  <xsl:template match="text()"/>
  
  
  <xsl:template match="/">
    <xsl:call-template name="process.rootid.node"/>
  </xsl:template>
  
  
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