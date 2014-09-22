<?xml version="1.0" encoding="UTF-8"?>
<!--
  Purpose:
    Restyle bibliography page

  Author(s):  Stefan Knorr <sknorr@suse.de>,
              Thomas Schraitle <toms@opensuse.org>

  Copyright:  2013, Stefan Knorr, Thomas Schraitle

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

  <!-- Bibliography =============================================== -->
  <xsl:template name="bibliography.titlepage.recto">
    <fo:block
      xsl:use-attribute-sets="bibliography.titlepage.recto.style"
      font-size="&super-large;pt" font-family="{$title.fontset}">
      <xsl:attribute name="margin-{$start-border}">
        <xsl:value-of select="$title.margin.left"/>
      </xsl:attribute>
      <xsl:call-template name="component.title">
        <xsl:with-param name="node" select="ancestor-or-self::bibliography[1]"/>
      </xsl:call-template>
    </fo:block>
    <xsl:choose>
      <xsl:when test="bibliographyinfo/subtitle">
        <xsl:apply-templates mode="bibliography.titlepage.recto.auto.mode" select="bibliographyinfo/subtitle"/>
      </xsl:when>
      <xsl:when test="docinfo/subtitle">
        <xsl:apply-templates mode="bibliography.titlepage.recto.auto.mode" select="docinfo/subtitle"/>
      </xsl:when>
      <xsl:when test="info/subtitle">
        <xsl:apply-templates mode="bibliography.titlepage.recto.auto.mode" select="info/subtitle"/>
      </xsl:when>
      <xsl:when test="subtitle">
        <xsl:apply-templates mode="bibliography.titlepage.recto.auto.mode" select="subtitle"/>
      </xsl:when>
    </xsl:choose>

    <xsl:apply-templates mode="bibliography.titlepage.recto.auto.mode" select="bibliographyinfo/itermset"/>
    <xsl:apply-templates mode="bibliography.titlepage.recto.auto.mode" select="docinfo/itermset"/>
    <xsl:apply-templates mode="bibliography.titlepage.recto.auto.mode" select="info/itermset"/>
  </xsl:template>

</xsl:stylesheet>
