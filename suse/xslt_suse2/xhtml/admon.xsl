<?xml version="1.0" encoding="UTF-8"?>
<!-- 
  Purpose:
     Changing structure of graphical admonitions

   Author(s):    Thomas Schraitle <toms@opensuse.org>
   Copyright: 2012, Thomas Schraitle

-->
<xsl:stylesheet version="1.0"
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:exsl="http://exslt.org/common"
  xmlns="http://www.w3.org/1999/xhtml"
  exclude-result-prefixes="exsl">
  
  <xsl:template name="graphical.admonition">
    <xsl:variable name="admon.type">
      <xsl:choose>
        <xsl:when test="local-name(.)='note'">Note</xsl:when>
        <xsl:when test="local-name(.)='warning'">Warning</xsl:when>
        <xsl:when test="local-name(.)='caution'">Caution</xsl:when>
        <xsl:when test="local-name(.)='tip'">Tip</xsl:when>
        <xsl:when test="local-name(.)='important'">Important</xsl:when>
        <xsl:otherwise>Note</xsl:otherwise>
      </xsl:choose>
    </xsl:variable>
    <xsl:variable name="alt">
      <xsl:call-template name="gentext">
        <xsl:with-param name="key" select="$admon.type"/>
      </xsl:call-template>
    </xsl:variable>
    
    <div>
      <xsl:call-template name="generate.class.attribute">
        <xsl:with-param name="class">admonition <xsl:value-of select="local-name()"/></xsl:with-param>
      </xsl:call-template>
      <img class="symbol" alt="{$alt}" title="{$admon.type}">
        <xsl:attribute name="src">
          <xsl:call-template name="admon.graphic"/>
        </xsl:attribute>
      </img>
      <h6>
        <xsl:call-template name="anchor"/>
        <xsl:if test="$admon.textlabel != 0 or title or info/title">
            <xsl:apply-templates select="." mode="object.title.markup"/>
        </xsl:if>
      </h6>
      <xsl:apply-templates/>
    </div>
  </xsl:template>
  
  <xsl:template name="admon.graphic">
  <xsl:param name="node" select="."/>
  <xsl:value-of select="$admon.graphics.path"/>
  <xsl:text>icon-</xsl:text>
  <xsl:choose>
    <xsl:when test="local-name($node)='note'">note</xsl:when>
    <xsl:when test="local-name($node)='warning'">warning</xsl:when>
    <xsl:when test="local-name($node)='caution'">caution</xsl:when>
    <xsl:when test="local-name($node)='tip'">tip</xsl:when>
    <xsl:when test="local-name($node)='important'">important</xsl:when>
    <xsl:otherwise>note</xsl:otherwise>
  </xsl:choose>
  <xsl:value-of select="$admon.graphics.extension"/>
</xsl:template>

</xsl:stylesheet>