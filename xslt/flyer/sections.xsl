<?xml version='1.0'?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:fo="http://www.w3.org/1999/XSL/Format"
                xmlns:axf="http://www.antennahouse.com/names/XSL/Extensions"
                version='1.0'>

<!-- ********************************************************************
     $Id: sections.xsl 6199 2006-08-24 15:36:31Z bobstayton $
     ********************************************************************

     This file is part of the XSL DocBook Stylesheet distribution.
     See ../README or http://nwalsh.com/docbook/xsl/ for copyright
     and other information.

     ******************************************************************** -->

<!-- ==================================================================== -->

<xsl:param name="legal.body.size" select="$body.font.master div 1.75"/>
<xsl:param name="legal.title.size" select="$body.font.master div 1.5"/>


<xsl:template match="sect1[@role='legal']">
  <xsl:variable name="id">
    <xsl:call-template name="object.id"/>
  </xsl:variable>

  <fo:block id="{$id}" page-break-before="always"
            xsl:use-attribute-sets="section.level1.properties">
    <fo:block font-size="{$body.font.master}pt" font-weight="bold"
              space-before="1.12em" space-after="0.75em"
       keep-with-next="always">
      <xsl:value-of select="title" /> 
      <!-- mode="sect1.titlepage.recto.mode" -->
    </fo:block>
    <fo:block font-size="{$legal.body.size}pt">
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
    <!--<xsl:call-template name="sect2.titlepage"/>-->
    <fo:block font-size="{$legal.title.size}pt"
      keep-with-next="always"
      space-before="1.12em" space-after="0.5em" 
      space-after.precedence="2">
      <xsl:value-of select="title"/> 
      <!-- mode="sect2.titlepage.recto.mode"/> -->
    </fo:block>
    <fo:block font-size="{$legal.body.size}pt">
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
    <!--<xsl:call-template name="sect3.titlepage"/>-->
    <fo:block font-size="{$legal.title.size}pt" font-weight="italic"
      space-before="1.12em" space-after="0.5em" >
      <xsl:value-of select="title"/> 
      <!-- mode="sect3.titlepage.recto.mode"/> --> 
    </fo:block>
    <fo:block font-size="{$legal.body.size}pt">
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
    <!--<xsl:call-template name="sect4.titlepage"/>-->
    <fo:block font-size="{$legal.title.size}pt" font-weight="normal">
      <xsl:value-of select="title"/> 
      <!-- mode="sect4.titlepage.recto.mode"/> --> 
    </fo:block>
    <fo:block font-size="{$legal.body.size}pt">
      <xsl:apply-templates/>
    </fo:block>
  </fo:block>
</xsl:template>



<!-- ==================================================================== -->

<xsl:template name="section.heading">
  <xsl:param name="level" select="1"/>
  <xsl:param name="marker" select="1"/>
  <xsl:param name="title"/>
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
          <xsl:copy-of select="$title"/>
        </fo:block>
      </xsl:when>
      <xsl:when test="$level=2">
        <fo:block xsl:use-attribute-sets="section.title.level2.properties">
          <xsl:copy-of select="$title"/>
        </fo:block>
      </xsl:when>
      <xsl:when test="$level=3">
        <fo:block xsl:use-attribute-sets="section.title.level3.properties">
          <xsl:copy-of select="$title"/>
        </fo:block>
      </xsl:when>
      <xsl:when test="$level=4">
        <fo:block xsl:use-attribute-sets="section.title.level4.properties">
          <xsl:copy-of select="$title"/>
        </fo:block>
      </xsl:when>
      <xsl:when test="$level=5">
        <fo:block xsl:use-attribute-sets="section.title.level5.properties">
          <xsl:copy-of select="$title"/>
        </fo:block>
      </xsl:when>
      <xsl:otherwise>
        <fo:block xsl:use-attribute-sets="section.title.level6.properties">
          <xsl:copy-of select="$title"/>
        </fo:block>
      </xsl:otherwise>
    </xsl:choose>
  </fo:block>
</xsl:template>


</xsl:stylesheet>

