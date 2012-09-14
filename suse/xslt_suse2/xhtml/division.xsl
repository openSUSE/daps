<?xml version="1.0" encoding="UTF-8"?>
<!-- 
  Purpose:
     Splitting part-wise titles into number and title

   Author(s): Thomas Schraitle <toms@opensuse.org>
   Copyright: 2012, Thomas Schraitle

-->
<xsl:stylesheet version="1.0"
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns="http://www.w3.org/1999/xhtml">
  
  
  
  <xsl:template name="division.title">
    <xsl:param name="node" select="."/>
    
    <h1 class="title">
      <xsl:call-template name="anchor">
        <xsl:with-param name="node" select="$node"/>
        <xsl:with-param name="conditional" select="0"/>
      </xsl:call-template>
      <xsl:call-template name="create.header.title">
        <xsl:with-param name="node" select="$node"/>
      </xsl:call-template>
      <!--<xsl:apply-templates select="$node" mode="object.title.markup">
        <xsl:with-param name="allow-anchors" select="1"/>
      </xsl:apply-templates>-->
    </h1>
  </xsl:template>
  
</xsl:stylesheet>