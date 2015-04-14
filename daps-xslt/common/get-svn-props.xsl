<?xml version="1.0" encoding="UTF-8"?>
<!-- 
   Purpose:
     Prints filenames of SVN property file 
     
   Parameters:
     * sep (default: ' ')
       Separator between filenames
     * docprop (default: 'doc:trans')
       The doc property you want to search
     * docvalue (default: 'yes')
       Only output the filename, when $docprop = $docvalue
     
   Input:
     XML file from "svn pl -v -|-xml" 
     
   Output:
     List of filenames, separated by spaces
   
   Author:    Thomas Schraitle <toms@opensuse.org>
   Copyright (C) 2012-2015 SUSE Linux GmbH
-->

<xsl:stylesheet version="1.0"
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
  
  <xsl:output method="text"/>
  
  <xsl:param name="sep"><xsl:text> </xsl:text></xsl:param>
  <xsl:param name="docprop">doc:trans</xsl:param>
  <xsl:param name="docvalue">yes</xsl:param>
  
  <xsl:template match="text()"/>
  
  <xsl:template match="target">
    <xsl:if test="property[@name=$docprop][. = $docvalue]">
      <xsl:value-of select="concat(@path, $sep)"/>
    </xsl:if>
  </xsl:template>
  
</xsl:stylesheet>
