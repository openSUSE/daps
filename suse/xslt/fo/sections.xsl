<?xml version="1.0" encoding="UTF-8"?>
<!-- $Id: sections.xsl 38275 2009-01-07 13:57:18Z toms $ -->
<xsl:stylesheet version="1.0"
 xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
 xmlns:fo="http://www.w3.org/1999/XSL/Format">


<xsl:include href="section.heading.xsl"/>


<xsl:template match="sect1[@role='legal']">
  <xsl:variable name="id">
    <xsl:call-template name="object.id"/>
  </xsl:variable>

  <fo:block id="{$id}" 
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
    <fo:block font-size="{$legal.title.size}pt" font-style="italic"
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

<xsl:template match="screen[ancestor::sect1[@role='legal']]">
  <fo:block  font-size="{$legal.body.size}pt"
             white-space-collapse='false'
             white-space-treatment='preserve'
             linefeed-treatment='preserve'
             xsl:use-attribute-sets="monospace.verbatim.properties">
    <xsl:apply-templates/>
  </fo:block>
</xsl:template>

</xsl:stylesheet>
