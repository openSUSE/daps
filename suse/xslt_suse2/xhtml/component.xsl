<?xml version="1.0" encoding="UTF-8"?>
<!-- 
  Purpose:
     Splitting chapter-wise titles into number and title

   Author(s):    Thomas Schraitle <toms@opensuse.org>
   Copyright: 2012, Thomas Schraitle

-->
<xsl:stylesheet  version="1.0"
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:exsl="http://exslt.org/common"
  xmlns="http://www.w3.org/1999/xhtml"
  exclude-result-prefixes="exsl">


  <xsl:template name="component.title">
   <xsl:param name="node" select="."/>
   <xsl:param name="wrapper"/> 
    
  <!-- This handles the case where a component (bibliography, for example)
       occurs inside a section; will we need parameters for this? -->

  <!-- This "level" is a section level.  To compute <h> level, add 1. -->
  <xsl:variable name="level">
    <xsl:choose>
      <!-- chapters and other book children should get <h1> -->
      <xsl:when test="$node/parent::book">0</xsl:when>
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
  <xsl:variable name="wrapperplus">
    <xsl:choose>
      <xsl:when test="$wrapper = ''">
        <xsl:value-of select="concat('h', $level+1)"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:value-of select="$wrapper"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:variable>

  <xsl:element name="{$wrapperplus}" namespace="http://www.w3.org/1999/xhtml">
    <xsl:attribute name="class">title</xsl:attribute>
    <xsl:call-template name="id.attribute"/>
    <xsl:call-template name="anchor">
      <xsl:with-param name="node" select="$node"/>
      <xsl:with-param name="conditional" select="0"/>
    </xsl:call-template>
    <xsl:call-template name="create.header.title">
      <xsl:with-param name="node" select=".."/>
    </xsl:call-template>
  </xsl:element>
  </xsl:template>
  
  <xsl:template match="article">
    <xsl:call-template name="id.warning"/>
    
    <xsl:element name="{$div.element}" namespace="http://www.w3.org/1999/xhtml">
      <xsl:call-template name="common.html.attributes">
        <xsl:with-param name="inherit" select="1"/>
      </xsl:call-template>
      <xsl:call-template name="id.attribute">
        <xsl:with-param name="conditional" select="0"/>
      </xsl:call-template>
      
      <xsl:call-template name="article.titlepage"/>
      
      <xsl:variable name="toc.params">
        <xsl:call-template name="find.path.params">
          <xsl:with-param name="table" select="normalize-space($generate.toc)"/>
        </xsl:call-template>
      </xsl:variable>
      
      <xsl:call-template name="make.lots">
        <xsl:with-param name="toc.params" select="$toc.params"/>
        <xsl:with-param name="toc">
          <xsl:call-template name="component.toc">
            <xsl:with-param name="toc.title.p" select="contains($toc.params, 'title')"/>
          </xsl:call-template>
        </xsl:with-param>
      </xsl:call-template>
      
      <xsl:apply-templates mode="article.titlepage.recto.auto.mode" select="articleinfo/legalnotice"/>
      <xsl:apply-templates mode="article.titlepage.recto.auto.mode" select="artheader/legalnotice"/>
      <xsl:apply-templates mode="article.titlepage.recto.auto.mode" select="info/legalnotice"/>
      
      <xsl:apply-templates/>
      <xsl:call-template name="process.footnotes"/>
    </xsl:element>
  </xsl:template>  

  <xsl:template match="chapter">
    <xsl:call-template name="id.warning"/>
    
    <xsl:element name="{$div.element}" namespace="http://www.w3.org/1999/xhtml">
      <xsl:call-template name="common.html.attributes">
        <xsl:with-param name="inherit" select="1"/>
      </xsl:call-template>
      <xsl:call-template name="id.attribute">
        <xsl:with-param name="conditional" select="0"/>
      </xsl:call-template>
      
      <xsl:call-template name="component.separator"/>
      <xsl:call-template name="chapter.titlepage"/>
      
      <xsl:variable name="toc.params">
        <xsl:call-template name="find.path.params">
          <xsl:with-param name="table" select="normalize-space($generate.toc)"/>
        </xsl:call-template>
      </xsl:variable>
      <xsl:if test="contains($toc.params, 'toc')">
        <div class="line">
        <xsl:call-template name="component.toc">
          <xsl:with-param name="toc.title.p" select="contains($toc.params, 'title')"/>
        </xsl:call-template>
        <xsl:call-template name="component.toc.separator"/>
        </div>
      </xsl:if>
      <xsl:apply-templates/>
      <xsl:call-template name="process.footnotes"/>
    </xsl:element>
  </xsl:template>
  
  <xsl:template match="chapter/title|chapter/chapterinfo/title|chapter/info/title" mode="titlepage.mode" priority="2">
    <xsl:call-template name="component.title">
      <xsl:with-param name="node" select="ancestor::chapter[1]"/>
    </xsl:call-template>
  </xsl:template>
  
  <xsl:template match="chapter/subtitle|chapter/chapterinfo/subtitle|chapter/info/subtitle|chapter/docinfo/subtitle" mode="titlepage.mode" priority="2">
    <xsl:call-template name="component.subtitle">
      <xsl:with-param name="node" select="ancestor::chapter[1]"/>
    </xsl:call-template>
  </xsl:template>

</xsl:stylesheet>