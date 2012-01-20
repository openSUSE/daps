<?xml version="1.0" encoding="UTF-8"?>
<!-- $Id: $ -->
<xsl:stylesheet
	version="1.0"
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform">

    
    <xsl:template match="example" mode="wiki">
        <xsl:text>&#10;</xsl:text>
        <xsl:call-template name="inline.boldseq">
            <xsl:with-param name="contents">
                <xsl:text>Example: </xsl:text>
                <xsl:value-of select="normalize-space(title)"/>
            </xsl:with-param>
        </xsl:call-template>
        <xsl:text>&#10;</xsl:text>
        <xsl:apply-templates mode="wiki"/>
    </xsl:template>
    
    <xsl:template match="example/title" mode="wiki"/>

    
    
</xsl:stylesheet>
