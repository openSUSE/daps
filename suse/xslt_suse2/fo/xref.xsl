<?xml version="1.0" encoding="UTF-8"?>
<!--
  Purpose:
    Add an arrow after outward links to highlight them.

  Author(s):  Stefan Knorr <sknorr@suse.de>
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
<xsl:stylesheet  version="1.0"
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:fo="http://www.w3.org/1999/XSL/Format">

<xsl:template match="ulink" name="ulink">
  <xsl:param name="url" select="@url"/>
  <xsl:variable name="contents">
    <xsl:apply-imports/>
  </xsl:variable>
  
    <fo:inline hyphenate="false" xsl:use-attribute-sets="dark-green">
      <xsl:copy-of select="$contents"/>
      <fo:leader leader-pattern="space" leader-length="0.2em"/>
      <xsl:call-template name="image-after-link"/>
    </fo:inline>
</xsl:template>


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
          <fo:inline xsl:use-attribute-sets="dark-green">
            <fo:basic-link external-destination="{$ulink.url}">
              <xsl:call-template name="hyphenate-url">
                <xsl:with-param name="url" select="$url"/>
              </xsl:call-template>
              <fo:leader leader-pattern="space" leader-length="0.2em"/>
              <xsl:call-template name="image-after-link"/>
            </fo:basic-link>
          </fo:inline>
          <xsl:text>)</xsl:text>
        </fo:inline>
  </xsl:if>
</xsl:template>


<xsl:template name="image-after-link">
  <xsl:variable name="fill">
    <xsl:call-template name="dark-green"/>
  </xsl:variable>

  <fo:instream-foreign-object content-height="0.65em">
    <svg:svg xmlns:svg="http://www.w3.org/2000/svg" width="100"
      height="100">
      <svg:rect width="54" height="54" x="0" y="46" fill-opacity="0.4"
        fill="{$fill}"/>

      <svg:path d="M 27,0 27,16 72.7,16 17,71.75 28.25,83 84,27.3 84,73 l 16,0 0,-73 z"
        fill="{$fill}"/>
    </svg:svg>
  </fo:instream-foreign-object>
</xsl:template>

<xsl:template match="chapter|appendix" mode="insert.title.markup">
  <xsl:param name="purpose"/>
  <xsl:param name="xrefstyle"/>
  <xsl:param name="title"/>

  <xsl:choose>
    <xsl:when test="$purpose = 'xref'">
      <fo:inline xsl:use-attribute-sets="italicized">
        <xsl:copy-of select="$title"/>
      </fo:inline>
    </xsl:when>
    <xsl:otherwise>
      <xsl:copy-of select="$title"/>
    </xsl:otherwise>
  </xsl:choose>
</xsl:template>

<xsl:template match="*" mode="insert.olink.docname.markup">
  <xsl:param name="docname" select="''"/>
  
  <fo:inline xsl:use-attribute-sets="italicized">
    <xsl:value-of select="$docname"/>
  </fo:inline>
</xsl:template>

<xsl:template name="title.xref">
  <xsl:param name="target" select="."/>
  <xsl:choose>
    <xsl:when test="local-name($target) = 'figure'
                    or local-name($target) = 'example'
                    or local-name($target) = 'equation'
                    or local-name($target) = 'table'
                    or local-name($target) = 'dedication'
                    or local-name($target) = 'acknowledgements'
                    or local-name($target) = 'preface'
                    or local-name($target) = 'bibliography'
                    or local-name($target) = 'glossary'
                    or local-name($target) = 'index'
                    or local-name($target) = 'setindex'
                    or local-name($target) = 'colophon'">
      <xsl:call-template name="gentext.startquote"/>
      <xsl:apply-templates select="$target" mode="title.markup"/>
      <xsl:call-template name="gentext.endquote"/>
    </xsl:when>
    <xsl:otherwise>
      <fo:inline xsl:use-attribute-sets="italicized">
        <xsl:apply-templates select="$target" mode="title.markup"/>
      </fo:inline>
    </xsl:otherwise>
  </xsl:choose>
</xsl:template>

</xsl:stylesheet>
