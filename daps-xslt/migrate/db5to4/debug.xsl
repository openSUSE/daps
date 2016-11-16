<?xml version="1.0" encoding="UTF-8"?>
<!--
   Purpose:
     Output a consistent debugging message string

   Stylesheet Parameters:
     * debug.level (default: 4)
       Controls the output of debug messages

   Parameters for "message":
     * text
       The debugging text that should be displayed
     * type (default: " > ")
       The type of the message (usually 'INFO', 'ERROR', etc.)
     * abourt (default: 0)
       If the transformation should be aborted (=1) or not (=0)

   Author:    Thomas Schraitle <toms@opensuse.org>
   Copyright (C) 2012-2016 SUSE Linux GmbH

-->
<xsl:stylesheet version="1.0"
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform">

  <!-- ################################################################## -->
  <!-- Parameter -->
  <xsl:param name="debug.level" select="4"/>


  <!-- ################################################################## -->
  <xsl:template name="message">
    <xsl:param name="text"/>
    <xsl:param name="type"/>
    <xsl:param name="abort" select="0"/>

    <xsl:choose>
      <xsl:when test="$abort != 0">
        <xsl:message terminate="yes">
          <xsl:value-of select="$type"/>
          <xsl:text>: </xsl:text>
          <xsl:value-of select="$text"/>
          <xsl:if test="ancestor-or-self::*/@id">
            <xsl:text>&#10;  (within ID: </xsl:text>
            <xsl:value-of select="ancestor-or-self::*[@id][1]/@id"/>
            <xsl:text>)</xsl:text>
          </xsl:if>
        </xsl:message>
      </xsl:when>
      <xsl:otherwise>
        <xsl:message>
          <xsl:value-of select="$type"/>
          <xsl:text>: </xsl:text>
          <xsl:value-of select="$text"/>
          <xsl:if test="ancestor-or-self::*/@id">
            <xsl:text>&#10;  (within ID: </xsl:text>
            <xsl:value-of select="ancestor-or-self::*[@id][1]/@id"/>
            <xsl:text>)</xsl:text>
          </xsl:if>
        </xsl:message>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:template name="log.fatal">
    <xsl:param name="text"/>
    <xsl:param name="abort" select="1"/>
    <xsl:call-template name="message">
      <xsl:with-param name="type">FATAL</xsl:with-param>
      <xsl:with-param name="text" select="$text"/>
      <xsl:with-param name="abort" select="$abort"/>
    </xsl:call-template>
  </xsl:template>

  <xsl:template name="log.warn">
    <xsl:param name="text"/>
    <xsl:if test="$debug.level > 1">
      <xsl:call-template name="message">
        <xsl:with-param name="type">WARNING</xsl:with-param>
        <xsl:with-param name="text" select="$text"/>
      </xsl:call-template>
    </xsl:if>
  </xsl:template>

  <xsl:template name="log.info">
    <xsl:param name="text"/>
    <xsl:if test="$debug.level > 2">
      <xsl:call-template name="message">
        <xsl:with-param name="type">INFO</xsl:with-param>
        <xsl:with-param name="text" select="$text"/>
      </xsl:call-template>
    </xsl:if>
  </xsl:template>
</xsl:stylesheet>