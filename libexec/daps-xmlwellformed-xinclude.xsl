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

 <xsl:template match="xi:include">
  <xsl:variable name="abspath" select="s:abspath(@href)"/>
  <xsl:choose>
   <xsl:when test="s:exists(@href)">
    <xsl:message>INFO: XIncluding <xsl:value-of select="$abspath"/></xsl:message>
    <xsl:apply-templates select="document($abspath, .)"/>
   </xsl:when>
   <xsl:otherwise>
    <xsl:message>WARN: File not found "<xsl:value-of select="@href"/>"</xsl:message>
   </xsl:otherwise>
  </xsl:choose>
 </xsl:template>

</xsl:stylesheet>
