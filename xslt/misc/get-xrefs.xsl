<?xml version="1.0" encoding="UTF-8"?>
<!-- $Id: get-xrefs.xsl 25990 2007-11-13 14:05:19Z toms $ -->
<!DOCTYPE xsl:stylesheet >

<!-- extracts linkends from xref elements all over the place -->

<xsl:stylesheet version="1.0"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform">

<xsl:import href="http://docbook.sourceforge.net/release/xsl/current/profiling/profile.xsl"/>


<xsl:output method="text"/>

<xsl:template match="/">
  <xsl:choose>
    <xsl:when test="$rootid != ''">
      <xsl:apply-templates select="key('id', $rootid)"/>
    </xsl:when>
    <xsl:otherwise>
      <xsl:apply-templates/>
    </xsl:otherwise>
  </xsl:choose>  
</xsl:template>
  
<xsl:template match="//xref/@linkend">
  <xsl:value-of select="."/>
  <xsl:text>&#10;</xsl:text>
</xsl:template>

</xsl:stylesheet>