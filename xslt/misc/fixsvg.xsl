<?xml version="1.0" encoding="UTF-8"?>
<!-- $Id: fixsvg.xsl 6334 2006-02-20 09:20:44Z toms $ -->
<xsl:stylesheet version="1.0"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:svg="http://www.w3.org/2000/svg"
    xmlns:exslt="http://exslt.org/common"
    exclude-result-prefixes="exslt">


<xsl:import href="../common/attributes.xsl"/>

<xsl:output method="xml" encoding="UTF-8" indent="yes"/>


<xsl:template match="/">
   <xsl:copy-of select="svg:*|svg:*/text()"/>
</xsl:template>

<!--<xsl:template match="svg:svg">
   <svg:svg>
      <xsl:call-template name="attribute.copy"/>
      <xsl:copy-of select="svg:*|svg:*/text()"/>
   </svg:svg>
</xsl:template>


<xsl:template match="svg:*">
   <xsl:element name="{name(.)}">
      <xsl:call-template name="attribute.copy"/>
      <xsl:copy-of select="svg:*|svg:*/text()"/>
   </xsl:element>
</xsl:template>

<xsl:template match="svg:*/text()">
   <xsl:value-of select="."/>
</xsl:template>


<xsl:template name="attribute.copy">
   <xsl:param name="nodes" select="@*"/>

   <xsl:for-each select="$nodes">
      <xsl:choose>
         <xsl:when test="name(.)='style'">
            <xsl:call-template name="fix.style.attribute"/>
         </xsl:when>

         <xsl:when test="name(.)='font-family'"/><!- - Don't copy - ->

         <xsl:otherwise>
            <xsl:copy-of select="."/>
         </xsl:otherwise>
      </xsl:choose>
   </xsl:for-each>
</xsl:template>


<xsl:template name="fix.style.attribute">
   <xsl:param name="node" select="."/>
   <xsl:param name="attname">style</xsl:param>

   <xsl:attribute name="{$attname}">
   <xsl:call-template name="delete.attribute.names">
      <xsl:with-param name="node" select="$node"/>
      <xsl:with-param name="names">font-family stroke-opacity</xsl:with-param>
   </xsl:call-template>
   </xsl:attribute>
</xsl:template>-->

</xsl:stylesheet>
