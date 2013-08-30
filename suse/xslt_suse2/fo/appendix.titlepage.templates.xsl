<?xml version="1.0" encoding="UTF-8"?>
<!--
  Purpose:
    Restyle appendix titlepage

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
  
  
  <!--  Appendix ================================================== -->
  <xsl:template match="title" mode="appendix.titlepage.recto.auto.mode">
    <fo:block
      xsl:use-attribute-sets="appendix.titlepage.recto.style"
      margin-left="{$title.margin.left}" font-size="&super-large;pt"
      font-family="{$title.fontset}">
      <xsl:call-template name="component.title">
        <xsl:with-param name="node" select="ancestor-or-self::appendix[1]"/>
      </xsl:call-template>
    </fo:block>
  </xsl:template>
  
  <xsl:template match="subtitle" mode="appendix.titlepage.recto.auto.mode">
    <fo:block
      xsl:use-attribute-sets="appendix.titlepage.recto.style"
      font-family="{$title.fontset}" font-size="&small;pt">
      <xsl:apply-templates select="." mode="appendix.titlepage.recto.mode"/>
    </fo:block>
  </xsl:template>
  
  <xsl:template match="corpauthor" mode="appendix.titlepage.recto.auto.mode">
    <fo:block
      xsl:use-attribute-sets="appendix.titlepage.recto.style"
      font-family="{$title.fontset}" font-size="&small;pt">
      <xsl:apply-templates select="." mode="appendix.titlepage.recto.mode"/>
    </fo:block>
  </xsl:template>
  
  <xsl:template match="authorgroup" mode="appendix.titlepage.recto.auto.mode">
    <fo:block
      xsl:use-attribute-sets="appendix.titlepage.recto.style"
      font-family="{$title.fontset}" font-size="&small;pt">
      <xsl:apply-templates select="." mode="appendix.titlepage.recto.mode"/>
    </fo:block>
  </xsl:template>
  
  <xsl:template match="author" mode="appendix.titlepage.recto.auto.mode">
    <fo:block
      xsl:use-attribute-sets="appendix.titlepage.recto.style"
      font-family="{$title.fontset}" font-size="&small;pt">
      <xsl:apply-templates select="." mode="appendix.titlepage.recto.mode"/>
    </fo:block>
  </xsl:template>
  
  <xsl:template match="othercredit" mode="appendix.titlepage.recto.auto.mode">
    <fo:block
      xsl:use-attribute-sets="appendix.titlepage.recto.style"
      font-family="{$title.fontset}" font-size="&small;pt">
      <xsl:apply-templates select="." mode="appendix.titlepage.recto.mode"/>
    </fo:block>
  </xsl:template>
  
</xsl:stylesheet>