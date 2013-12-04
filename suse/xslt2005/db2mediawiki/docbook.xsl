<?xml version="1.0" encoding="UTF-8"?>
<!-- $Id: docbook.xsl 10194 2006-06-08 13:38:26Z toms $ -->
<xsl:stylesheet
	version="1.0"
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:exsl="http://exslt.org/common"
	xmlns:t="http://nwalsh.com/docbook/xsl/template/1.0"
	exclude-result-prefixes="exsl">

<xsl:output method="text"
            encoding="UTF-8"
            indent="no"/>

<!-- <xsl:preserve-space elements="*"/> -->
<!-- <xsl:strip-space elements="book chapter listitem orderedlist variablelist varlistentry para"/> -->
<xsl:strip-space elements="*"/>

<!-- ==================================================================== -->

<xsl:include href="param.xsl"/>
<xsl:include href="lib.xsl"/>
<xsl:include href="lists.xsl"/>
<xsl:include href="verbatim.xsl"/>
<xsl:include href="graphics.xsl"/>
<xsl:include href="inline.xsl"/>
<xsl:include href="table.xsl"/>
<xsl:include href="sections.xsl"/>
<xsl:include href="division.xsl"/>
<xsl:include href="admon.xsl"/>
<xsl:include href="index.xsl"/>
<xsl:include href="refentry.xsl"/>
<xsl:include href="header.xsl"/>
<xsl:include href="footer.xsl"/>
<xsl:include href="xref.xsl"/>
<xsl:include href="formal.xsl"/>

<xsl:include href="text.wrap.xsl"/>


<!-- ==================================================================== -->

<xsl:key name="id" match="*" use="@id|@xml:id"/>
<xsl:key name="gid" match="*" use="generate-id()"/>


<!-- ==================================================================== -->
<xsl:template name="notemplatematches">
   <xsl:param name="mode"/>
   <xsl:variable name="parentnode" select="parent::*"/>

   <xsl:message>
      <xsl:text>*** No template matches </xsl:text>
      <xsl:value-of select="name(.)"/>
      <xsl:if test="$parentnode">
         <xsl:text> in </xsl:text>
         <xsl:value-of select="name($parentnode)"/>
         <xsl:if test="$parentnode/@id">
           <xsl:text> (</xsl:text>
           <xsl:value-of select="$parentnode/@id"/>
         <xsl:text>)</xsl:text>
         </xsl:if>
      </xsl:if>
      <xsl:if test="$mode">
        <xsl:text>  mode=</xsl:text>
        <xsl:value-of select="$mode"/>
      </xsl:if>
      <xsl:text>.</xsl:text>
   </xsl:message>
</xsl:template>

<xsl:template match="*">
     <xsl:call-template name="notemplatematches"/>
</xsl:template>

<xsl:template match="*" mode="wiki">
     <xsl:call-template name="notemplatematches">
        <xsl:with-param name="mode">wiki</xsl:with-param>
     </xsl:call-template>
</xsl:template>


<!-- ==================================================================== -->
<xsl:template match="/">
  <xsl:call-template name="header.text"/>

  <xsl:choose>
    <xsl:when test="$rootid = ''">
      <xsl:choose>
         <xsl:when test="$use.wikitemplates != 0">
            <xsl:apply-templates mode="wiki"/>
         </xsl:when>
         <xsl:otherwise>
            <xsl:apply-templates/>
         </xsl:otherwise>
      </xsl:choose>
    </xsl:when>
    <xsl:when test="count(key('id',$rootid)) &gt; 0">
      <xsl:choose>
         <xsl:when test="$use.wikitemplates != 0">
            <xsl:apply-templates select="key('id',$rootid)" mode="wiki"/>
         </xsl:when>
         <xsl:otherwise>
            <xsl:apply-templates select="key('id',$rootid)" />
         </xsl:otherwise>
      </xsl:choose>
    </xsl:when>
    <xsl:otherwise>
      <xsl:message terminate="yes">
            <xsl:text>ID '</xsl:text>
            <xsl:value-of select="$rootid"/>
            <xsl:text>' not found in document.</xsl:text>
          </xsl:message>
    </xsl:otherwise>
  </xsl:choose>

   <xsl:call-template name="footer.text"/>
</xsl:template>


</xsl:stylesheet>