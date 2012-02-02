<?xml version="1.0" encoding="UTF-8"?>
<!--
   Purpose:
     
     
   Parameters:
     * separator (default: "@")
       Separator between each filename
     * filename.sep (default: " ")
       String to separate each filename
       
   Input:
     DocBook document
     
   Output:
     
   
   Author:    Thomas Schraitle <toms@opensuse.org>
   Copyright: 2012, Thomas Schraitle
   
-->
<xsl:stylesheet version="1.0"
  xmlns:db="http://docbook.org/ns/docbook"
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform">

<xsl:import href="get-graphics.xsl"/>

<xsl:output method="text"/>

<xsl:strip-space elements="*"/>


<xsl:param name="separator">@</xsl:param>
<xsl:param name="filename.sep"><xsl:text> </xsl:text></xsl:param>


<xsl:template name="ends-with">
    <xsl:param name="value">not a node</xsl:param>
    <xsl:param name="substr">node</xsl:param>
    
    <xsl:value-of select="substring($value, (string-length($value) - string-length($substr)) +1) = $substr"/>
</xsl:template>


<xsl:template match="imageobject/text()|db:imageobject/text()"/>

<xsl:template name="process.imagedata">
    <xsl:value-of select="concat(@fileref, $filename.sep)"/>
    
    <xsl:choose>
        <xsl:when test="contains(@fileref, '.png')">
            <xsl:value-of select="substring-before(@fileref, '.png')"/>
        </xsl:when>
        <xsl:when test="contains(@fileref, '.jpg') or contains(@fileref, '.JPEG')">
            <xsl:value-of select="substring-before(@fileref, '.jpg')"/>
        </xsl:when>
        <xsl:when test="contains(@fileref, '.gif')">
            <xsl:value-of select="substring-before(@fileref, '.gif')"/>
        </xsl:when>
    </xsl:choose>
    
    <xsl:value-of select="$separator"/>
      
    <xsl:choose>
        <xsl:when test="@width != ''">
            <xsl:text>w</xsl:text>
            <xsl:value-of select="translate(normalize-space(@width), '%', 'P')"/>
            <xsl:text>.png</xsl:text>
        </xsl:when>
        <xsl:when test="@height != ''">
            <xsl:text>h</xsl:text>
            <xsl:value-of select="translate(normalize-space(@height), '%', 'P')"/>
            <xsl:text>.png</xsl:text>
        </xsl:when>
        <xsl:otherwise>
            <xsl:value-of select="@fileref"/>
        </xsl:otherwise>
    </xsl:choose>
    
    <xsl:text>&#xa;</xsl:text>
</xsl:template>

<xsl:template match="imagedata|db:imagedata">
    <xsl:choose>
        <xsl:when test="contains(@width, 'em') or contains(@width, 'px')">
            <xsl:message>ERROR: Image file '<xsl:value-of select="@fileref"/>' contains in width the unit 'em' or 'px' which is not useful.</xsl:message>
        </xsl:when>
        <xsl:when test="contains(@height, 'em') or contains(@height, 'px')">
            <xsl:message>ERROR: Image file '<xsl:value-of select="@fileref"/>' contains in height the unit 'em' or 'px' which is not useful.</xsl:message>
        </xsl:when>
        <xsl:otherwise>
            <xsl:call-template name="process.imagedata"/>
        </xsl:otherwise>
    </xsl:choose>
</xsl:template>


</xsl:stylesheet>
