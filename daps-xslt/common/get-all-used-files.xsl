<?xml version="1.0" encoding="UTF-8"?>
<!--

  Purpose:
   Search for all xi:include elements in a given XML file
   and output the file list found in xi:include/@href and
   its descendant

   DO NOT USE THE -xinclude OPTION! THE RESOLUTION WILL BE DONE
   BY THIS STYLESHEET!

  The stylesheet contains two passes:
  1. Search for every xi:include element, memorize the href
     attribute and resolve it. Memorize the attributes from
     the root element (mainly id). Create an internal
     intermediate structure which looks like this:
     <files>
       <div href="MAIN.daps.xml" remap="set" lang="en" text="false">
         <div href="daps_user_install.xml" remap="include" ns="http://www.w3.org/2001/XInclude" text="false">
          <div id="cha.daps.user.inst" remap="chapter"/>
        </div>
         <div href="daps_user_edit.xml" remap="include" ns="http://www.w3.org/2001/XInclude" text="false">
          <div id="cha.daps.user.edit" remap="chapter">
            <image fileref="daps_chklink_report.png"/>
            <image fileref="daps_chklink_report.png"/>
          </div>
        </div>
       </div>
     </files>


  2. Parse the intermediate XML structure and apply the /files
     template. If rootid is set, search for a div element which
     contains the correct id and href attributes and process all of its
     children.

   Used in combination with extract-files-and-images.xsl


   Parameters:
     * separator (default: ' ')
       Separator between each filename

     * output.intermediate.xml (default: 0)
       Should the in-memory XML tree be saved? (0=no, 1=yes)

     * intermediate.xml.filename (default: 'included-files-output.xml')
       Filename of the in-memory XML tree, when $output.intermediate.xml=1

     * rootid (default: '')
       Only recognize elements with the correct id attribute:

     * xml.src.path (default: '')
       Base path of XML files (ALWAYS end a trailing slash!)

     * img.src.path (default: '')
       Base path for all graphic files (ALWAYS end a trailing slash!)

     * text.src.path (default: '')
       Base path for all text files (ALWAYS end a trailing slash!)

     * mainfile (default: '')
       Name of the main file


   Input:
     Output from get-all-used-files.xsl

   Output:
     List of filenames separated by $separator

   DocBook 5 compatible:
     yes

  Author:  Thomas Schraitle <toms@opensuse.org>
  Copyright (C) 2012-2015 SUSE Linux GmbH

-->
<xsl:stylesheet version="1.0"
  xmlns:exsl="http://exslt.org/common"
  xmlns:db="http://docbook.org/ns/docbook"
  xmlns:xi="http://www.w3.org/2001/XInclude"
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  extension-element-prefixes="exsl"
  exclude-result-prefixes="exsl xi db">

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

  <!-- Base path for all text files (ALWAYS end a trailing slash!): -->
  <xsl:param name="text.src.path"/>

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

  <xsl:param name="profiling.attributes.enabled">
    <xsl:if test="$profile.arch">arch<xsl:text> </xsl:text></xsl:if>
    <xsl:if test="$profile.audience">audience<xsl:text> </xsl:text></xsl:if>
    <xsl:if test="$profile.condition">condition<xsl:text> </xsl:text></xsl:if>
    <xsl:if test="$profile.conformance">conformance<xsl:text> </xsl:text></xsl:if>
    <xsl:if test="$profile.lang">lang<xsl:text> </xsl:text></xsl:if>
    <xsl:if test="$profile.os">os<xsl:text> </xsl:text></xsl:if>
    <xsl:if test="$profile.revision">revision<xsl:text> </xsl:text></xsl:if>
    <xsl:if test="$profile.revisionflag">revisionflag<xsl:text> </xsl:text></xsl:if>
    <xsl:if test="$profile.role">role<xsl:text> </xsl:text></xsl:if>
    <xsl:if test="$profile.security">security<xsl:text> </xsl:text></xsl:if>
    <xsl:if test="$profile.status">status<xsl:text> </xsl:text></xsl:if>
    <xsl:if test="$profile.userlevel">userlevel<xsl:text> </xsl:text></xsl:if>
    <xsl:if test="$profile.vendor">vendor<xsl:text> </xsl:text></xsl:if>
    <xsl:if test="$profile.userlevel">userlevel<xsl:text> </xsl:text></xsl:if>
    <xsl:if test="$profile.wordsize">wordsize<xsl:text> </xsl:text></xsl:if>
    <xsl:if test="$profile.vendor">userlevel<xsl:text> </xsl:text></xsl:if>
    <xsl:if test="$profile.value"><xsl:value-of select="$profile.attribute"/><xsl:text> </xsl:text></xsl:if>
  </xsl:param>

  <xsl:param name="profiling.values.merged">
    <xsl:if test="$profile.arch"><xsl:value-of select="$profile.arch"/><xsl:text> </xsl:text></xsl:if>
    <xsl:if test="$profile.audience"><xsl:value-of select="$profile.audience"/><xsl:text> </xsl:text></xsl:if>
    <xsl:if test="$profile.condition"><xsl:value-of select="$profile.condition"/><xsl:text> </xsl:text></xsl:if>
    <xsl:if test="$profile.conformance"><xsl:value-of select="$profile.conformance"/><xsl:text> </xsl:text></xsl:if>
    <xsl:if test="$profile.lang"><xsl:value-of select="$profile.lang"/><xsl:text> </xsl:text></xsl:if>
    <xsl:if test="$profile.os"><xsl:value-of select="$profile.os"/><xsl:text> </xsl:text></xsl:if>
    <xsl:if test="$profile.revision"><xsl:value-of select="$profile.revision"/><xsl:text> </xsl:text></xsl:if>
    <xsl:if test="$profile.revisionflag"><xsl:value-of select="$profile.revisionflag"/><xsl:text> </xsl:text></xsl:if>
    <xsl:if test="$profile.role"><xsl:value-of select="$profile.role"/><xsl:text> </xsl:text></xsl:if>
    <xsl:if test="$profile.security"><xsl:value-of select="$profile.security"/><xsl:text> </xsl:text></xsl:if>
    <xsl:if test="$profile.status"><xsl:value-of select="$profile.status"/><xsl:text> </xsl:text></xsl:if>
    <xsl:if test="$profile.userlevel"><xsl:value-of select="$profile.userlevel"/><xsl:text> </xsl:text></xsl:if>
    <xsl:if test="$profile.vendor"><xsl:value-of select="$profile.vendor"/><xsl:text> </xsl:text></xsl:if>
    <xsl:if test="$profile.userlevel"><xsl:value-of select="$profile.userlevel"/><xsl:text> </xsl:text></xsl:if>
    <xsl:if test="$profile.wordsize"><xsl:value-of select="$profile.wordsize"/><xsl:text> </xsl:text></xsl:if>
    <xsl:if test="$profile.vendor"><xsl:value-of select="$profile.userlevel"/><xsl:text> </xsl:text></xsl:if>
    <xsl:if test="$profile.value"><xsl:value-of select="$profile.value"/><xsl:text> </xsl:text></xsl:if>
  </xsl:param>

  <xsl:param name="profiling.enabled">
    <xsl:choose>
      <xsl:when test="not(normalize-space($profiling.attributes.enabled))">0</xsl:when>
      <xsl:otherwise>1</xsl:otherwise>
    </xsl:choose>
  </xsl:param>


  <xsl:template match="text()"/>

  <xsl:template match="/">
    <xsl:comment>
      This is an intermediate XML file from
      get-all-used-files.xsl which was created in-memory
    </xsl:comment>
    <files>
        <xsl:apply-templates mode="root"/>
    </files>
  </xsl:template>

  <!-- This stylesheet gets only called once -->
  <xsl:template match="/*" mode="root">
    <div href="{concat($xml.src.path, $mainfile)}" remap="{local-name()}" text="false"  id="{(@id|@xml:id)[1]}">
        <xsl:copy-of select="@*"/>
        <xsl:apply-templates/>
    </div>
  </xsl:template>

  <xsl:template match="*">
    <xsl:variable name="prof">
      <xsl:if test="$profiling.enabled = 1">
        <xsl:call-template name="check.profiling"/>
      </xsl:if>
    </xsl:variable>
    <xsl:if test="$prof != 0">
      <xsl:apply-templates/>
    </xsl:if>
  </xsl:template>

  <xsl:template match="*[@id | @xml:id]">
    <xsl:param name="xi" select="0"/>
    <xsl:variable name="prof">
      <xsl:if test="$profiling.enabled = 1">
        <xsl:call-template name="check.profiling"/>
      </xsl:if>
    </xsl:variable>
    <xsl:if test="$prof != 0">
      <div id="{(@id|@xml:id)[1]}" remap="{local-name()}">
        <xsl:apply-templates/>
      </div>
    </xsl:if>
  </xsl:template>


  <xsl:template match="mediaobject|db:mediaobject">
    <xsl:variable name="prof">
      <xsl:if test="$profiling.enabled = 1">
        <xsl:call-template name="check.profiling"/>
      </xsl:if>
    </xsl:variable>
    <xsl:if test="$prof != 0">
      <xsl:apply-templates/>
    </xsl:if>
  </xsl:template>
  <xsl:template match="imageobject|db:imageobject">
    <xsl:variable name="prof">
      <xsl:if test="$profiling.enabled = 1">
        <xsl:call-template name="check.profiling"/>
      </xsl:if>
    </xsl:variable>
    <xsl:if test="$prof != 0">
      <xsl:apply-templates/>
    </xsl:if>
  </xsl:template>
  <xsl:template match="imagedata|db:imagedata">
    <xsl:variable name="prof">
      <xsl:if test="$profiling.enabled = 1">
        <xsl:call-template name="check.profiling"/>
      </xsl:if>
    </xsl:variable>
    <xsl:if test="$prof != 0">
      <image fileref="{concat($img.src.path, @fileref)}"/>
    </xsl:if>
  </xsl:template>


  <xsl:template match="xi:include">
    <xsl:variable name="prof">
      <xsl:if test="$profiling.enabled = 1">
        <xsl:call-template name="check.profiling"/>
      </xsl:if>
    </xsl:variable>

    <xsl:variable name="path">
      <xsl:choose>
        <xsl:when test="@parse = 'text'">
          <xsl:value-of select="$text.src.path"/>
        </xsl:when>
        <xsl:otherwise>
          <xsl:value-of select="$xml.src.path"/>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:variable>

    <xsl:if test="$prof != 0">
      <div href="{concat($path, @href)}" remap="{local-name()}">
        <xsl:choose>
          <xsl:when test="@parse='text'">
            <!-- Do nothing, but include parse='text' -->
            <xsl:attribute name="text">true</xsl:attribute>
          </xsl:when>
          <xsl:otherwise>
            <xsl:variable name="rootnode" select="document(@href)/*"/>
            <xsl:copy-of select="$rootnode/@*[not(local-name() = 'id')]"/>
            <xsl:attribute name="text">false</xsl:attribute>
            <xsl:apply-templates select="$rootnode">
              <xsl:with-param name="xi" select="1"/>
            </xsl:apply-templates>
          </xsl:otherwise>
        </xsl:choose>
      </div>
    </xsl:if>
  </xsl:template>

  <xsl:template name="cross.compare">
    <xsl:param name="a"/>
    <xsl:param name="b"/>
    <xsl:param name="sep" select="$profile.separator"/>

    <xsl:if test="$a and $b">
      <xsl:call-template name="cross.compare.inner">
        <xsl:with-param name="a" select="$a"/>
        <xsl:with-param name="b" select="concat($sep, $b, $sep)"/>
        <xsl:with-param name="sep" select="$sep"/>
      </xsl:call-template>
    </xsl:if>
  </xsl:template>

  <xsl:template name="cross.compare.inner">
    <xsl:param name="a"/>
    <xsl:param name="b"/>
    <xsl:param name="sep"/>
    <xsl:variable name="head"
      select="substring-before(concat($a, $sep), $sep)"/>
    <!-- As soon as one checks out, we can stop checking whether the rest
    matches. -->
    <xsl:choose>
      <xsl:when test="contains($b, concat($sep, $head, $sep))">1</xsl:when>
      <xsl:otherwise>
        <xsl:variable name="tail" select="substring-after($a, $sep)"/>
        <xsl:if test="$tail">
        <xsl:call-template name="cross.compare.inner">
          <xsl:with-param name="a" select="$tail"/>
          <xsl:with-param name="b" select="$b"/>
        </xsl:call-template>
        </xsl:if>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

</xsl:stylesheet>
