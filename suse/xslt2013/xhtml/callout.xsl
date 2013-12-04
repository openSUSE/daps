<?xml version="1.0" encoding="UTF-8"?>
<!-- 
   Purpose:
     Create callout "bugs"
     
   Author:    Thomas Schraitle <toms@opensuse.org>
   Copyright: 2012, Thomas Schraitle
     
-->
<xsl:stylesheet version="1.0"  
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:exsl="http://exslt.org/common"
    xmlns="http://www.w3.org/1999/xhtml"
    xmlns:t="http://nwalsh.com/docbook/xsl/template/1.0"
    xmlns:l="http://docbook.sourceforge.net/xmlns/l10n/1.0"
    exclude-result-prefixes="exsl l t">
  
  
  <xsl:template name="callout-bug">
  <xsl:param name="conum" select="1"/>
  
  <xsl:choose>
    <xsl:when test="$callout.graphics != 0 and $conum &lt;= $callout.graphics.number.limit">
      <!-- Added span to make valid in XHTML 1 -->
      <span><img src="{$callout.graphics.path}{$conum}{$callout.graphics.extension}" alt="{$conum}" border="0"/></span>
    </xsl:when>
    <xsl:when test="$callout.unicode != 0 and $conum &lt;= $callout.unicode.number.limit">
      <xsl:choose>
        <xsl:when test="$callout.unicode.start.character = 10102">
          <xsl:choose>
            <xsl:when test="$conum = 1">&#10102;</xsl:when>
            <xsl:when test="$conum = 2">&#10103;</xsl:when>
            <xsl:when test="$conum = 3">&#10104;</xsl:when>
            <xsl:when test="$conum = 4">&#10105;</xsl:when>
            <xsl:when test="$conum = 5">&#10106;</xsl:when>
            <xsl:when test="$conum = 6">&#10107;</xsl:when>
            <xsl:when test="$conum = 7">&#10108;</xsl:when>
            <xsl:when test="$conum = 8">&#10109;</xsl:when>
            <xsl:when test="$conum = 9">&#10110;</xsl:when>
            <xsl:when test="$conum = 10">&#10111;</xsl:when>
          </xsl:choose>
        </xsl:when>
        <xsl:otherwise>
          <xsl:message>
            <xsl:text>Don't know how to generate Unicode callouts </xsl:text>
            <xsl:text>when $callout.unicode.start.character is </xsl:text>
            <xsl:value-of select="$callout.unicode.start.character"/>
          </xsl:message>
          <xsl:text>(</xsl:text>
          <xsl:value-of select="$conum"/>
          <xsl:text>)</xsl:text>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:when>
    <xsl:otherwise>
      <span class="callout">
        <xsl:value-of select="$conum"/>
      </span>
    </xsl:otherwise>
  </xsl:choose>
</xsl:template>

</xsl:stylesheet>