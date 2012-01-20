<?xml version="1.0" encoding="UTF-8"?>
<!-- 
 The output of this stylesheet conforms to the following syntax: 
  NUMBER SEP ID SEP TITLE

 For example:
I#part.kde.desktop#Introduction
1#cha.kde.start#Getting Started with the KDE Desktop
2#cha.kde.use#Working with Your Desktop

-->

<xsl:stylesheet version="1.0"
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform">

  <xsl:import href="rootid.xsl"/>
  <xsl:output method="text" encoding="UTF-8"/>

  <xsl:param name="sep">#</xsl:param>

  <xsl:template match="text()"/>


  <xsl:template match="appendix">
    <xsl:variable name="num">
      <xsl:number format="A"/>
    </xsl:variable>
    <xsl:variable name="title" select="(title|appendixinfo/title)[1]"/>

    <xsl:call-template name="build-string">
      <xsl:with-param name="num" select="$num"/>
      <xsl:with-param name="title" select="$title"/>
    </xsl:call-template>
    <xsl:apply-templates/>
  </xsl:template>

  <xsl:template match="chapter">
    <xsl:variable name="num">
      <xsl:number from="book" level="any"/>
    </xsl:variable>
    <xsl:variable name="title" select="(title|chapterinfo/title)[1]"/>

    <xsl:call-template name="build-string">
      <xsl:with-param name="num" select="$num"/>
      <xsl:with-param name="title" select="$title"/>
    </xsl:call-template>
    <xsl:apply-templates/>
  </xsl:template>

  <xsl:template match="glossary">
    <xsl:variable name="num">
      <xsl:number from="book" format="1"/>
    </xsl:variable>
    <xsl:variable name="title" select="(title|glossaryinfo/title)[1]"/>

    <xsl:call-template name="build-string">
      <xsl:with-param name="num" select="concat('G', $num)"/>
      <xsl:with-param name="title" select="$title"/>
    </xsl:call-template>
    <xsl:apply-templates/>
  </xsl:template>

  <xsl:template match="part">
    <xsl:variable name="num">
      <xsl:number from="book" format="I"/>
    </xsl:variable>
    <xsl:variable name="title" select="(title|partinfo/title)[1]"/>
    
    <xsl:call-template name="build-string">
      <xsl:with-param name="num" select="$num"/>
      <xsl:with-param name="title" select="$title"/>
    </xsl:call-template>
    <xsl:apply-templates/>
  </xsl:template>
  
  <xsl:template match="preface">
    <xsl:variable name="title" select="(title|prefaceinfo/title)[1]"/>
    
    <xsl:call-template name="build-string">
      <xsl:with-param name="num" select="'P'"/>
      <xsl:with-param name="title" select="$title"/>
    </xsl:call-template>
    <xsl:apply-templates/>
  </xsl:template>

  <xsl:template match="refentry">
    <xsl:variable name="num">
      <xsl:number from="book" format="1"/>
    </xsl:variable>
    <xsl:variable name="title" select="(refmeta/refentrytitle)[1]"/>
    
    <xsl:call-template name="build-string">
      <xsl:with-param name="num" select="concat('R', $num)"/>
      <xsl:with-param name="title" select="$title"/>
    </xsl:call-template>
    <xsl:apply-templates/>
  </xsl:template>

  <xsl:template name="build-string">
    <xsl:param name="num"/>
    <xsl:param name="title"/>
    
    <xsl:choose>
      <xsl:when test="@id != ''">
        <xsl:value-of
          select="concat($num, $sep,
                         @id, $sep,
                         normalize-space($title),
                         '&#10;')"/>
      </xsl:when>
      <xsl:otherwise>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

</xsl:stylesheet>
