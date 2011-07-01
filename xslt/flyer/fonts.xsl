<?xml version="1.0" encoding="UTF-8"?>
<!-- $Id: fonts.xsl 2362 2005-11-21 14:12:00Z toms $ -->
<xsl:stylesheet version="1.0"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:fo="http://www.w3.org/1999/XSL/Format"
>

<!--
   The fonts are from the RPM package freefont
-->
<xsl:param name="body.font.master">10.5</xsl:param>

<xsl:param name="body.font.family">
    <xsl:value-of select="$sans.font.family"/>
 <!-- <xsl:choose>
   <xsl:when test="/*[starts-with(@lang,'zh')]">
    <xsl:text>suse.serif,FreeSerif,Chinese,serif</xsl:text>
   </xsl:when>
   <xsl:when test="/*[starts-with(@lang,'ja')]">
    <xsl:text>suse.serif,FreeSerif,Japanese,serif</xsl:text>
   </xsl:when>
   <xsl:otherwise>
    <xsl:text>suse.serif,serif</xsl:text><!- - FreeSerif, - ->
   </xsl:otherwise>
  </xsl:choose>-->
</xsl:param>
<xsl:param name="sans.font.family">
  <xsl:choose>
   <xsl:when test="/*[starts-with(@lang,'zh')]">
    <xsl:text>suse.sans,Chinese,FreeSans,sansserif</xsl:text>
   </xsl:when>
   <xsl:when test="/*[starts-with(@lang,'ja')]">
    <xsl:text>suse.sans,Japanese,FreeSans,sansserif</xsl:text>
   </xsl:when>
   <xsl:otherwise>
    <xsl:text>suse.sans,sansserif</xsl:text><!-- FreeSans,-->
   </xsl:otherwise>
  </xsl:choose>
</xsl:param>

<xsl:param name="monospace.font.family">
  <xsl:choose>
   <xsl:when test="/*[starts-with(@lang,'zh')]">
    <xsl:text>suse.mono,ChineseMono</xsl:text>
   </xsl:when>
   <xsl:when test="/*[starts-with(@lang,'ja')]">
    <xsl:text>suse.mono,JapaneseMono</xsl:text>
   </xsl:when>
   <xsl:otherwise>
    <xsl:text>monospace</xsl:text><!-- FreeSans,-->
   </xsl:otherwise>
  </xsl:choose>
</xsl:param><!-- FreeMono, -->

<xsl:param name="title.font.family" select="$sans.font.family"/>
<!-- <xsl:param name="symbol.font.family"></xsl:param> -->

<xsl:param name="dingbat.font.family">
  <xsl:value-of select="$sans.font.family"/>
</xsl:param>

</xsl:stylesheet>