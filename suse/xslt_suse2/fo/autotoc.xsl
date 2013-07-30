<?xml version='1.0'?>
<!--
  Purpose:
    Rework the structure of Tables of Contents in Parts.

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
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:fo="http://www.w3.org/1999/XSL/Format"
                version='1.0'>

<xsl:template name="division.part.toc">
  <xsl:param name="toc-context" select="."/>

  <xsl:variable name="cid">
    <xsl:call-template name="object.id">
      <xsl:with-param name="object" select="$toc-context"/>
    </xsl:call-template>
  </xsl:variable>

  <xsl:variable name="nodes"
                select="$toc-context/part
                        |$toc-context/reference
                        |$toc-context/preface
                        |$toc-context/chapter
                        |$toc-context/appendix
                        |$toc-context/article
                        |$toc-context/topic
                        |$toc-context/bibliography
                        |$toc-context/glossary
                        |$toc-context/index"/>


  <xsl:apply-templates select="$nodes" mode="part.toc">
    <xsl:with-param name="toc-context" select="$toc-context"/>
  </xsl:apply-templates>
</xsl:template>

<xsl:template match="reference" mode="part.toc">
  <xsl:param name="toc-context" select="."/>

  <xsl:variable name="id">
    <xsl:call-template name="object.id"/>
  </xsl:variable>

  <xsl:variable name="cid">
    <xsl:call-template name="object.id">
      <xsl:with-param name="object" select="$toc-context"/>
    </xsl:call-template>
  </xsl:variable>

  <xsl:call-template name="toc.part.line">
    <xsl:with-param name="toc-context" select="$toc-context"/>
  </xsl:call-template>

</xsl:template>

<xsl:template match="preface|chapter|appendix|article" mode="part.toc">
  <xsl:param name="toc-context" select="."/>

  <xsl:variable name="id">
    <xsl:call-template name="object.id"/>
  </xsl:variable>

  <xsl:variable name="cid">
    <xsl:call-template name="object.id">
      <xsl:with-param name="object" select="$toc-context"/>
    </xsl:call-template>
  </xsl:variable>

  <xsl:call-template name="toc.part.line">
    <xsl:with-param name="toc-context" select="$toc-context"/>
  </xsl:call-template>
</xsl:template>


<xsl:template match="bibliography|glossary" mode="part.toc">
  <xsl:param name="toc-context" select="."/>

  <xsl:call-template name="toc.part.line">
    <xsl:with-param name="toc-context" select="$toc-context"/>
  </xsl:call-template>
</xsl:template>


<xsl:template match="index" mode="part.toc">
  <xsl:param name="toc-context" select="."/>

  <xsl:if test="* or $generate.index != 0">
    <xsl:call-template name="toc.part.line">
      <xsl:with-param name="toc-context" select="$toc-context"/>
    </xsl:call-template>
  </xsl:if>
</xsl:template>


<xsl:template name="toc.part.line">
  <xsl:param name="toc-context" select="NOTANODE"/>

  <xsl:variable name="line-height" select="'{$base-lineheight}em'"/>

  <xsl:variable name="id">
    <xsl:call-template name="object.id"/>
  </xsl:variable>

  <xsl:variable name="label">
    <xsl:apply-templates select="." mode="label.markup"/>
  </xsl:variable>

  <fo:list-item>
    <fo:list-item-label end-indent="label-end()">
      <fo:block text-align="end" font-family="{$title.fontset}"
        font-size="&large;pt" color="&mid-gray;" line-height="{$line-height}">
        <fo:basic-link internal-destination="{$id}">
          <xsl:if test="$label != ''">
            <xsl:copy-of select="$label"/>
          </xsl:if>
        </fo:basic-link>
      </fo:block>
    </fo:list-item-label>
    <fo:list-item-body start-indent="body-start()">
      <fo:block line-height="{$line-height}" padding-after="{&gutter; div 2}mm">
        <fo:inline keep-with-next.within-line="always"
        font-family="{$title.fontset}" font-size="&large;pt">
          <fo:basic-link internal-destination="{$id}">
            <xsl:apply-templates select="." mode="titleabbrev.markup"/>
          </fo:basic-link>
        </fo:inline>
        <fo:inline keep-together.within-line="always" font-size="&large;pt"
        font-family="{$serif-stack}" xsl:use-attribute-sets="dark-green">
          <fo:basic-link internal-destination="{$id}">
            <fo:leader leader-pattern="space" leader-length="&gutterfragment;mm"/>
            <fo:page-number-citation ref-id="{$id}"/>
          </fo:basic-link>
        </fo:inline>
      </fo:block>
    </fo:list-item-body>
  </fo:list-item>
</xsl:template>

</xsl:stylesheet>
