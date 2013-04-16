<?xml version="1.0" encoding="UTF-8"?>
<!--
  Purpose:
    Restyle titles of chapters, etc.

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
<xsl:stylesheet  version="1.0"
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:fo="http://www.w3.org/1999/XSL/Format">

<xsl:template match="section/title
                     |simplesect/title
                     |sect1/title
                     |sect2/title
                     |sect3/title
                     |sect4/title
                     |sect5/title
                     |section/info/title
                     |simplesect/info/title
                     |sect1/info/title
                     |sect2/info/title
                     |sect3/info/title
                     |sect4/info/title
                     |sect5/info/title
                     |section/sectioninfo/title
                     |sect1/sect1info/title
                     |sect2/sect2info/title
                     |sect3/sect3info/title
                     |sect4/sect4info/title
                     |sect5/sect5info/title"
              mode="titlepage.mode"
              priority="2">

  <xsl:variable name="section" 
                select="(ancestor::section |
                        ancestor::simplesect |
                        ancestor::sect1 |
                        ancestor::sect2 |
                        ancestor::sect3 |
                        ancestor::sect4 |
                        ancestor::sect5)[position() = last()]"/>

  <fo:block keep-with-next.within-column="always">
    <xsl:variable name="id">
      <xsl:call-template name="object.id">
        <xsl:with-param name="object" select="$section"/>
      </xsl:call-template>
    </xsl:variable>

    <xsl:variable name="renderas">
      <xsl:choose>
        <xsl:when test="$section/@renderas = 'sect1'">1</xsl:when>
        <xsl:when test="$section/@renderas = 'sect2'">2</xsl:when>
        <xsl:when test="$section/@renderas = 'sect3'">3</xsl:when>
        <xsl:when test="$section/@renderas = 'sect4'">4</xsl:when>
        <xsl:when test="$section/@renderas = 'sect5'">5</xsl:when>
        <xsl:otherwise><xsl:value-of select="''"/></xsl:otherwise>
      </xsl:choose>
    </xsl:variable>
  
    <xsl:variable name="level">
      <xsl:choose>
        <xsl:when test="$renderas != ''">
          <xsl:value-of select="$renderas"/>
        </xsl:when>
        <xsl:otherwise>
          <xsl:call-template name="section.level">
            <xsl:with-param name="node" select="$section"/>
          </xsl:call-template>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:variable>

    <xsl:variable name="marker">
      <xsl:choose>
        <xsl:when test="$level &lt;= $marker.section.level">1</xsl:when>
        <xsl:otherwise>0</xsl:otherwise>
      </xsl:choose>
    </xsl:variable>

    <xsl:variable name="marker.title">
      <xsl:apply-templates select="$section" mode="titleabbrev.markup">
        <xsl:with-param name="allow-anchors" select="0"/>
      </xsl:apply-templates>
    </xsl:variable>

    <xsl:call-template name="section.heading">
      <xsl:with-param name="level" select="$level"/>
      <xsl:with-param name="marker" select="$marker"/>
      <xsl:with-param name="marker.title" select="$marker.title"/>
    </xsl:call-template>
  </fo:block>
</xsl:template>

<xsl:template name="section.heading">
  <xsl:param name="level" select="1"/>
  <xsl:param name="marker" select="1"/>
  <xsl:param name="marker.title"/>

  <fo:block xsl:use-attribute-sets="section.title.properties">
    <xsl:if test="$marker != 0">
      <fo:marker marker-class-name="section.head.marker">
        <xsl:copy-of select="$marker.title"/>
      </fo:marker>
    </xsl:if>

    <xsl:choose>
      <xsl:when test="$level=1">
        <fo:block xsl:use-attribute-sets="section.title.level1.properties">
          <xsl:call-template name="title.split">
            <xsl:with-param name="node" select="."/>
          </xsl:call-template>
        </fo:block>
      </xsl:when>
      <xsl:when test="$level=2">
        <fo:block xsl:use-attribute-sets="section.title.level2.properties">
          <xsl:call-template name="title.split">
            <xsl:with-param name="node" select="."/>
          </xsl:call-template>
        </fo:block>
      </xsl:when>
      <xsl:when test="$level=3">
        <fo:block xsl:use-attribute-sets="section.title.level3.properties">
          <xsl:call-template name="title.split">
            <xsl:with-param name="node" select="."/>
          </xsl:call-template>
        </fo:block>
      </xsl:when>
      <xsl:when test="$level=4">
        <fo:block xsl:use-attribute-sets="section.title.level4.properties">
          <xsl:call-template name="title.split">
            <xsl:with-param name="node" select="."/>
          </xsl:call-template>
        </fo:block>
      </xsl:when>
      <xsl:when test="$level=5">
        <fo:block xsl:use-attribute-sets="section.title.level5.properties">
          <xsl:call-template name="title.split">
            <xsl:with-param name="node" select="."/>
          </xsl:call-template>>
        </fo:block>
      </xsl:when>
      <xsl:otherwise>
        <fo:block xsl:use-attribute-sets="section.title.level6.properties">
          <xsl:call-template name="title.split">
            <xsl:with-param name="node" select="."/>
          </xsl:call-template>
        </fo:block>
      </xsl:otherwise>
    </xsl:choose>
  </fo:block>
</xsl:template>

<!-- ======================================================================= -->

<xsl:template match="sect1[@role='legal']">
  <xsl:variable name="id">
    <xsl:call-template name="object.id"/>
  </xsl:variable>

  <fo:block id="{$id}"
            xsl:use-attribute-sets="section.level1.properties">
    <fo:block font-size="&small;pt" font-weight="bold"
              space-before="1.12em" space-after="0.75em"
       keep-with-next="always">
      <xsl:value-of select="title" /> 
    </fo:block>
    <fo:block font-size="&xxx-small;pt">
      <xsl:apply-templates/>
    </fo:block>
  </fo:block>
</xsl:template>

<xsl:template match="sect2[parent::sect1[@role='legal']]">
  <xsl:variable name="id">
    <xsl:call-template name="object.id"/>
  </xsl:variable>

  <fo:block id="{$id}"
            xsl:use-attribute-sets="section.level2.properties">
    <fo:block font-size="&x-small;pt"
      keep-with-next="always"
      space-before="1.12em" space-after="0.5em" 
      space-after.precedence="2">
      <xsl:value-of select="title"/> 
    </fo:block>
    <fo:block font-size="&xxx-small;pt">
      <xsl:apply-templates/>
    </fo:block>
  </fo:block>
</xsl:template>

<xsl:template match="sect3[ancestor::sect1[@role='legal']]">
  <xsl:variable name="id">
    <xsl:call-template name="object.id"/>
  </xsl:variable>

  <fo:block id="{$id}"
            xsl:use-attribute-sets="section.level3.properties">
    <fo:block font-size="&x-small;pt" font-style="italic"
      space-before="1.12em" space-after="0.5em" >
      <xsl:value-of select="title"/> 
    </fo:block>
    <fo:block font-size="&xxx-small;pt">
      <xsl:apply-templates/>
    </fo:block>
  </fo:block>
</xsl:template>

<xsl:template match="sect4[ancestor::sect1[@role='legal']]">
  <xsl:variable name="id">
    <xsl:call-template name="object.id"/>
  </xsl:variable>

  <fo:block id="{$id}"
            xsl:use-attribute-sets="section.level4.properties">
    <fo:block font-size="&x-small;pt" font-weight="normal">
      <xsl:value-of select="title"/> 
    </fo:block>
    <fo:block font-size="&xxx-small;pt">
      <xsl:apply-templates/>
    </fo:block>
  </fo:block>
</xsl:template>

<xsl:template match="screen[ancestor::sect1[@role='legal']]">
  <fo:block xsl:use-attribute-sets="monospace.verbatim.properties shade.verbatim.style"
            font-size="{&xxx-small; - 1}pt"
            white-space-collapse='false'
            white-space-treatment='preserve'
            linefeed-treatment='preserve'>
            <!-- I seriously hope no one is going to beat me up over this font
                 size – but the screens in the GPL really do look better this
                 way. -->
    <xsl:apply-templates/>
  </fo:block>
</xsl:template>

</xsl:stylesheet>
