<?xml version="1.0" encoding="UTF-8"?>
<!--
  Purpose:
    A very simplified version of the process.image template that only
    serves as a makeshift measure until the $link.to.self.for.mediaobject has
    arrived upstream.

    FIXME: Remove this file when DocBook 1.79.0 comes out. (Of course, with this
    file's process.image template, the processor has far less to do, so maybe
    we should keep it..?)

   Author(s):   Stefan Knorr<sknorr@suse.de>,
                Thomas Schraitle <toms@opensuse.org>
   Copyright:   2013, Stefan Knorr, Thomas Schraitle

-->

<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xlink="http://www.w3.org/1999/xlink"
  xmlns:xtext="xalan://com.nwalsh.xalan.Text"
  xmlns:lxslt="http://xml.apache.org/xslt"
  exclude-result-prefixes="xlink xtext lxslt"
  extension-element-prefixes="xtext" version="1.0">

  <lxslt:component prefix="xtext" elements="insertfile"/>

  <xsl:template name="process.image">
    <xsl:param name="tag" select="'img'"/>
    <xsl:param name="alt"/>
    <xsl:param name="longdesc"/>
    <xsl:variable name="filename">
      <xsl:call-template name="mediaobject.filename">
        <xsl:with-param name="object" select=".."/>
      </xsl:call-template>
    </xsl:variable>
    <xsl:variable name="output_filename">
      <xsl:value-of select="$filename"/>
    </xsl:variable>

    <xsl:choose>
      <xsl:when test="@format = 'SVG'">
        <object type="image/svg+xml">
          <xsl:attribute name="data">
            <xsl:choose>
              <xsl:when test="$img.src.path != '' and $tag = 'img' and
                              not(starts-with($output_filename, '/')) and
                              not(contains($output_filename, '://'))">
                <xsl:value-of select="$img.src.path"/>
              </xsl:when>
            </xsl:choose>
            <xsl:value-of select="$output_filename"/>
          </xsl:attribute>
          <xsl:call-template name="process.image.attributes">
            <xsl:with-param name="longdesc" select="$longdesc"/>
          </xsl:call-template>
        </object>
      </xsl:when>
      <xsl:otherwise>
        <xsl:variable name="src">
          <xsl:choose>
            <xsl:when test="$img.src.path != '' and $tag = 'img' and
                            not(starts-with($output_filename, '/')) and
                            not(contains($output_filename, '://'))">
                <xsl:value-of select="$img.src.path"/>
            </xsl:when>
          </xsl:choose>
          <xsl:value-of select="$output_filename"/>
        </xsl:variable>

        <xsl:variable name="imgcontents">
          <xsl:element name="{$tag}">
            <xsl:attribute name="src">
              <xsl:value-of select="$src"/>
            </xsl:attribute>
            <xsl:call-template name="process.image.attributes">
              <xsl:with-param name="alt">
                <xsl:choose>
                  <xsl:when test="$alt != ''">
                    <xsl:copy-of select="$alt"/>
                  </xsl:when>
                  <xsl:when test="ancestor::figure">
                    <xsl:variable name="fig.title">
                      <xsl:apply-templates select="ancestor::figure/title/node()"/>
                    </xsl:variable>
                    <xsl:value-of select="normalize-space($fig.title)"/>
                  </xsl:when>
                </xsl:choose>
              </xsl:with-param>
            </xsl:call-template>
        </xsl:element>
      </xsl:variable>

      <a href="{$src}">
        <xsl:copy-of select="$imgcontents"/>
      </a>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

</xsl:stylesheet>
