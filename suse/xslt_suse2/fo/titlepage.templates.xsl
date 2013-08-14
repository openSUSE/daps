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

<xsl:template name="glossary.titlepage.recto">
  <fo:block 
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
  <fo:block 
    xsl:use-attribute-sets="glossdiv.titlepage.recto.style"
    margin-left="{$title.margin.left}" font-size="&xxx-large;pt"
    font-family="{$title.fontset}">
    <xsl:call-template name="component.title">
      <xsl:with-param name="node" select="ancestor-or-self::glossdiv[1]"/>
    </xsl:call-template>
  </fo:block>
</xsl:template>

<xsl:template name="preface.titlepage.recto">
  <fo:block 
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
  <fo:block 
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

<xsl:template match="title" mode="article.titlepage.recto.auto.mode">
  <fo:block 
    xsl:use-attribute-sets="article.titlepage.recto.style"
    keep-with-next.within-column="always">
    <xsl:call-template name="component.title">
      <xsl:with-param name="node" select="ancestor-or-self::article[1]"/>
    </xsl:call-template>
  </fo:block>
</xsl:template>

<xsl:template match="author|corpauthor|authorgroup"
  mode="article.titlepage.recto.auto.mode">
  <fo:block 
  xsl:use-attribute-sets="article.titlepage.recto.style" space-before="0.5em"
  font-size="&x-large;pt">
    <xsl:apply-templates select="." mode="article.titlepage.recto.mode"/>
  </fo:block>
</xsl:template>

<xsl:template match="title" mode="set.titlepage.recto.auto.mode">
  <fo:block xsl:use-attribute-sets="set.titlepage.recto.style"
    font-size="&ultra-large;pt" space-before="&columnfragment;mm"
    font-family="{$title.fontset}">
    <xsl:call-template name="division.title">
      <xsl:with-param name="node" select="ancestor-or-self::set[1]"/>
    </xsl:call-template>
  </fo:block>
</xsl:template>


<xsl:template name="book.titlepage.recto">
  <xsl:variable name="height">
    <xsl:call-template name="get.value.from.unit">
      <xsl:with-param name="string" select="$page.height"/>
    </xsl:call-template>
  </xsl:variable>
  <xsl:variable name="logo.width" select="&column;"/>
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
  <xsl:variable name="cover-image">
    <xsl:call-template name="fo-external-image">
      <xsl:with-param name="filename">
        <xsl:choose>
          <xsl:when test="$format.print != 0">
            <xsl:value-of select="concat($styleroot,
              'images/logos/suse-logo-tail-bw.svg')"/>
          </xsl:when>
          <xsl:otherwise>
            <xsl:value-of select="concat($styleroot,
              'images/logos/suse-logo-tail.svg')"/>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:with-param>
    </xsl:call-template>
  </xsl:variable>

  <fo:block-container top="{(2 - &goldenratio;) * $height}{$unit}" left="0"
    text-align="right"
    absolute-position="fixed">
    <fo:block>
    <!-- Almost golden ratio... -->
      <fo:external-graphic content-width="{(&column; * 5) + (&gutter; * 4)}mm"
        width="{(&column; * 5) + (&gutter; * 4)}mm"
        src="{$cover-image}"/>
    </fo:block>
  </fo:block-container>

  <fo:block-container top="{$page.margin.top}"
    left="{$margin.start - ((400 div 3395) * $logo.width)}mm" absolute-position="fixed">
    <!-- The above calculation is not complete voodoo - the SUSE logo SVG is
         3395px wide, the first "S" of SUSE starts at 602px and the output width
         of the logo is $logo.width mm. Effectively, the Geeko tail ends up on
         the page border. -->
    <fo:block>
      <fo:external-graphic content-width="{$logo.width}mm" width="{$logo.width}mm"
        src="{$logo}"/>
    </fo:block>
  </fo:block-container>

  <fo:block-container bottom="{$height div &goldenratio;}{$unit}" left="0"
    absolute-position="fixed">
    <fo:table width="{(&column; * 7) + (&gutter; * 5)}mm" table-layout="fixed">
      <fo:table-column column-number="1" column-width="100%"/>

      <fo:table-body>
        <fo:table-row>
          <fo:table-cell display-align="after"
            height="{$height * (2 - &goldenratio;)}{$unit}" >
            <fo:block padding-start="&column;mm">
              <xsl:attribute name="border-top">0.5mm solid <xsl:call-template name="mid-green"/></xsl:attribute>
              <fo:block width="{(&column; * 6) + (&gutter; * 5)}mm"
                padding-before="&columnfragment;mm"
                padding-after="&columnfragment;mm">
            <xsl:apply-templates mode="book.titlepage.recto.auto.mode"
              select="bookinfo/productname[1]" vertical-align="bottom"/>
            <xsl:choose>
              <xsl:when test="bookinfo/title">
                <xsl:apply-templates mode="book.titlepage.recto.auto.mode"
                  select="bookinfo/title"/>
              </xsl:when>
              <xsl:when test="info/title">
                <xsl:apply-templates mode="book.titlepage.recto.auto.mode"
                  select="info/title"/>
              </xsl:when>
              <xsl:when test="title">
                <xsl:apply-templates mode="book.titlepage.recto.auto.mode"
                  select="title"/>
              </xsl:when>
            </xsl:choose>
              </fo:block>
            </fo:block>
          </fo:table-cell>
        </fo:table-row>
      </fo:table-body>
    </fo:table>
  </fo:block-container>

</xsl:template>

<xsl:template match="title" mode="book.titlepage.recto.auto.mode">
  <fo:block text-align="left" line-height="1.2" hyphenate="false"
    xsl:use-attribute-sets="book.titlepage.recto.style
    sans.bold.noreplacement title.name.color"
    font-weight="normal"
    font-size="{(&ultra-large; + &super-large;) div 2}pt" 
    font-family="{$title.fontset}">
    <xsl:apply-templates select="." mode="book.titlepage.recto.mode"/>
  </fo:block>
</xsl:template>

<xsl:template match="subtitle" mode="book.titlepage.recto.auto.mode">
  <fo:block 
    xsl:use-attribute-sets="book.titlepage.recto.style"
    font-size="&super-large;pt"
    space-before="&gutterfragment;mm" font-family="{$title.fontset}">
    <xsl:apply-templates select="." mode="book.titlepage.recto.mode"/>
  </fo:block>
</xsl:template>

<xsl:template match="productname" mode="book.titlepage.recto.auto.mode">
  <fo:block text-align="left" hyphenate="false"
    line-height="{$base-lineheight * $sans-lineheight-adjust}em"
    font-weight="normal" font-size="&super-large;pt"
    xsl:use-attribute-sets="book.titlepage.recto.style sans.bold.noreplacement mid-green">
    <xsl:apply-templates select="." mode="book.titlepage.recto.mode"/>
    <xsl:text> </xsl:text>
    <xsl:apply-templates select="../productnumber" mode="book.titlepage.recto.mode"/>
  </fo:block>
</xsl:template>

<xsl:template match="title" mode="book.titlepage.verso.auto.mode">
  <fo:block
    xsl:use-attribute-sets="book.titlepage.verso.style sans.bold"
    font-size="&x-large;pt" font-family="{$title.fontset}">
  <xsl:call-template name="book.verso.title"/>
  </fo:block>
</xsl:template>

<xsl:template match="legalnotice" mode="book.titlepage.verso.auto.mode">
  <fo:block 
    xsl:use-attribute-sets="book.titlepage.verso.style" font-size="&small;pt">
    <xsl:apply-templates select="." mode="book.titlepage.verso.mode"/>
  </fo:block>
</xsl:template>

<xsl:template match="title" mode="part.titlepage.recto.auto.mode">
  <fo:block
    xsl:use-attribute-sets="part.titlepage.recto.style sans.bold.noreplacement"
    font-size="&super-large;pt" space-before="&columnfragment;mm"
    font-family="{$title.fontset}">
    <xsl:call-template name="division.title">
      <xsl:with-param name="node" select="ancestor-or-self::part[1]"/>
    </xsl:call-template>
  </fo:block>
</xsl:template>

<xsl:template match="subtitle" mode="part.titlepage.recto.auto.mode">
  <fo:block
    xsl:use-attribute-sets="part.titlepage.recto.style sans.bold.noreplacement
    italicized.noreplacement" font-size="&xxx-large;pt"
    space-before="&gutter;mm" font-family="{$title.fontset}">
    <xsl:apply-templates select="." mode="part.titlepage.recto.mode"/>
  </fo:block>
</xsl:template>

</xsl:stylesheet>
