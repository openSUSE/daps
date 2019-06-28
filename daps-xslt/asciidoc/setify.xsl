<?xml version="1.0" encoding="UTF-8"?>
<!--

-->
<xsl:stylesheet version="1.0"
 xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
 xmlns:d="http://docbook.org/ns/docbook"
 xmlns="http://docbook.org/ns/docbook"
>

 <xsl:template match="node() | @*">
  <xsl:copy>
    <xsl:apply-templates select="@* | node()"/>
  </xsl:copy>
</xsl:template>

<xsl:template match="/d:book">
 <set>
  <xsl:copy-of select="@*"/>
  <xsl:apply-templates/>
 </set>
</xsl:template>

<xsl:template match="/d:book/d:part">
 <book>
  <xsl:copy-of select="@*"/>
  <xsl:apply-templates/>
 </book>
</xsl:template>

<xsl:template match="/d:book/d:part/d:partintro">
 <colophon>
  <xsl:copy-of select="@*"/>
  <xsl:apply-templates/>
 </colophon>
</xsl:template>


<!--
<xsl:template match="/d:book/d:chapter">
 <book>
  <xsl:copy-of select="@*"/>
  <xsl:apply-templates/>
 </book>
</xsl:template>

<xsl:template match="/d:book/d:chapter/d:section">
 <chapter>
  <xsl:copy-of select="@*"/>
  <xsl:apply-templates/>
 </chapter>
</xsl:template>

<xsl:template match="/d:book/d:chapter/*[not(self::d:title or self::d:subtitle or self::d:sect1 or self::d:info)]">
 <preface>
  <xsl:copy-of select="@*"/>
   <xsl:apply-templates/>
 </preface>
</xsl:template>
-->

<!--
<xsl:template match="/d:book/d:chapter/d:simpara|/d:book/d:chapter/d:para">
 <preface>
  <xsl:copy-of select="@*"/>
  <para>
   <xsl:apply-templates/>
  </para>
 </preface>
</xsl:template>
-->
</xsl:stylesheet>
