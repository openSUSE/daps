<?xml version="1.0" encoding="UTF-8"?>
<!--
  Purpose:
    Format our callouts as normal text, albeit with a pretty SVG frame around
    them.

  Author(s):  Stefan Knorr <sknorr@suse.de>

  Copyright:  2013, Stefan Knorr

-->
<!DOCTYPE xsl:stylesheet
[
  <!ENTITY % fonts SYSTEM "fonts.ent">
  <!ENTITY % colors SYSTEM "colors.ent">
  <!ENTITY % metrics SYSTEM "metrics.ent">
  %fonts;
  %colors;
  %metrics;
]>
<xsl:stylesheet version="1.0"
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:fo="http://www.w3.org/1999/XSL/Format">

<xsl:template name="callout-bug">
  <xsl:param name="conum" select='1'/>
  <xsl:variable name="instream-font-size" select="80"/>
  <xsl:variable name="font-metrics-ratio" select="&sans-numbers-ratio;"/>
    <!-- Most fonts's default figures are so-called "tabular figures," that is,
         monospaced figures. Don't use a font where that doesn't apply here. -->
  <xsl:variable name="width">
    <xsl:choose>
      <xsl:when test="$conum &lt; 10">100</xsl:when>
      <xsl:otherwise>
        <xsl:value-of
          select="100 + ((string-length(normalize-space($conum)) - 1) * $instream-font-size * $font-metrics-ratio)"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:variable>
  <xsl:variable name="color">
    <xsl:call-template name="dark-green"/>
  </xsl:variable>

  <fo:leader leader-pattern="space" leader-length="0.2em"/>

  <fo:instream-foreign-object content-height="0.9em" alignment-baseline="alphabetic"
    alignment-adjust="-0.15em">
    <svg:svg xmlns:svg="http://www.w3.org/2000/svg" height="100px" width="{$width}">
      <svg:rect height="100" rx="50" ry="50" x="0" y="0"
        fill="{$color}" stroke="none" width="{$width}"/>
      <svg:text y="{$instream-font-size - 1}" fill="&white;" font-family="{$sans-stack}"
        font-size="{$instream-font-size}" font-weight="600"
        text-anchor="middle">
        <xsl:attribute name="x">
          <xsl:choose>
            <xsl:when test="substring($conum,1,1) = 1">
              <xsl:value-of select="($width div 2) - 7"/>
            </xsl:when>
              <!-- Callout (1) as well as (10) and up will be horribly
                   off-center if they are not special-cased. -->
            <xsl:otherwise><xsl:value-of select="$width div 2"/></xsl:otherwise>
          </xsl:choose>
        </xsl:attribute><xsl:value-of select="$conum"/></svg:text>
    </svg:svg>
  </fo:instream-foreign-object>

  <fo:leader leader-pattern="space" leader-length="0.2em"/>
</xsl:template>


</xsl:stylesheet>
