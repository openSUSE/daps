<?xml version="1.0" encoding="UTF-8"?>
<!--
   Purpose:
     Removes DocBook 5 namespace from a DocBook 5 document

   Parameters:
     None

   Input:
     DocBook 5 document

   Output:
     DocBook 5 document without the DocBook 5 namespace
   
   Author:    Thomas Schraitle <toms@opensuse.org>
   Copyright (C) 2012-2015 SUSE Linux GmbH

-->
<xsl:stylesheet version="1.0"
  xmlns:db="http://docbook.org/ns/docbook"
  xmlns:exsl="http://exslt.org/common"
  xmlns:exslt="http://exslt.org/common"
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  exclude-result-prefixes="exsl exslt">
  
  <xsl:import
    href="http://docbook.sourceforge.net/release/xsl/current/common/stripns.xsl"/>
  
  <xsl:param name="exsl.node.set.available">
    <xsl:choose>
      <xsl:when xmlns:exsl="http://exslt.org/common" exsl:foo=""
        test="function-available('exsl:node-set') or  
      contains(system-property('xsl:vendor'),  'Apache Software Foundation')"
        >1</xsl:when>
      <xsl:otherwise>0</xsl:otherwise>
    </xsl:choose>
  </xsl:param>

  <xsl:template match="/">
    <xsl:choose>
      <xsl:when test="$exsl.node.set.available != 0 and */self::db:*">
        <xsl:variable name="nons">
          <xsl:apply-templates mode="stripNS"/>
        </xsl:variable>
        <xsl:message>
          <xsl:text>Stripping DB5 namespace...</xsl:text>
        </xsl:message>
        <xsl:apply-templates select="exsl:node-set($nons)"/>
      </xsl:when>
      
      <!-- Can't process unless namespace removed -->
      <xsl:when test="*/self::db:*">
        <xsl:message terminate="yes">
          <xsl:text>Unable to strip the namespace from DB5 document,</xsl:text>
          <xsl:text> cannot proceed.</xsl:text>
        </xsl:message>
      </xsl:when>
      
      <xsl:otherwise>
        <xsl:apply-templates/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>
  
</xsl:stylesheet>
