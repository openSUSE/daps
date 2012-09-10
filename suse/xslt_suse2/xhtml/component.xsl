<?xml version="1.0" encoding="UTF-8"?>
<!-- 
  Purpose:
     Splitting chapter-wise titles into number and title

   Author(s):    Thomas Schraitle <toms@opensuse.org>
   Copyright: 2012, Thomas Schraitle

-->
<xsl:stylesheet  version="1.0"
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:exsl="http://exslt.org/common"
  xmlns="http://www.w3.org/1999/xhtml"
  exclude-result-prefixes="exsl">


  <xsl:template name="component.title">
   <xsl:param name="node" select="."/>
   <xsl:param name="wrapper" select="concat('h', $level+1)"/> 

  <!-- This handles the case where a component (bibliography, for example)
       occurs inside a section; will we need parameters for this? -->

  <!-- This "level" is a section level.  To compute <h> level, add 1. -->
  <xsl:variable name="level">
    <xsl:choose>
      <!-- chapters and other book children should get <h1> -->
      <xsl:when test="$node/parent::book">0</xsl:when>
      <xsl:when test="ancestor::section">
        <xsl:value-of select="count(ancestor::section)+1"/>
      </xsl:when>
      <xsl:when test="ancestor::sect5">6</xsl:when>
      <xsl:when test="ancestor::sect4">5</xsl:when>
      <xsl:when test="ancestor::sect3">4</xsl:when>
      <xsl:when test="ancestor::sect2">3</xsl:when>
      <xsl:when test="ancestor::sect1">2</xsl:when>
      <xsl:otherwise>1</xsl:otherwise>
    </xsl:choose>
  </xsl:variable>

  <xsl:element name="{$wrapper}" namespace="http://www.w3.org/1999/xhtml">
    <xsl:attribute name="class">title</xsl:attribute>
    <xsl:call-template name="id.attribute"/>
    <xsl:call-template name="anchor">
      <xsl:with-param name="node" select="$node"/>
      <xsl:with-param name="conditional" select="0"/>
    </xsl:call-template>
    <xsl:call-template name="create.header.title">
      <xsl:with-param name="node" select=".."/>
    </xsl:call-template>
  </xsl:element>
</xsl:template>

</xsl:stylesheet>