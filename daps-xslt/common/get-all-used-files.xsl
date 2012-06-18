<?xml version="1.0" encoding="UTF-8"?>
<!--
  
  Purpose:
   Search for all xi:include elements in a given XML file
   and output the file list found in xi:include/@href and
   its descendant
   
  The stylesheet contains two passes:
  1. Profiling
     Apply profiling to the XML document and save the result
     in a temporary RTF (result tree fragment).
     Any xi:include elements are resolved and wrapped inside
     a <included xml:base="...">...</included> element. 
     This element is needed to find the corresponding file name.
  
  2. Generate the File List
     The RTF is converted into a node set. If the parameter
     rootid is set, only the part of the tree is considered
     which contains an element with id=$rootid. If no rootid
     is set, the complete tree is traversed.
  
     The output looks can like this:
     <files>
       <file href="foo.xml">
         <file href="bar.xml" id="bar"/>
         <file href="xyz.xml">
            <image fileref="foo.png"/>
         </file>
       </file>
     </files>
     
     Which reads: foo.xml includes bar.xml and bar.xml's root
     element contains the id attribute "bar". File xyz.xml contains
     additionally an image foo.png.
     
   +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
   
   CAVEAT:
   Every xincluded file is mapped to a <file> entry. That means,
   if you have inserted some structures *directly*, these generate
   NOT a <file> entry. For example:
   
   <book xmlns:xi="http://www.w3.org/2001/XInclude">
      <part id="foo">
        <title>The Foo Part</title>
        <xi:include href="chapter_a.xml"/>
        <xi:include href="chapter_b.xml"/>
        <xi:include href="chapter_c.xml"/>
      </part>
   </book>

   The stylesheet only generated three <file> entries for each chapter.
   However, the part with id=foo does NOT get a <file> element (as it
   is not included with a xi:include element).
   
   
   Used in combination with extract-files-and-images.xsl
      
-->
<xsl:stylesheet version="1.0"
  xmlns:exsl="http://exslt.org/common"
  xmlns:db="http://docbook.org/ns/docbook"
  xmlns:xi="http://www.w3.org/2001/XInclude"
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  extension-element-prefixes="exsl"
  exclude-result-prefixes="exsl xi db">

 
  <xsl:import href="http://docbook.sourceforge.net/release/xsl/current/profiling/profile-mode.xsl"/>
  <xsl:import href="http://docbook.sourceforge.net/release/xsl/current//common/stripns.xsl"/>
  
  <xsl:output method="xml" indent="yes"/>

  <xsl:key name="file-id" match="file" use="@id|@xml:id"/>
  
  <xsl:param name="exsl.node.set.available">
    <xsl:choose>
      <xsl:when xmlns:exsl="http://exslt.org/common" exsl:foo=""
        test="function-available('exsl:node-set') or contains(system-property('xsl:vendor'), 'Apache Software Foundation')"
        >1</xsl:when>
      <xsl:otherwise>0</xsl:otherwise>
    </xsl:choose>
  </xsl:param>
  

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
  
  <!--  -->
  <xsl:param name="xmlbase"/>
  
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
  
  <xsl:template name="add-xml-base">
    <xsl:value-of select="$xmlbase"/>
  </xsl:template>
  
  <!-- Special handling of xi:include elements in profile mode -->
  <xsl:template match="xi:include[not(@parse) or @parse='xml']" mode="profile" priority="10">   
    <xsl:message>Included <xsl:value-of select="@href"/></xsl:message>
    <included xml:base="{@href}">
      <xsl:apply-templates select="document(@href)/*" mode="profile"/>
    </included>
  </xsl:template>
  
  <!--  -->
  <xsl:template match="/">
    <xsl:variable name="rtf">
      <xsl:apply-templates select="." mode="profile"/>
    </xsl:variable>
    <xsl:if test="$exsl.node.set.available = 0">
      <xsl:message terminate="yes">
        <xsl:text>Need XSLT processor which support EXSLT node-set function.</xsl:text>
      </xsl:message>
    </xsl:if>
    <xsl:variable name="node" select="exsl:node-set($rtf)"/>
    
    <xsl:comment>
      This is an intermediate XML file from
      get-included-files.xsl which was created in-memory
    </xsl:comment>
    <xsl:message>rootid="<xsl:value-of select="$rootid"/>"</xsl:message>
    <files>
    <xsl:choose>
      <xsl:when test="$rootid != ''">
        <xsl:choose>
          <xsl:when test="count($node//*[@id=$rootid]) = 0">
            <xsl:message terminate="yes">
              <xsl:text>ID '</xsl:text>
              <xsl:value-of select="$rootid"/>
              <xsl:text>' not found in document.</xsl:text>
            </xsl:message>
          </xsl:when>
          <xsl:otherwise>
            <xsl:message>Applying <xsl:value-of select="$rootid"/> to document</xsl:message>
              <xsl:apply-templates select="$node//*[@id=$rootid]"/>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:when>
      <xsl:otherwise>
          <xsl:apply-templates select="$node/node()"/>
      </xsl:otherwise>     
    </xsl:choose> 
    </files>
  </xsl:template>
  
  <!-- This stylesheet gets only called once -->
  <xsl:template match="/*">
    <file href="{concat($xml.src.path, $mainfile)}">
        <xsl:copy-of select="@*"/>
        <xsl:apply-templates/>
    </file>
  </xsl:template>

  <xsl:template match="imagedata|db:imagedata">
      <image fileref="{concat($img.src.path, @fileref)}"/>
  </xsl:template>

  <xsl:template match="included">
      <file href="{concat($xml.src.path, @xml:base)}">
        <xsl:apply-templates/>
      </file>
  </xsl:template>

</xsl:stylesheet>
