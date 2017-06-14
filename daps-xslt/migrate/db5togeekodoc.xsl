<?xml version="1.0" encoding="UTF-8"?>
<!--
   Purpose:
     Migrate a DocBook5 document to Geekodoc (main stylesheet)

   Parameters:
     see param.xsl

   Input:
     Valid DocBook5


   Author:    Thomas Schraitle <toms@opensuse.org>
   Copyright:  2016 SUSE Linux GmbH

-->
<xsl:stylesheet version="1.0" xmlns="http://docbook.org/ns/docbook"
 xmlns:d="http://docbook.org/ns/docbook"
 xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
 xmlns:xi="http://www.w3.org/2001/XInclude"
 xmlns:xlink="http://www.w3.org/1999/xlink"
 xmlns:html="http://www.w3.org/1999/xhtml" xmlns:exsl="http://exslt.org/common"
 exclude-result-prefixes="d xi xlink exsl html">

 <xsl:import href="../common/copy.xsl"/>

 <xsl:output indent="yes"/>

 <!-- =============================================================== -->
 <xsl:param name="rootid"/>

 <!-- =============================================================== -->
 <!-- Helper templates -->
 <xsl:template name="section.level">
  <xsl:param name="node" select="."/>
  <xsl:choose>
   <xsl:when test="local-name($node) = 'sect1'">1</xsl:when>
   <xsl:when test="local-name($node) = 'sect2'">2</xsl:when>
   <xsl:when test="local-name($node) = 'sect3'">3</xsl:when>
   <xsl:when test="local-name($node) = 'sect4'">4</xsl:when>
   <xsl:when test="local-name($node) = 'sect5'">5</xsl:when>
   <xsl:when test="local-name($node) = 'section'">
    <xsl:choose>
     <xsl:when test="$node/../../../../../../d:section">6</xsl:when>
     <xsl:when test="$node/../../../../../d:section">5</xsl:when>
     <xsl:when test="$node/../../../../d:section">4</xsl:when>
     <xsl:when test="$node/../../../d:section">3</xsl:when>
     <xsl:when test="$node/../../d:section">2</xsl:when>
     <xsl:otherwise>1</xsl:otherwise>
    </xsl:choose>
   </xsl:when>
   <!--<xsl:when test="local-name($node)='refsect1' or
        local-name($node)='refsect2' or
        local-name($node)='refsect3' or
        local-name($node)='refsection' or
        local-name($node)='refsynopsisdiv'">
        <xsl:call-template name="refentry.">
          <xsl:with-param name="node" select="$node"/>
        </xsl:call-template>
      </xsl:when>-->
   <xsl:when test="local-name($node) = 'simplesect'">
    <xsl:choose>
     <xsl:when test="$node/../../d:sect1">2</xsl:when>
     <xsl:when test="$node/../../d:sect2">3</xsl:when>
     <xsl:when test="$node/../../d:sect3">4</xsl:when>
     <xsl:when test="$node/../../d:sect4">5</xsl:when>
     <xsl:when test="$node/../../d:sect5">5</xsl:when>
     <xsl:when test="$node/../../d:section">
      <xsl:choose>
       <xsl:when test="$node/../../../../../d:section">5</xsl:when>
       <xsl:when test="$node/../../../../d:section">4</xsl:when>
       <xsl:when test="$node/../../../d:section">3</xsl:when>
       <xsl:otherwise>2</xsl:otherwise>
      </xsl:choose>
     </xsl:when>
     <xsl:otherwise>1</xsl:otherwise>
    </xsl:choose>
   </xsl:when>
   <xsl:otherwise>1</xsl:otherwise>
  </xsl:choose>
 </xsl:template>


 <!-- =============================================================== -->
 <!-- Division Elements -->
 <xsl:template match="d:section">
  <xsl:variable name="depth">
   <xsl:call-template name="section.level"/>
  </xsl:variable>

  <xsl:element name="sect{$depth}">
   <xsl:apply-templates select="@*"/>
   <xsl:apply-templates/>
  </xsl:element>
 </xsl:template>

 <!-- =============================================================== -->
 <!-- Block Elements -->
 <xsl:template match="d:step/d:procedure">
  <substeps>
   <xsl:apply-templates/>
  </substeps>
 </xsl:template>

 <!-- =============================================================== -->
 <!-- Inline Elements -->
 <xsl:template match="d:guilabel">
  <guimenu>
   <xsl:apply-templates/>
  </guimenu>
 </xsl:template>

</xsl:stylesheet>
