<?xml version="1.0" encoding="UTF-8"?>
<!-- $Id: docbook.xsl 10321 2006-06-27 07:11:58Z toms $ -->
<xsl:stylesheet
    version="1.0"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform">

<xsl:template match="toc">
  <xsl:comment>htdig_noindex</xsl:comment>
    <xsl:apply-imports/>
  <xsl:comment>/htdig_noindex</xsl:comment>
</xsl:template>

<xsl:template match="*" mode="toc.for.section">
  <xsl:comment>htdig_noindex</xsl:comment>
  <xsl:call-template name="section.toc"/>
  <xsl:comment>/htdig_noindex</xsl:comment>
</xsl:template>

<xsl:template match="*" mode="toc.for.component">
  <xsl:comment>htdig_noindex</xsl:comment>
  <xsl:call-template name="component.toc"/>
  <xsl:comment>/htdig_noindex</xsl:comment>
</xsl:template>

<xsl:template match="*" mode="toc.for.section">
  <xsl:comment>htdig_noindex</xsl:comment>
  <xsl:call-template name="section.toc"/>
  <xsl:comment>/htdig_noindex</xsl:comment>
</xsl:template>

<xsl:template match="*" mode="toc.for.division">
  <xsl:comment>htdig_noindex</xsl:comment>
  <xsl:call-template name="division.toc"/>
  <xsl:comment>/htdig_noindex</xsl:comment>
</xsl:template>

<!--<xsl:template match="/set" mode="toc.for.set">
  <xsl:comment>htdig_noindex</xsl:comment>
  <xsl:message>DISCOVERED A SET</xsl:message>
  <xsl:comment>/htdig_noindex</xsl:comment>
</xsl:template>
-->

<xsl:template match="*" mode="toc.for.set">
  <xsl:comment>htdig_noindex</xsl:comment>
  <xsl:call-template name="set.toc"/>
  <xsl:comment>htdig_noindex</xsl:comment>
</xsl:template>


<!--
  Only display book titles in a set toc:
  http://www.sagehill.net/docbookxsl/TOCcontrol.html#BriefSetToc
-->
<xsl:template match="book" mode="toc">
  <xsl:param name="toc-context" select="."/>

  <xsl:call-template name="subtoc">
    <xsl:with-param name="toc-context" select="$toc-context"/>
    <xsl:with-param name="nodes" select="EMPTY"/>
  </xsl:call-template>
</xsl:template>
  
</xsl:stylesheet>