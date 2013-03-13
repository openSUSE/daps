<?xml version="1.0" encoding="UTF-8"?>
<!-- 
  Purpose:
    Contains all attribute sets for XSL-FO

  Author(s):  Stefan Knorr <sknorr@suse.de>
              Thomas Schraitle <toms@opensuse.org>

  Copyright:  2013, Stefan Knorr, Thomas Schraitle

-->
<!DOCTYPE xsl:stylesheets 
[
  <!ENTITY % fonts SYSTEM "fonts.ent">
  <!ENTITY % colors SYSTEM "colors.ent">
  %fonts;
  %colors;
]>
<xsl:stylesheet  version="1.0"
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:fo="http://www.w3.org/1999/XSL/Format">

  <xsl:variable name="hook">
    <xsl:choose>
      <xsl:when test="$fop1.extensions != 0">&#160;</xsl:when>
        <!-- FOP doesn't like either " " or "&#32;" – no-break space works however-->
      <xsl:otherwise>&#8617;</xsl:otherwise>
    </xsl:choose>
  </xsl:variable>

  <xsl:attribute-set name="footer.content.properties">
    <xsl:attribute name="font-family">
      <xsl:value-of select="$sans.font.family"/>, <xsl:value-of select="$symbol.font.family"/>
    </xsl:attribute>
    <xsl:attribute name="font-size">
      <xsl:text>&small;pt</xsl:text>
    </xsl:attribute>
    <xsl:attribute name="margin-left">
      <xsl:value-of select="$title.margin.left"/>
    </xsl:attribute>
  </xsl:attribute-set>

  <xsl:attribute-set name="section.title.properties">
    <xsl:attribute name="font-family">
      <xsl:value-of select="$title.fontset"></xsl:value-of>
    </xsl:attribute>
    <xsl:attribute name="font-weight">normal</xsl:attribute>
    <xsl:attribute name="keep-with-next.within-column">always</xsl:attribute>
    <xsl:attribute name="space-before.minimum">0.8em</xsl:attribute>
    <xsl:attribute name="space-before.optimum">1.0em</xsl:attribute>
    <xsl:attribute name="space-before.maximum">1.2em</xsl:attribute>
    <xsl:attribute name="text-align">start</xsl:attribute>
    <xsl:attribute name="start-indent"><xsl:value-of select="$title.margin.left"></xsl:value-of></xsl:attribute>
  </xsl:attribute-set>

  <xsl:attribute-set name="section.title.level1.properties">
    <xsl:attribute name="font-size">&xxx-large;pt</xsl:attribute>
  </xsl:attribute-set>
  <xsl:attribute-set name="section.title.level2.properties">
    <xsl:attribute name="font-size">&xx-large;pt</xsl:attribute>
  </xsl:attribute-set>
  <xsl:attribute-set name="section.title.level3.properties">
    <xsl:attribute name="font-size">&x-large;pt</xsl:attribute>
  </xsl:attribute-set>
  <xsl:attribute-set name="section.title.level4.properties">
    <xsl:attribute name="font-size">&large;pt</xsl:attribute>
    <xsl:attribute name="font-weight">700</xsl:attribute>
  </xsl:attribute-set>
  <xsl:attribute-set name="section.title.level5.properties">
    <xsl:attribute name="font-size">&large;pt</xsl:attribute>
  </xsl:attribute-set>
  <xsl:attribute-set name="section.title.level6.properties">
    <xsl:attribute name="font-size">&normal;pt</xsl:attribute>
    <xsl:attribute name="font-weight">700</xsl:attribute>
  </xsl:attribute-set>

<xsl:attribute-set name="monospace.verbatim.properties" use-attribute-sets="verbatim.properties monospace.properties">
  <xsl:attribute name="text-align">start</xsl:attribute>
  <xsl:attribute name="wrap-option">wrap</xsl:attribute>
  <xsl:attribute name="hyphenation-character"><xsl:value-of select="$hook"/></xsl:attribute>
  <xsl:attribute name="font-size">&small;pt</xsl:attribute>
</xsl:attribute-set>

<xsl:attribute-set name="variablelist.term.properties">
  <xsl:attribute name="font-weight">600</xsl:attribute>
  <xsl:attribute name="font-family"><xsl:value-of select="$sans.font.family"/></xsl:attribute>
</xsl:attribute-set>

<xsl:attribute-set name="glossterm.block.properties">
  <xsl:attribute name="font-weight">600</xsl:attribute>
  <xsl:attribute name="font-family"><xsl:value-of select="$sans.font.family"/></xsl:attribute>
</xsl:attribute-set>

<xsl:attribute-set name="shade.verbatim.style">
  <xsl:attribute name="background-color">&light-gray-old;</xsl:attribute>
  <xsl:attribute name="padding">0.5em</xsl:attribute>
  <xsl:attribute name="start-indent">0.5em</xsl:attribute>
  <xsl:attribute name="end-indent">0.5em</xsl:attribute>
</xsl:attribute-set>

<!-- +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ -->

<xsl:attribute-set name="title.name.color">
  <xsl:attribute name="color">&dark-green;</xsl:attribute>
</xsl:attribute-set>

<xsl:attribute-set name="title.number.color">
  <xsl:attribute name="color">&mid-gray;</xsl:attribute>
</xsl:attribute-set>

</xsl:stylesheet>
