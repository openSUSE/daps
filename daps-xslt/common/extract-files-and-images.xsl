<?xml version="1.0" encoding="UTF-8"?>
<!--
   Purpose:
     Prints all used referenced images or XML files
     With rootid parameter, the nearest <div> with a href attribute is processed.
     
   Parameters:
     * xml.or.img (default: 'xml')
       xml or image? img=images files, xml=XML files
     * separator (default: ' ')
       Separator between each filename
     * show.first (default: 0)
       If set to 1, only the first filename will be printed 
       
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

  <xsl:param name="show.first" select="0"/>
  <xsl:param name="xml.or.img" select="'xml'"/>
  <xsl:param name="separator">
    <xsl:text> </xsl:text>
  </xsl:param>
  
  <xsl:template match="text()"/>
  
  
  <xsl:template match="/">
    <xsl:call-template name="process.rootid.node"/>
    <xsl:text>&#10;</xsl:text>
  </xsl:template>
  
  <xsl:template name="rootid.process">
    <xsl:variable name="node" select="key('id',$rootid)"/>
    <xsl:variable name="anc.href" select="$node/ancestor-or-self::*[@href]"/>
    <!--<xsl:message>#### <xsl:value-of select="$anc.href[last()]/@href"/></xsl:message>-->
    <!-- Use only the first div element in reversed order which is our nearest div -->
    <xsl:apply-templates select="$anc.href[last()]"/>
  </xsl:template>
  
  <xsl:template match="div">
    <xsl:if test="$xml.or.img = 'xml'">
      <xsl:if test="@href">
        <xsl:value-of select="@href"/>
        <!-- We only need the separator, when we are interested in all files -->
        <xsl:if test="$show.first = 0">
          <xsl:value-of select="$separator"/>
        </xsl:if>
      </xsl:if>
    </xsl:if>
    <xsl:if test="$show.first = 0">
      <xsl:apply-templates />
    </xsl:if>
  </xsl:template>
  
  <xsl:template match="image">
    <xsl:if test="$xml.or.img = 'img'">
      <xsl:value-of select="@fileref"/>
      <xsl:value-of select="$separator"/>
    </xsl:if>
  </xsl:template>
  
</xsl:stylesheet>
