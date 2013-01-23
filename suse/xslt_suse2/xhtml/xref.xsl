<?xml version="1.0"?>
<!-- 
  Purpose:
     Make the anchor template dysfunctional.
     
   See Also:
     * http://docbook.sourceforge.net/release/xsl/current/doc/html/index.html

   Author(s): Stefan Knorr <sknorr@suse.de>
   Copyright: 2012, Stefan Knorr

-->

<xsl:stylesheet version="1.0"
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns="http://www.w3.org/1999/xhtml">


  <xsl:template name="anchor">
    <xsl:param name="node" select="."/>
      <xsl:param name="conditional" select="1"/>
      <xsl:if test="local-name($node) = 'figure'">
        <xsl:attribute name="id">
          <xsl:call-template name="object.id">
            <xsl:with-param name="object" select="$node"/>
          </xsl:call-template>
        </xsl:attribute>
      </xsl:if>

    <!-- Elif: Sorry! -->
  </xsl:template>

  <xsl:template match="question" mode="xref-to">
    <xsl:param name="referrer"/>
    <xsl:param name="xrefstyle"/>
    <xsl:param name="verbose" select="1"/>
    <xsl:variable name="teaser">
      <xsl:apply-templates select="para[1]" mode="question"/>
    </xsl:variable>
    <xsl:variable name="teaser-length">
      <xsl:value-of select="string-length(normalize-space($teaser))"/>
    </xsl:variable>
    <xsl:variable name="interpunction">
      <xsl:if test="$teaser-length &gt; 100">
        <xsl:choose>
          <xsl:when test="substring-before(substring($teaser,99,$teaser-length),'?')
            != ''">..?</xsl:when>
          <xsl:otherwise>…</xsl:otherwise>
        </xsl:choose>
      </xsl:if>
    </xsl:variable>

    <em>
      <xsl:choose>
        <xsl:when test="$teaser-length &gt; 100">
            <xsl:value-of select="substring(normalize-space($teaser),1,100)"/>
            <xsl:value-of select="$interpunction"/>
        </xsl:when>
        <xsl:otherwise>
          <xsl:apply-templates select="para[1]" mode="question"/>
        </xsl:otherwise>
      </xsl:choose>
    </em>
  </xsl:template>

  <xsl:template match="question/para[1]" mode="question">
    <!-- We don't want a block here: we just process the next
         child inside a para
    -->
    <xsl:apply-templates mode="question"/>
  </xsl:template>

  <xsl:template match="*" mode="qanda">
    <!-- Fallback to default mode -->
    <xsl:apply-templates select="."/>
  </xsl:template>

</xsl:stylesheet>
