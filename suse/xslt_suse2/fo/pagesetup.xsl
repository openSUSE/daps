<?xml version="1.0" encoding="UTF-8"?>
<!-- 
   Purpose:
     Remove blank pages from PDF output – we really don't need them if people
     are supposed to print books on their own.

   Authors:    Stefan Knorr <sknorr@suse.de>
   Copyright:  2013, Stefan Knorr

-->
<xsl:stylesheet version="1.0"
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:exsl="http://exslt.org/common"
  xmlns:fo="http://www.w3.org/1999/XSL/Format"
  exclude-result-prefixes="exsl">

<!-- Replacement for the force.blank.pages parameter. Remove once we've moved
    past 1.77.1 -->
<xsl:template name="initial.page.number">auto</xsl:template>
<xsl:template name="force.page.count">no-force</xsl:template>
<!-- End replacement for force.blank.pages -->

<xsl:template name="header.table"/>

<xsl:template name="footer.content">
  <xsl:param name="pageclass" select="''"/>
  <xsl:param name="sequence" select="''"/>
  <xsl:param name="position" select="''"/>
  <xsl:param name="gentext-key" select="''"/>

  <fo:block>
    <!-- pageclass can be front, body, back -->
    <!-- sequence can be odd, even, first, blank -->
    <!-- position can be left, center, right -->
    <xsl:choose>
      <xsl:when test="$pageclass = 'titlepage'"/> <!-- Nothing -->

      <xsl:when test="$double.sided != 0 and $sequence = 'even'
                      and $position='left'">
        <fo:page-number/>
      </xsl:when>

      <xsl:when test="$double.sided != 0 and ($sequence = 'odd' or $sequence = 'first')
                      and $position='right'">
        <fo:page-number/>
      </xsl:when>

      <xsl:when test="$position='center'">
        <xsl:if test="$pageclass != 'titlepage'">
          <xsl:choose>
            <xsl:when test="ancestor::book and ($double.sided != 0)">
              <fo:retrieve-marker retrieve-class-name="section.head.marker"
                                  retrieve-position="first-including-carryover"
                                  retrieve-boundary="page-sequence"/>
            </xsl:when>
            <xsl:otherwise>
              <xsl:apply-templates select="." mode="titleabbrev.markup"/>
            </xsl:otherwise>
          </xsl:choose>
        </xsl:if>
      </xsl:when>

      <xsl:when test="$sequence='blank' and $position = 'left'">
        <fo:page-number/>
      </xsl:when>
      <xsl:otherwise/> <!-- Nothing -->
    </xsl:choose>
  </fo:block>
</xsl:template>

</xsl:stylesheet>
