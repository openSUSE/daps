<?xml version="1.0" encoding="UTF-8"?>
<!-- $Id: param.xsl 9778 2006-05-11 12:43:55Z toms $ -->
<xsl:stylesheet
	version="1.0"
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform">

<!--[[Image:Wiki.png|frame|The logo for this Wiki]]-->
    <xsl:template match="figure">
        <xsl:text>&#10;[[Image:</xsl:text>
        <xsl:apply-templates select="mediaobject"/>
        <xsl:text>|frame</xsl:text>
        <xsl:if test="title">
            <xsl:text>|</xsl:text>
            <xsl:apply-templates select="title"/>
        </xsl:if>
        <xsl:text>]]&#10;</xsl:text>
    </xsl:template>
    <xsl:template match="figure" mode="wiki">
        <xsl:text>&#10;[[Image:</xsl:text>
        <xsl:apply-templates select="mediaobject" mode="wiki"/>
        <xsl:text>|frame</xsl:text>
        <xsl:if test="title">
            <xsl:text>|</xsl:text>
            <xsl:apply-templates select="title" mode="wiki"/>
        </xsl:if>
        <xsl:text>]]&#10;</xsl:text>
    </xsl:template>

    <xsl:template match="figure/title" name="figuretitle">
        <xsl:value-of select="normalize-space(.)"/>
    </xsl:template>
    <xsl:template match="figure/title" mode="wiki">
        <xsl:call-template name="figuretitle"/>
    </xsl:template>

    <xsl:template match="mediaobject">
        <xsl:apply-templates/>
    </xsl:template>
    <xsl:template match="mediaobject" mode="wiki">
        <xsl:apply-templates mode="wiki"/>
    </xsl:template>

    <xsl:template match="inlinemediaobject">
        <xsl:param name="content">
          <xsl:apply-templates/>
        </xsl:param>
        <xsl:text> [[Image:</xsl:text>
        <xsl:value-of select="$content"/>
        <xsl:text>]] </xsl:text>
    </xsl:template>
    <xsl:template match="inlinemediaobject" mode="wrap">
        <xsl:apply-templates select="self::inlinemediaobject"/>
    </xsl:template>
    <xsl:template match="inlinemediaobject" mode="wiki">
        <xsl:apply-templates select="self::inlinemediaobject">
            <xsl:with-param name="content">
                <xsl:apply-templates mode="wiki"/>
            </xsl:with-param>
        </xsl:apply-templates>
    </xsl:template>


    <xsl:template match="imageobject[@role='html']">
        <xsl:value-of select="imagedata/@fileref"/>
    </xsl:template>
    <xsl:template match="imageobject[@role='html']" mode="wiki">
        <xsl:value-of select="imagedata/@fileref"/>
    </xsl:template>


    <xsl:template match="imageobject"/><!-- Empty -->
    <xsl:template match="imagedata"/>
    <xsl:template match="imageobject" mode="wiki"/><!-- Empty -->
    <xsl:template match="imagedata" mode="wiki"/>


</xsl:stylesheet>