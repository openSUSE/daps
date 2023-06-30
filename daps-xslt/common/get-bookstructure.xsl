<?xml version="1.0" encoding="UTF-8"?>
<!--
   Purpose:
     Prints informative lines about a document structure
     
   Parameters:
     * sep (default: '#')
       Separator between number and id
     
   Input:
     Normal DocBook 4 or 5 document
     
   Output:
     The output of this stylesheet conforms to the following syntax: 
        NUMBER SEP ID SEP TITLE
        
     NUMBER: The number of the component, arabic or roman
     SEP:    Separator from parameter $sep
     ID:     ID value of the component
     TITLE:  Title of the component
     
     For example:
        I#part.kde.desktop#Introduction
        1#cha.kde.start#Getting Started with the KDE Desktop
        2#cha.kde.use#Working with Your Desktop

   DocBook 5 compatible:
     yes

   Author:    Thomas Schraitle <toms@opensuse.org>
   Copyright (C) 2012-2020 SUSE Software Solutions Germany GmbH
   
-->

<xsl:stylesheet version="1.0"
  xmlns:db="http://docbook.org/ns/docbook"
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform">

  <xsl:import href="rootid.xsl"/>
  <xsl:output method="text" encoding="UTF-8"/>

  <xsl:param name="sep">#</xsl:param>

  <xsl:template match="text()"/>

  <xsl:template match="appendix|db:appendix">
    <xsl:variable name="num">
      <xsl:number format="A"/>
    </xsl:variable>
    <xsl:variable name="title"
      select="(title|appendixinfo/title|
               db:title|db:info/db:title)[1]"/>

    <xsl:call-template name="build-string">
      <xsl:with-param name="num" select="$num"/>
      <xsl:with-param name="title" select="$title"/>
    </xsl:call-template>
    <xsl:apply-templates/>
  </xsl:template>

  <xsl:template match="chapter|db:chapter|article|db:article">
    <xsl:variable name="num">
      <xsl:number from="book" level="any"/>
    </xsl:variable>
    <xsl:variable name="title" 
      select="(title|chapterinfo/title|
               db:title|db:info/db:title)[1]"/>

    <xsl:call-template name="build-string">
      <xsl:with-param name="num" select="$num"/>
      <xsl:with-param name="title" select="$title"/>
    </xsl:call-template>
    <xsl:apply-templates/>
  </xsl:template>

  <xsl:template match="glossary|db:glossary">
    <xsl:variable name="num">
      <xsl:number from="book" format="1"/>
    </xsl:variable>
    <xsl:variable name="title" 
      select="(title|glossaryinfo/title|
               db:title|db:info/db:title)[1]"/>

    <xsl:call-template name="build-string">
      <xsl:with-param name="num" select="concat('G', $num)"/>
      <xsl:with-param name="title" select="$title"/>
    </xsl:call-template>
    <xsl:apply-templates/>
  </xsl:template>

  <xsl:template match="part|db:part">
    <xsl:variable name="num">
      <xsl:number from="book" format="I"/>
    </xsl:variable>
    <xsl:variable name="title" 
      select="(title|partinfo/title|
               db:title|db:info/db:title)[1]"/>
    
    <xsl:call-template name="build-string">
      <xsl:with-param name="num" select="$num"/>
      <xsl:with-param name="title" select="$title"/>
    </xsl:call-template>
    <xsl:apply-templates/>
  </xsl:template>
  
  <xsl:template match="preface|db:preface">
    <xsl:variable name="title" 
      select="(title|prefaceinfo/title|
               db:title|db:info/db:title)[1]"/>
    
    <xsl:call-template name="build-string">
      <xsl:with-param name="num" select="'P'"/>
      <xsl:with-param name="title" select="$title"/>
    </xsl:call-template>
    <xsl:apply-templates/>
  </xsl:template>

  <xsl:template match="refentry|db:refentry">
    <xsl:variable name="num">
      <xsl:number from="book" format="1"/>
    </xsl:variable>
    <xsl:variable name="title" 
      select="(refmeta/refentrytitle|db:refmeta/db:refentrytitle)[1]"/>
    
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
      <xsl:when test="@id != '' or @xml:id != ''">
        <xsl:value-of
          select="concat($num, $sep,
                         (@id|@xml:id)[1], $sep,
                         normalize-space($title),
                         '&#10;')"/>
      </xsl:when>
      <xsl:otherwise>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

</xsl:stylesheet>
