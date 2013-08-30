<?xml version="1.0" encoding="UTF-8"?>
<!--
  Purpose:
    Restyle titles of chapters, etc.

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
<xsl:stylesheet  version="1.0"
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:fo="http://www.w3.org/1999/XSL/Format">

  <xsl:include href="article.titlepage.templates.xsl"/>
  <xsl:include href="appendix.titlepage.templates.xsl"/>
  <xsl:include href="bibliography.titlepage.templates.xsl"/>
  <xsl:include href="book.titlepage.templates.xsl"/>
  <xsl:include href="chapter.titlepage.templates.xsl"/>
  <xsl:include href="glossary.titlepage.templates.xsl"/>
  <xsl:include href="preface.titlepage.templates.xsl"/>
  

<!-- Set ==================================================== -->
<xsl:template match="title" mode="set.titlepage.recto.auto.mode">
  <fo:block xsl:use-attribute-sets="set.titlepage.recto.style"
    font-size="&ultra-large;pt" space-before="&columnfragment;mm"
    font-family="{$title.fontset}">
    <xsl:call-template name="division.title">
      <xsl:with-param name="node" select="ancestor-or-self::set[1]"/>
    </xsl:call-template>
  </fo:block>
</xsl:template>


<!--  TOC ==================================================== -->
<xsl:template name="table.of.contents.titlepage.recto">
    <fo:block
      xsl:use-attribute-sets="table.of.contents.titlepage.recto.style dark-green"
      space-before.minimum="1em" space-before.optimum="1.5em"
      space-before.maximum="2em"
      start-indent="{&column; + &gutter;}mm"
      font-weight="normal"
      font-family="{$title.fontset}">
      <xsl:choose>
        <xsl:when test="ancestor-or-self::article">
          <xsl:attribute name="space-after">.5em</xsl:attribute>
          <xsl:attribute name="font-size">&x-large;pt</xsl:attribute>
        </xsl:when>
        <xsl:when test="ancestor-or-self::book">
          <xsl:attribute name="space-after">3em</xsl:attribute>
          <xsl:attribute name="font-size">&super-large;pt</xsl:attribute>
        </xsl:when>
        <xsl:otherwise/>
      </xsl:choose>
      <xsl:call-template name="gentext">
        <xsl:with-param name="key" select="'TableofContents'"/>
      </xsl:call-template>
    </fo:block>
</xsl:template>


</xsl:stylesheet>
