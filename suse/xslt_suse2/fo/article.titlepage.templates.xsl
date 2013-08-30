<?xml version="1.0" encoding="UTF-8"?>
<!--
  Purpose:
    Restyle article titlepage

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
  
  <!-- Article ==================================================== -->
  <xsl:template name="article.titlepage.recto">
    <xsl:variable name="height">
      <xsl:call-template name="get.value.from.unit">
        <xsl:with-param name="string" select="$page.height"/>
      </xsl:call-template>
    </xsl:variable>
    <xsl:variable name="logo.width"
      select="(1 + (602 div 3395)) * &column;"/>
    <xsl:variable name="margin.start">
      <xsl:call-template name="get.value.from.unit">
        <xsl:with-param name="string" select="$page.margin.outer"/>
      </xsl:call-template>
    </xsl:variable>
    <xsl:variable name="unit">
      <xsl:call-template name="get.unit.from.unit">
        <xsl:with-param name="string" select="$page.height"/>
      </xsl:call-template>
    </xsl:variable>
    <xsl:variable name="logo">
      <xsl:call-template name="fo-external-image">
        <xsl:with-param name="filename">
          <xsl:choose>
            <xsl:when test="$format.print != 0">
              <xsl:value-of select="$booktitlepage.bw.logo"/>
            </xsl:when>
            <xsl:otherwise>
              <xsl:value-of select="$booktitlepage.color.logo"/>
            </xsl:otherwise>
          </xsl:choose>
        </xsl:with-param>
      </xsl:call-template>
    </xsl:variable>

    
    <fo:block margin-left="-5mm" space-after="2em" text-align="left">
        <fo:external-graphic content-width="{$logo.width}mm"
          width="{$logo.width}mm" src="{$logo}"/>
    </fo:block>
    
    <fo:block space-after=".75em">
      <xsl:choose>
        <xsl:when test="articleinfo/title">
          <xsl:apply-templates mode="article.titlepage.recto.auto.mode"
            select="articleinfo/title"/>
        </xsl:when>
        <xsl:when test="artheader/title">
          <xsl:apply-templates mode="article.titlepage.recto.auto.mode"
            select="artheader/title"/>
        </xsl:when>
        <xsl:when test="info/title">
          <xsl:apply-templates mode="article.titlepage.recto.auto.mode"
            select="info/title"/>
        </xsl:when>
        <xsl:when test="title">
          <xsl:apply-templates mode="article.titlepage.recto.auto.mode"
            select="title"/>
        </xsl:when>
      </xsl:choose>
    </fo:block>
   
    <fo:block padding-before="1em">
      <xsl:attribute name="border-top">0.5mm solid <xsl:call-template name="dark-green"/></xsl:attribute>
      <xsl:apply-templates mode="article.titlepage.recto.auto.mode"
            select="articleinfo/productname[not(@role)]"/>
    </fo:block>
    
    <xsl:apply-templates mode="article.titlepage.recto.auto.mode" select="articleinfo/corpauthor"/>
    <xsl:apply-templates mode="article.titlepage.recto.auto.mode" select="artheader/corpauthor"/>
    <xsl:apply-templates mode="article.titlepage.recto.auto.mode" select="info/corpauthor"/>
    <xsl:apply-templates mode="article.titlepage.recto.auto.mode" select="articleinfo/authorgroup"/>
    <xsl:apply-templates mode="article.titlepage.recto.auto.mode" select="artheader/authorgroup"/>
    <xsl:apply-templates mode="article.titlepage.recto.auto.mode" select="info/authorgroup"/>
    <xsl:apply-templates mode="article.titlepage.recto.auto.mode" select="articleinfo/author"/>
    <xsl:apply-templates mode="article.titlepage.recto.auto.mode" select="artheader/author"/>
    <xsl:apply-templates mode="article.titlepage.recto.auto.mode" select="info/author"/>
    
    <xsl:apply-templates mode="article.titlepage.recto.auto.mode" select="articleinfo/abstract"/>
    <xsl:apply-templates mode="article.titlepage.recto.auto.mode" select="info/abstract"/>
    
  </xsl:template>
  
  <xsl:template match="title" mode="article.titlepage.recto.auto.mode">
    <fo:block font-size="&super-large;pt" line-height="1.25"
      xsl:use-attribute-sets="article.titlepage.recto.style"
      keep-with-next.within-column="always">
      <xsl:call-template name="component.title">
        <xsl:with-param name="node" select="ancestor-or-self::article[1]"/>
      </xsl:call-template>
    </fo:block>
  </xsl:template>
  
  <xsl:template match="productname" mode="article.titlepage.recto.auto.mode">
    <fo:block text-align="start" font-size="&xx-large;pt">
      <xsl:apply-templates select="." mode="article.titlepage.recto.mode"/>
      <xsl:if test="../productnumber">
        <xsl:text> </xsl:text>
        <xsl:apply-templates select="../productnumber" mode="article.titlepage.recto.mode"/>
      </xsl:if>
    </fo:block>
  </xsl:template>
  
  <xsl:template match="authorgroup"  mode="article.titlepage.recto.auto.mode">
    <fo:block font-size="&large;pt" space-before="1em" 
      text-align="start">
      <xsl:call-template name="person.name.list">
        <xsl:with-param name="person.list" select="author|corpauthor"/>
      </xsl:call-template>
    </fo:block>
  </xsl:template>
  
  <xsl:template match="author|corpauthor|editor"
    mode="article.titlepage.recto.auto.mode">
    <fo:inline  space-before="0.5em"
      font-size="&large;pt">
      <xsl:apply-templates select="." mode="article.titlepage.recto.mode"/>
    </fo:inline>
  </xsl:template>
  
  <xsl:template name="article.titlepage.verso">
    <xsl:variable name="toc.params">
      <xsl:call-template name="find.path.params">
        <xsl:with-param name="table" select="normalize-space($generate.toc)"/>
      </xsl:call-template>
    </xsl:variable>
    <xsl:if test="contains($toc.params, 'toc')">
      <xsl:call-template name="component.toc">
        <xsl:with-param name="toc.title.p" select="contains($toc.params, 'title')"/>
      </xsl:call-template>
    </xsl:if>
  </xsl:template>
  
  <xsl:template name="make.component.tocs">
    <xsl:if test="not(self::article)">
      <xsl:apply-imports/>
    </xsl:if>
  </xsl:template>

</xsl:stylesheet>