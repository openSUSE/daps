<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0"
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:exsl="http://exslt.org/common"
  xmlns:fo="http://www.w3.org/1999/XSL/Format"
  exclude-result-prefixes="exsl">
  
  <xsl:template match="set|book|article" mode="fop1.outline"
    priority="2">
    
    <xsl:variable name="id">
      <xsl:call-template name="object.id"/>
    </xsl:variable>
    <xsl:variable name="bookmark-label">
      <xsl:apply-templates select="." mode="object.title.markup"/>
    </xsl:variable>
    <xsl:variable name="toc.params">
      <xsl:call-template name="find.path.params">
        <xsl:with-param name="table"
          select="normalize-space($generate.toc)"/>
      </xsl:call-template>
    </xsl:variable>
    
    <xsl:message>######## <xsl:value-of select="local-name()"
    />
      toc.params: <xsl:value-of select="$toc.params"/>
    </xsl:message>
    
    
    <fo:bookmark internal-destination="{$id}">
      <xsl:attribute name="starting-state">
        <xsl:value-of select="$bookmarks.state"/>
      </xsl:attribute>
      <fo:bookmark-title>
        <xsl:value-of select="normalize-space($bookmark-label)"/>
      </fo:bookmark-title>
    </fo:bookmark>
    
    <xsl:if  test="contains($toc.params, 'toc')
      and (book|part|reference|preface|chapter|appendix|article|topic
      |glossary|bibliography|index|setindex
      |refentry
      |sect1|sect2|sect3|sect4|sect5|section)">
      <xsl:message>yes!!!</xsl:message>
      <fo:bookmark internal-destination="toc...{$id}">
        <fo:bookmark-title>
          <xsl:call-template name="gentext">
            <xsl:with-param name="key" select="'TableofContents'"/>
          </xsl:call-template>
        </fo:bookmark-title>
      </fo:bookmark>
    </xsl:if>
    <xsl:apply-templates select="*" mode="fop1.outline"/>
  </xsl:template>
  
  
</xsl:stylesheet>