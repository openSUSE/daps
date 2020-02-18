<?xml version="1.0" encoding="UTF-8"?>
<!--
   Purpose:
      Process xi:include elements and return warning message if file
      cannot be found

   Parameters:
      n/a

   Input:
      DocBook 4/5 document

    Output:
      nothing, only INFO or WARNING messages

   Dependencies:
      s:abspath and s:exists, two Python extension functions used by
      the daps-xmlwellformed script

   Author: Thomas Schraitle
   Copyright (C) 2018 SUSE Linux GmbH

-->
<xsl:stylesheet version="1.0"
 xmlns:xi="http://www.w3.org/2001/XInclude"
 xmlns:s="urn:x-suse:ns:python"
 xmlns:xsl="http://www.w3.org/1999/XSL/Transform">

 <xsl:output method="text"/>
 <xsl:template match="text()"/>

 <xsl:template match="*" mode="included">
  <xsl:param name="base"/>
  <xsl:copy>
   <xsl:copy-of select="@*"/>
   <xsl:attribute name="xml:base">
    <xsl:value-of select="$base"/>
   </xsl:attribute>
   <xsl:apply-templates>
    <xsl:with-param name="base" select="$base"/>
   </xsl:apply-templates>
  </xsl:copy>
 </xsl:template>

 <xsl:template match="xi:include">
  <xsl:param name="base" select="s:base()"/>
  <xsl:variable name="abspath" select="s:abspath(@href)"/>
  <xsl:choose>
   <xsl:when test="s:exists(@href)">
    <xsl:text>FILE:</xsl:text>
    <xsl:value-of select="$abspath"/>
    <xsl:text>&#10;</xsl:text>
    <xsl:apply-templates select="document($abspath, .)" mode="included">
      <xsl:with-param name="base" select="@href"/>
    </xsl:apply-templates>
   </xsl:when>
   <xsl:otherwise>
    <xsl:message><xsl:value-of select="s:errormsg($base, @href)"/></xsl:message>
   </xsl:otherwise>
  </xsl:choose>
 </xsl:template>

</xsl:stylesheet>