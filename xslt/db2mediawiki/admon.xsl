<?xml version="1.0" encoding="UTF-8"?>
<!-- $Id: $ -->
<xsl:stylesheet
	version="1.0"
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform">

    <xsl:template match="tip/title|
                         caution/title|
                         warning/title|
                         note/title|
                         important/title"/>
    <xsl:template match="tip/title|
                         caution/title|
                         warning/title|
                         note/title|
                         important/title" mode="wiki"/>
    <xsl:template match="title" mode="admon">
        <xsl:value-of select="normalize-space(.)"/>
    </xsl:template>

    <xsl:template match="*" mode="admon"/>

    <xsl:template match="caution">
        <xsl:call-template name="admonition.box"/>
    </xsl:template>
    <xsl:template match="note">
        <xsl:call-template name="admonition.box"/>
    </xsl:template>
    <xsl:template match="tip">
        <xsl:call-template name="admonition.box"/>
    </xsl:template>
    <xsl:template match="warning">
        <xsl:call-template name="admonition.box"/>
    </xsl:template>
    <xsl:template match="important">
        <xsl:call-template name="admonition.box"/>
    </xsl:template>
    <!-- -->
    <xsl:template match="caution" mode="wiki">
        <xsl:call-template name="admonition.box">
          <xsl:with-param name="content">
            <xsl:apply-templates mode="wiki"/>
          </xsl:with-param>
        </xsl:call-template>
    </xsl:template>
    <xsl:template match="note" mode="wiki">
        <xsl:call-template name="admonition.box">
          <xsl:with-param name="content">
            <xsl:apply-templates mode="wiki"/>
          </xsl:with-param>
        </xsl:call-template>
    </xsl:template>
    <xsl:template match="tip" mode="wiki">
        <xsl:call-template name="admonition.box">
          <xsl:with-param name="content">
            <xsl:apply-templates mode="wiki"/>
          </xsl:with-param>
        </xsl:call-template>
    </xsl:template>
    <xsl:template match="warning" mode="wiki">
        <xsl:call-template name="admonition.box">
          <xsl:with-param name="content">
            <xsl:apply-templates mode="wiki"/>
          </xsl:with-param>
        </xsl:call-template>
    </xsl:template>
    <xsl:template match="important" mode="wiki">
        <xsl:call-template name="admonition.box">
          <xsl:with-param name="content">
            <xsl:apply-templates mode="wiki"/>
          </xsl:with-param>
        </xsl:call-template>
    </xsl:template>


    <xsl:template name="admonition.box">
        <xsl:param name="content">
          <xsl:apply-templates/>
        </xsl:param>
        <xsl:call-template name="call.block.wikitemplate">
            <xsl:with-param name="template">
                <xsl:choose>
                    <xsl:when test="self::caution">Caution</xsl:when>
                    <xsl:when test="self::warning">Warning</xsl:when>
                    <xsl:when test="self::note">Note</xsl:when>
                    <xsl:when test="self::tip">Tip</xsl:when>
                    <xsl:when test="self::important">Important</xsl:when>
                    <xsl:otherwise>
                        <xsl:message>Unknown admonition. Using Note.</xsl:message>
                        <xsl:text>Note</xsl:text>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:with-param>
            <xsl:with-param name="content">
                <xsl:if test="title">
                    <xsl:apply-templates select="title" mode="admon"/>
                </xsl:if>
                <xsl:text>|</xsl:text>
                <xsl:value-of select="$content"/>
            </xsl:with-param>
        </xsl:call-template>
    </xsl:template>

</xsl:stylesheet>
