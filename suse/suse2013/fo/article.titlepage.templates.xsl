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
    <xsl:variable name="unit">
      <xsl:call-template name="get.unit.from.unit">
        <xsl:with-param name="string" select="$page.height"/>
      </xsl:call-template>
    </xsl:variable>

    <fo:block margin-left="{&columnfragment; + &gutter; - $titlepage.logo.overhang}mm" space-after="&gutter;mm"
      text-align="left">
      <fo:instream-foreign-object content-width="{$titlepage.logo.width}"
        width="{$titlepage.logo.width}">
        <xsl:call-template name="logo-image"/>
      </fo:instream-foreign-object>
    </fo:block>

    <fo:block start-indent="{&columnfragment; + &gutter;}mm" text-align="start"
      role="article.titlepage.recto">
      <fo:block space-after="{&gutterfragment;}mm">
        <xsl:choose>
          <xsl:when test="articleinfo/title">
            <xsl:apply-templates
              mode="article.titlepage.recto.auto.mode"
              select="articleinfo/title"/>
          </xsl:when>
          <xsl:when test="artheader/title">
            <xsl:apply-templates
              mode="article.titlepage.recto.auto.mode"
              select="artheader/title"/>
          </xsl:when>
          <xsl:when test="info/title">
            <xsl:apply-templates
              mode="article.titlepage.recto.auto.mode"
              select="info/title"/>
          </xsl:when>
          <xsl:when test="title">
            <xsl:apply-templates
              mode="article.titlepage.recto.auto.mode" select="title"/>
          </xsl:when>
        </xsl:choose>
      </fo:block>

    <fo:block padding-before="{2 * &gutterfragment;}mm"
      padding-start="{&column; + &columnfragment; + &gutter;}mm">
      <xsl:attribute name="border-top"><xsl:value-of select="concat(&mediumline;,'mm solid ',$dark-green)"/></xsl:attribute>
      <xsl:apply-templates mode="article.titlepage.recto.auto.mode"
            select="articleinfo/productname[not(@role)]"/>
    </fo:block>

    <xsl:apply-templates mode="article.titlepage.recto.auto.mode" select="articleinfo/corpauthor"/>
    <xsl:apply-templates mode="article.titlepage.recto.auto.mode" select="info/corpauthor"/>
    <xsl:apply-templates mode="article.titlepage.recto.auto.mode" select="articleinfo/authorgroup"/>
    <xsl:apply-templates mode="article.titlepage.recto.auto.mode" select="info/authorgroup"/>
    <xsl:apply-templates mode="article.titlepage.recto.auto.mode" select="articleinfo/author"/>
    <xsl:apply-templates mode="article.titlepage.recto.auto.mode" select="info/author"/>

    <xsl:choose>
      <xsl:when test="articleinfo/abstract or info/abstract">
        <xsl:apply-templates mode="article.titlepage.recto.auto.mode" select="articleinfo/abstract"/>
        <xsl:apply-templates mode="article.titlepage.recto.auto.mode" select="info/abstract"/>
      </xsl:when>
      <xsl:when test="abstract">
        <xsl:apply-templates mode="article.titlepage.recto.auto.mode" select="abstract"/>
      </xsl:when>
    </xsl:choose>

    <fo:block>
      <xsl:apply-templates mode="article.titlepage.recto.auto.mode"  select="articleinfo/othercredit"/>
      <xsl:apply-templates mode="article.titlepage.recto.auto.mode"  select="info/othercredit"/>
    </fo:block>

    <fo:block>
      <xsl:apply-templates mode="article.titlepage.recto.auto.mode" select="articleinfo/editor"/>
      <xsl:apply-templates mode="article.titlepage.recto.auto.mode" select="info/editor"/>
    </fo:block>

    <fo:block>
      <xsl:call-template name="date.and.revision"/>
    </fo:block>

    </fo:block>
  </xsl:template>


  <xsl:template match="title" mode="article.titlepage.recto.auto.mode">
    <fo:block font-size="&super-large;pt" line-height="{$base-lineheight * 0.85}em"
      xsl:use-attribute-sets="article.titlepage.recto.style dark-green"
      keep-with-next.within-column="always" space-after="{&gutterfragment;}mm">
      <xsl:apply-templates select="." mode="article.titlepage.recto.mode"/>
    </fo:block>
  </xsl:template>

  <xsl:template match="productname[1]" mode="article.titlepage.recto.auto.mode">
    <fo:block text-align="start" font-size="&xx-large;pt"
      xsl:use-attribute-sets="mid-green">
      <xsl:apply-templates select="." mode="article.titlepage.recto.mode"/>
      <xsl:if test="../productnumber">
        <xsl:text> </xsl:text>
        <xsl:apply-templates select="../productnumber[1]" mode="article.titlepage.recto.mode"/>
      </xsl:if>
    </fo:block>
  </xsl:template>

  <xsl:template match="authorgroup" mode="article.titlepage.recto.auto.mode">
    <fo:block font-size="&large;pt" space-before="1em" text-align="start">
      <xsl:call-template name="person.name.list">
        <xsl:with-param name="person.list" select="author|corpauthor"/>
      </xsl:call-template>
    </fo:block>
  </xsl:template>

  <xsl:template match="author|corpauthor"
    mode="article.titlepage.recto.auto.mode">
    <fo:block space-before="1em" font-size="&large;pt" text-align="start">
      <xsl:apply-templates select="." mode="article.titlepage.recto.mode"/>
    </fo:block>
  </xsl:template>

  <xsl:template match="editor|othercredit"
    mode="article.titlepage.recto.auto.mode">
    <xsl:if test=". = ((../othercredit)|(../editor))[1]">
      <fo:block font-size="&normal;pt">
        <xsl:call-template name="gentext">
          <xsl:with-param name="key">
            <xsl:choose>
              <xsl:when test="count((../othercredit)|(../editor)) > 1"
                >Contributors</xsl:when>
              <xsl:otherwise>Contributor</xsl:otherwise>
            </xsl:choose>
          </xsl:with-param>
        </xsl:call-template>
        <xsl:text>: </xsl:text>
        <xsl:call-template name="person.name.list">
          <xsl:with-param name="person.list"
            select="(../othercredit)|(../editor)"/>
        </xsl:call-template>
      </fo:block>
    </xsl:if>
  </xsl:template>

  <xsl:template match="abstract" mode="article.titlepage.recto.auto.mode">
    <fo:block space-after="1.5em">
      <xsl:apply-templates select="." mode="article.titlepage.recto.mode"/>
    </fo:block>
  </xsl:template>

  <xsl:template match="article/abstract"/>

</xsl:stylesheet>
