<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0"
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:exsl="http://exslt.org/common"
  xmlns="http://www.w3.org/1999/xhtml"
  exclude-result-prefixes="exsl">
  
  
  <xsl:template name="inline.sansseq">
    <xsl:param name="content">
      <xsl:call-template name="anchor"/>
      <xsl:call-template name="simple.xlink">
        <xsl:with-param name="content">
          <xsl:apply-templates/>
        </xsl:with-param>
      </xsl:call-template>
    </xsl:param>
    <span class="{local-name(.)}">
      <xsl:call-template name="generate.html.title"/>
      <xsl:if test="@dir">
        <xsl:attribute name="dir">
          <xsl:value-of select="@dir"/>
        </xsl:attribute>
      </xsl:if>
      <xsl:copy-of select="$content"/>
      <xsl:call-template name="apply-annotations"/>
    </span>
  </xsl:template>
  
  
  <xsl:template match="keycap">
    <!-- See also Ticket#84 -->
    <xsl:choose>
      <xsl:when test="@function">
        <xsl:call-template name="inline.sansseq">
          <xsl:with-param name="content">
            <xsl:call-template name="gentext.template">
              <xsl:with-param name="context" select="'msgset'"/>
              <xsl:with-param name="name" select="@function"/>
            </xsl:call-template>
          </xsl:with-param>
        </xsl:call-template>
      </xsl:when>
      <xsl:otherwise>
        <xsl:call-template name="inline.sansseq"/>
      </xsl:otherwise>
    </xsl:choose>
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