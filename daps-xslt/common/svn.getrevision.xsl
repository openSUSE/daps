<?xml version="1.0" encoding="UTF-8"?>
<!--
   Purpose:
     Extracts first revision from svn log --xml output
     
   Parameters:
     None
       
   Input:
     XML file from "svn log --xml" 
     
   Output:
     Text, first revision
   
   Author:    Thomas Schraitle <toms@opensuse.org>
   Copyright: 2012, Thomas Schraitle
   
-->

<xsl:stylesheet version="1.0"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform">

<xsl:output method="text"/>

<xsl:template match="logentry[1]">
   <xsl:value-of select="@revision"/>
</xsl:template>

<xsl:template match="text()"/>

</xsl:stylesheet>