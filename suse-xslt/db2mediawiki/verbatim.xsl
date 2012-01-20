<?xml version="1.0" encoding="UTF-8"?>
<!-- $Id: $ -->
<xsl:stylesheet
	version="1.0"
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform">

    <xsl:template name="verbatim">
        <xsl:param name="contents" select="."/>
        
        <xsl:if test="preceding-sibling::para">
            <xsl:text>&#10;</xsl:text>
        </xsl:if>
        <xsl:text>&lt;pre&gt;</xsl:text>
        <xsl:value-of select="$contents"/>
        <xsl:text>&lt;/pre&gt;&#10;</xsl:text>
    </xsl:template>
    
    <xsl:template match="screen" mode="wiki">
        <xsl:call-template name="verbatim">
            <xsl:with-param name="contents">
                <xsl:apply-templates mode="wiki"/>
            </xsl:with-param>
        </xsl:call-template>
    </xsl:template>
    <xsl:template match="screen" mode="wrap">
        <xsl:call-template name="verbatim">
            <xsl:with-param name="contents">
                <xsl:apply-templates mode="wrap"/>
            </xsl:with-param>
        </xsl:call-template>
    </xsl:template>
    
    <xsl:template match="screen/text()">
        <xsl:value-of select="."/>
    </xsl:template>
</xsl:stylesheet>
