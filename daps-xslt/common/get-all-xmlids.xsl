<?xml version="1.0" encoding="UTF-8"?>
<!--
   Purpose:
     Output all elements with an xml:id/id

   Parameters:
     * sep (default: '\n')
       Separator between IDs

   Input:
     A DocBook 4 or DocBook 5 document

   Output:
     line with the ID     

   Author:    Thomas Schraitle <toms@opensuse.org>
   Copyright (C) 2017 SUSE Linux GmbH

-->
<xsl:stylesheet version="1.0"
 xmlns:db="http://docbook.org/ns/docbook"
 xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
 
 <xsl:output method="text"/>
 
 <xsl:param name="sep">
  <xsl:text>
</xsl:text>
 </xsl:param>
 
 <xsl:template match="text()"/>
 
 <xsl:template match="*[@xml:id or @id]">
  <xsl:variable name="id" select="(@xml:id | @id)[1]"/>
  <xsl:value-of select="concat($id, $sep)"/>
  <xsl:apply-templates/>
 </xsl:template>
 
</xsl:stylesheet>