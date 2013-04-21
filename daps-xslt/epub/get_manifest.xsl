<?xml version="1.0" encoding="UTF-8"?>
<!-- 
   Purpose:
     Prints a manifest for ePUB from OEBPS/content.opf
     
   Parameters:
     * sep (default: ' ')
       Separator between filenames
     * docprop (default: 'doc:trans')
       The doc property you want to search
     * docvalue (default: 'yes')
       Only output the filename, when $docprop = $docvalue
     
   Input:
     XML file OEBPS/content.opf from ePUB
     
   Output:
     List of filenames, separated by spaces
   
   Author:    Frank Sundermeyer <fsundermeyer@opensuse.org>
   Copyright: 2013, Frank Sundermeyer
-->

<xsl:stylesheet version="1.0"
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:opf="http://www.idpf.org/2007/opf">

 <xsl:output method="text"/>

 <xsl:param name="sep"><xsl:text> </xsl:text></xsl:param>
 <xsl:template match="text()"/>
 
<!--  <xsl:template match="//*[local-name() = 'item']"> -->
  <xsl:template match="/opf:package/opf:manifest/opf:item">
   <xsl:value-of select="concat(@href, $sep)"/>
  </xsl:template>
  
</xsl:stylesheet>
