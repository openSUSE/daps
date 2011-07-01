<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0">

<!-- 
   Original template from http://docbook.sourceforge.net/release/xsl/current/lib/lib.xsl

    Returns the XPath of a the current node
-->    
    
    <xsl:template name="xpath.location">
        <xsl:param name="node" select="."/>
        <xsl:param name="path" select="''"/>
        
        <xsl:variable name="fo-sib"
            select="count($node/following-sibling::*[name(.) = name($node)])"/>
        <xsl:variable name="prec-sib"
            select="count($node/preceding-sibling::*[name(.) = name($node)])"/>
        
        <xsl:variable name="next.path">
            <xsl:value-of select="local-name($node)"/>
            <xsl:if test="$path != ''">
                <xsl:if test="$prec-sib >0">
                    <xsl:value-of select="concat('[', $prec-sib+1, ']')"/>
                </xsl:if>
                <xsl:text>/</xsl:text>
            </xsl:if>
            <xsl:value-of select="$path"/>
        </xsl:variable>
        
        <xsl:choose>
            <xsl:when test="$node/parent::*">
                <xsl:call-template name="xpath.location">
                    <xsl:with-param name="node" select="$node/parent::*"/>
                    <xsl:with-param name="path" select="$next.path"/>
                </xsl:call-template>
            </xsl:when>
            <xsl:otherwise>
                <xsl:text>/</xsl:text>
                <xsl:value-of select="$next.path"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>    
    
</xsl:stylesheet>
