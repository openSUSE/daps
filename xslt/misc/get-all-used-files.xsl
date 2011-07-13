<?xml version="1.0" encoding="UTF-8"?>
<!--
  
  Purpose:
   Search for all xi:include elements in a given XML file
   and output the file list found in xi:include/@href and
   its descendant
   
  The stylesheet contains two passes:
  1. Search for every xi:include element, memorize the href
     attribute and resolve it. Memorize the attributes from
     the root element (mainly id). Create an internal
     intermediate structure which looks like this:
     <files>
       <file href="foo.xml">
         <file href="bar.xml" id="bar"/>
         <file href="xyz.xml">
            <image fileref="foo.png"/>
         </file>
       </file>
     </files>
     
     Which reads: foo.xml includes bar.xml and bar.xml's root
     element contains the id attribute "bar".
     
  2. Parse the intermediate XML structure and apply the /files
     template. If rootid is set, search for an file element which
     contains the correct id attribute and process all of its
     children.
     Otherwise just apply the file template.
     
   
   Used in combination with extract-files-and-images.xsl
      
-->
<xsl:stylesheet version="1.0"
  xmlns:exsl="http://exslt.org/common"
  xmlns:xi="http://www.w3.org/2001/XInclude"
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  extension-element-prefixes="exsl"
  exclude-result-prefixes="exsl xi">

  <xsl:import href="../profiling/check.profiling.xsl"/>
  <xsl:output method="xml" indent="yes"/>

  <xsl:key name="file-id" match="file" use="@id|@xml:id"/>

  <!-- Separator between each filename: -->
  <xsl:param name="separator">
    <xsl:text> </xsl:text>
  </xsl:param>
  
  <!-- Should the in-memory XML tree be saved? -->
  <xsl:param name="output.intermediate.xml" select="0"/>
  <!-- Filename of the in-memory XML tree -->
  <xsl:param name="intermediate.xml.filename">included-files-output.xml</xsl:param>
  
  <!-- Only recognize elements with the correct id attribute: -->
  <xsl:param name="rootid"/>
  
  <!-- Base path of XML files (ALWAYS end a trailing slash!): -->
  <xsl:param name="xml.src.path"/>
  
  <!-- Base path for all graphic files (ALWAYS end a trailing slash!): -->
  <xsl:param name="img.src.path"/>
  
  <!-- Name of the main file: -->
  <xsl:param name="mainfile"/>
  
  <!-- Profiling parameters -->
  <xsl:param name="profile.arch" select="''"/>
  <xsl:param name="profile.audience" select="''"/>
  <xsl:param name="profile.condition" select="''"/>
  <xsl:param name="profile.conformance" select="''"/>
  <xsl:param name="profile.lang" select="''"/>
  <xsl:param name="profile.os" select="''"/>
  <xsl:param name="profile.revision" select="''"/>
  <xsl:param name="profile.revisionflag" select="''"/>
  <xsl:param name="profile.role" select="''"/>
  <xsl:param name="profile.security" select="''"/>
  <xsl:param name="profile.status" select="''"/>
  <xsl:param name="profile.userlevel" select="''"/>
  <xsl:param name="profile.vendor" select="''"/>
  <xsl:param name="profile.wordsize" select="''"/>
  <xsl:param name="profile.attribute" select="''"/>
  <xsl:param name="profile.value" select="''"/>
  <xsl:param name="profile.separator" select="';'"/>

  <xsl:template match="text()"/>
  
  <xsl:template match="/">
    <xsl:comment>
      This is an intermediate XML file from
      get-included-files.xsl which was created in-memory
    </xsl:comment>
    <files>
        <xsl:apply-templates mode="root"/>
    </files>
  </xsl:template>
  
  <!-- This stylesheet gets only called once -->
  <xsl:template match="/*" mode="root">
    <xsl:message><xsl:value-of select="name()"/> found</xsl:message>
    <file href="{concat($xml.src.path, mainfile)}">
        <xsl:copy-of select="@*"/>
        <xsl:apply-templates/>
    </file>
  </xsl:template>
  
  <xsl:template match="*">
    <xsl:variable name="prof">
      <xsl:call-template name="check.profiling"/>
    </xsl:variable>
    <xsl:if test="$prof != 0">
      <xsl:apply-templates/>
    </xsl:if>
  </xsl:template>

  <xsl:template match="mediaobject">
    <xsl:variable name="prof">
      <xsl:call-template name="check.profiling"/>
    </xsl:variable>
    <xsl:if test="$prof != 0">
      <xsl:apply-templates/>
    </xsl:if>
  </xsl:template>
  <xsl:template match="imageobject">
    <xsl:variable name="prof">
      <xsl:call-template name="check.profiling"/>
    </xsl:variable>
    <xsl:if test="$prof != 0">
      <xsl:apply-templates/>
    </xsl:if>
  </xsl:template>
  <xsl:template match="imagedata">
    <xsl:variable name="prof">
      <xsl:call-template name="check.profiling"/>
    </xsl:variable>
    <xsl:if test="$prof != 0">
      <image fileref="{concat($img.src.path, @fileref)}"/>
    </xsl:if>
  </xsl:template>


  <xsl:template match="xi:include">
    <xsl:variable name="prof">
      <xsl:call-template name="check.profiling"/>
    </xsl:variable>
    <xsl:if test="$prof != 0">
      <xsl:variable name="rootnode" select="document(@href)/*"/>
      <file href="{concat($xml.src.path, @href)}">
        <xsl:copy-of select="$rootnode/@*"/>
        <xsl:apply-templates select="$rootnode"/>
      </file>
    </xsl:if>
  </xsl:template>

  <xsl:template name="cross.compare">
    <xsl:param name="a"/>
    <xsl:param name="b"/>
    <xsl:param name="sep" select="$profile.separator"/>
    <xsl:variable name="head"
      select="substring-before(concat($a, $sep), $sep)"/>
    <xsl:variable name="tail" select="substring-after($a, $sep)"/>
    <xsl:if
      test="contains(concat($sep, $b, $sep), concat($sep, $head, $sep))"
      >1</xsl:if>
    <xsl:if test="$tail">
      <xsl:call-template name="cross.compare">
        <xsl:with-param name="a" select="$tail"/>
        <xsl:with-param name="b" select="$b"/>
      </xsl:call-template>
    </xsl:if>
  </xsl:template>

  
  
</xsl:stylesheet>
