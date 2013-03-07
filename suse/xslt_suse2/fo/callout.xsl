<?xml version="1.0" encoding="UTF-8"?>
<!-- 
  Purpose:
    Format our callouts as normal text, albeit with a pretty SVG frame around
    them.

  Author(s):  Stefan Knorr <sknorr@suse.de>

  Copyright:  2013, Stefan Knorr

-->
<!DOCTYPE xsl:stylesheets 
[
  <!ENTITY % fonts SYSTEM "fonts.ent">
  %fonts;
]>
<xsl:stylesheet  version="1.0"
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:fo="http://www.w3.org/1999/XSL/Format">

<xsl:template name="callout-bug">
  <xsl:param name="conum" select='1'/>
  <xsl:param name="cowidth">
    <xsl:choose>
      <xsl:when test="$conum &lt; 10 and $conum &gt; 0">
        <xsl:text>100px</xsl:text>
      </xsl:when>
      <xsl:when test="$conum &lt; 100 and $conum &gt; 9">
        <xsl:text>140px</xsl:text>
      </xsl:when>
      <xsl:otherwise>
        <xsl:message>You are using too many callouts.</xsl:message>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:param>

  <fo:inline padding="0" baseline-shift="0">
    <fo:instream-foreign-object content-height="0.9em">
      <svg:svg xmlns:svg="http://www.w3.org/2000/svg" height="100px">
        <xsl:attribute name="width"><xsl:value-of select="$cowidth"/></xsl:attribute>
        <svg:rect height="100px" rx="50px" ry="50px" x="0" y="0"
            style="fill:#439539; stroke: none">
          <xsl:attribute name="width"><xsl:value-of select="$cowidth"/></xsl:attribute>
        </svg:rect>
        <svg:text y="79px" style="fill:#FFF; font-family: &sans;, sans-serif; font-size: 80px; font-weight: 600;">
          <xsl:attribute name="x">
            <xsl:choose>
              <xsl:when test="$conum = 5 or $conum = 7">
                <xsl:text>29px</xsl:text>
              </xsl:when>
              <xsl:when test="$conum = 2 or $conum = 3">
                <xsl:text>27px</xsl:text>
              </xsl:when>
              <xsl:when test="$conum = 6 or $conum = 9 or $conum = 8">
                <xsl:text>26px</xsl:text>
              </xsl:when>
              <xsl:when test="$conum = 4 or $conum &gt; 10">
                <xsl:text>23px</xsl:text>
              </xsl:when>
              <xsl:otherwise>25px</xsl:otherwise>
            </xsl:choose>
          </xsl:attribute>
          <xsl:value-of select="$conum"/>
        </svg:text>
      </svg:svg>
    </fo:instream-foreign-object>
  </fo:inline>
</xsl:template>


</xsl:stylesheet>
