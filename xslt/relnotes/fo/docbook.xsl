<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0"
  xmlns:fo="http://www.w3.org/1999/XSL/Format"
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
  
  <!-- <xsl:import href="http://docbook.sourceforge.net/release/xsl/current/fo/docbook.xsl"/> -->
  <xsl:import href="file:///usr/share/xml/docbook/stylesheet/nwalsh/current//fo/docbook.xsl"/>
  
  <!-- 
           Parameter
  -->
  <!-- Define indentation of body text area -->
  <xsl:param name="body.start.indent">0pt</xsl:param>

  <!-- Define page dimensions -->
  <xsl:param name="paper.type">A4</xsl:param>

  <!-- Enable FOP 1.0 -->
  <xsl:param name="fop1.extension" select="1"/> 

  <!-- Enable Section numbering -->
  <xsl:param name="section.autolabel" select="1"/>
  <xsl:param name="section.label.includes.component.label" select="1"/>

  <!-- Fonts -->
  <xsl:param name="sans.font.family">DroidSans</xsl:param>
  <xsl:param name="title.font.family">DroidSans</xsl:param>
  <xsl:param name="body.font.family">DroidSerif</xsl:param>
  <xsl:param name="monospace.font.family">DroidSansMono</xsl:param>

  <!-- Show links? -->
  <xsl:param name="ulink.show" select="0"/>

  <!-- 
           Attribute Sets
  -->
  <!-- Make tables content always left aligned, regardless of body text  -->
  <xsl:attribute-set name="table.properties">
    <xsl:attribute name="text-align">left</xsl:attribute>
  </xsl:attribute-set>
  
  <xsl:attribute-set name="section.title.properties">
    <xsl:attribute name="hyphenate">false</xsl:attribute>
    <xsl:attribute name="space-before.minimum">1.2em</xsl:attribute>
    <xsl:attribute name="space-before.optimum">1.4em</xsl:attribute>
    <xsl:attribute name="space-before.maximum">1.72em</xsl:attribute>
    <xsl:attribute name="space-after.minimum">0em</xsl:attribute>
    <xsl:attribute name="space-after.optimum">0em</xsl:attribute>
    <xsl:attribute name="space-after.maximum">0em</xsl:attribute>
  </xsl:attribute-set>
  

  <!-- 
           Templates
  -->
  <!-- Fix FATE ulink: no URL should appear -->
  <xsl:template match="ulink[@role='small']">
    <xsl:param name="url" select="@url"/>
    <xsl:variable name ="ulink.url">
      <xsl:call-template name="fo-external-image">
        <xsl:with-param name="filename" select="$url"/>
      </xsl:call-template>
    </xsl:variable>

    <fo:basic-link xsl:use-attribute-sets="xref.properties"
                 external-destination="{$ulink.url}">
      <xsl:apply-templates/>
    </fo:basic-link>
    <xsl:call-template name="hyperlink.url.display">
      <xsl:with-param name="url" select="$url"/>
      <xsl:with-param name="ulink.url" select="$ulink.url"/>
    </xsl:call-template>
  </xsl:template>
  
  <!-- Suppress sections with role='notoc' -->
  <xsl:template match="section[@role='notoc']" mode="toc"/>
  
  <!-- Make all section titles with role='nonumber' -->
  <xsl:template match="section/title[@role='nonumber']" mode="titlepage.mode">
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
    <xsl:variable name="title">
      <xsl:apply-templates />
      <!--
        <xsl:apply-templates select="$section" mode="object.title.markup.textonly">
        <xsl:with-param name="allow-anchors" select="1"/>
      </xsl:apply-templates>
      -->
    </xsl:variable>
    <xsl:variable name="marker.title">
      <xsl:apply-templates select="$section" mode="titleabbrev.markup">
        <xsl:with-param name="allow-anchors" select="0"/>
      </xsl:apply-templates>
    </xsl:variable>
    <xsl:call-template name="section.heading">
      <xsl:with-param name="level" select="$level"/>
      <xsl:with-param name="title" select="$title"/>
      <xsl:with-param name="marker" select="$marker"/>
      <xsl:with-param name="marker.title" select="$marker.title"/>
    </xsl:call-template>
  </fo:block>
  </xsl:template>

  
</xsl:stylesheet>
