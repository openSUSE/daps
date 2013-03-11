<?xml version="1.0" encoding="UTF-8"?>
<!-- 
  Purpose:
    Adapt inline monospaced font, so its x-height is about as tall as that of
    the serif font (Charis SIL), we use for the body text.

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

<xsl:template name="inline.monoseq">
  <xsl:param name="content">
    <xsl:call-template name="simple.xlink">
      <xsl:with-param name="content">
        <xsl:apply-templates/>
      </xsl:with-param>
    </xsl:call-template>
  </xsl:param>

  <fo:inline xsl:use-attribute-sets="monospace.properties">
    <xsl:if test="local-name(ancestor::*) != 'title'">
      <xsl:attribute name="font-size">&normal;pt</xsl:attribute>
    </xsl:if>
    <xsl:call-template name="anchor"/>
    <xsl:if test="@dir">
      <xsl:attribute name="direction">
        <xsl:choose>
          <xsl:when test="@dir = 'ltr' or @dir = 'lro'">ltr</xsl:when>
          <xsl:otherwise>rtl</xsl:otherwise>
        </xsl:choose>
      </xsl:attribute>
    </xsl:if>
    <xsl:copy-of select="$content"/>
  </fo:inline>
</xsl:template>

<xsl:template name="inline.boldmonoseq">
  <xsl:param name="content">
    <xsl:call-template name="simple.xlink">
      <xsl:with-param name="content">
        <xsl:apply-templates/>
      </xsl:with-param>
    </xsl:call-template>
  </xsl:param>

  <fo:inline font-weight="bold" xsl:use-attribute-sets="monospace.properties">
    <xsl:if test="local-name(ancestor::*) != 'title'">
      <xsl:attribute name="font-size">&normal;pt</xsl:attribute>
    </xsl:if>
    <xsl:call-template name="anchor"/>
    <xsl:if test="@dir">
      <xsl:attribute name="direction">
        <xsl:choose>
          <xsl:when test="@dir = 'ltr' or @dir = 'lro'">ltr</xsl:when>
          <xsl:otherwise>rtl</xsl:otherwise>
        </xsl:choose>
      </xsl:attribute>
    </xsl:if>
    <xsl:copy-of select="$content"/>
  </fo:inline>
</xsl:template>

<xsl:template name="inline.italicmonoseq">
  <xsl:param name="content">
    <xsl:call-template name="simple.xlink">
      <xsl:with-param name="content">
        <xsl:apply-templates/>
      </xsl:with-param>
    </xsl:call-template>
  </xsl:param>

  <fo:inline font-style="italic" xsl:use-attribute-sets="monospace.properties">
    <xsl:if test="local-name(ancestor::*) != 'title'">
      <xsl:attribute name="font-size">&normal;pt</xsl:attribute>
    </xsl:if>
    <xsl:call-template name="anchor"/>
    <xsl:if test="@dir">
      <xsl:attribute name="direction">
        <xsl:choose>
          <xsl:when test="@dir = 'ltr' or @dir = 'lro'">ltr</xsl:when>
          <xsl:otherwise>rtl</xsl:otherwise>
        </xsl:choose>
      </xsl:attribute>
    </xsl:if>
    <xsl:copy-of select="$content"/>
  </fo:inline>
</xsl:template>

<!-- ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ -->

<xsl:template match="command">
  <xsl:call-template name="inline.boldmonoseq">
  </xsl:call-template>
</xsl:template>


<!-- This template is only almost the same version as that in the upcoming
     1.77.2 upstream release. However, we probably want to use upstream's
     "keycap" context, then.-->
<xsl:template match="keycap">
  <xsl:variable name="cap">
    <xsl:choose>
      <xsl:when test="@function and normalize-space(.) = ''">
        <xsl:call-template name="gentext.template">
          <xsl:with-param name="context" select="'msgset'"/>
            <!-- This context is called 'keycap' instead in the upcoming
                  upstream release – use this later on. -->
          <xsl:with-param name="name" select="@function"/>
        </xsl:call-template>
      </xsl:when>
      <xsl:otherwise>
        <xsl:apply-templates/>
      </xsl:otherwise>
   </xsl:choose>
  </xsl:variable>

    <fo:instream-foreign-object content-height=".93em" alignment-baseline="alphabetic"
      alignment-adjust="-0.185em">
    <svg:svg xmlns:svg="http://www.w3.org/2000/svg" width="55" height="100">
      <svg:defs>
        <svg:linearGradient id="svg-gr-recessed" x1="0.05" y1="0.05" x2=".95" y2=".95">
          <svg:stop style="stop-color:#999;stop-opacity:1" offset="0" />
          <svg:stop style="stop-color:#999;stop-opacity:1" offset="0.25" />
          <svg:stop style="stop-color:#666;stop-opacity:1" offset="0.75" />
          <svg:stop style="stop-color:#666;stop-opacity:1" offset="1" />
        </svg:linearGradient>
     </svg:defs>
       <svg:rect width="55" height="100" rx="10" ry="10" x="0" y="0"
         style="fill:url(#svg-gr-recessed);fill-opacity:1;stroke:none" />
       <svg:rect width="40" height="85" rx="7.5" ry="7.5" x="5" y="5"
          style="fill:#efeff0;fill-opacity:1;stroke:none" />
       <svg:text style="font-family: &mono;; font-size: 70px;"
         x="30" y="70" text-anchor="middle"><xsl:value-of select="$cap"/></svg:text>
    </svg:svg>
  </fo:instream-foreign-object>
</xsl:template>


</xsl:stylesheet>
