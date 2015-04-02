<?xml version="1.0" encoding="UTF-8"?>
<!--
   Purpose:
     Prints hint if index element is available
     
   Parameters:
     * rootid (imported)
       Applies stylesheet only to part of the document
       
   Input:
     DocBook 4/Novdoc document
     
   Output:
     Text: Yes or No. Depending on, if index element was found in
     the respective child nodes
   
   Author:    Thomas Schraitle <toms@opensuse.org>
   Copyright (C) 2012-2015 SUSE Linux GmbH
   
-->

<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0">

<xsl:import href="rootid.xsl"/>
<xsl:output method="text"/>

<xsl:template match="*|text()"/>


<xsl:template name="rootid.process">
  <xsl:choose>
    <xsl:when test="key('id', $rootid)//index">Yes&#10;</xsl:when>
    <xsl:otherwise>No&#10;</xsl:otherwise>
  </xsl:choose>
</xsl:template>
 
<xsl:template name="normal.process">
  <xsl:choose>
    <xsl:when test="//index">Yes&#10;</xsl:when>
    <xsl:otherwise>No&#10;</xsl:otherwise>
  </xsl:choose>
</xsl:template>
 
</xsl:stylesheet>
