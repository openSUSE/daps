<?xml version='1.0'?>
<!--
  Purpose:
    Rework the structure of Tables of Contents in Parts.

  Author(s):  Stefan Knorr <sknorr@suse.de>

  Copyright:  2013, Stefan Knorr

-->
<!DOCTYPE xsl:stylesheets 
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

<xsl:template name="division.toc">
  <xsl:param name="toc-context" select="."/>
  <xsl:param name="toc.title.p" select="true()"/>

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

  <xsl:if test="$nodes">
    <fo:block id="toc...{$cid}" xsl:use-attribute-sets="toc.margin.properties">
      <xsl:if test="$toc.title.p">
        <xsl:call-template name="table.of.contents.titlepage"/>
      </xsl:if>
      <xsl:apply-templates select="$nodes" mode="part.toc">
        <xsl:with-param name="toc-context" select="$toc-context"/>
      </xsl:apply-templates>
    </fo:block>
  </xsl:if>
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

  <xsl:variable name="id">
    <xsl:call-template name="object.id"/>
  </xsl:variable>

  <xsl:variable name="label">
    <xsl:apply-templates select="." mode="label.markup"/>
  </xsl:variable>

  <fo:block font-family="{$title.fontset}" size="&large;" start-indent="{&column; + &gutter;}mm">
    <fo:inline keep-with-next.within-line="always">
      <fo:basic-link internal-destination="{$id}">
        <xsl:if test="$label != ''">
          <xsl:copy-of select="$label"/>
          <xsl:value-of select="$autotoc.label.separator"/>
        </xsl:if>
        <xsl:apply-templates select="." mode="titleabbrev.markup"/>
      </fo:basic-link>
    </fo:inline>
    <fo:inline keep-together.within-line="always">
      <xsl:text> </xsl:text>
      <fo:basic-link internal-destination="{$id}">
        <fo:page-number-citation ref-id="{$id}"/>
      </fo:basic-link>
    </fo:inline>
  </fo:block>
</xsl:template>

</xsl:stylesheet>
