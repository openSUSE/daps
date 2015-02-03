<?xml version="1.0" encoding="UTF-8"?>
<!--
   Purpose:
     Copy nodes
     
   Parameters:
     None
       
   Input:
     None, input is passed through special modes
     
   Output:
     Identity transformation, all nodes are copied
     
   See Also:
     Sal Mangano, XSLT Cookbook, p. 201 (XML to XML)
   
   Author:    Thomas Schraitle <toms@opensuse.org>
   Copyright: 2012, Thomas Schraitle
   
-->

<xsl:stylesheet version="1.0"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform">

<xsl:template match="node() | @*" name="copy">
  <xsl:copy>
    <xsl:apply-templates select="@* | node()"/>
  </xsl:copy>
</xsl:template>

</xsl:stylesheet>