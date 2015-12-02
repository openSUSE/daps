<?xml version="1.0" encoding="UTF-8"?>
<!--
   Purpose:
     Templates for block elements

   Input:
     Valid DocBook5


   Author:    Thomas Schraitle <toms@opensuse.org>
   Copyright:  2015 SUSE Linux GmbH

-->
<xsl:stylesheet version="1.0"
  xmlns:d="http://docbook.org/ns/docbook"
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:xi="http://www.w3.org/2001/XInclude"
  xmlns:xlink="http://www.w3.org/1999/xlink"
  xmlns:html="http://www.w3.org/1999/xhtml"
  xmlns:exsl="http://exslt.org/common"
  exclude-result-prefixes="d xi xlink exsl html">


  <!-- Move any nested lists inside variablelist out of variablelist -->
  <xsl:template name="separate.nested.lists">
    <xsl:apply-templates select="d:variablelist|d:itemizedlist|d:orderedlist"/>
    <xsl:element name="{local-name()}">
      <xsl:apply-templates select="@*|d:*[not(self::d:variablelist or
                                              self::d:itemizedlist or
                                              self::d:orderedlist)]"/>
    </xsl:element>
  </xsl:template>

  <xsl:template match="d:itemizedlist[d:variablelist|d:itemizedlist|d:orderedlist]">
    <xsl:call-template name="separate.nested.lists"/>
  </xsl:template>
  <xsl:template match="d:orderedlist[d:variablelist|d:itemizedlist|d:orderedlist]">
    <xsl:call-template name="separate.nested.lists"/>
  </xsl:template>
  <xsl:template match="d:variablelist[d:variablelist|d:itemizedlist|d:orderedlist]">
    <xsl:call-template name="separate.nested.lists"/>
  </xsl:template>

</xsl:stylesheet>