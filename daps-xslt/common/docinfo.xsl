<?xml version="1.0" encoding="UTF-8"?>
<!--
   Purpose:
     Provide Information about a book/article/set via daps bookinfo
   Parameters:
     format = plain|xml (plain is default)
     rootid = [root id]
   Output:
     XML or plaintext version of book information
   Author:    Stefan Knorr <sknorr@suse.de>
   Copyright (C) 2017 SUSE Linux GmbH
-->

<xsl:stylesheet version="1.0"
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:db5="http://docbook.org/ns/docbook">

<!-- Hopefully won't hurt the text mode. Fingers crossed. -->
<xsl:output method="xml" omit-xml-declaration="yes"/>

<xsl:param name="format" select="'plain'"/>
  <!-- FIXME: Avoid selecting elements with id="" and use a bogus value as
  the default $rootid that is less probable than an empty id attribute. Seems
  super-hacky. -->
<xsl:param name="rootid" select="''"/>

<xsl:template match="/">
  <xsl:choose>
    <xsl:when test="$format = 'xml'">
      <xsl:element name="documentsummary">
        <xsl:text>&#10;</xsl:text>
        <xsl:call-template name="content"/>
      </xsl:element>
    </xsl:when>
    <xsl:otherwise>
      <xsl:call-template name="content"/>
    </xsl:otherwise>
  </xsl:choose>
</xsl:template>

<xsl:template name="boilerplate">
  <xsl:param name="attribute" select="'Attribute'"/>
  <xsl:param name="value" select="'Value'"/>
  <xsl:param name="newline" select="1"/>
  <xsl:choose>
    <xsl:when test="$format = 'xml'">
      <xsl:variable name="attribute-lower" select="translate($attribute,'ABCDEFGHIJKLMNOPQRSTUVWXYZ ','abcdefghijklmnopqrstuvwxyz')"/>
      <xsl:element name="{$attribute-lower}"><xsl:value-of select="$value"/></xsl:element>
      <xsl:text>&#10;</xsl:text>
    </xsl:when>
    <xsl:otherwise>
      <xsl:value-of select="$attribute"/>
      <xsl:text>: </xsl:text>
      <xsl:value-of select="$value"/>
      <xsl:if test="$newline != 0">
        <xsl:text>&#10;</xsl:text>
      </xsl:if>
    </xsl:otherwise>
  </xsl:choose>
</xsl:template>

<xsl:template name="content">
  <!-- No matter whether we order the select in this variable as
  rootid|documentroot or documentroot|rootid, we always need last() to select
  the right element (that is, rootid where it exists). My working hypothesis
  for this behavior is that whatever ordering I choose, xsltproc will always
  order by document structure: root element -> first level -> second level ->
  etc. -->
  <xsl:variable name="docroot" select="(/*|//*[$rootid][@id = $rootid]|//*[$rootid][@xml:id = $rootid])[last()]"/>
  <xsl:variable name="docinfo" select="$docroot/*[contains(local-name(.),'info')][1]"/>
  <!-- If no $rootid is set, this is the same as $docinfo. -->
  <xsl:variable name="baseinfo" select="/*/*[contains(local-name(.),'info')][1]"/>

  <xsl:variable name="authors">
    <xsl:apply-templates select="($docinfo/authorgroup|$docinfo/db5:authorgroup|$docroot/authorgroup|$docroot/db5:authorgroup)[1]"/>
  </xsl:variable>

  <xsl:if test="$rootid and not($docroot/@id = $rootid or $docroot/@xml:id = $rootid)">
    <xsl:message>Root ID could not be found in document. Showing generic information about the document.</xsl:message>
  </xsl:if>

  <xsl:call-template name="boilerplate">
    <xsl:with-param name="attribute" select="'Title'"/>
    <xsl:with-param name="value" select="normalize-space(($docinfo/title|$docinfo/db5:title|$docroot/title|$docroot/db5:title)[1])"/>
  </xsl:call-template>
  <xsl:call-template name="boilerplate">
    <xsl:with-param name="attribute" select="'Subtitle'"/>
    <xsl:with-param name="value" select="normalize-space(($docinfo/subtitle|$docinfo/db5:subtitle|$docroot/subtitle|$docroot/db5:subtitle)[1])"/>
  </xsl:call-template>
  <xsl:call-template name="boilerplate">
    <xsl:with-param name="attribute" select="'Product Name'"/>
    <!-- This is inheritable, hence use of $baseinfo. -->
    <xsl:with-param name="value" select="normalize-space(($docinfo/productname|$docinfo/db5:productname|$baseinfo/productname|$baseinfo/db5:productname)[1])"/>
  </xsl:call-template>
  <xsl:call-template name="boilerplate">
    <xsl:with-param name="attribute" select="'Product Version'"/>
    <!-- This is inheritable, hence use of $baseinfo. -->
    <xsl:with-param name="value" select="normalize-space(($docinfo/productnumber|$docinfo/db5:productnumber|$baseinfo/productnumber|$baseinfo/db5:productnumber)[1])"/>
  </xsl:call-template>
  <xsl:call-template name="boilerplate">
    <xsl:with-param name="attribute" select="'Authors'"/>
    <xsl:with-param name="value" select="$authors"/>
  </xsl:call-template>
  <xsl:call-template name="boilerplate">
    <xsl:with-param name="attribute" select="'Language'"/>
    <xsl:with-param name="value" select="($docroot/@lang|$docroot/@xml:lang|/*/@lang|/*/@xml:lang)[1]"/>
  </xsl:call-template>
  <xsl:call-template name="boilerplate">
    <xsl:with-param name="attribute" select="'Type'"/>
    <xsl:with-param name="value" select="local-name($docroot)"/>
  </xsl:call-template>
  <xsl:call-template name="boilerplate">
    <xsl:with-param name="attribute" select="'Root ID'"/>
    <!-- Obviously, this makes more sense when not specifying a root ID beforehand. -->
    <xsl:with-param name="value" select="($docroot/@id|$docroot/@xml:id)[1]"/>
    <xsl:with-param name="newline" select="0"/>
  </xsl:call-template>
</xsl:template>

<xsl:template match="authorgroup">
  <xsl:apply-templates select="*"/>
</xsl:template>

<xsl:template match="authorgroup/author">
  <xsl:value-of select="firstname"/>
  <xsl:text> </xsl:text>
  <xsl:value-of select="surname"/>
  <xsl:if test="following-sibling::*">
    <xsl:text>, </xsl:text>
  </xsl:if>
</xsl:template>

<xsl:template match="authorgroup/*">
  <xsl:value-of select="."/>
  <xsl:if test="following-sibling::*">
    <xsl:text>, </xsl:text>
  </xsl:if>
</xsl:template>


<xsl:template match="db5:authorgroup">
  <xsl:apply-templates select="*/db5:personname"/>
</xsl:template>

<xsl:template match="db5:personname">
  <xsl:value-of select="db5:firstname"/>
  <xsl:text> </xsl:text>
  <xsl:value-of select="db5:surname"/>
  <xsl:if test="parent::*/following-sibling::*">
    <xsl:text>, </xsl:text>
  </xsl:if>
</xsl:template>

<xsl:template match="*"/>

</xsl:stylesheet>
