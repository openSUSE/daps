<?xml version="1.0"?>
<!--
   Purpose:
     Creates a hierarchy without text nodes. All elements, comments(*), 
     processing-instructions(*) and attributs are preserved.
     
     (*) Can be enabled or disabled
     
   Parameters:
     * use.comments (default: 0)
       Should comments be preserved? (1=yes, 0=no)
       
     * use.pis (default: 0)
       Should processing instructions be preserved? (1=yes, 0=no)
       
     * use.indexterms (default: 1)
       Should indexterms be copied? (1=yes, 0=no)
       
   Input:
     DocBook 4/Novdoc document
     
   Output:
     DocBook XML structure without any text nodes
   
   Author:    Thomas Schraitle <toms@opensuse.org>
   Copyright (C) 2012-2015 SUSE Linux GmbH
   
-->

<xsl:stylesheet version="1.0"
   xmlns:xi="http://www.w3.org/2001/XInclude"
   xmlns:xsl="http://www.w3.org/1999/XSL/Transform">

<xsl:import href="copy.xsl"/>

<xsl:output method="xml"
   indent="yes"/>
<!--
   doctype-public="-//SuSE//DTD DocBook XML V4.3-Based Variant 1.0//EN"
   doctype-system="http://w3.suse.de/~lxbuch/dtd/1.0/susex.dtd"
-->

<!-- Some parameters -->
<xsl:param name="use.comments" select="0"/>
<xsl:param name="use.pis" select="0"/>
<xsl:param name="use.indexterms" select="1"/>


<!-- ====================================================== -->
<!-- Standard rules                                         -->
<xsl:template match="text()"/>

<xsl:template match="processing-instruction()">
   <xsl:if test="$use.pis != 0">
      <xsl:copy-of select="."/>
   </xsl:if>
</xsl:template>

<xsl:template match="comment()">
   <xsl:if test="$use.comments != 0">
      <xsl:text>&#10;</xsl:text>
      <xsl:copy-of select="."/>
      <xsl:text>&#10;</xsl:text>
   </xsl:if>
</xsl:template>

<xsl:template match="remark"/>

<xsl:template match="indexterm|primary|secondary|tertiary|see|seealso">
   <xsl:if test="$use.indexterms != 0">
      <xsl:apply-templates/>
   </xsl:if>
</xsl:template>

<xsl:template match="xi:include|xi:fallback">
   <xsl:copy-of select="."/>
</xsl:template>

</xsl:stylesheet>
