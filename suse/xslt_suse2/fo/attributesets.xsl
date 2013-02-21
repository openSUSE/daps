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
  <!ENTITY % fontsizes SYSTEM "font-sizes.ent">
  %fontsizes;
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
  
<xsl:attribute-set name="monospace.verbatim.properties" use-attribute-sets="verbatim.properties monospace.properties">
  <xsl:attribute name="text-align">start</xsl:attribute>
  <xsl:attribute name="wrap-option">wrap</xsl:attribute>
  <xsl:attribute name="hyphenation-character"><xsl:value-of select="$hook"/></xsl:attribute>
  <xsl:attribute name="font-size">&small;pt</xsl:attribute>
</xsl:attribute-set>

</xsl:stylesheet>
