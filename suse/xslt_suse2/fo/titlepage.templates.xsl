<?xml version="1.0" encoding="UTF-8"?>
<!--
  Purpose:
    Restyle titles of chapters, etc.

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
<xsl:stylesheet  version="1.0"
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:fo="http://www.w3.org/1999/XSL/Format">

<xsl:template match="title" mode="chapter.titlepage.recto.auto.mode">
  <fo:block xmlns:fo="http://www.w3.org/1999/XSL/Format"
    xsl:use-attribute-sets="chapter.titlepage.recto.style"
    font-size="&super-large;pt">
    <xsl:call-template name="component.title">
      <xsl:with-param name="node" select="ancestor-or-self::chapter[1]"/>
    </xsl:call-template>
  </fo:block>
</xsl:template>

<xsl:template match="subtitle" mode="chapter.titlepage.recto.auto.mode">
  <fo:block xmlns:fo="http://www.w3.org/1999/XSL/Format"
    xsl:use-attribute-sets="chapter.titlepage.recto.style italicized"
    font-size="&large;pt" font-family="{$title.fontset}">
    <xsl:apply-templates select="." mode="chapter.titlepage.recto.mode"/>
  </fo:block>
</xsl:template>

<xsl:template match="corpauthor" mode="chapter.titlepage.recto.auto.mode">
  <fo:block xmlns:fo="http://www.w3.org/1999/XSL/Format"
    xsl:use-attribute-sets="chapter.titlepage.recto.style"
    space-after="0.5em" font-size="&small;pt" font-family="{$title.fontset}">
    <xsl:apply-templates select="." mode="chapter.titlepage.recto.mode"/>
  </fo:block>
</xsl:template>

<xsl:template match="authorgroup" mode="chapter.titlepage.recto.auto.mode">
  <fo:block xmlns:fo="http://www.w3.org/1999/XSL/Format"
    xsl:use-attribute-sets="chapter.titlepage.recto.style"
    space-before="0.5em" space-after="0.5em" font-size="&small;pt"
    font-family="{$title.fontset}">
    <xsl:apply-templates select="." mode="chapter.titlepage.recto.mode"/>
  </fo:block>
</xsl:template>

<xsl:template match="author" mode="chapter.titlepage.recto.auto.mode">
  <fo:block xmlns:fo="http://www.w3.org/1999/XSL/Format"
    xsl:use-attribute-sets="chapter.titlepage.recto.style"
    space-before="0.5em" space-after="0.5em" font-size="&small;pt"
    font-family="{$title.fontset}">
    <xsl:apply-templates select="." mode="chapter.titlepage.recto.mode"/>
  </fo:block>
</xsl:template>

<xsl:template match="othercredit" mode="chapter.titlepage.recto.auto.mode">
  <fo:block xmlns:fo="http://www.w3.org/1999/XSL/Format"
    xsl:use-attribute-sets="chapter.titlepage.recto.style" font-size="&small;pt"
    font-family="{$title.fontset}">
    <xsl:apply-templates select="." mode="chapter.titlepage.recto.mode"/>
  </fo:block>
</xsl:template>


<xsl:template match="title" mode="appendix.titlepage.recto.auto.mode">
  <fo:block xmlns:fo="http://www.w3.org/1999/XSL/Format"
    xsl:use-attribute-sets="appendix.titlepage.recto.style"
    margin-left="{$title.margin.left}" font-size="&super-large;pt"
    font-family="{$title.fontset}">
    <xsl:call-template name="component.title">
      <xsl:with-param name="node" select="ancestor-or-self::appendix[1]"/>
    </xsl:call-template>
  </fo:block>
</xsl:template>

<xsl:template match="subtitle" mode="appendix.titlepage.recto.auto.mode">
  <fo:block xmlns:fo="http://www.w3.org/1999/XSL/Format"
    xsl:use-attribute-sets="appendix.titlepage.recto.style"
      font-family="{$title.fontset}" font-size="&small;pt">
    <xsl:apply-templates select="." mode="appendix.titlepage.recto.mode"/>
  </fo:block>
</xsl:template>

<xsl:template match="corpauthor" mode="appendix.titlepage.recto.auto.mode">
  <fo:block xmlns:fo="http://www.w3.org/1999/XSL/Format"
    xsl:use-attribute-sets="appendix.titlepage.recto.style"
    font-family="{$title.fontset}" font-size="&small;pt">
    <xsl:apply-templates select="." mode="appendix.titlepage.recto.mode"/>
  </fo:block>
</xsl:template>

<xsl:template match="authorgroup" mode="appendix.titlepage.recto.auto.mode">
  <fo:block xmlns:fo="http://www.w3.org/1999/XSL/Format"
    xsl:use-attribute-sets="appendix.titlepage.recto.style"
    font-family="{$title.fontset}" font-size="&small;pt">
    <xsl:apply-templates select="." mode="appendix.titlepage.recto.mode"/>
  </fo:block>
</xsl:template>

<xsl:template match="author" mode="appendix.titlepage.recto.auto.mode">
  <fo:block xmlns:fo="http://www.w3.org/1999/XSL/Format"
    xsl:use-attribute-sets="appendix.titlepage.recto.style"
    font-family="{$title.fontset}" font-size="&small;pt">
    <xsl:apply-templates select="." mode="appendix.titlepage.recto.mode"/>
  </fo:block>
</xsl:template>

<xsl:template match="othercredit" mode="appendix.titlepage.recto.auto.mode">
  <fo:block xmlns:fo="http://www.w3.org/1999/XSL/Format"
    xsl:use-attribute-sets="appendix.titlepage.recto.style"
    font-family="{$title.fontset}" font-size="&small;pt">
    <xsl:apply-templates select="." mode="appendix.titlepage.recto.mode"/>
  </fo:block>
</xsl:template>

<xsl:template name="glossary.titlepage.recto">
  <fo:block xmlns:fo="http://www.w3.org/1999/XSL/Format"
    xsl:use-attribute-sets="glossary.titlepage.recto.style"
    margin-left="{$title.margin.left}" font-size="&super-large;pt"
    font-family="{$title.fontset}">
    <xsl:call-template name="component.title">
      <xsl:with-param name="node" select="ancestor-or-self::glossary[1]"/>
    </xsl:call-template>
  </fo:block>
  <xsl:choose>
    <xsl:when test="glossaryinfo/subtitle">
      <xsl:apply-templates mode="glossary.titlepage.recto.auto.mode" select="glossaryinfo/subtitle"/>
    </xsl:when>
    <xsl:when test="docinfo/subtitle">
      <xsl:apply-templates mode="glossary.titlepage.recto.auto.mode" select="docinfo/subtitle"/>
    </xsl:when>
    <xsl:when test="info/subtitle">
      <xsl:apply-templates mode="glossary.titlepage.recto.auto.mode" select="info/subtitle"/>
    </xsl:when>
    <xsl:when test="subtitle">
      <xsl:apply-templates mode="glossary.titlepage.recto.auto.mode" select="subtitle"/>
    </xsl:when>
  </xsl:choose>

  <xsl:apply-templates mode="glossary.titlepage.recto.auto.mode" select="glossaryinfo/itermset"/>
  <xsl:apply-templates mode="glossary.titlepage.recto.auto.mode" select="docinfo/itermset"/>
  <xsl:apply-templates mode="glossary.titlepage.recto.auto.mode" select="info/itermset"/>
</xsl:template>

<xsl:template match="title" mode="glossdiv.titlepage.recto.auto.mode">
  <fo:block xmlns:fo="http://www.w3.org/1999/XSL/Format"
    xsl:use-attribute-sets="glossdiv.titlepage.recto.style"
    margin-left="{$title.margin.left}" font-size="&xxx-large;pt"
    font-family="{$title.fontset}">
    <xsl:call-template name="component.title">
      <xsl:with-param name="node" select="ancestor-or-self::glossdiv[1]"/>
    </xsl:call-template>
  </fo:block>
</xsl:template>

<xsl:template name="preface.titlepage.recto">
  <fo:block xmlns:fo="http://www.w3.org/1999/XSL/Format"
    xsl:use-attribute-sets="preface.titlepage.recto.style"
    margin-left="{$title.margin.left}" font-size="&super-large;pt"
    font-family="{$title.fontset}">
    <xsl:call-template name="component.title">
      <xsl:with-param name="node" select="ancestor-or-self::preface[1]"/>
    </xsl:call-template>
  </fo:block>
  <xsl:choose>
    <xsl:when test="prefaceinfo/subtitle">
      <xsl:apply-templates mode="preface.titlepage.recto.auto.mode" select="prefaceinfo/subtitle"/>
    </xsl:when>
    <xsl:when test="docinfo/subtitle">
      <xsl:apply-templates mode="preface.titlepage.recto.auto.mode" select="docinfo/subtitle"/>
    </xsl:when>
    <xsl:when test="info/subtitle">
      <xsl:apply-templates mode="preface.titlepage.recto.auto.mode" select="info/subtitle"/>
    </xsl:when>
    <xsl:when test="subtitle">
      <xsl:apply-templates mode="preface.titlepage.recto.auto.mode" select="subtitle"/>
    </xsl:when>
  </xsl:choose>

  <xsl:apply-templates mode="preface.titlepage.recto.auto.mode" select="prefaceinfo/corpauthor"/>
  <xsl:apply-templates mode="preface.titlepage.recto.auto.mode" select="docinfo/corpauthor"/>
  <xsl:apply-templates mode="preface.titlepage.recto.auto.mode" select="info/corpauthor"/>
  <xsl:apply-templates mode="preface.titlepage.recto.auto.mode" select="prefaceinfo/authorgroup"/>
  <xsl:apply-templates mode="preface.titlepage.recto.auto.mode" select="docinfo/authorgroup"/>
  <xsl:apply-templates mode="preface.titlepage.recto.auto.mode" select="info/authorgroup"/>
  <xsl:apply-templates mode="preface.titlepage.recto.auto.mode" select="prefaceinfo/author"/>
  <xsl:apply-templates mode="preface.titlepage.recto.auto.mode" select="docinfo/author"/>
  <xsl:apply-templates mode="preface.titlepage.recto.auto.mode" select="info/author"/>
  <xsl:apply-templates mode="preface.titlepage.recto.auto.mode" select="prefaceinfo/othercredit"/>
  <xsl:apply-templates mode="preface.titlepage.recto.auto.mode" select="docinfo/othercredit"/>
  <xsl:apply-templates mode="preface.titlepage.recto.auto.mode" select="info/othercredit"/>
  <xsl:apply-templates mode="preface.titlepage.recto.auto.mode" select="prefaceinfo/releaseinfo"/>
  <xsl:apply-templates mode="preface.titlepage.recto.auto.mode" select="docinfo/releaseinfo"/>
  <xsl:apply-templates mode="preface.titlepage.recto.auto.mode" select="info/releaseinfo"/>
  <xsl:apply-templates mode="preface.titlepage.recto.auto.mode" select="prefaceinfo/copyright"/>
  <xsl:apply-templates mode="preface.titlepage.recto.auto.mode" select="docinfo/copyright"/>
  <xsl:apply-templates mode="preface.titlepage.recto.auto.mode" select="info/copyright"/>
  <xsl:apply-templates mode="preface.titlepage.recto.auto.mode" select="prefaceinfo/legalnotice"/>
  <xsl:apply-templates mode="preface.titlepage.recto.auto.mode" select="docinfo/legalnotice"/>
  <xsl:apply-templates mode="preface.titlepage.recto.auto.mode" select="info/legalnotice"/>
  <xsl:apply-templates mode="preface.titlepage.recto.auto.mode" select="prefaceinfo/pubdate"/>
  <xsl:apply-templates mode="preface.titlepage.recto.auto.mode" select="docinfo/pubdate"/>
  <xsl:apply-templates mode="preface.titlepage.recto.auto.mode" select="info/pubdate"/>
  <xsl:apply-templates mode="preface.titlepage.recto.auto.mode" select="prefaceinfo/revision"/>
  <xsl:apply-templates mode="preface.titlepage.recto.auto.mode" select="docinfo/revision"/>
  <xsl:apply-templates mode="preface.titlepage.recto.auto.mode" select="info/revision"/>
  <xsl:apply-templates mode="preface.titlepage.recto.auto.mode" select="prefaceinfo/revhistory"/>
  <xsl:apply-templates mode="preface.titlepage.recto.auto.mode" select="docinfo/revhistory"/>
  <xsl:apply-templates mode="preface.titlepage.recto.auto.mode" select="info/revhistory"/>
  <xsl:apply-templates mode="preface.titlepage.recto.auto.mode" select="prefaceinfo/abstract"/>
  <xsl:apply-templates mode="preface.titlepage.recto.auto.mode" select="docinfo/abstract"/>
  <xsl:apply-templates mode="preface.titlepage.recto.auto.mode" select="info/abstract"/>
  <xsl:apply-templates mode="preface.titlepage.recto.auto.mode" select="prefaceinfo/itermset"/>
  <xsl:apply-templates mode="preface.titlepage.recto.auto.mode" select="docinfo/itermset"/>
  <xsl:apply-templates mode="preface.titlepage.recto.auto.mode" select="info/itermset"/>
</xsl:template>

<xsl:template name="bibliography.titlepage.recto">
  <fo:block xmlns:fo="http://www.w3.org/1999/XSL/Format"
    xsl:use-attribute-sets="bibliography.titlepage.recto.style"
    margin-left="{$title.margin.left}" font-size="&super-large;pt"
    font-family="{$title.fontset}">
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
