<?xml version="1.0" encoding="UTF-8"?>
<!--
   Purpose:
     Extract a division and all its descendants by providing a ID
     
   Parameters:
     * rootid
       Applies stylesheet only to part of the document
       
   Input:
     DocBook 4/Novdoc document
     
   Output:
     Reduced XML which contains only a fraction of the original document
   
   Author:    Thomas Schraitle <toms@opensuse.org>
   Copyright: 2012, Thomas Schraitle
   
-->

<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
  
  <xsl:import href="rootid.xsl"/>
  
  <xsl:output method="xml" encoding="UTF-8" 
     doctype-public="-//Novell//DTD NovDoc XML V1.0//EN"
     doctype-system="novdocx.dtd"/>

  <xsl:template name="rootid.process">
    <xsl:message>
      <xsl:text>Reducing book to rootid="</xsl:text>
      <xsl:value-of select="$rootid"/>
      <xsl:text>" </xsl:text>
      <xsl:value-of select="name(key('id', $rootid))"/>
      <xsl:text> title="</xsl:text>
      <xsl:value-of select="normalize-space(key('id', $rootid)/bookinfo/title)"/>
      <xsl:text>"</xsl:text>
    </xsl:message>
    <xsl:apply-templates select="key('id',$rootid)" mode="process.root"/>
  </xsl:template>
  
  <xsl:template name="normal.process">
    <xsl:message terminate="yes">ERROR: No rootid given. Nothing to do.</xsl:message>
  </xsl:template>

  <xsl:template match="node()" mode="process.root">
    <xsl:copy>
      <xsl:copy-of select="@*"/>
      <xsl:apply-templates mode="process.root"/>
    </xsl:copy>
  </xsl:template>

  <xsl:template match="xref" name="xref" mode="process.root" priority="2">
    <xsl:variable name="targets" select="key('id',@linkend)"/>
    <xsl:variable name="target" select="$targets[1]"/>
    <xsl:variable name="refelem" select="local-name($target)"/>
    <xsl:variable name="target.book" select="$target/ancestor-or-self::book"/>
    <xsl:variable name="this.book" select="ancestor-or-self::book"/>

    <xsl:choose>
      <xsl:when test="generate-id($target.book) = generate-id($this.book)">
        <!-- xref points into the same book -->
        <xref>
          <xsl:copy-of select="@*"/>
        </xref>
      </xsl:when>
      <xsl:otherwise>
        <!-- xref points into another book -->
        <!--<xsl:message>target/title:
        <xsl:value-of select="normalize-space($target/title)"/>
        </xsl:message>-->
        <phrase>
          <xsl:attribute name="role">
            <xsl:text>externalbook-</xsl:text>
            <xsl:value-of select="@linkend"/>
          </xsl:attribute>
        <xsl:text>&#8220;</xsl:text>
          <xsl:choose>
            <xsl:when test="$target/title">
              <xsl:value-of select="normalize-space($target/title)"/>
            </xsl:when>
            <xsl:when test="$target/bookinfo/title">
              <xsl:value-of select="normalize-space($target/bookinfo/title)"/>
            </xsl:when>
          </xsl:choose>
          
          <xsl:text>&#8221; (</xsl:text>
        <xsl:if
          test="$target/self::sect1 or
          $target/self::sect2 or
          $target/self::sect3 or
          $target/self::sect4">
          <xsl:text>Chapter &#8220;</xsl:text>
          <xsl:value-of select="($target/ancestor-or-self::chapter |
            $target/ancestor-or-self::appendix |
            $target/ancestor-or-self::preface)[1]/title"/>
          <xsl:text>&#8221;, </xsl:text>
        </xsl:if>
        <xsl:text>&#x2191;</xsl:text>
        <xsl:value-of select="normalize-space($target.book/bookinfo/title)"/>
        <xsl:text>)</xsl:text>
        </phrase>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

</xsl:stylesheet>
