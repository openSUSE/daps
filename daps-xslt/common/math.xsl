<?xml version="1.0" encoding="UTF-8"?>
<!--
   Purpose:
     Provides some math templates from the EXSLT initiative
     
   Functions:
     * decimal = math:cvt-hex-decimal( hexvalue )
       Converts a hexadecimal value to a decimal value
       
     * decimal = math:cvt-hex-decimal-digit( hexvalue )
       Converts a single hexadecimal value (0..F) to a decimal value
     
     * hexadecimal = math:cvt-decimal-hex( decvalue )
       Convert a decimal value to a hexadecimal value
     
   
   Author:    Thomas Schraitle <toms@opensuse.org>
   Copyright: 2012, Thomas Schraitle
   
-->

<xsl:stylesheet version="1.0" 
  xmlns:math="http://xsltsl.org/math"
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform">

    <xsl:template name="math:cvt-hex-decimal">
        <xsl:param name="value"/>

        <!--<xsl:message>math:cvt-hex-decimal = <xsl:value-of select="$value"/></xsl:message>-->

        <xsl:choose>
            <xsl:when test="$value = ''"/>

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
            <xsl:when test="$digit = 'a' or $digit = 'A'">10</xsl:when>
            <xsl:when test="$digit = 'b' or $digit = 'B'">11</xsl:when>
            <xsl:when test="$digit = 'c' or $digit = 'C'">12</xsl:when>
            <xsl:when test="$digit = 'd' or $digit = 'D'">13</xsl:when>
            <xsl:when test="$digit = 'e' or $digit = 'E'">14</xsl:when>
            <xsl:when test="$digit = 'f' or $digit = 'F'">15</xsl:when>
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
