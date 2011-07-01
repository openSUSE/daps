<?xml version="1.0" encoding="UTF-8"?>
<!-- $Id: param.xsl 9778 2006-05-11 12:43:55Z toms $ -->
<xsl:stylesheet
	version="1.0"
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform">


<xsl:template match="xref" mode="wrap">
  <xsl:variable name="targets" select="key('id',@linkend)"/>
  <xsl:variable name="target" select="$targets[1]"/>
  <xsl:variable name="refelem" select="local-name($target)"/>
  <xsl:variable name="target.book" select="$target/ancestor-or-self::book"/>
  <xsl:variable name="this.book" select="ancestor-or-self::book"/>

    <xsl:choose>
        <xsl:when test="$targets/title">
            <xsl:value-of select="normalize-space($targets/title)"/>
        </xsl:when>
        <xsl:otherwise>
            <xsl:text>&lt;!-- xref: </xsl:text>
            <xsl:value-of select="@linkend"/> 
            <xsl:text>--&gt;</xsl:text>
        </xsl:otherwise>
    </xsl:choose>
    
</xsl:template>

</xsl:stylesheet>