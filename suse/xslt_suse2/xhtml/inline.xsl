<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0"
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:exsl="http://exslt.org/common"
  xmlns="http://www.w3.org/1999/xhtml"
  exclude-result-prefixes="exsl">
  
  <xsl:template match="keycap">
  <xsl:call-template name="inline.charseq"/>
</xsl:template>
  
  <xsl:template match="keycombo">
    <xsl:variable name="action" select="@action"/>
    <xsl:variable name="joinchar">
      <xsl:choose>
        <xsl:when test="$action='seq'">
          <xsl:text> </xsl:text>
        </xsl:when>
        <xsl:when test="$action='simul'">+</xsl:when>
        <xsl:when test="$action='press'">-</xsl:when>
        <xsl:when test="$action='click'">-</xsl:when>
        <xsl:when test="$action='double-click'">-</xsl:when>
        <xsl:when test="$action='other'"/>
        <xsl:otherwise>+</xsl:otherwise>
      </xsl:choose>
    </xsl:variable>
    <xsl:for-each select="*">
      <xsl:if test="position()&gt;1">
        <span class="key-connector"><xsl:value-of select="$joinchar"/></span>
      </xsl:if>
      <xsl:apply-templates select="."/>
    </xsl:for-each>
  </xsl:template>
  
</xsl:stylesheet>