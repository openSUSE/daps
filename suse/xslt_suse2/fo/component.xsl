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
<xsl:stylesheet version="1.0"
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:exsl="http://exslt.org/common"
  xmlns:fo="http://www.w3.org/1999/XSL/Format"
  exclude-result-prefixes="exsl">

<xsl:template name="component.title">
  <xsl:param name="node" select="."/>
  <xsl:param name="pagewide" select="0"/>

  <xsl:variable name="id">
    <xsl:call-template name="object.id">
      <xsl:with-param name="object" select="$node"/>
    </xsl:call-template>
  </xsl:variable>

  <xsl:variable name="titleabbrev">
    <xsl:apply-templates select="$node" mode="titleabbrev.markup"/>
  </xsl:variable>

  <xsl:variable name="level">
    <xsl:choose>
      <xsl:when test="ancestor::section">
        <xsl:value-of select="count(ancestor::section)+1"/>
      </xsl:when>
      <xsl:when test="ancestor::sect5">6</xsl:when>
      <xsl:when test="ancestor::sect4">5</xsl:when>
      <xsl:when test="ancestor::sect3">4</xsl:when>
      <xsl:when test="ancestor::sect2">3</xsl:when>
      <xsl:when test="ancestor::sect1">2</xsl:when>
      <xsl:otherwise>1</xsl:otherwise>
    </xsl:choose>
  </xsl:variable>

  <fo:block xsl:use-attribute-sets="component.title.properties">
    <xsl:if test="$pagewide != 0">
      <!-- Doesn't work to use 'all' here since not a child of fo:flow -->
      <xsl:attribute name="span">inherit</xsl:attribute>
    </xsl:if>
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

    <xsl:choose>
      <xsl:when test="$level=2">
        <fo:block xsl:use-attribute-sets="section.title.level2.properties">
          <xsl:call-template name="title.split">
            <xsl:with-param name="node" select="$node"/>
          </xsl:call-template>
        </fo:block>
      </xsl:when>
      <xsl:when test="$level=3">
        <fo:block xsl:use-attribute-sets="section.title.level3.properties">
          <xsl:call-template name="title.split">
            <xsl:with-param name="node" select="$node"/>
          </xsl:call-template>
        </fo:block>
      </xsl:when>
      <xsl:when test="$level=4">
        <fo:block xsl:use-attribute-sets="section.title.level4.properties">
          <xsl:call-template name="title.split">
            <xsl:with-param name="node" select="$node"/>
          </xsl:call-template>
        </fo:block>
      </xsl:when>
      <xsl:when test="$level=5">
        <fo:block xsl:use-attribute-sets="section.title.level5.properties">
          <xsl:call-template name="title.split">
            <xsl:with-param name="node" select="$node"/>
          </xsl:call-template>
        </fo:block>
      </xsl:when>
      <xsl:when test="$level=6">
        <fo:block xsl:use-attribute-sets="section.title.level6.properties">
          <xsl:call-template name="title.split">
            <xsl:with-param name="node" select="$node"/>
          </xsl:call-template>
        </fo:block>
      </xsl:when>
      <xsl:otherwise>
        <xsl:call-template name="title.split">
          <xsl:with-param name="node" select="$node"/>
        </xsl:call-template>
      </xsl:otherwise>
    </xsl:choose>
  </fo:block>
</xsl:template>


<xsl:template name="title.split">
  <xsl:param name="node" select="."/>

  <xsl:variable name="title">
    <xsl:choose>
      <xsl:when test="refmeta/refentrytitle">
        <xsl:apply-templates select="refentry/refmetatitle"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:apply-templates select="$node" mode="title.markup"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:variable>

  <xsl:variable name="number">
    <xsl:apply-templates select="$node" mode="label.markup"/>
  </xsl:variable>

  <xsl:if test="$number != ''">
    <fo:inline xsl:use-attribute-sets="title.number.color">
      <xsl:copy-of select="$number"/>
      <fo:leader leader-pattern="space" leader-length="&gutter;mm"/>
    </fo:inline>
  </xsl:if>
  <fo:inline xsl:use-attribute-sets="title.name.color">
    <xsl:copy-of select="$title"/>
  </fo:inline>
</xsl:template>


<!-- Below, there are three templates (#1, #2, #3) that roughly do the following:
        #1.1  match appendices that have a role='legal' attribute
        #1.2  apply all upstream templates on it, then converted the tree fragment
              we just created to a node-set
        #1.3, 2
              let said node-set run through a template that copies everything
        #3    except for the part we want to wrap in a fo:block with the span
              attribute set.-->

<xsl:template match="appendix[@role='legal']">
  <xsl:variable name="tree-fragment">
    <xsl:apply-imports/>
  </xsl:variable>

  <xsl:variable name="converted-fragment" select="exsl:node-set($tree-fragment)/*"/>
  <xsl:apply-templates select="$converted-fragment" mode="minor.adjustments"/>
</xsl:template>


<xsl:template match="node() | @*" mode="minor.adjustments">
  <xsl:copy>
    <xsl:apply-templates select="@* | node()" mode="minor.adjustments"/>
  </xsl:copy>
</xsl:template>


<xsl:template match="fo:flow/fo:block[1]" mode="minor.adjustments">
  <!-- This template lets us add another block element around the appendix
       template, so we can set the span="all" attribute at the appropriate
       level. -->

    <fo:block span="all">
      <xsl:apply-templates select="*" mode="minor.adjustments"/>
    </fo:block>
</xsl:template>

</xsl:stylesheet>
