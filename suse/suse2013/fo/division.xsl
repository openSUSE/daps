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

<xsl:template name="division.title">
  <xsl:param name="node" select="."/>
  <xsl:variable name="id">
    <xsl:call-template name="object.id">
      <xsl:with-param name="object" select="$node"/>
    </xsl:call-template>
  </xsl:variable>

  <fo:block keep-with-next.within-column="always"
    hyphenate="false">
    <xsl:call-template name="title.part.split">
      <xsl:with-param name="node" select="."/>
    </xsl:call-template>
  </fo:block>
</xsl:template>

<xsl:template name="title.part.split">
  <xsl:param name="node" select="."/>

  <xsl:variable name="title">
      <xsl:apply-templates select="$node" mode="title.markup"/>
  </xsl:variable>

  <xsl:variable name="number">
      <xsl:apply-templates select="($node/parent::part|$node/parent::partinfo/parent::part)[last()]" mode="label.markup"/>
  </xsl:variable>

  <fo:list-block relative-align="baseline"
       space-before="&columnfragment;mm"
       space-after="&gutterfragment;mm"
       keep-with-next.within-column="always"
       provisional-distance-between-starts="{&column; + &gutter;}mm"
       provisional-label-separation="{&gutter;}mm">
    <fo:list-item>
      <fo:list-item-label end-indent="label-end()">
        <fo:block text-align="end" line-height="{$line-height}"
          width="&column;mm" font-weight="normal"
          xsl:use-attribute-sets="title.number.color title.font">
          <xsl:if test="$number != ''">
            <xsl:copy-of select="$number"/>
          </xsl:if>
        </fo:block>
      </fo:list-item-label>
      <fo:list-item-body start-indent="body-start()">
        <fo:block text-align="start" line-height="{$line-height}"
          start-indent="{&column; + &gutter;}mm" font-weight="normal"
          xsl:use-attribute-sets="title.name.color title.font">
          <xsl:copy-of select="$title"/>
        </fo:block>
      </fo:list-item-body>
    </fo:list-item>
  </fo:list-block>
</xsl:template>

<xsl:template name="generate.part.toc">
  <xsl:param name="part" select="."/>
  <xsl:param name="actually-do" select="0"/>

  <xsl:variable name="toc.params">
    <xsl:call-template name="find.path.params">
      <xsl:with-param name="node" select="$part"/>
      <xsl:with-param name="table" select="normalize-space($generate.toc)"/>
    </xsl:call-template>
  </xsl:variable>

  <xsl:variable name="nodes" select="$part/reference|
                                     $part/preface|
                                     $part/chapter|
                                     $part/appendix|
                                     $part/article|
                                     $part/bibliography|
                                     $part/glossary|
                                     $part/index"/>

  <xsl:if test="$actually-do = 1">
    <xsl:if test="count($nodes) &gt; 0 and contains($toc.params, 'toc')">
      <fo:list-block provisional-distance-between-starts="{&column; + &gutter;}mm"
        provisional-label-separation="&gutter;mm">
        <xsl:call-template name="division.part.toc">
          <xsl:with-param name="toc-context" select="$part"/>
        </xsl:call-template>
      </fo:list-block>
    </xsl:if>
  </xsl:if>
</xsl:template>


<xsl:template match="part" mode="part.titlepage.mode">
  <!-- done this way to force the context node to be the part -->
  <xsl:param name="additional.content"/>

  <xsl:variable name="id">
    <xsl:call-template name="object.id"/>
  </xsl:variable>

  <xsl:variable name="titlepage-master-reference">
    <xsl:call-template name="select.pagemaster">
      <xsl:with-param name="pageclass" select="'titlepage'"/>
    </xsl:call-template>
  </xsl:variable>

  <fo:page-sequence hyphenate="{$hyphenate}"
                    master-reference="{$titlepage-master-reference}">
    <xsl:attribute name="language">
      <xsl:call-template name="l10n.language"/>
    </xsl:attribute>
    <xsl:attribute name="format">
      <xsl:call-template name="page.number.format">
        <xsl:with-param name="master-reference"
                        select="$titlepage-master-reference"/>
      </xsl:call-template>
    </xsl:attribute>

    <xsl:attribute name="initial-page-number">
      <xsl:call-template name="initial.page.number">
        <xsl:with-param name="master-reference"
                        select="$titlepage-master-reference"/>
      </xsl:call-template>
    </xsl:attribute>

    <xsl:attribute name="force-page-count">
      <xsl:call-template name="force.page.count">
        <xsl:with-param name="master-reference"
                        select="$titlepage-master-reference"/>
      </xsl:call-template>
    </xsl:attribute>

    <xsl:attribute name="hyphenation-character">
      <xsl:call-template name="gentext">
        <xsl:with-param name="key" select="'hyphenation-character'"/>
      </xsl:call-template>
    </xsl:attribute>
    <xsl:attribute name="hyphenation-push-character-count">
      <xsl:call-template name="gentext">
        <xsl:with-param name="key" select="'hyphenation-push-character-count'"/>
      </xsl:call-template>
    </xsl:attribute>
    <xsl:attribute name="hyphenation-remain-character-count">
      <xsl:call-template name="gentext">
        <xsl:with-param name="key" select="'hyphenation-remain-character-count'"/>
      </xsl:call-template>
    </xsl:attribute>

    <xsl:apply-templates select="." mode="running.head.mode">
      <xsl:with-param name="master-reference" select="$titlepage-master-reference"/>
    </xsl:apply-templates>

    <xsl:apply-templates select="." mode="running.foot.mode">
      <xsl:with-param name="master-reference" select="$titlepage-master-reference"/>
    </xsl:apply-templates>

    <fo:flow flow-name="xsl-region-body">
      <xsl:call-template name="set.flow.properties">
        <xsl:with-param name="element" select="local-name(.)"/>
        <xsl:with-param name="master-reference"
                        select="$titlepage-master-reference"/>
      </xsl:call-template>

      <fo:block id="{$id}">
        <xsl:call-template name="part.titlepage"/>
      </fo:block>
      <fo:block space-before="{&column;}mm">
        <xsl:call-template name="generate.part.toc">
          <xsl:with-param name="actually-do" select="1"/>
        </xsl:call-template>
      </fo:block>
      <xsl:copy-of select="$additional.content"/>
    </fo:flow>
  </fo:page-sequence>
</xsl:template>

</xsl:stylesheet>
