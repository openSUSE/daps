<?xml version="1.0" encoding="UTF-8"?>
<!--
  Purpose:
    Adapt inline monospaced font, so its x-height is about as tall as that of
    the serif font (Charis SIL), we use for the body text.

    You might notice the pattern of using fo:leaders for distancing inline
    elements from each other instead of simply using paddings/margins: that is
    because FOP (at least v1.1) seems to apply margins and paddings only after
    laying out the text. Therefore, any element that a margin is applied to may
    be pushed behind the text. We do not approve.

  Author(s):  Stefan Knorr <sknorr@suse.de>,
              Thomas Schraitle <toms@opensuse.org>

  Copyright:  2013, Stefan Knorr, Thomas Schraitle

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
<xsl:stylesheet version="1.0"
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

  <fo:inline xsl:use-attribute-sets="monospace.properties" font-weight="normal">
    <xsl:if test="parent::para|parent::title">
      <xsl:attribute name="border-bottom">0.25mm solid &mid-gray;</xsl:attribute>
      <xsl:attribute name="padding-bottom">0.1em</xsl:attribute>
    </xsl:if>
    <xsl:if test="not(ancestor::title or ancestor::term)">
      <xsl:attribute name="font-size">&normal;pt</xsl:attribute>
    </xsl:if>
    <xsl:if test="parent::para|parent::title">
       <fo:leader leader-pattern="space" leader-length="0.2em"/>
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
    <xsl:if test="parent::para|parent::title">
       <fo:leader leader-pattern="space" leader-length="0.2em"/>
    </xsl:if>
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
    <xsl:if test="parent::para|parent::title">
      <xsl:attribute name="border-bottom">0.25mm solid &mid-gray;</xsl:attribute>
      <xsl:attribute name="padding-bottom">0.1em</xsl:attribute>
    </xsl:if>
    <xsl:if test="not(ancestor::title or ancestor::term)">
      <xsl:attribute name="font-size">&normal;pt</xsl:attribute>
    </xsl:if>
    <xsl:if test="parent::para|parent::title">
       <fo:leader leader-pattern="space" leader-length="0.2em"/>
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
    <xsl:if test="parent::para|parent::title">
       <fo:leader leader-pattern="space" leader-length="0.2em"/>
    </xsl:if>
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

  <fo:inline font-style="italic" xsl:use-attribute-sets="monospace.properties"
     font-weight="normal">
    <xsl:if test="parent::para|parent::title">
      <xsl:attribute name="border-bottom">0.25mm solid &mid-gray;</xsl:attribute>
      <xsl:attribute name="padding-bottom">0.1em</xsl:attribute>
    </xsl:if>
    <xsl:if test="not(ancestor::title or ancestor::term)">
      <xsl:attribute name="font-size">&normal;pt</xsl:attribute>
    </xsl:if>
    <xsl:if test="parent::para|parent::title">
       <fo:leader leader-pattern="space" leader-length="0.2em"/>
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
    <xsl:if test="parent::para|parent::title">
       <fo:leader leader-pattern="space" leader-length="0.2em"/>
    </xsl:if>
  </fo:inline>
</xsl:template>

<!-- ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ -->

<xsl:template match="command">
  <xsl:call-template name="inline.boldmonoseq">
  </xsl:call-template>
</xsl:template>

<xsl:template match="keycap">
  <xsl:variable name="cap">
    <xsl:choose>
      <xsl:when test="@function and normalize-space(.) = ''">
        <xsl:call-template name="gentext.template">
          <xsl:with-param name="context" select="'msgset'"/>
            <!-- This context is called "keycap" instead in the upcoming
                 upstream release – TODO: use "keycap" when we've switched to
                 1.77.2. -->
          <xsl:with-param name="name" select="@function"/>
        </xsl:call-template>
      </xsl:when>
      <xsl:otherwise>
        <xsl:apply-templates/>
      </xsl:otherwise>
   </xsl:choose>
  </xsl:variable>
  <xsl:variable name="instream-font-size" select="70"/>
  <xsl:variable name="font-metrics-ratio" select="&mono-ratio;"/>
    <!-- Only use a monospaced font for the keycaps, else this metrics-ratio
         won't work out all that well – it is used both for determining the
         width of the key image being shown as well as centering the text on the
         image. -->
  <xsl:variable name="width">
    <xsl:value-of select="string-length(normalize-space($cap))*$instream-font-size*$font-metrics-ratio"/>
  </xsl:variable>

  <xsl:if test="not(parent::keycombo)">
    <xsl:if test="(preceding-sibling::*|preceding-sibling::text()) and
                  not(preceding-sibling::remark)">
      <fo:leader leader-pattern="space" leader-length="0.2em"/>
    </xsl:if>
  </xsl:if>

  <fo:instream-foreign-object content-height="1em" alignment-baseline="alphabetic"
    alignment-adjust="-0.2em">
    <svg:svg xmlns:svg="http://www.w3.org/2000/svg" height="100"
      width="{$width + 55}">
      <svg:defs>
        <svg:linearGradient id="svg-gr-recessed" x1="0.05" y1="0.05" x2=".95" y2=".95">
          <svg:stop stop-color="&light-gray;" stop-opacity="1" offset="0" />
          <svg:stop stop-color="&light-gray;" stop-opacity="1" offset="0.4" />
          <svg:stop stop-color="&mid-gray;" stop-opacity="1" offset="0.6" />
          <svg:stop stop-color="&mid-gray;" stop-opacity="1" offset="1" />
        </svg:linearGradient>
      </svg:defs>
      <svg:rect height="100" rx="10" ry="10" x="0" y="0"
        fill="url(#svg-gr-recessed)" fill-opacity="1" stroke="none"
        width="{$width+55}">
      </svg:rect>
      <svg:rect height="85" rx="7.5" ry="7.5" x="5" y="5"
        fill="&light-gray-old;" fill-opacity="1" stroke="none" width="{$width+40}">
      </svg:rect>
      <svg:text font-family="&mono;" text-anchor="middle" x="{$width div 2 + 23}"
        y="{$instream-font-size}" color="&dark-gray;"
        font-size="{$instream-font-size}"><xsl:value-of select="$cap"/></svg:text>
    </svg:svg>
  </fo:instream-foreign-object>

  <xsl:if test="not(parent::keycombo)">
    <xsl:if test="(following-sibling::*|following-sibling::text()) and
                  not(following-sibling::remark)">
    <fo:leader leader-pattern="space" leader-length="0.2em"/>
    </xsl:if>
  </xsl:if>

</xsl:template>

<xsl:template match="keycombo">
  <xsl:variable name="joinchar">–</xsl:variable>

  <xsl:if test="(preceding-sibling::*|preceding-sibling::text()) and
                not(preceding-sibling::remark)">
    <fo:leader leader-pattern="space" leader-length="0.2em"/>
  </xsl:if>

  <xsl:for-each select="*">
    <xsl:if test="position()>1">
      <fo:inline space-start="-0.05em" space-end="0" color="#666">
        <xsl:value-of select="$joinchar"/>
      </fo:inline>
    </xsl:if>
    <xsl:apply-templates select="."/>
  </xsl:for-each>

  <xsl:if test="(following-sibling::*|following-sibling::text()) and
                not(following-sibling::remark)">
    <fo:leader leader-pattern="space" leader-length="0.2em"/>
  </xsl:if>
</xsl:template>

</xsl:stylesheet>
