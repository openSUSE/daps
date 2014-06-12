<?xml version="1.0" encoding="UTF-8"?>
<!--
  Purpose:
    Use sans-serif font in formalpara titles.

  Author(s):  Stefan Knorr <sknorr@suse.de>,
              Thomas Schraitle <toms@opensuse.org>

  Copyright:  2013, Stefan Knorr, Thomas Schraitle

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
  xmlns:fo="http://www.w3.org/1999/XSL/Format"
  xmlns:svg="http://www.w3.org/2000/svg">


<xsl:template match="formalpara/title|formalpara/info/title">
  <xsl:variable name="titleStr">
      <xsl:apply-templates/>
  </xsl:variable>
  <xsl:variable name="lastChar">
    <xsl:if test="$titleStr != ''">
      <xsl:value-of select="substring($titleStr,string-length($titleStr),1)"/>
    </xsl:if>
  </xsl:variable>

  <fo:inline keep-with-next.within-line="always" padding-end="0.6em"
    font-size="{$sans-xheight-adjust}em"
    xsl:use-attribute-sets="variablelist.term.properties">
    <xsl:copy-of select="$titleStr"/>
    <xsl:if test="$lastChar != ''
                  and not(contains($runinhead.title.end.punct, $lastChar))">
      <xsl:value-of select="$runinhead.default.title.end.punct"/>
    </xsl:if>
    <xsl:text>&#160;</xsl:text>
  </fo:inline>
</xsl:template>


<xsl:template name="arch-arrows">
  <!-- It's enough to have one input param to determine both whether we want a
       start or end arrow and what the arrow should say, as end arrows do not
       contain text. -->
  <xsl:param name="arch-value" select="''"/>

  <xsl:if test="$para.use.arch = 1">
    <xsl:choose>
      <xsl:when test="$arch-value != ''">
        <xsl:variable name="arch-string">
          <xsl:call-template name="readable.arch.string">
            <xsl:with-param name="input" select="$arch-value"/>
          </xsl:call-template>
        </xsl:variable>
        <xsl:variable name="instream-font-size" select="70 div 4.54"/>
        <xsl:variable name="font-metrics-ratio" select="&mono-ratio;"/>
          <!-- Only use a monospaced font for the arch-string, else this metrics-ratio
               won't work out all that well – it is used for determining the
               width of the arrow image being shown. -->
        <xsl:variable name="width">
          <xsl:value-of select="string-length(normalize-space($arch-string))*$instream-font-size*$font-metrics-ratio"/>
        </xsl:variable>

        <fo:instream-foreign-object content-height="1em" alignment-baseline="alphabetic"
          alignment-adjust="-0.2em">
          <svg:svg width="{$width + 22}" height="22">
            <svg:path d="m 2.5,0.5 c -1.108,0 -2,0.851 -2,1.909 l 0,17.181 c 0,1.058 0.892,1.909 2,1.909 l {$width + 8},0 c 0.693,0 1.22,-0.348 1.656,-0.835 l 8.751,-8.322 c 0.784,-0.748 0.784,-1.937 0,-2.685 L {$width + 12.161},1.336 C {$width + 11.747},0.889 {$width + 11.197},0.5 {$width + 10.505},0.5 z"
               stroke-width="1" stroke="{$dark-green}" fill="{$dark-green}"/>
            <svg:text font-family="{$mono-stack}" text-anchor="start"
              x="7" y="{$instream-font-size + 1.5}" fill="&white;" font-weight="bold"
              font-size="{$instream-font-size}"><xsl:value-of select="$arch-string"/></svg:text>
          </svg:svg>
        </fo:instream-foreign-object>
        <fo:leader leader-pattern="space" leader-length="0.1em"/>
      </xsl:when>
      <xsl:otherwise>
        <fo:leader leader-pattern="space" leader-length="0.1em"/>
        <fo:instream-foreign-object content-height="1em" alignment-baseline="alphabetic"
          alignment-adjust="-0.2em">
          <svg:svg width="24" height="22">
            <svg:path d="m 21.50025,0.501 c 1.108,0 2,0.851 2,1.909 l 0,17.181 c 0,1.057 -0.892,1.909 -2,1.909 l -10,0 c -0.693,0 -1.22,-0.347 -1.656,-0.835 l -8.751,-8.322 c -0.783,-0.748 -0.783,-1.937 0,-2.685 l 8.751,-8.322 c 0.414,-0.447 0.964,-0.836 1.656,-0.836 z"
               stroke-width="1" stroke="{$dark-green}" fill="{$dark-green}"/>
          </svg:svg>
        </fo:instream-foreign-object>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:if>
</xsl:template>


<!-- Add special handling for arch attribute. -->
<xsl:template match="para">
  <xsl:variable name="keep.together">
    <xsl:call-template name="pi.dbfo_keep-together"/>
  </xsl:variable>

  <fo:block xsl:use-attribute-sets="para.properties">
    <xsl:if test="$keep.together != ''">
      <xsl:attribute name="keep-together.within-column"><xsl:value-of
                      select="$keep.together"/></xsl:attribute>
    </xsl:if>
    <xsl:call-template name="anchor"/>

    <xsl:if test="@arch != ''">
      <xsl:call-template name="arch-arrows">
        <xsl:with-param name="arch-value" select="@arch"/>
      </xsl:call-template>
    </xsl:if>

    <xsl:apply-templates/>

    <xsl:if test="@arch != ''">
      <xsl:call-template name="arch-arrows"/>
    </xsl:if>
  </fo:block>
</xsl:template>

</xsl:stylesheet>
