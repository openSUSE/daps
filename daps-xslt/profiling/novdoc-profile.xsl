<?xml version="1.0" encoding="UTF-8"?>
<!-- $Id: novdoc-profile.xsl 40777 2009-04-06 07:11:42Z toms $ -->
<!DOCTYPE xsl:stylesheet
[
  <!ENTITY db "http://docbook.sourceforge.net/release/xsl/current">
]>
<xsl:stylesheet
	version="1.0"
	xmlns:p="urn:x-suse:xmlns:docproperties"
	xmlns:exsl="http://exslt.org/common"
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	exclude-result-prefixes="p exsl">


<xsl:import href="&db;/profiling/profile.xsl"/>
<xsl:import href="&db;/common/pi.xsl"/>
<xsl:import href="profile-rootid.xsl"/>
  
<xsl:include href="xml-stylesheet.xsl"/>
<xsl:include href="check.profiling.xsl"/>
<xsl:include href="set.operations4profiling.xsl"/>
<xsl:include href="param.xsl"/>
<xsl:include href="suse-pi.xsl"/>


<xsl:output method="xml"
            encoding="UTF-8"
            doctype-public="-//Novell//DTD NovDoc XML V1.0//EN"
            doctype-system="novdocx.dtd"/>

<xsl:param name="pubdate"/>


<!--
  Template for adding a missing xml:base attribute
-->
<xsl:template match="/*[not(@xml:base)]" mode="profile">
<!--    <xsl:message> /<xsl:value-of select="name(.)"/> profiling (without xml:base)</xsl:message> -->
  <xsl:variable name="root.ok">
    <xsl:call-template name="check.profiling"/>
  </xsl:variable>
  
  <xsl:if test="$root.ok = 1">
   <xsl:copy>
     <xsl:attribute name="xml:base">
       <xsl:value-of select="$filename"/>
     </xsl:attribute>
     <xsl:copy-of select="@*"/>
     <xsl:apply-templates mode="profile"/>
   </xsl:copy>
  </xsl:if>
</xsl:template>


<!--
  Template for checking an existing xml:base attribute
-->
<xsl:template match="/*[@xml:base]" mode="profile">
<!--    <xsl:message> /<xsl:value-of select="name(.)"/> profiling (with xml:base)</xsl:message> -->
  <xsl:variable name="root.ok">
    <xsl:call-template name="check.profiling"/>
  </xsl:variable>
  
  <xsl:if test="$root.ok = 1">
   <xsl:copy>
      <xsl:copy-of select="@*[not(@xml:base)]"/>
      <xsl:attribute name="xml:base">
         <xsl:choose>
            <xsl:when test="$filename = ''">
               <xsl:message> HINT: Parameter filename is empty, used original xml:base attribute</xsl:message>
               <xsl:value-of select="@xml:base"/>
            </xsl:when>
            <xsl:when test="@xml:base = $filename">
               <xsl:value-of select="@xml:base"/>
            </xsl:when>
            <xsl:otherwise>
               <xsl:value-of select="$filename"/>
               <xsl:message terminate="yes">
                  <xsl:text>ERROR: Wrong xml:base</xsl:text>
                  <xsl:text> attribute in </xsl:text>
                  <xsl:value-of select="$filename"/>
                  <xsl:text>. Please remove it.</xsl:text>
               </xsl:message>
            </xsl:otherwise>
         </xsl:choose>
      </xsl:attribute>
      <xsl:apply-templates mode="profile"/>
   </xsl:copy>
  </xsl:if>
</xsl:template>

<!--
  Overwrite any specific templates. In set we don't want to have xml:base
-->
<xsl:template match="set" mode="profile" priority="2">
   <xsl:copy>
       <xsl:copy-of select="@*"/>
       <xsl:apply-templates mode="profile"/>
   </xsl:copy>
</xsl:template>


<xsl:template match="remark" mode="profile">
  <xsl:if test="$show.comments != 0">
    <xsl:apply-imports/>
  </xsl:if>
</xsl:template>


<xsl:template match="comment()" mode="profile">
  <xsl:if test="$keep.xml.comments != 0">
    <xsl:apply-imports/>
  </xsl:if>
</xsl:template>

<xsl:template match="processing-instruction()|processing-instruction('xml-stylesheet')" mode="profile">
   <xsl:processing-instruction name="{local-name()}">
      <xsl:value-of select="."/>
   </xsl:processing-instruction>
   <xsl:text>&#10;</xsl:text>
</xsl:template>


<!-- ****************************************************** -->
<!--

  HACK: Reorganizes indexterms to avoid linebreaks in HTML/FO

        This should go into the stylesheets but here it is a
        bit easier.
-->

<xsl:template match="varlistentry/term" mode="profile">
   <xsl:copy>
      <xsl:copy-of select="@*"/>
      <xsl:apply-templates mode="profile"/>
      <xsl:if test="../listitem/indexterm">
         <xsl:apply-templates select="../listitem/indexterm" mode="indexterm"/>
      </xsl:if>
   </xsl:copy>
</xsl:template>

<xsl:template match="varlistentry/listitem" mode="profile">
   <xsl:copy>
      <xsl:copy-of select="@*"/>
      <xsl:apply-templates mode="profile"/>
   </xsl:copy>
</xsl:template>

<xsl:template match="varlistentry/listitem/indexterm" mode="profile"/>

<xsl:template match="varlistentry/listitem/indexterm" mode="indexterm">
   <xsl:copy>
      <xsl:copy-of select="@*"/>
      <xsl:apply-templates mode="indexterm"/>
   </xsl:copy>
</xsl:template>

<xsl:template match="*" mode="indexterm">
   <xsl:element name="{name()}">
      <xsl:copy-of select="@*"/>
      <xsl:apply-templates mode="indexterm"/>
   </xsl:element>
</xsl:template>

<!-- Special template rule to rewrite pubdate (DocBook) or date (Novdoc)   -->
<xsl:template match="pubdate|date" mode="profile">
  <xsl:choose>
    <xsl:when test="$pubdate != ''">
      <xsl:element name="{local-name()}">
        <xsl:value-of select="$pubdate"/>
      </xsl:element>
    </xsl:when>
    <xsl:otherwise>
      <xsl:copy>
        <xsl:copy-of select="node()"/>
      </xsl:copy>
    </xsl:otherwise>
  </xsl:choose>
</xsl:template>
  
</xsl:stylesheet>
