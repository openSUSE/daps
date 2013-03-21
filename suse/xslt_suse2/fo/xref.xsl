<?xml version="1.0" encoding="UTF-8"?>
<!-- 
  Purpose:
    Re-Style admonitions

  Author(s):  Stefan Knorr <sknorr@suse.de>
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
<xsl:stylesheet  version="1.0"
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:fo="http://www.w3.org/1999/XSL/Format">

<xsl:template name="hyperlink.url.display">
  <!-- * This template is called for all external hyperlinks (ulinks and -->
  <!-- * for all simple xlinks); it determines whether the URL for the -->
  <!-- * hyperlink is displayed, and how to display it. -->
  <xsl:param name="url"/>
  <xsl:param name="ulink.url">
    <!-- * ulink.url is just the value of the URL wrapped in 'url(...)' -->
    <xsl:call-template name="fo-external-image">
      <xsl:with-param name="filename" select="$url"/>
    </xsl:call-template>
  </xsl:param>

  <xsl:if test="count(child::node()) != 0
                and string(.) != $url
                and $ulink.show != 0">
    <!-- * Display the URL for this hyperlink only if it is non-empty, -->
    <!-- * and the value of its content is not a URL that is the same as -->
    <!-- * URL it links to, and if ulink.show is non-zero. -->
        <fo:inline hyphenate="false">
          <xsl:text> (</xsl:text>
          <fo:inline color="&dark-green;">
            <fo:basic-link external-destination="{$ulink.url}">
              <xsl:call-template name="hyphenate-url">
                <xsl:with-param name="url" select="$url"/>
              </xsl:call-template>
              <fo:leader leader-pattern="space" leader-length="0.2em"/>
              <fo:instream-foreign-object content-height="0.7em">
                <svg:svg xmlns:svg="http://www.w3.org/2000/svg" width="100"
                  height="100">
                  <svg:rect width="54" height="54" x="0" y="46"
                    fill="&dark-green;" fill-opacity="0.4"/>
                  <svg:path d="M 27,0 27,16 72.7,16 17,71.75 28.25,83 84,27.3 84,73 l 16,0 0,-73 z"
                    fill="&dark-green;"/>
                </svg:svg>
              </fo:instream-foreign-object>
            </fo:basic-link>
          </fo:inline>
          <xsl:text>)</xsl:text>
        </fo:inline>
  </xsl:if>
</xsl:template>

</xsl:stylesheet>
