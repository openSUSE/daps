<?xml version="1.0" encoding="UTF-8"?>
<!--
   Purpose:
     Resolves <?dbtimestamp?> PI
     
   Parameters:
     * l10n.gentext.language
       The language to use for the PI
     
     * l10n.gentext.use.xref.language
       Not really used, just needed from the DB stylesheets
       
   Input:
     DocBook 4/Novdoc document with <?dbtimestamp?> PIs
     
   Output:
     Everything is copied, except the PI is resolved
   
   Author:    Thomas Schraitle <toms@opensuse.org>
   Copyright: 2012, Thomas Schraitle
   
-->

<xsl:stylesheet version="1.0"
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
  
  <xsl:include href="http://docbook.sourceforge.net/release/xsl/current/lib/lib.xsl"/>
  <xsl:include href="http://docbook.sourceforge.net/release/xsl/current/common/pi.xsl"/>
  <xsl:include href="http://docbook.sourceforge.net/release/xsl/current/common/l10n.xsl"/>
  
  <xsl:include href="copy.xsl"/>
  
  <!-- These are the minimum parameters -->
  <xsl:param name="l10n.gentext.language"/>
  <xsl:param name="l10n.gentext.use.xref.language" select="0"/>
  <xsl:param name="exsl.node.set.available">
  <xsl:choose>
    <xsl:when xmlns:exsl="http://exslt.org/common" exsl:foo="" 
      test="function-available('exsl:node-set') or contains(system-property('xsl:vendor'), 'Apache Software Foundation')">1</xsl:when>
    <xsl:otherwise>0</xsl:otherwise>
  </xsl:choose>
</xsl:param>
  
  
</xsl:stylesheet>