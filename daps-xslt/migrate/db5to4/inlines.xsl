<?xml version="1.0" encoding="UTF-8"?>
<!--
   Purpose:
     Templates for inline elements

   Input:
     Valid DocBook5


   Author:    Thomas Schraitle <toms@opensuse.org>
   Copyright:  2015 SUSE Linux GmbH

-->
<xsl:stylesheet version="1.0"
  xmlns:d="http://docbook.org/ns/docbook"
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:xi="http://www.w3.org/2001/XInclude"
  xmlns:xlink="http://www.w3.org/1999/xlink"
  xmlns:html="http://www.w3.org/1999/xhtml"
  xmlns:exsl="http://exslt.org/common"
  exclude-result-prefixes="d xi xlink exsl html">

  <!-- Omit any phrase inside guimenus -->
  <xsl:template match="d:guimenu/d:phrase">
    <xsl:apply-templates select="*"/>
  </xsl:template>

  <xsl:template match="d:tag">
    <sgmltag>
      <xsl:apply-templates select="@*|node()"/>
    </sgmltag>
  </xsl:template>

  <xsl:template match="d:author/d:personname|d:editor/d:personname">
   <!-- Ignore personname for DocBook4 -->
   <xsl:apply-templates/>
  </xsl:template>
</xsl:stylesheet>