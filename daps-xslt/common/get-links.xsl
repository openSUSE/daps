<?xml version="1.0"?>
<!--
   Purpose:
     Extracts all <ulink>s or <link>s from a DocBook document and
     creates a HTML page for "daps checkbot"
     
   Parameters:
     * nolocalhost (default: 1)
       Suppressing localhost URLs (1=yes, 0=no)
     * rootid
       Applies stylesheet only to part of the document
       
   Input:
     DocBook 4/5 document
     
   Output:
     HTML file which contains all links from a document, easy to feed
     to checkbot
   
   Author:    Thomas Schraitle <toms@opensuse.org>
   Copyright (C) 2012-2015 SUSE Linux GmbH
   
-->
<xsl:stylesheet version="1.0" 
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:xlink="http://www.w3.org/1999/xlink"
  xmlns:d="http://docbook.org/ns/docbook"
  exclude-result-prefixes="d xlink">

  <xsl:output method="html"/>

  <xsl:key name="id" match="*" use="@id|@xml:id"/>
    
  <xsl:param name="nolocalhost" select="1"/>
  <xsl:param name="rootid"/>

  <xsl:template match="/">
    <html>
      <body>
        <xsl:choose>
          <xsl:when test="$rootid != ''">
            <h1>
              <xsl:text>Links for </xsl:text>
              <xsl:choose>
                <xsl:when test="key('id',$rootid)/@xml:base">
                  <xsl:value-of select="key('id',$rootid)/@xml:base"/>
                  <xsl:text> (id=</xsl:text>
                  <xsl:value-of select="$rootid"/>
                  <xsl:text>)</xsl:text>
                </xsl:when>
              </xsl:choose>
            </h1>
            <p>Total links: <xsl:value-of
                select="count(key('id',$rootid)//ulink|
                              key('id',$rootid)//d:link
                             )"/></p>
            <xsl:apply-templates select="key('id',$rootid)//ulink |
                                         key('id',$rootid)//d:link"/>
          </xsl:when>
          <xsl:otherwise>
            <h1>Links for Checkbot</h1>
            <p>Total links: <xsl:value-of select="count(.//ulink|.//d:link)"/></p>
            <br/>
            <xsl:apply-templates select=".//ulink|.//d:link"/>
          </xsl:otherwise>
        </xsl:choose>
      </body>
    </html>
  </xsl:template>

  <xsl:template match="ulink|d:link">
    <xsl:variable name="href" select="@url|@xlink:href"/>
    <xsl:choose>
      <xsl:when test="starts-with($href, 'http://') or 
                      starts-with($href, 'https://')">
        <xsl:choose>
          <xsl:when test="$nolocalhost != 0 and 
                          contains($href, 'localhost')">
            <xsl:message> Suppressing URL "<xsl:value-of
              select="$href"/>"</xsl:message>
          </xsl:when>
          <xsl:otherwise>
            <p>
              <a href="{$href}"><xsl:value-of select="$href"/></a>
              <xsl:call-template name="getxmlbase"/>
            </p>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:when>
      <xsl:when test="starts-with($href, 'ftp') or 
                      starts-with($href, 'sftp')">
        <p>
          <a href="{$href}"><xsl:value-of select="$href"/></a>
          <xsl:call-template name="getxmlbase"/>
        </p>
      </xsl:when>
      <xsl:when test="starts-with($href, 'mailto')">
        <!--<p>Test this mailto reference: <xsl:value-of select="$href"/></p>-->
      </xsl:when>
      <xsl:when test="contains($href, '@')">
        <xsl:message> HINT: Missing mailto in '<xsl:value-of
            select="$href"/>'?</xsl:message>
      </xsl:when>
      <xsl:when test="starts-with($href, 'file')">
        <p>Local reference available? <xsl:value-of select="$href"/></p>
      </xsl:when>
      <xsl:otherwise>
        <p>WARNING: Fix syntax of this link: "<span style="color:red"
              ><xsl:value-of select="$href"/></span>"</p>
        <xsl:message> HINT: Check syntax of this link: <xsl:value-of
            select="$href"/></xsl:message>
      </xsl:otherwise>
    </xsl:choose>
    <!--</xsl:for-each>-->
  </xsl:template>



<xsl:template name="getxmlbase">
  <xsl:param name="node" select="."/>
  
  <xsl:choose>
    <xsl:when test="$node/ancestor::*/@xml:base">
      <xsl:text> </xsl:text>
      <span class="xmlbase">Filename: <xsl:value-of select="$node/ancestor::*/@xml:base"/></span>
    </xsl:when>
    <xsl:otherwise>
      <xsl:message> No ancestor with xml:base for '<xsl:value-of
        select="concat(name(.), '@id=', @id)"/>' found.</xsl:message>
    </xsl:otherwise>
  </xsl:choose>  
</xsl:template>
</xsl:stylesheet>
