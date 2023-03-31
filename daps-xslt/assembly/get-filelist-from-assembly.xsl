<?xml version="1.0" encoding="UTF-8"?>
<!--

   Purpose:
     Find all files references in an assembly

   Input:
     DocBook 5 assembly document

   Output:
     Text output

   Parameters:
     * seperator (string): separator between each file, default is space

   Author:
     Thomas Schraitle <toms@opensuse.org>

   Copyright (C) 2023 SUSE Linux GmbH

-->
<xsl:stylesheet version="1.0"
  xmlns:d="http://docbook.org/ns/docbook"
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform">

  <xsl:strip-space elements="*"/>
  <xsl:output method="text"/>

  <xsl:key name="resources" match="d:resources/d:resource" use="@xml:id"/>

  <!-- Parameter -->
  <xsl:param name="seperator" select="' '"/>

  <!-- Templates -->
  <xsl:template match="text()"/>

  <xsl:template match="d:structure">
    <xsl:apply-templates select="*|@resourceref"/>
  </xsl:template>

  <xsl:template match="d:structure/@resourceref">
    <xsl:variable name="href" select="."/>
    <xsl:value-of select="concat(key('resources', $href)/@href, $seperator)"/>
  </xsl:template>

  <xsl:template match="d:module">
    <xsl:variable name="href" select="@resourceref"/>
    <xsl:value-of select="concat(key('resources', $href)/@href, $seperator)"/>
    <xsl:apply-templates/>
  </xsl:template>

</xsl:stylesheet>