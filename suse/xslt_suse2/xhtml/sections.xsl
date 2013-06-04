<?xml version="1.0" encoding="UTF-8"?>
<!-- 
  Purpose:
     Splitting section-wise titles into number and title

   Author(s):    Thomas Schraitle <toms@opensuse.org>
   Copyright: 2012, Thomas Schraitle

-->
<xsl:stylesheet version="1.0"
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:exsl="http://exslt.org/common"
  xmlns="http://www.w3.org/1999/xhtml"
  exclude-result-prefixes="exsl">

  <xsl:template name="create.header.title">
    <xsl:param name="node" select="."/>
    <xsl:param name="level" select="0"/>
    <xsl:param name="legal" select="0"/>
    <xsl:variable name="label">
      <xsl:apply-templates select="$node" mode="label.markup">
        <xsl:with-param name="allow-anchors" select="1"/>
      </xsl:apply-templates>
    </xsl:variable>
    <!-- NOTE: The gentext context is NOT considered -->
    <xsl:if test="$legal = 0">
      <span class="number">
        <xsl:copy-of select="$label"/>
        <xsl:text> </xsl:text>
      </span>
    </xsl:if>
    <span class="name">
      <xsl:apply-templates select="$node" mode="title.markup">
        <xsl:with-param name="allow-anchors" select="1"/>
      </xsl:apply-templates>
    </span>
    <xsl:text> </xsl:text>
  </xsl:template>


<xsl:template match="sect1[@role='legal']|section[@role='legal']|
                     part[@role='legal']|chapter[@role='legal']|
                     appendix[@role='legal']">
  <xsl:choose>
    <xsl:when test="ancestor::*[@role='legal']">
      <xsl:apply-imports/>
    </xsl:when>
    <xsl:otherwise>
      <div class="legal-section">
        <xsl:apply-imports/>
      </div>
    </xsl:otherwise>
  </xsl:choose>
</xsl:template>


<xsl:template name="section.heading">
  <xsl:param name="section" select="."/>
  <xsl:param name="level" select="1"/>
  <xsl:param name="allow-anchors" select="1"/>
  <xsl:param name="title"/>
  <xsl:variable name="legal">
    <xsl:choose>
      <xsl:when test="$section/ancestor::*[@role='legal']">1</xsl:when>
      <xsl:otherwise>0</xsl:otherwise>
    </xsl:choose>
  </xsl:variable>
  <xsl:variable name="class">title<xsl:if test="$legal = 1"> legal</xsl:if></xsl:variable>

  <xsl:variable name="id">
    <xsl:choose>
      <!-- Make sure the subtitle doesn't get the same id as the title -->
      <xsl:when test="self::subtitle">
        <xsl:call-template name="object.id">
          <xsl:with-param name="object" select="."/>
        </xsl:call-template>
      </xsl:when>
      <!-- if title is in an *info wrapper, get the grandparent -->
      <xsl:when test="contains(local-name(..), 'info')">
        <xsl:call-template name="object.id">
          <xsl:with-param name="object" select="../.."/>
        </xsl:call-template>
      </xsl:when>
      <xsl:otherwise>
        <xsl:call-template name="object.id">
          <xsl:with-param name="object" select=".."/>
        </xsl:call-template>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:variable>

  <!-- HTML H level is one higher than section level -->
  <xsl:variable name="hlevel">
    <xsl:choose>
      <!-- highest valid HTML H level is H6; so anything nested deeper
           than 5 levels down just becomes H6 -->
      <xsl:when test="$level &gt; 5">6</xsl:when>
      <xsl:otherwise>
        <xsl:value-of select="$level + 1"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:variable>

  <xsl:element name="h{$hlevel}" namespace="http://www.w3.org/1999/xhtml">
    <xsl:attribute name="class"><xsl:value-of select="$class"/></xsl:attribute>

    <xsl:if test="$allow-anchors != 0">
      <xsl:call-template name="id.attribute">
        <xsl:with-param name="node" select="$section"/>
        <xsl:with-param name="force" select="1"/>
      </xsl:call-template>
    </xsl:if>
    <xsl:call-template name="create.header.title">
      <xsl:with-param name="node" select=".."/>
      <xsl:with-param name="level" select="$level"/>
      <xsl:with-param name="legal" select="$legal"/>
    </xsl:call-template>
    <xsl:call-template name="create.permalink">
       <xsl:with-param name="object" select="$section"/>
    </xsl:call-template>
  </xsl:element>
  <xsl:call-template name="debug.filename-id"/>
</xsl:template>

<xsl:template name="debug.filename-id">
  <xsl:param name="node" select="."/>
  <xsl:variable name="xmlbase" 
    select="ancestor-or-self::*[self::chapter or 
                                self::appendix or
                                self::part or
                                self::reference or 
                                self::preface or
                                self::glossary or
                                self::sect1 or 
                                self::sect2 or
                                self::sect3 or
                                self::sect4]/@xml:base"/>
  
  <xsl:if test="$draft.mode = 'yes' and $xmlbase != ''">
    <div class="doc-status">
      <ul>
        <li>
          <span class="ds-label">Filename: </span>
          <xsl:value-of select="$xmlbase"/>
        </li>
        <li>
          <span class="ds-label">ID: </span>
          <xsl:choose>
            <xsl:when test="$node/parent::*[@id] != ''">
              <xsl:call-template name="object.id">
                <xsl:with-param name="object" select="$node/parent::*"/>
              </xsl:call-template>
            </xsl:when>
            <xsl:otherwise><span class="ds-message">no ID found</span></xsl:otherwise>
          </xsl:choose>
        </li>
      </ul>
    </div>
  </xsl:if>
</xsl:template>


</xsl:stylesheet>
