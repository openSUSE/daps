<?xml version="1.0"?>
<!-- $Id: onlystructure.xsl 2118 2005-09-21 13:34:29Z toms $ -->
<xsl:stylesheet version="1.0"
   xmlns:xi="http://www.w3.org/2001/XInclude"
   xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
<!--
  This XSLT stylesheet creates a hierarchy structure of a XML file.
  The result contains no text nodes and therefore no inline elements.
  All elements, comments(*), processing-instructions(*) and attributs
  are preserved.

  (*) You can omit this, by setting a parameter
-->

<xsl:output method="xml"
   indent="yes"/>
<!--
   doctype-public="-//SuSE//DTD DocBook XML V4.3-Based Variant 1.0//EN"
   doctype-system="http://w3.suse.de/~lxbuch/dtd/1.0/susex.dtd"
-->

<!-- Some parameters -->
<xsl:param name="use.comments">0</xsl:param>
<xsl:param name="use.pis">0</xsl:param>
<xsl:param name="use.indexterms">1</xsl:param>


<!-- ====================================================== -->
<!-- Standard rules                                         -->
<xsl:template match="text()"/>

<xsl:template match="processing-instruction()">
   <xsl:if test="$use.pis='1'">
      <xsl:copy-of select="."/>
   </xsl:if>
</xsl:template>

<xsl:template match="comment()">
   <xsl:if test="$use.comments='1'">
      <xsl:text>&#10;</xsl:text>
      <xsl:copy-of select="."/>
      <xsl:text>&#10;</xsl:text>
   </xsl:if>
</xsl:template>


<!-- ====================================================== -->

<xsl:template match="*">
   <xsl:element name="{name(.)}">
      <xsl:copy-of select="@*"/>
      <xsl:apply-templates/>
   </xsl:element>
</xsl:template>


<xsl:template match="remark"/>

<xsl:template match="para|term|edition|title|subtitle|firstname|surname|othername">
   <xsl:element name="{name(.)}">
      <xsl:copy-of select="@*"/>
      <xsl:text> </xsl:text>
   </xsl:element>
</xsl:template>


<xsl:template match="indexterm">
   <xsl:if test="$use.indexterms='1'">
      <xsl:element name="{name(.)}">
         <xsl:copy-of select="@*"/>
         <xsl:apply-templates/>
      </xsl:element>
   </xsl:if>
</xsl:template>

<xsl:template match="primary|secondary|tertiary|see|seealso">
   <xsl:if test="$use.indexterms='1'">
      <xsl:element name="{name(.)}">
         <xsl:copy-of select="@*"/>
         <xsl:text> </xsl:text>
      </xsl:element>
   </xsl:if>
</xsl:template>

<!-- ====================================================== -->
<xsl:template match="xi:include|xi:fallback">
   <xsl:copy-of select="."/>
</xsl:template>

<!-- ====================================================== -->


</xsl:stylesheet>
