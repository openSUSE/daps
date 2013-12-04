<?xml version="1.0" encoding="UTF-8"?>
<!-- $Id: fonts.xsl 29928 2008-04-01 08:28:10Z toms $ -->
<xsl:stylesheet version="1.0"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:fo="http://www.w3.org/1999/XSL/Format"
>

<!--
   The fonts are from the RPM package freefont
-->
<xsl:param name="body.font.master">10.5</xsl:param>

<xsl:param name="body.font.family">
  <xsl:call-template name="genfont">
    <xsl:with-param name="font-family">body.font.family</xsl:with-param>
  </xsl:call-template>
</xsl:param>
  
<xsl:param name="sans.font.family">
  <xsl:call-template name="genfont">
    <xsl:with-param name="font-family">sans.font.family</xsl:with-param>
  </xsl:call-template>
</xsl:param>

<xsl:param name="monospace.font.family">
  <xsl:call-template name="genfont">
    <xsl:with-param name="font-family">monospace.font.family</xsl:with-param>
  </xsl:call-template>
</xsl:param>

<xsl:param name="title.font.family" select="$sans.font.family"/>
<!--
<xsl:param name="symbol.font.family">
  <xsl:call-template name="genfont">
    <xsl:with-param name="font-family">symbol.font.family</xsl:with-param>
  </xsl:call-template>
</xsl:param>
-->


<xsl:param name="callout.unicode.font">
  <xsl:call-template name="genfont">
    <xsl:with-param name="font-family">callout.unicode.font</xsl:with-param>
  </xsl:call-template>
</xsl:param>


<!-- Extracts a font list from language files
     Needs the parameter font-family to look up in table.
-->
<xsl:template name="genfont">
  <xsl:param name="font-family"/>
  <xsl:variable name="formatter">
    <xsl:choose>
      <xsl:when test="$fop1.extensions != 0">fop1</xsl:when>
      <xsl:when test="$xep.extensions != 0">xep</xsl:when>
      <xsl:when test="$axf.extensions != 0">axf</xsl:when>
      <xsl:otherwise/>
    </xsl:choose>
    <xsl:text>.</xsl:text>
  </xsl:variable>  

  <!-- 
    <xsl:message>genfont (<xsl:value-of
    select="concat($formatter,$font-family)"/>)
    lang:        <xsl:call-template name="l10n.language">
    <xsl:with-param name="target" select="(/* | key('id', $rootid))[last()]"/>
    </xsl:call-template>
    formatter:   "<xsl:value-of select="$formatter"/>"
    font-family: "<xsl:value-of select="$font-family"/>"
    </xsl:message>
  -->
  
    <xsl:call-template name="gentext">
      <!--<xsl:with-param name="lang" 
                        select="(/*/@lang |
                                 key('id', $rootid)/ancestor-or-self::*/@lang
                                 )[last()]"/>
        -->
      <xsl:with-param name="lang">
        <xsl:call-template name="l10n.language">
          <xsl:with-param name="target"
            select="(/* | key('id', $rootid))[last()]"/>
        </xsl:call-template>
      </xsl:with-param>
      <xsl:with-param name="key"
        select="concat($formatter, $font-family)"/>
    </xsl:call-template>
</xsl:template>

</xsl:stylesheet>