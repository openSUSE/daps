<?xml version="1.0" encoding="UTF-8"?>
<!--
   Purpose:
     Retrieve identifier of DocBook 5 schema from xml-model PI
     
   Parameters:
     None
       
   Input:
     DocBook 5 document

   Example 1:
     <?xml-model href="http://docbook.org/xml/5.0/rng/docbook.rng" 
            schematypens="http://relaxng.org/ns/structure/1.0"?>
     <?xml-model href="http://docbook.org/xml/5.0/rng/docbook.rng" 
            type="application/xml" 
            schematypens="http://purl.oclc.org/dsdl/schematron"?>

   Example 2:
     <?xml-model href="susedoc5.rnc" type="application/relax-ng-compact-syntax"?>

   Output:
     In the above example, it prints the following strings:
     
     * Example 1:
       http://docbook.org/xml/5.0/rng/docbook.rng
     * Example 2:
       susedoc5.rnc

   Author:    Thomas Schraitle <toms@opensuse.org>
   Copyright (C) 2016 SUSE Linux GmbH
   
-->
<xsl:stylesheet version="1.0" 
 xmlns:xsl="http://www.w3.org/1999/XSL/Transform">

 <xsl:output method="text"/>

 <!-- Taken from the DocBook XSL stylesheets: lib/lib.xsl -->
 <xsl:template name="pi-attribute">
  <xsl:param name="pis" select="processing-instruction('BOGUS_PI')"/>
  <xsl:param name="attribute">filename</xsl:param>
  <xsl:param name="count">1</xsl:param>

  <xsl:choose>
   <xsl:when test="$count &gt; count($pis)">
    <!-- not found -->
   </xsl:when>
   <xsl:otherwise>
    <xsl:variable name="pi">
     <xsl:value-of select="$pis[$count]"/>
    </xsl:variable>
    <xsl:variable name="pivalue">
     <xsl:value-of select="concat(' ', normalize-space($pi))"/>
    </xsl:variable>
    <xsl:choose>
     <xsl:when test="contains($pivalue, concat(' ', $attribute, '='))">
      <xsl:variable name="rest"
       select="substring-after($pivalue, concat(' ', $attribute, '='))"/>
      <xsl:variable name="quote" select="substring($rest, 1, 1)"/>
      <xsl:value-of select="substring-before(substring($rest, 2), $quote)"/>
     </xsl:when>
     <xsl:otherwise>
      <xsl:call-template name="pi-attribute">
       <xsl:with-param name="pis" select="$pis"/>
       <xsl:with-param name="attribute" select="$attribute"/>
       <xsl:with-param name="count" select="$count + 1"/>
      </xsl:call-template>
     </xsl:otherwise>
    </xsl:choose>
   </xsl:otherwise>
  </xsl:choose>
 </xsl:template>

 <xsl:template match="text()"/>

 <xsl:template match="/">
  <xsl:apply-templates select="processing-instruction('xml-model')"/>
 </xsl:template>

 <xsl:template match="/processing-instruction('xml-model')">
  <xsl:variable name="type">
   <xsl:call-template name="pi-attribute">
    <xsl:with-param name="pis" select="."/>
    <xsl:with-param name="attribute">type</xsl:with-param>
   </xsl:call-template>
  </xsl:variable>
  <xsl:variable name="schematypens">
   <xsl:call-template name="pi-attribute">
    <xsl:with-param name="pis" select="."/>
    <xsl:with-param name="attribute">schematypens</xsl:with-param>
   </xsl:call-template>
  </xsl:variable>
  <xsl:variable name="href">
   <xsl:call-template name="pi-attribute">
    <xsl:with-param name="pis" select="."/>
    <xsl:with-param name="attribute">href</xsl:with-param>
   </xsl:call-template>
  </xsl:variable>

  <xsl:choose>
   <xsl:when test="$type = 'application/relax-ng-compact-syntax'">
    <xsl:value-of select="$href"/>
   </xsl:when>
   <xsl:when test="$schematypens = 'http://relaxng.org/ns/structure/1.0'">
    <xsl:value-of select="$href"/>
   </xsl:when>
   <xsl:otherwise>
    <xsl:message>WARNING: No xml-model PI found.</xsl:message>
   </xsl:otherwise>
  </xsl:choose>

 </xsl:template>

</xsl:stylesheet>