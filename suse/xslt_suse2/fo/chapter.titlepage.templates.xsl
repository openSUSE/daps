<?xml version="1.0" encoding="UTF-8"?>
<!--
  Purpose:
    Restyle chapter titlepage

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
  
  <!-- Chapter ==================================================== -->
  <xsl:template match="title" mode="chapter.titlepage.recto.auto.mode">
    <fo:block
      xsl:use-attribute-sets="chapter.titlepage.recto.style"
      font-size="&super-large;pt">
      <xsl:call-template name="component.title">
        <xsl:with-param name="node" select="ancestor-or-self::chapter[1]"/>
      </xsl:call-template>
    </fo:block>
  </xsl:template>
  
  <xsl:template match="subtitle" mode="chapter.titlepage.recto.auto.mode">
    <fo:block
      xsl:use-attribute-sets="chapter.titlepage.recto.style italicized"
      font-size="&large;pt" font-family="{$title.fontset}">
      <xsl:apply-templates select="." mode="chapter.titlepage.recto.mode"/>
    </fo:block>
  </xsl:template>
  
  <xsl:template match="author|corpauthor|authorgroup" mode="chapter.titlepage.recto.auto.mode">
    <fo:block
      xsl:use-attribute-sets="chapter.titlepage.recto.style"
      space-after="0.5em" font-size="&small;pt" font-family="{$title.fontset}">
      <xsl:apply-templates select="." mode="chapter.titlepage.recto.mode"/>
    </fo:block>
  </xsl:template>
  
  <xsl:template match="othercredit" mode="chapter.titlepage.recto.auto.mode">
    <fo:block
      xsl:use-attribute-sets="chapter.titlepage.recto.style" font-size="&small;pt"
      font-family="{$title.fontset}">
      <xsl:apply-templates select="." mode="chapter.titlepage.recto.mode"/>
    </fo:block>
  </xsl:template>
</xsl:stylesheet>