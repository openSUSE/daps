<?xml version="1.0"?>
<!--
   Purpose:
     Print titles of DocBook divisions
     
   Parameters:
     * separator (default: " ")
       Split each filename with the content of this parameter
     
     * endseparator (default: "\n")
       Terminate the list with the content of this parameter
   
     * rootid (imported)
       Applies stylesheet only to part of the document
       
   Input:
     DocBook 4/Novdoc document
     
   Output:
     Text with the following structure:
       [ ]TITLE (@id)
   
   Author:    Thomas Schraitle <toms@opensuse.org>
   Copyright (C) 2012-2015 SUSE Linux GmbH
   
-->

<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  version="1.0">

  <xsl:import href="rootid.xsl"/>
  <xsl:output method="text" encoding="UTF-8"/>

  <!-- this stylesheets prints a table of contents with filename, element, title and ID -->

  <xsl:param name="separator" select="' '"/>
  <xsl:param name="endseparator" select="'&#10;'"/>

  <xsl:template match="text()"/>


  <xsl:template match="book|article">
    <xsl:param name="indent" select="''"/>
    <xsl:variable name="title">
      <xsl:choose>
        <xsl:when test="bookinfo/title">
          <xsl:value-of select="normalize-space(bookinfo/title)"/>
        </xsl:when>
        <xsl:otherwise>
          <xsl:value-of select="normalize-space(title)"/>
        </xsl:otherwise>
      </xsl:choose>      
    </xsl:variable>
    
    <xsl:value-of select="concat(local-name(), ': ', normalize-space($title))" />
    <xsl:choose>
      <xsl:when test="@xml:base">
        <xsl:value-of select="concat(' (', @xml:base, ')')"/>
      </xsl:when>
    </xsl:choose>
    <xsl:text>&#10;</xsl:text>
    
    <xsl:apply-templates/>
  </xsl:template>

  <xsl:template match="part|chapter|appendix|preface">
    <xsl:param name="indent" select="''"/>
    <!--<xsl:choose>
      <xsl:when test="@xml:base">
        <xsl:call-template name="getbasename"/>
      </xsl:when>
    </xsl:choose>-->
    <!--<xsl:choose>
      <xsl:when test="@id">
        <xsl:value-of select="concat('[ ]',  $indent)"/>
        <xsl:call-template name="gettitle_id"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:value-of
          select="concat('[ ]', $indent, 
            normalize-space(title))"
        />
      </xsl:otherwise>
      </xsl:choose>-->
    
    <xsl:value-of select="concat('[ ]',  $indent)"/>
    
    <xsl:choose>
      <xsl:when test="self::part">
        <xsl:value-of select="concat('Part: ', normalize-space(title))"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:value-of select="normalize-space(title)"/>
      </xsl:otherwise>
    </xsl:choose>
    
    
    <xsl:choose>
      <xsl:when test="@xml:base">
        <xsl:value-of select="concat(' (', @xml:base, ')')"/>
      </xsl:when>
    </xsl:choose>
    <xsl:text>&#10;</xsl:text>
    
    <xsl:apply-templates>
      <xsl:with-param name="indent" select="concat($indent, '  ')"/>
    </xsl:apply-templates>
  </xsl:template>

  <!-- ****************************************** -->

  <xsl:template name="gettitle_id">
    <xsl:param name="node" select="."/>
    <xsl:variable name="title">
      <xsl:choose>
        <xsl:when test="local-name($node)='book'">
          <xsl:value-of select="normalize-space(bookinfo/title)"/>
        </xsl:when>
        <xsl:otherwise>
          <xsl:value-of select="normalize-space(title)"/>
        </xsl:otherwise>
      </xsl:choose>      
    </xsl:variable>
    
    <xsl:value-of select="concat($title,  '&#10;')"/>
  </xsl:template>

  <xsl:template name="getbasename">
    <xsl:param name="node" select="."/>
    <xsl:value-of
      select="concat('-----', $node/@xml:base, '-----', '&#10;')"/>
  </xsl:template>

</xsl:stylesheet>
