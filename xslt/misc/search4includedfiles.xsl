<?xml version="1.0" encoding="UTF-8"?>
<!-- $Id: search4includedfiles.xsl 42954 2009-07-10 10:39:17Z toms $ -->
<xsl:stylesheet version="1.0"
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:xi="http://www.w3.org/2001/XInclude"
  xmlns:xi3="http://www.w3.org/2003/XInclude">

<!--
 This stylesheet search for xml:base attributes<
 It prints every filenames under ROOTID.

 See specification http://www.w3.org/TR/xmlbase/ for
 more information

 The parameter "rootid" can be used to list only xml:base
 attributes under a specific element.

-->

<xsl:import href="rootid.xsl"/>
<xsl:output method="text"/>

<xsl:param name="separator"><xsl:text> </xsl:text></xsl:param>
<xsl:param name="terminator"><xsl:text>&#10;</xsl:text></xsl:param>


<xsl:template match="/">
  <xsl:apply-imports/>
  <xsl:value-of select="$terminator"/>
</xsl:template>


<xsl:template name="rootid.process">
  <xsl:apply-templates select="key('id',$rootid)" mode="xmlbase" />
</xsl:template>


<xsl:template name="normal.process">
  <xsl:apply-templates  mode="xmlbase"/>
</xsl:template>


<xsl:template match="/"  mode="xmlbase">
   <xsl:apply-templates  mode="xmlbase"/>
</xsl:template>

<xsl:template match="*"  mode="xmlbase">
   <xsl:apply-templates select="@xml:base"  mode="xmlbase"/>
   <xsl:apply-templates  mode="xmlbase"/>
</xsl:template>

<xsl:template match="text()"  mode="xmlbase"/>

<xsl:template match="@xml:base"  mode="xmlbase">
   <xsl:value-of select="concat(., $separator)"/>
</xsl:template>

</xsl:stylesheet>