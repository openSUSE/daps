<?xml version="1.0" encoding="UTF-8"?>
<!-- 
   Purpose:
     Returns version number of the DocBook XSL stylesheets
     
   Parameters:
     n/a
       
   Input:
     VERSION.xsl from the DocBook XSL distribution
     
   Output:
     String of the version number 
   
   Example:
     $ xsltproc get-dbxslt-version.xsl http://docbook.sourceforge.net/release/xsl/current/VERSION.xsl
   
   Author:    Thomas Schraitle <toms@opensuse.org>
   Copyright (C) 2012-2015 SUSE Linux GmbH
-->
<xsl:stylesheet  version="1.0"
  xmlns:fm="http://freshmeat.net/projects/freshmeat-submit/"
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:x="http://www.w3.org/1999/XSL/Transform">
  
  <xsl:output method="text"/>
  
  <xsl:template match="text()"/>
  
  <xsl:template match="fm:project/fm:Version">
    <xsl:value-of select="."/>
  </xsl:template>

  <xsl:template match="/x:stylesheet/x:param[@name='STYLE.VERSION']">
    <xsl:choose>
     <xsl:when test="@select">
      <xsl:value-of select="@select"/>
     </xsl:when>
     <xsl:otherwise>
      <xsl:value-of select="."/>
     </xsl:otherwise>
    </xsl:choose>
  </xsl:template>
  
</xsl:stylesheet>
