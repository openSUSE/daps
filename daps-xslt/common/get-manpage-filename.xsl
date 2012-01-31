<?xml version="1.0" encoding="UTF-8"?>
<!--
   Purpose:
     Prints filename including path to generated manpage(s)

   Parameters:
     See http://docbook.sourceforge.net/release/xsl/current/doc/manpages/output.html
     Additionally:
     * filename.sep (default: ' ')
       String to separate each manpage filename

   Input:
     Normal DocBook source code

   Output:
     Text output with each manpage filename separated by $filename.sep
   
   Author:    Thomas Schraitle <toms@opensuse.org>
   Copyright: 2012, Thomas Schraitle

-->
<!DOCTYPE xsl:stylesheet 
[
  <!ENTITY db "http://docbook.sourceforge.net/release/xsl/current">
]>
<xsl:stylesheet version="1.0"
  xmlns:exsl="http://exslt.org/common"
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
  
  <xsl:import href="&db;/manpages/docbook.xsl"/>

  <xsl:output method="text"/>
  <xsl:param name="filename.sep"><xsl:text> </xsl:text></xsl:param>
  
  <xsl:template match="/">
    <xsl:apply-templates select="//refentry"/>
  </xsl:template>
  
  <xsl:template match="refentry">
    <xsl:param name="lang">
      <xsl:call-template name="l10n.language"/>
    </xsl:param>

    <xsl:variable name="first.refname" select="refnamediv[1]/refname[1]"/>
    
    <xsl:variable name="get.info"
                  select="ancestor-or-self::*/*[substring(local-name(),
                          string-length(local-name()) - 3) = 'info']"/>
    <xsl:variable name="info" select="exsl:node-set($get.info)"/>
    
    <xsl:variable name="get.refentry.metadata">
      <xsl:call-template name="get.refentry.metadata">
        <xsl:with-param name="refname" select="$first.refname"/>
        <xsl:with-param name="info" select="$info"/>
        <xsl:with-param name="prefs" select="$refentry.metadata.prefs"/>
      </xsl:call-template>
    </xsl:variable>
    
    <xsl:variable name="refentry.metadata" 
      select="exsl:node-set($get.refentry.metadata)"/>

    <xsl:call-template name="make.adjusted.man.filename">
        <xsl:with-param name="name" select="$first.refname"/>
        <xsl:with-param name="section" select="$refentry.metadata/section"/>
        <xsl:with-param name="lang" select="$lang"/>
    </xsl:call-template>
    <xsl:value-of select="filename.sep"/>
  </xsl:template>
  
</xsl:stylesheet>