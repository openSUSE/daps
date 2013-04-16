<?xml version="1.0" encoding="UTF-8"?>
<!-- 
  Purpose:
    Unconditionally use a filled circle as the bullet before lists.

  Author(s):  Stefan Knorr <sknorr@suse.de>

  Copyright:  2013, Stefan Knorr

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
  xmlns:exsl="http://exslt.org/common"
  xmlns:fo="http://www.w3.org/1999/XSL/Format"
  exclude-result-prefixes="exsl">

<xsl:template name="itemizedlist.label.markup">
  <xsl:param name="itemsymbol" select="'disc'"/>
  <xsl:variable name="size">
    <xsl:choose>
      <xsl:when test="ancestor::abstract|ancestor::highlights">&x-large;</xsl:when>
        <!-- TODO: Figure out if that's indeed the right size here. -->
      <xsl:otherwise>&normal;</xsl:otherwise>
    </xsl:choose>
  </xsl:variable>

  <fo:inline font-size="{$size * 1.7}pt">
      <!-- We want nice large bullets like we get in the browser. I wonder if
           this is actually the best approach or if we should just use an inline
           SVG. -->
    <xsl:text>&#x2022;</xsl:text>
  </fo:inline>
</xsl:template>

</xsl:stylesheet>
