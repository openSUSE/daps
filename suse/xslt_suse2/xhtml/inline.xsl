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
    <xsl:for-each select="*">
      <xsl:if test="position()&gt;1">
        <span class="key-connector">–</span>
      </xsl:if>
      <xsl:apply-templates select="."/>
    </xsl:for-each>
  </xsl:template>
  
  <xsl:template match="function/parameter" priority="2">
    <xsl:call-template name="inline.italicseq"/>
    <xsl:if test="following-sibling::*">
      <xsl:text>, </xsl:text>
    </xsl:if>
  </xsl:template>
  
  <xsl:template match="parameter">
    <xsl:call-template name="inline.italicseq"/>
  </xsl:template>
  
  <xsl:template match="function/replaceable" priority="2">
    <xsl:call-template name="inline.italicseq"/>
    <xsl:if test="following-sibling::*">
      <xsl:text>, </xsl:text>
    </xsl:if>
  </xsl:template>
  
  <xsl:template match="replaceable" priority="1">
    <xsl:call-template name="inline.italicseq"/>
  </xsl:template>
  
  <xsl:template match="command">
    <xsl:call-template name="inline.monoseq"/>
  </xsl:template>
  
</xsl:stylesheet>