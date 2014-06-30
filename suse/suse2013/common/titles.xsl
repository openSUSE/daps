<?xml version="1.0" encoding="UTF-8"?>
<!--
  Purpose:
  Always add the type of an admonition to the title, not just if there wouldn't
  be a title otherwise.

  Author(s):    Stefan Knorr <sknorr@suse.de>
  Copyright:    2012, 2013, Stefan Knorr

-->

<xsl:stylesheet version="1.0"
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:exsl="http://exslt.org/common"
  exclude-result-prefixes="exsl">

<xsl:template match="caution|tip|warning|important|note" mode="title.markup">
  <xsl:param name="allow-anchors" select="0"/>
  <xsl:variable name="title" select="(title|info/title)[1]"/>
    <xsl:call-template name="gentext">
      <xsl:with-param name="key">
        <xsl:choose>
          <xsl:when test="local-name(.)='note'">Note</xsl:when>
          <xsl:when test="local-name(.)='important'">Important</xsl:when>
          <xsl:when test="local-name(.)='caution'">Caution</xsl:when>
          <xsl:when test="local-name(.)='warning'">Warning</xsl:when>
          <xsl:when test="local-name(.)='tip'">Tip</xsl:when>
        </xsl:choose>
      </xsl:with-param>
    </xsl:call-template>
    <xsl:if test="$title">
      <xsl:call-template name="gentext">
        <xsl:with-param name="key">admonseparator</xsl:with-param>
      </xsl:call-template>
      <xsl:apply-templates select="$title" mode="title.markup">
        <xsl:with-param name="allow-anchors" select="$allow-anchors"/>
      </xsl:apply-templates>
    </xsl:if>
</xsl:template>

<xsl:template match="refnamediv" mode="title.markup">
  <!-- Delegate it to the refname template -->
  <xsl:apply-templates select="refname" mode="title.markup"/>
</xsl:template>


<!--
   Temporary fix for version 1.78.1:
   See upstream revision 9820. Remove this snippet, if there is a newer 
   version available.

   TODO: Currently, with this template xsltproc detects a recursion. 
         I disabled the template for the time being, but we need to 
         investigate it further.
-->
<!--
<xsl:template match="ulink" mode="no.anchor.mode">
  <xsl:param name="url" select="@url"/>
  <xsl:choose>
    <xsl:when test="count(child::node())=0">
      <xsl:value-of select="$url"/>
    </xsl:when>
    <xsl:otherwise>
      <xsl:apply-templates/>
    </xsl:otherwise>
  </xsl:choose>
</xsl:template>
-->

</xsl:stylesheet>
