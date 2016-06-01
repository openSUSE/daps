<?xml version="1.0" encoding="UTF-8"?>
<!--
   Purpose:
     Extract a division and all its descendants by providing a ID;
     if no rootid parameter is given, the complete set is copied.
     
   Parameters:
     * rootid
       Applies stylesheet only to part of the document
       
   Input:
     DocBook 4/5/Novdoc document
   
   Dependencies:
     - DocBook XSL stylesheets: common/l10n.xsl
     - rootid.xsl
     - ../lib/resolve-xrefs.xsl

   Implementation Details:
     Currently, the main task is done by the xref template rule: It
     checks if the link goes outside the current book or not.
     Furthermore, it distinguishes between DB4 and DB5. The actual resolving
     mechanism is done in the xref.target mode, separately for DB4 and DB5.
     
   Output:
     Reduced XML which contains only a fraction of the original document
   
   Author:    Thomas Schraitle <toms@opensuse.org>
   Copyright (C) 2012-2015 SUSE Linux GmbH
   
-->

<!DOCTYPE xsl:stylesheet
[
  <!ENTITY db5ns "http://docbook.org/ns/docbook">
]>

<xsl:stylesheet version="1.0" 
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:d="http://docbook.org/ns/docbook"
  exclude-result-prefixes="d">
  
  <xsl:import href="rootid.xsl"/>
  <xsl:import href="../lib/create-doctype.xsl"/>

  <xsl:import href="http://docbook.sourceforge.net/release/xsl/current/common/l10n.xsl"/>
 
  <xsl:include href="../lib/resolve-xrefs.xsl"/>

  <xsl:param name="l10n.gentext.language"/>
  <xsl:param name="l10n.gentext.use.xref.language" select="0"/>

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
         https://github.com/openSUSE/daps/issues/248
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
    <xsl:variable name="title" select="(key('id', $rootid)/d:title |
                                       key('id', $rootid)/d:info/d:title |
                                       key('id', $rootid)/bookinfo/title)[1]"/>
    <xsl:message>
      <xsl:text>Reducing book to rootid="</xsl:text>
      <xsl:value-of select="$rootid"/>
      <xsl:text>" </xsl:text>
      <xsl:value-of select="name(key('id', $rootid))"/>
      <xsl:text> title="</xsl:text>
      <xsl:value-of select="normalize-space($title)"/>
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


</xsl:stylesheet>
