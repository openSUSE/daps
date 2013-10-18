<?xml version="1.0" encoding="UTF-8"?>
<!--
  Purpose:
    Return ready-made markup for the date and revision field on the imprint
    page in both FO and HTML.

  Author(s):    Stefan Knorr <sknorr@suse.de>,
                Thomas Schraitle <toms@opensuse.org>

  Copyright:    2013, Stefan Knorr, Thomas Schraitle

-->
<xsl:stylesheet version="1.0"
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform">


  <xsl:template name="date.and.revision.check">
    <xsl:variable name="date.revision"
      select="(bookinfo/date | info/date | articleinfo/date |
               bookinfo/releaseinfo | articleinfo/releaseinfo |
               info/releaseinfo)[1]"/>
    <xsl:choose>
      <xsl:when test="$date.revision != ''">1</xsl:when>
      <xsl:otherwise>0</xsl:otherwise>
    </xsl:choose>
  </xsl:template>


  <xsl:template name="date.and.revision.inner">
    <xsl:variable name="date">
      <xsl:apply-templates select="(bookinfo/date | info/date |
        articleinfo/date)[1]"/>
    </xsl:variable>
    <xsl:variable name="revision-candidate"
      select="substring-before((bookinfo/releaseinfo | articleinfo/releaseinfo |
                               info/releaseinfo)[1],' $')"/>
    <xsl:variable name="revision">
      <xsl:choose>
        <xsl:when test="starts-with($revision-candidate, '$Rev: ')">
          <xsl:value-of select="substring-after($revision-candidate,
                                                '$Rev: ')"/>
        </xsl:when>
        <xsl:when test="starts-with($revision-candidate, '$Revision: ')">
          <xsl:value-of select="substring-after($revision-candidate,
                                                '$Revision: ')"/>
        </xsl:when>
        <xsl:when test="starts-with($revision-candidate, '$LastChangedRevision: ')">
          <xsl:value-of select="substring-after($revision-candidate,
                                                '$LastChangedRevision: ')"/>
        </xsl:when>
        <xsl:otherwise/>
      </xsl:choose>
    </xsl:variable>

    <xsl:if test="$date != ''">
      <xsl:call-template name="imprint.label">
        <xsl:with-param name="label" select="'pubdate'"/>
      </xsl:call-template>
      <xsl:value-of select="$date"/>
      <xsl:if test="$revision != ''">
        <!-- Misappropriated but hopefully still correct everywhere. -->
        <xsl:call-template name="gentext.template">
          <xsl:with-param name="context" select="'iso690'"/>
          <xsl:with-param name="name" select="'spec.pubinfo.sep'"/>
        </xsl:call-template>
      </xsl:if>
    </xsl:if>
    <xsl:if test="$revision != ''">
      <xsl:call-template name="imprint.label">
        <xsl:with-param name="label" select="'revision'"/>
      </xsl:call-template>
      <xsl:value-of select="$revision"/>
    </xsl:if>
  </xsl:template>


</xsl:stylesheet>