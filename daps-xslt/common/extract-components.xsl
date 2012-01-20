<?xml version="1.0" encoding="UTF-8"?>
<!-- $Id: extract-components.xsl 442 2005-06-22 09:23:51Z toms $ -->
<xsl:stylesheet version="1.0"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:exsl="http://exslt.org/common"
    extension-element-prefixes="exsl"
>

<!--
    Purpose:
      This stylesheet extracts appendix, bibliography, chapter, glossary,
      preface and save it into separate files
-->

<!-- PUBLIC identifier -->
<xsl:param name="doctype.public"
>-//Novell//DTD NovDoc XML V1.0//EN</xsl:param>

<!-- SYSTEM identifier -->
<xsl:param name="doctype.system">novdocx.dtd</xsl:param>

<!-- Encoding of the generated file -->
<xsl:param name="doctype.encoding">UTF-8</xsl:param>

<!-- Base directory: where all the generated files are stored -->
<xsl:param name="base.dir">novell/</xsl:param>

<!-- Should xml:base attributes considered? 1=on, 0=off -->
<xsl:param name="use.xml.base">1</xsl:param>

<!-- Print messages? 1=on, 0=off -->
<xsl:param name="debug">1</xsl:param>


<!-- ******************************************************* -->
<xsl:template match="/">
  <xsl:choose>
    <xsl:when test="element-available('exsl:document')">
      <xsl:apply-templates/>
    </xsl:when>
    <xsl:otherwise>
      <xsl:message terminate="yes"
       >ERROR: Your XSLT Processor doesn't support the extention element exsl:document!&#10;</xsl:message>
    </xsl:otherwise>
  </xsl:choose>
</xsl:template>

<xsl:template match="*">
</xsl:template>


<xsl:template match="text()">
</xsl:template>


<xsl:template match="book|part">
   <xsl:apply-templates />
</xsl:template>


<xsl:template match="chapter|preface|glossary|bibliography|appendix">
   <xsl:variable name="filename">
      <xsl:choose>
        <xsl:when test="$use.xml.base='1' and @xml:base">
          <xsl:value-of select="@xml:base"/>
        </xsl:when>
        <xsl:otherwise>
            <xsl:choose>
            <xsl:when test="self::chapter">cha</xsl:when>
            <xsl:when test="self::preface">pre</xsl:when>
            <xsl:when test="self::glossary">glo</xsl:when>
            <xsl:when test="self::bibliography">bib</xsl:when>
            <xsl:when test="self::appendix">app</xsl:when>
            </xsl:choose>
            <xsl:text>.</xsl:text>
            <xsl:choose>
            <xsl:when test="@id"><xsl:value-of select="@id"/></xsl:when>
            <xsl:otherwise>
               <xsl:message>WARNING: Element <xsl:value-of select="name(.)" /> doesn't contain an id attribute. Using generated id.</xsl:message>
               <xsl:value-of select="generate-id(.)"/>
            </xsl:otherwise>
            </xsl:choose>
            <xsl:text>.xml</xsl:text>
        </xsl:otherwise>
      </xsl:choose>
   </xsl:variable>

   <xsl:if test="$debug = '1'">
    <xsl:message> Writing <xsl:value-of select="concat($base.dir, $filename)"/></xsl:message>
   </xsl:if>

   <xsl:call-template name="write.chunk">
     <xsl:with-param name="filename" select="$filename"/>
     <xsl:with-param name="content">
       <xsl:element name="{local-name()}">
         <xsl:copy-of select="@*"/>
         <xsl:apply-templates mode="chunk"/>
       </xsl:element>
     </xsl:with-param>
   </xsl:call-template>

</xsl:template>


<xsl:template match="*" mode="chunk">
<!--    <xsl:message> Chunk: <xsl:value-of select="name()"/></xsl:message> -->
   <xsl:copy>
    <xsl:copy-of select="@*"/>
    <xsl:apply-templates select="node()" mode="chunk"/>
   </xsl:copy>
</xsl:template>

<xsl:template name="write.chunk">
  <xsl:param name="content"/>
  <xsl:param name="filename"/>

   <exsl:document
     method="xml"
     href="{concat($base.dir,$filename)}"
     omit-xml-declaration="no"
     indent="yes"
     doctype-public="{$doctype.public}"
     doctype-system="{$doctype.system}"
     encoding="{$doctype.encoding}">
      <xsl:copy-of select="$content"/>
   </exsl:document>
</xsl:template>

</xsl:stylesheet>