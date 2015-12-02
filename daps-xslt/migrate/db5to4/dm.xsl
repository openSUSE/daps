<?xml version="1.0" encoding="UTF-8"?>
<!--
   Purpose:
     Migrate DocManager dm:bugtracker element into suse-bugtracker
     processing instruction

   Author:    Thomas Schraitle <toms@opensuse.org>
   Copyright:  2015 SUSE Linux GmbH

-->
<xsl:stylesheet version="1.0"
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:dm="urn:x-suse:ns:docmanager"
  xmlns:d="http://docbook.org/ns/docbook"
  xmlns:xlink="http://www.w3.org/1999/xlink"
  exclude-result-prefixes="dm">

  <xsl:strip-space elements="*"/>

  <xsl:template match="dm:docmanager|dm:docmanager/*">
    <xsl:apply-templates/>
  </xsl:template>

  <xsl:template match="dm:docmanager/dm:bugtracker">
    <xsl:processing-instruction name="suse-bugtracker">
      <xsl:text>&#10;   </xsl:text>
      <xsl:apply-templates/>
    </xsl:processing-instruction>
    <xsl:text>&#10;</xsl:text>
  </xsl:template>

  <xsl:template match="dm:url|dm:component|dm:product|dm:assignee">
    <xsl:value-of select="concat(local-name(), '=&quot;', ., '&quot;')"/>
    <xsl:text>&#10;   </xsl:text>
  </xsl:template>

  <xsl:template match="dm:*/text()"/>

</xsl:stylesheet>