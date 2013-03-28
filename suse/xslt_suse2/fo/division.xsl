<?xml version="1.0" encoding="UTF-8"?>
<!-- 
  Purpose:
    Restyle titles of chapters, etc.

  Author(s):  Stefan Knorr <sknorr@suse.de>

  Copyright:  2013, Stefan Knorr

-->
<!DOCTYPE xsl:stylesheets 
[
  <!ENTITY % fonts SYSTEM "fonts.ent">
  <!ENTITY % colors SYSTEM "colors.ent">
  <!ENTITY % metrics SYSTEM "metrics.ent">
  %fonts;
  %colors;
  %metrics;
]>
<xsl:stylesheet  version="1.0"
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:fo="http://www.w3.org/1999/XSL/Format">

<xsl:template name="division.title">
  <xsl:param name="node" select="."/>
  <xsl:variable name="id">
    <xsl:call-template name="object.id">
      <xsl:with-param name="object" select="$node"/>
    </xsl:call-template>
  </xsl:variable>

  <fo:block keep-with-next.within-column="always"
            hyphenate="false" start-indent="{&column; + &gutter;}mm">
    <xsl:call-template name="title.part.split">
      <xsl:with-param name="node" select="."/>
    </xsl:call-template>
  </fo:block>
</xsl:template>


<xsl:template name="title.part.split">
  <xsl:param name="node" select="."/>

  <xsl:variable name="title">
      <xsl:apply-templates select="$node" mode="title.markup"/>
  </xsl:variable>

  <xsl:variable name="number">
      <xsl:apply-templates select="($node/parent::part|$node/parent::partinfo/parent::part)[last()]" mode="label.markup"/>
  </xsl:variable>

  <xsl:if test="$number != ''">
    <fo:block xsl:use-attribute-sets="title.number.color" font-family="&serif;"
      font-size="&ultra-large;pt" font-weight="normal" text-align="start">
      <xsl:copy-of select="$number"/>
      <xsl:text> </xsl:text>
    </fo:block>
  </xsl:if>
  <fo:block xsl:use-attribute-sets="title.name.color" font-family="{$title.fontset}"
      font-size="&super-large;pt" font-weight="normal" text-align="start">
    <xsl:copy-of select="$title"/>
  </fo:block>
</xsl:template>


</xsl:stylesheet>
