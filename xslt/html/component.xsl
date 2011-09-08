<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  version="1.0">
  
  <xsl:template name="component.title">
    <xsl:param name="node" select="."/>
    
    <!--<xsl:message>component.title: <xsl:value-of
      select="concat(name(.), 
              ':',
              ancestor-or-self::title)"/></xsl:message>-->
    
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
    <!-- Let's handle the case where a component (bibliography, for example)
      occurs inside a section; will we need parameters for this? -->
    
    <xsl:element name="h{$level+1}">
      <xsl:attribute name="class">title</xsl:attribute>
      <xsl:if test="$generate.id.attributes = 0">
        <xsl:call-template name="anchor">
          <xsl:with-param name="node" select="$node"/>
          <xsl:with-param name="conditional" select="0"/>
        </xsl:call-template>
      </xsl:if>
      <xsl:apply-templates select="$node" mode="object.title.markup">
        <xsl:with-param name="allow-anchors" select="1"/>
      </xsl:apply-templates>
      <xsl:call-template name="permalink">
        <xsl:with-param name="id" select="$id"/>
        <xsl:with-param name="title" select="title"/>
      </xsl:call-template>
      <xsl:call-template name="addos">
	<xsl:with-param name="id" select="$id"/>
	<xsl:with-param name="title" select="title"/>
      </xsl:call-template>
      <xsl:call-template name="addstatus">
	<xsl:with-param name="id" select="$id"/>
	<xsl:with-param name="title" select="title"/>
      </xsl:call-template>
      <xsl:call-template name="debug.filename"/>
      <xsl:call-template name="addid"/>
    </xsl:element>
  </xsl:template>
  
  
</xsl:stylesheet>
