<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0" xmlns:math="http://xsltsl.org/math"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform">


    <xsl:template name="math:cvt-hex-decimal">
        <xsl:param name="value"/>

        <!--<xsl:message>math:cvt-hex-decimal = <xsl:value-of select="$value"/></xsl:message>-->

        <xsl:choose>
            <xsl:when test="$value = &quot;&quot;"/>

            <xsl:when test="string-length($value) = 1">
                <xsl:call-template name="math:cvt-hex-decimal-digit">
                    <xsl:with-param name="digit" select="$value"/>
                </xsl:call-template>
            </xsl:when>
            <xsl:otherwise>
                <xsl:variable name="first-digit">
                    <xsl:call-template name="math:cvt-hex-decimal-digit">
                        <xsl:with-param name="digit" select="substring($value, 1, 1)"/>
                    </xsl:call-template>
                </xsl:variable>
                <xsl:variable name="remainder">
                    <xsl:call-template name="math:cvt-hex-decimal">
                        <xsl:with-param name="value" select="substring($value, 2)"/>
                    </xsl:call-template>
                </xsl:variable>

                <xsl:value-of select="$first-digit * 16 + $remainder"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>

    <xsl:template name="math:cvt-hex-decimal-digit">
        <xsl:param name="digit" select="0"/>
        <xsl:choose>
            <xsl:when test="$digit &lt;= 9">
                <xsl:value-of select="$digit"/>
            </xsl:when>
            <xsl:when test="$digit = &quot;a&quot; or $digit = &quot;A&quot;">10</xsl:when>
            <xsl:when test="$digit = &quot;b&quot; or $digit = &quot;B&quot;">11</xsl:when>
            <xsl:when test="$digit = &quot;c&quot; or $digit = &quot;C&quot;">12</xsl:when>
            <xsl:when test="$digit = &quot;d&quot; or $digit = &quot;D&quot;">13</xsl:when>
            <xsl:when test="$digit = &quot;e&quot; or $digit = &quot;E&quot;">14</xsl:when>
            <xsl:when test="$digit = &quot;f&quot; or $digit = &quot;F&quot;">15</xsl:when>
        </xsl:choose>
    </xsl:template>

    <xsl:template name="math:cvt-decimal-hex">
        <xsl:param name="value"/>
        <xsl:variable name="hexDigits" select="'0123456789ABCDEF'"/>

        <xsl:if test="$value >= 16">
            <xsl:call-template name="math:cvt-decimal-hex">
                <xsl:with-param name="value" select="floor($value div 16)"/>
            </xsl:call-template>
        </xsl:if>
        <xsl:value-of select="substring($hexDigits, ($value mod 16) + 1, 1)"/>
    </xsl:template>
</xsl:stylesheet>
