<?xml version="1.0" encoding="UTF-8"?>
<!--
  Purpose:
    Split formal titles into number and title

  Author(s):    Thomas Schraitle <toms@opensuse.org>,
                Stefan Knorr <sknorr@suse.de>

  Copyright:    2012, 2013, Thomas Schraitle, Stefan Knorr

-->
<!DOCTYPE xsl:stylesheet
[
  <!ENTITY % fonts SYSTEM "fonts.ent">
  <!ENTITY % colors SYSTEM "colors.ent">
  <!ENTITY % metrics SYSTEM "metrics.ent">
  %fonts;
  %colors;
  %metrics;
]>
<xsl:stylesheet version="1.0"
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:fo="http://www.w3.org/1999/XSL/Format">

  <xsl:template
    match="procedure|example|table|figure|variablelist|itemizedlist|orderedlist"
    mode="object.label.template">
    <xsl:call-template name="gentext.template">
      <xsl:with-param name="context" select="'styles'"/>
      <xsl:with-param name="name" select="concat( local-name(),'-label')"/>
    </xsl:call-template>
  </xsl:template>

  <xsl:template match="procedure|example|table|figure|variablelist|itemizedlist|orderedlist"
    mode="object.title.template">
    <xsl:call-template name="gentext.template">
      <xsl:with-param name="context" select="'styles'"/>
      <xsl:with-param name="name" select="concat( local-name(),'-title')"/>
    </xsl:call-template>
  </xsl:template>

  <xsl:template name="formal.object.heading">
    <xsl:param name="object" select="."/>
    <xsl:param name="placement" select="'before'"/>
    <xsl:variable name="label.template">
      <xsl:apply-templates select="$object" mode="object.label.template"/>
    </xsl:variable>

    <fo:block xsl:use-attribute-sets="formal.title.properties"
      space-before="{&gutter;}mm" space-after="0em"
      line-height="{$base-lineheight * 0.85}em">
      <xsl:choose>
        <xsl:when test="$placement = 'before'">
          <xsl:attribute
            name="keep-with-next.within-column">always</xsl:attribute>
        </xsl:when>
        <xsl:otherwise>
          <xsl:attribute
            name="keep-with-previous.within-column">always</xsl:attribute>
        </xsl:otherwise>
      </xsl:choose>
      <xsl:if test="$label.template != ''">
        <fo:inline xsl:use-attribute-sets="title.number.color">
          <xsl:call-template name="substitute-markup">
            <xsl:with-param name="template" select="$label.template"/>
          </xsl:call-template>
          <xsl:text>&#xA0;</xsl:text>
        </fo:inline>
      </xsl:if>
      <fo:inline xsl:use-attribute-sets="title.name.color">
        <xsl:apply-templates select="$object" mode="title.markup">
          <xsl:with-param name="allow-anchors" select="1"/>
        </xsl:apply-templates>
        <xsl:text> </xsl:text>
      </fo:inline>
    </fo:block>
  </xsl:template>

</xsl:stylesheet>
