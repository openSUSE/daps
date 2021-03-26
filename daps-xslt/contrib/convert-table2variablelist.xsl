<?xml version="1.0" encoding="UTF-8"?>
<!--
   Purpose:
     Converts a informaltable or table into a variablelist.

   Parameters:
     * None

   Input:
     DocBook 5 document

   Output:
     DocBook 5 document with variablelist.

   Design:
     Any elements inside entry/para are copied to a listitem. It is
     assumed, that both content models are the same.

   HINTS:
     * If you want to keep entities, you need to protect them before the
       transformation, for example: &foo; -> [[foo]]
       See libexec/entities-exchange.sh
     * As with almost every XSLT transformation, whitespace can be an issue.
       Either it isn't preserved or additional whitespace can be introduced.

   Author:    Tom Schraitle <toms@opensuse.org>
   Copyright (C) 2021 SUSE Software Solutions Germany GmbH

-->
<xsl:stylesheet version="1.0"
  xmlns="http://docbook.org/ns/docbook"
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:d="http://docbook.org/ns/docbook"
  xmlns:xi="http://www.w3.org/2001/XInclude"
  xmlns:xlink="http://www.w3.org/1999/xlink"
  exclude-result-prefixes="d">

  <xsl:strip-space elements="d:*"/>
  <xsl:output indent="yes"/>

  <!-- Identity transformation, all nodes are copied -->
  <xsl:template match="node() | @*">
    <xsl:copy>
      <xsl:apply-templates select="@* | node()"/>
    </xsl:copy>
  </xsl:template>

  <!-- Ignore these elements -->
  <xsl:template match="d:tgroup/d:thead"/>
  <xsl:template match="d:colspec"/>
  <xsl:template match="d:entry[3]"/>

  <!-- The template rules -->
  <xsl:template match="d:informaltable|d:table">
    <variablelist>
      <xsl:copy-of select="@*"/>
      <xsl:apply-templates/>
    </variablelist>
  </xsl:template>

  <xsl:template match="d:tgroup | d:tbody | d:thead">
    <xsl:apply-templates/>
  </xsl:template>

  <xsl:template match="d:row">
    <varlistentry>
      <xsl:apply-templates/>
    </varlistentry>
  </xsl:template>

  <xsl:template match="d:entry[1]">
    <term>
      <xsl:apply-templates select="d:para[1]/node()"/>
    </term>
    <xsl:text>&#10;</xsl:text>
  </xsl:template>

  <xsl:template match="d:entry[2]">
    <listitem>
      <xsl:copy-of select="node()"/>
      <xsl:copy-of select="../d:entry[position()>=3]/node()"/>
    </listitem>
    <xsl:text>&#10;</xsl:text>
  </xsl:template>

</xsl:stylesheet>
