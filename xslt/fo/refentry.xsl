<?xml version="1.0" encoding="UTF-8"?>
<!-- $Id: $ -->
<xsl:stylesheet version="1.0"
 xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
 xmlns:fo="http://www.w3.org/1999/XSL/Format">


 <xsl:template match="refsect1" mode="label.markup">
  <xsl:choose>
   <xsl:when test="@label">
    <xsl:value-of select="@label"/>
   </xsl:when>
   <xsl:when test="$refsection.autolabel != 0">
    <xsl:variable name="format">
     <xsl:call-template name="autolabel.format">
      <xsl:with-param name="format" select="$section.autolabel"/>
     </xsl:call-template>
    </xsl:variable>
    <xsl:number count="refsect1" format="{$format}"/>
   </xsl:when>
  </xsl:choose>
 </xsl:template>

 <xsl:template match="refnamediv">
  <xsl:variable name="id">
   <xsl:call-template name="object.id"/>
  </xsl:variable>

  <fo:block id="{$id}">

   <!-- if refentry.generate.name is non-zero, then we need to generate a -->
   <!-- localized "Name" subheading for this refnamdiv (unless it has a -->
   <!-- preceding sibling that is a refnamediv, in which case we have already -->
   <!-- generated a "Name" subheading, so we don't need to do it again -->
   <xsl:if test="$refentry.generate.name != 0">
    <xsl:choose>
     <xsl:when test="preceding-sibling::refnamediv">
      <!-- no generated title on secondary refnamedivs! -->
     </xsl:when>
     <xsl:otherwise>
      <fo:block
       xsl:use-attribute-sets="refnamediv.titlepage.recto.style"
       font-family="{$title.fontset}">
       <!-- Contents of what is now the format.refentry.subheading -->
       <!-- template were formerly intended to be used only to -->
       <!-- process those subsections of Refentry that have "real" -->
       <!-- title children. So as a kludge to get around the fact -->
       <!-- that the template still basically "expects" to be -->
       <!-- processing that kind of a node, when we call the -->
       <!-- template to process generated titles, we must call it -->
       <!-- with values for the "offset" and "section" parameters -->
       <!-- that are different from the default values in the -->
       <!-- format.refentry.subheading template itself. Because -->
       <!-- those defaults are the values appropriate for processing -->
       <!-- "real" title nodes. -->
       <xsl:call-template name="format.refentry.subheading">
        <xsl:with-param name="section" select="self::*"/>
        <xsl:with-param name="offset" select="1"/>
        <xsl:with-param name="gentext.key" select="'RefName'"/>
       </xsl:call-template>
      </fo:block>
     </xsl:otherwise>
    </xsl:choose>
   </xsl:if>

   <xsl:if test="$refentry.generate.title != 0">
    <xsl:variable name="section.level">
     <xsl:call-template name="refentry.level">
      <xsl:with-param name="node" select="ancestor::refentry"/>
     </xsl:call-template>
    </xsl:variable>

    <xsl:variable name="reftitle">
     <xsl:choose>
      <xsl:when test="../refmeta/refentrytitle">
       <xsl:apply-templates select="../refmeta/refentrytitle"/>
       <xsl:if test="$refentry.usemanvolume != 0">
        <xsl:text> (</xsl:text>
        <xsl:value-of select="../refmeta/manvolnum"/>
        <xsl:text>)</xsl:text>
       </xsl:if>
      </xsl:when>
      <xsl:otherwise>
       <xsl:apply-templates select="refname[1]"/>
      </xsl:otherwise>
     </xsl:choose>
    </xsl:variable>

    <!-- xsl:use-attribute-sets takes only a Qname, not a variable -->
    <xsl:choose>
     <xsl:when test="preceding-sibling::refnamediv">
      <!-- no title on secondary refnamedivs! -->
     </xsl:when>
     <xsl:when test="$section.level = 1">
      <fo:block xsl:use-attribute-sets="refentry.title.properties">
       <fo:block xsl:use-attribute-sets="refentry.title.level1.properties">
        <xsl:value-of select="$reftitle"/>
       </fo:block>
      </fo:block>
     </xsl:when>
     <xsl:when test="$section.level = 2">
      <fo:block xsl:use-attribute-sets="refentry.title.properties">
       <fo:block xsl:use-attribute-sets="refentry.title.level2.properties">
        <xsl:value-of select="$reftitle"/>
        </fo:block>
      </fo:block>
     </xsl:when>
     <xsl:when test="$section.level = 3">
      <fo:block xsl:use-attribute-sets="refentry.title.properties">
       <fo:block xsl:use-attribute-sets="refentry.title.level3.properties">
        <xsl:value-of select="$reftitle"/>
       </fo:block>
      </fo:block>
     </xsl:when>
     <xsl:when test="$section.level = 4">
      <fo:block xsl:use-attribute-sets="refentry.title.properties">
       <fo:block xsl:use-attribute-sets="refentry.title.level4.properties">        
        <xsl:value-of select="$reftitle"/>
       </fo:block>
      </fo:block>
     </xsl:when>
     <xsl:when test="$section.level = 5">
      <fo:block xsl:use-attribute-sets="refentry.title.properties">
       <fo:block xsl:use-attribute-sets="refentry.title.level5.properties">        
        <xsl:value-of select="$reftitle"/>
       </fo:block>
      </fo:block>
     </xsl:when>
     <xsl:otherwise>
      <fo:block xsl:use-attribute-sets="refentry.title.properties">
        <xsl:value-of select="$reftitle"/>
      </fo:block>
     </xsl:otherwise>
    </xsl:choose>
    <!--<xsl:message>refnamediv:
     title = "<xsl:value-of select="$reftitle"/>"
     level = "<xsl:value-of select="$section.level"/>"
    </xsl:message>-->
   </xsl:if>


   <fo:block>
    <xsl:if test="not(following-sibling::refnamediv)">
     <xsl:attribute name="space-after">1em</xsl:attribute>
    </xsl:if>
    <xsl:apply-templates/>
   </fo:block>
  </fo:block>
 </xsl:template>

</xsl:stylesheet>
