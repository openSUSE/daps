<?xml version="1.0" encoding="UTF-8"?>
<!--
   Purpose:
     Prints the ID (@id or @xml:id) of the root element
     
   Parameters:
     None
       
   Input:
     Any document which contains @id or @xml:id attributes in its 
     root element
     
   Output:
     Text, value of @id, @xml:id, or nothing
   
   Author:    Thomas Schraitle <toms@opensuse.org>
   Copyright (C) 2012-2015 SUSE Linux GmbH
   
-->
<xsl:stylesheet version="1.0"
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
  
  <xsl:output method="text"/>
  
  <xsl:template match="/">
    <xsl:value-of select="(/*/@id | /*/@xml:id)[1]"/>
  </xsl:template>
</xsl:stylesheet>
