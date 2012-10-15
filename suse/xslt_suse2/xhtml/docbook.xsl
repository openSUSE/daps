<?xml version="1.0" encoding="UTF-8"?>
<!-- 
   Purpose:
     Transform DocBook document into single XHTML file
     
   Parameters:
     Too many to list here, see:
     http://docbook.sourceforge.net/release/xsl/current/doc/html/index.html
       
   Input:
     DocBook 4/5 document
     
   Output:
     Single XHTML file
     
   See Also:
     * http://doccookbook.sf.net/html/en/dbc.common.dbcustomize.html
     * http://sagehill.net/docbookxsl/CustomMethods.html#WriteCustomization

   Author:    Thomas Schraitle <toms@opensuse.org>
   Copyright: 2012, Thomas Schraitle

-->

<xsl:stylesheet version="1.0"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:exsl="http://exslt.org/common"
    xmlns="http://www.w3.org/1999/xhtml"
    exclude-result-prefixes="exsl">
  
 <xsl:import href="http://docbook.sourceforge.net/release/xsl/current/xhtml/docbook.xsl"/>
 
 <xsl:include href="../common/titles.xsl"/>
 <xsl:include href="../common/navigation.xsl"/>

 <xsl:include href="param.xsl"/>
 <xsl:include href="create-permalink.xsl"/>

 <xsl:include href="autotoc.xsl"/>
 <xsl:include href="autobubbletoc.xsl"/> 
 <xsl:include href="lists.xsl"/>
 <xsl:include href="callout.xsl"/>
 <xsl:include href="verbatim.xsl"/>
 <xsl:include href="component.xsl"/>
 <xsl:include href="glossary.xsl"/>
 <xsl:include href="formal.xsl"/>
 <xsl:include href="sections.xsl"/>
 <xsl:include href="division.xsl"/>
 <xsl:include href="inline.xsl"/>
 <xsl:include href="admon.xsl"/>
 <xsl:include href="block.xsl"/>
 <xsl:include href="titlepage.templates.xsl"/>
 
 <xsl:include href="metadata.xsl"/>
 
 <!-- Adapt head.contents to...
 + generate more useful page titles ("Chapter x. Chapter Name" -> "Chapter Name | Book Name")
 + remove the inline styles for draft mode, so they can be substituted by styles 
   in the real stylesheet
 -->
 <xsl:template name="head.content">
  <xsl:param name="node" select="."/>
  <xsl:param name="title">
    <xsl:choose>
      <xsl:when test="(bookinfo | articleinfo | setinfo)/title">
        <xsl:apply-templates select="(bookinfo | articleinfo | setinfo)/title" mode="title.markup.textonly"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:apply-templates select="title" mode="title.markup.textonly"/>
      </xsl:otherwise>
    </xsl:choose>
    <xsl:if test="not(self::book or self::article or self::set)">
      <xsl:copy-of select="$head.content.title.separator"/>
      <xsl:choose>
        <xsl:when test="(ancestor::book | ancestor::article)[last()]/*[contains(local-name(), 'info')]/title">
          <xsl:apply-templates select="(ancestor::book | ancestor::article)[last()]/*[contains(local-name(), 'info')]/title" mode="title.markup.textonly"/>
        </xsl:when>
        <xsl:otherwise>
          <xsl:apply-templates select="(ancestor::book | ancestor::article)[last()]/title" mode="title.markup.textonly"/>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:if>
  </xsl:param>
   
  <title><xsl:copy-of select="$title"/></title>

  <xsl:if test="$html.base != ''">
    <base href="{$html.base}"/>
  </xsl:if>

  <!-- Insert links to CSS files or insert literal style elements -->
  <xsl:call-template name="generate.css"/>

  <xsl:if test="$html.stylesheet != ''">
    <xsl:call-template name="output.html.stylesheets">
      <xsl:with-param name="stylesheets" select="normalize-space($html.stylesheet)"/>
    </xsl:call-template>
  </xsl:if>

  <xsl:if test="$html.script != ''">
    <xsl:call-template name="output.html.scripts">
      <xsl:with-param name="scripts" select="normalize-space($html.script)"/>
    </xsl:call-template>
  </xsl:if>

  <xsl:if test="$link.mailto.url != ''">
    <link rev="made" href="{$link.mailto.url}"/>
  </xsl:if>

  <meta name="generator" content="DocBook {$DistroTitle} V{$VERSION}"/>

  <xsl:if test="$generate.meta.abstract != 0">
    <xsl:variable name="info" select="(articleinfo|bookinfo|prefaceinfo|chapterinfo|appendixinfo|
              sectioninfo|sect1info|sect2info|sect3info|sect4info|sect5info
             |referenceinfo
             |refentryinfo
             |partinfo
             |info
             |docinfo)[1]"/>
    <xsl:if test="$info and $info/abstract">
      <meta name="description">
        <xsl:attribute name="content">
          <xsl:for-each select="$info/abstract[1]/*">
            <xsl:value-of select="normalize-space(.)"/>
            <xsl:if test="position() &lt; last()">
              <xsl:text> </xsl:text>
            </xsl:if>
          </xsl:for-each>
        </xsl:attribute>
      </meta>
    </xsl:if>
  </xsl:if>

  <xsl:apply-templates select="." mode="head.keywords.content"/>
</xsl:template>
 
</xsl:stylesheet>
