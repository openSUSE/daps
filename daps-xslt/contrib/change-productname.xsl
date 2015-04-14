<?xml version="1.0" encoding="UTF-8"?>
<!-- 
   Purpose:
     Changes misplaced <productname> elements inside para and subtitle
     
   Parameters:
     * None

   Input:
     DocBook 4/Novdoc document
     
   Output:
     <productname> replaced with <phrase role="productname"> (when inside para)
     or removed entirely (when inside article/subtitle or articleinfo/subtitle
   
   Author:    Thomas Schraitle <toms@opensuse.org>
   Copyright (C) 2012-2015 SUSE Linux GmbH


-->
<xsl:stylesheet version="1.0"
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
    
  <xsl:template match="node() | @*">
  <xsl:copy>
    <xsl:apply-templates select="@* | node()"/>
  </xsl:copy>
</xsl:template>
  
  <xsl:template match="para/productname">
    <phrase role="productname">
      <xsl:apply-templates/>
    </phrase>
  </xsl:template>

  <xsl:template match="article/subtitle/productname|articleinfo/subtitle/productname">
    <xsl:apply-templates/>
  </xsl:template>

</xsl:stylesheet>
