<?xml version="1.0" encoding="UTF-8"?>
<!-- 
   Purpose:
     Creates DOCTYPE headers manually
   
   Templates:
     * create.doctype:
       Creates a DOCTYPE header with the following parameters:
       - rootnode: 
         root node of the document
       - public.identifier: 
         the public identifier after the PUBLIC keyword
       - system.identifier:
         the system identifier, followed after the public
       - internal.subset:
         If not empty, inserted any code which is included as internal subset
         of the DTD. The "[" and "]" characters are provided.
         
     * create.db45.doctype
       Creates a DOCTYPE header for DocBook V4.5
       Only parameters rootnode and internal.subset are allowed
       see create.doctype
       Additional parameters:
       - version (default "4.5")
         The DocBook version used
       
     * create.novdoc.doctype
       Creates a DOCTYPE header for Novdoc V1.0
       Only parameters rootnode and internal.subset are allowed
       see create.doctype
       Additional parameters:
       - version (default "1.0")
         The Novdoc version used
   
   Input:
     n/a, must be imported in other stylesheets
     
   Output:
     Text node with DOCTYPE declaration
   
   Author:    Thomas Schraitle <toms@opensuse.org>
   Copyright: 2015, Thomas Schraitle

-->

<xsl:stylesheet version="1.0"
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform">


<xsl:template name="create.doctype">
  <xsl:param name="rootnode" select="."/>
  <xsl:param name="public.identifier"/>
  <xsl:param name="system.identifier"/>
  <xsl:param name="internal.subset"/>
  
  <xsl:text disable-output-escaping="yes">&lt;!DOCTYPE </xsl:text>
  <xsl:value-of select="local-name($rootnode)"/>
  <xsl:text> PUBLIC </xsl:text>
  <xsl:value-of select="concat('&quot;', $public.identifier, '&quot;&#10;')"/>
  <xsl:value-of select="concat('&quot;', $system.identifier, '&quot;&#10;')"/>
  <xsl:if test="$internal.subset != ''">
    <xsl:text>[&#10;</xsl:text>
    <xsl:value-of select="$internal.subset"/>
    <xsl:text>&#10;]</xsl:text>
  </xsl:if>
  <xsl:text>></xsl:text>
</xsl:template>

<xsl:template name="create.db45.doctype">
  <xsl:param name="rootnode" select="."/>
  <xsl:param name="internal.subset"/>
  <xsl:param name="version">4.5</xsl:param>
  <xsl:call-template name="create.doctype">
    <xsl:with-param name="rootnode" select="$rootnode"/>
    <xsl:with-param name="public.identifier">-//OASIS//DTD DocBook XML V<xsl:value-of select="$version"/>//EN</xsl:with-param>
    <xsl:with-param name="system.identifier">http://www.oasis-open.org/docbook/xml/<xsl:value-of select="$version"/>/docbookx.dtd</xsl:with-param>
    <xsl:with-param name="internal.subset" select="$internal.subset"/>
  </xsl:call-template>
</xsl:template>

<xsl:template name="create.novdoc.doctype">
  <xsl:param name="rootnode" select="."/>
  <xsl:param name="internal.subset"/>
  <xsl:param name="version">1.0</xsl:param>
  <xsl:call-template name="create.doctype">
    <xsl:with-param name="rootnode" select="$rootnode"/>
    <xsl:with-param name="public.identifier">-//Novell//DTD NovDoc XML V<xsl:value-of select="$version"/>//EN</xsl:with-param>
    <xsl:with-param name="system.identifier">novdocx.dtd</xsl:with-param>
    <xsl:with-param name="internal.subset" select="$internal.subset"/>
  </xsl:call-template>
</xsl:template>

</xsl:stylesheet>