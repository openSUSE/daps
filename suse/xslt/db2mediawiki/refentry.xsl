<?xml version="1.0" encoding="UTF-8"?>
<!-- $Id: $ -->
<xsl:stylesheet
	version="1.0"
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform">


<xsl:template match="refentry">
  <xsl:apply-templates/>
</xsl:template>

<xsl:template match="refmeta"/>

<xsl:template match="refnamediv">
</xsl:template>

<xsl:template match="refsynopsisdiv">
</xsl:template>

<!-- *********************************************************** -->

<xsl:template match="refsect1">
   <xsl:call-template name="section.heading"/>
   <xsl:apply-templates/>
</xsl:template>

<xsl:template match="refsect1/title"/>

<xsl:template match="refsect1/title" mode="title" name="refsect1title">
   <xsl:text>&#10;=</xsl:text>
   <xsl:value-of select="normalize-space(.)"/>
   <xsl:text>=&#10;</xsl:text>
</xsl:template>

<!-- *********************************************************** -->

<xsl:template match="refsect2">
   <xsl:call-template name="section.heading"/>
   <xsl:apply-templates />
</xsl:template>

<xsl:template match="refsect2/title"/>

<xsl:template match="refsect2/title" mode="title" name="refsect2title">
   <xsl:text>&#10;==</xsl:text>
   <xsl:value-of select="normalize-space(.)"/>
   <xsl:text>==&#10;</xsl:text>
</xsl:template>


<!-- *********************************************************** -->

<xsl:template match="refsect3">
   <xsl:call-template name="section.heading"/>
   <xsl:apply-templates />
</xsl:template>

<xsl:template match="refsect3/title"/>

<xsl:template match="refsect3/title" mode="title" name="refsect3title">
   <xsl:text>&#10;===</xsl:text>
   <xsl:value-of select="normalize-space(.)"/>
   <xsl:text>===&#10;</xsl:text>
</xsl:template>



</xsl:stylesheet>