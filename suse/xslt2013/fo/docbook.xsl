<?xml version="1.0" encoding="UTF-8"?>
<!--
  Purpose:
    Transform DocBook document into XSL-FO file

    The page layout is based upon a grid of eight columns (the leftmost and
    rightmost column function as margins), each 22.5 mm wide, and five gutters,
    each 6 mm wide:
    |   C1  |  C2  |G1|  C3  |G2|  C4  |G3|  C5  |G4|  C6  |G5|  C7  |  C8  |

  Parameters:
    Too many to list here, see:
    http://docbook.sourceforge.net/release/xsl/current/doc/fo/index.html

  Input:
    DocBook 4/5 document

   Output:
     XSL-FO file

  Authors:    Thomas Schraitle <toms@opensuse.org>,
              Stefan Knorr <sknorr@suse.de>
  Copyright:  2013, Thomas Schraitle, Stefan Knorr

-->
<xsl:stylesheet version="1.0"
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:exsl="http://exslt.org/common"
  xmlns:fo="http://www.w3.org/1999/XSL/Format"
  exclude-result-prefixes="exsl">

  <xsl:import href="http://docbook.sourceforge.net/release/xsl/current/fo/docbook.xsl"/>

  <xsl:include href="../VERSION.xsl"/>
  <xsl:include href="param.xsl"/>
  <xsl:include href="attributesets.xsl"/>
  <xsl:include href="../common/units.xsl"/>
  <xsl:include href="../common/titles.xsl"/>
  <xsl:include href="../common/labels.xsl"/>
  <xsl:include href="../common/dates-revisions.xsl"/>
  <xsl:include href="../common/navigation.xsl"/>

  <xsl:include href="autotoc.xsl"/>
  <xsl:include href="callout.xsl"/>
  <xsl:include href="xref.xsl"/>
  <xsl:include href="formal.xsl"/>
  <xsl:include href="sections.xsl"/>
  <xsl:include href="table.xsl"/>
  <xsl:include href="htmltbl.xsl"/>
  <xsl:include href="inline.xsl"/>
  <xsl:include href="fo.xsl"/>
  <xsl:include href="refentry.xsl"/>
  <xsl:include href="division.xsl"/>
  <xsl:include href="admon.xsl"/>
  <xsl:include href="component.xsl"/>
  <xsl:include href="block.xsl"/>
  <xsl:include href="hyphenate-url.xsl"/>
  <xsl:include href="titlepage.xsl"/>
  <xsl:include href="titlepage.templates.xsl"/>
  <xsl:include href="pagesetup.xsl"/>


  <xsl:include href="lists.xsl"/>
  <xsl:include href="l10n.properties.xsl"/>

  <xsl:include href="fop1.xsl"/>
  <xsl:include href="xep.xsl"/>

  <!-- 
    This fragment is used to build a sect1 by using rootid parameter 
  -->
  <xsl:template match="sect1|section" mode="process.root">
      <xsl:variable name="document.element" select="self::*"/>

  <xsl:call-template name="root.messages"/>

  <xsl:variable name="title">
    <xsl:choose>
      <xsl:when test="$document.element/title[1]">
        <xsl:value-of select="$document.element/title[1]"/>
      </xsl:when>
      <xsl:otherwise>[could not find document title]</xsl:otherwise>
    </xsl:choose>
  </xsl:variable>
  
  <!-- Include all id values in XEP output -->
  <xsl:if test="$xep.extensions != 0">
    <xsl:processing-instruction 
     name="xep-pdf-drop-unused-destinations">false</xsl:processing-instruction>
  </xsl:if>

  <fo:root xsl:use-attribute-sets="root.properties">
    <xsl:attribute name="language">
      <xsl:call-template name="l10n.language">
        <xsl:with-param name="target" select="/*[1]"/>
      </xsl:call-template>
    </xsl:attribute>

    <xsl:if test="$xep.extensions != 0">
      <xsl:call-template name="xep-pis"/>
      <xsl:call-template name="xep-document-information"/>
    </xsl:if>
    <xsl:if test="$axf.extensions != 0">
      <xsl:call-template name="axf-document-information"/>
    </xsl:if>

    <xsl:call-template name="setup.pagemasters"/>

    <xsl:if test="$fop.extensions != 0">
      <xsl:apply-templates select="$document.element" mode="fop.outline"/>
    </xsl:if>

    <xsl:if test="$fop1.extensions != 0">
      <xsl:call-template name="fop1-document-information"/>
      <xsl:variable name="bookmarks">
        <xsl:apply-templates select="$document.element" 
                             mode="fop1.outline"/>
      </xsl:variable>
      <xsl:if test="string($bookmarks) != ''">
        <fo:bookmark-tree>
          <xsl:copy-of select="$bookmarks"/>
        </fo:bookmark-tree>
      </xsl:if>
      <xsl:apply-templates select="$document.element" 
                           mode="fop1.foxdest"/>
    </xsl:if>

    <xsl:if test="$xep.extensions != 0">
      <xsl:variable name="bookmarks">
        <xsl:apply-templates select="$document.element" mode="xep.outline"/>
      </xsl:variable>
      <xsl:if test="string($bookmarks) != ''">
        <rx:outline xmlns:rx="http://www.renderx.com/XSL/Extensions">
          <xsl:copy-of select="$bookmarks"/>
        </rx:outline>
      </xsl:if>
    </xsl:if>

    <xsl:if test="$arbortext.extensions != 0 and $ati.xsl11.bookmarks != 0">
      <xsl:variable name="bookmarks">
        <xsl:apply-templates select="$document.element"
                             mode="ati.xsl11.bookmarks"/>
      </xsl:variable>
      <xsl:if test="string($bookmarks) != ''">
        <fo:bookmark-tree>
          <xsl:copy-of select="$bookmarks"/>
        </fo:bookmark-tree>
      </xsl:if>
    </xsl:if>

    <xsl:call-template name="section.page.sequence"/>
  </fo:root>
  </xsl:template>

</xsl:stylesheet>
