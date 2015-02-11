<?xml version="1.0" encoding="UTF-8"?>
<!--
   Purpose:
     Extract a division and all its descendants by providing a ID;
     if no rootid parameter is given, the complete set is copied.
     
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

<xsl:stylesheet version="1.0" 
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:d="http://docbook.org/ns/docbook"
  exclude-result-prefixes="d">
  
  <xsl:import href="rootid.xsl"/>
  <xsl:import href="../lib/create-doctype.xsl"/>

<!-- fs 2014-11-21:
     This always generates a NovDoc Header, which is no good on systems where
     NovDoc is not installed. The header should be generated in compliance
     with the original MAIN. This will also be needed for DocBook5.

     As a workaround I will use a standard Docbook 4.5 Header for now - Novdoc
     will work with it anyway, since it is backwards compatible to DocBook4
  
  <xsl:output method="xml" encoding="UTF-8" 
     doctype-public="-//Novell//DTD NovDoc XML V1.0//EN"
     doctype-system="novdocx.dtd"/>
     
     See https://sourceforge.net/p/daps/tickets/249/
-->

  <!-- No xsl:output here! We create the DOCTYPE header manually *sigh* -->


  <xsl:template match="/">
    <xsl:variable name="pi" select="processing-instruction('xml-stylesheet')"/>
    <xsl:choose>
      <xsl:when test="/d:*">
        <!-- We don't need a DOCTYPE header for DocBook >5, skip it -->
      </xsl:when>
      
      <xsl:when test="contains($pi, 'novdoc-profile')">
        <xsl:call-template name="create.novdoc.doctype">
          <xsl:with-param name="rootnode" select="*[1]"/>
        </xsl:call-template>
      </xsl:when>
      <xsl:when test="contains($pi, 'docbook4')">
        <xsl:call-template name="create.db45.doctype">
          <xsl:with-param name="rootnode" select="*[1]"/>
        </xsl:call-template>
      </xsl:when>
      
      <xsl:otherwise>
        <!-- we can't be sure here: -->
        <xsl:message>WARNING: Could not determin DocBook or Novdoc version. No PI xml-stylesheets found! Using DocBook V4 header.</xsl:message>
        <xsl:call-template name="create.db45.doctype">
          <xsl:with-param name="rootnode" select="*[1]"/>
        </xsl:call-template>
      </xsl:otherwise>
    </xsl:choose>
    <xsl:call-template name="process.rootid.node"/>
  </xsl:template>

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
    <!-- No rootid parameter given, copy the complete tree -->
    <xsl:copy-of select="/"/>
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
