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
   
   Author:    Thomas Schraitle <toms@opensuse.org>
   Copyright: 2012, Thomas Schraitle
-->
<xsl:stylesheet  version="1.0"
  xmlns:fm="http://freshmeat.net/projects/freshmeat-submit/"
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
  
  <xsl:output method="text"/>
  
  <xsl:template match="text()"/>
  
  <xsl:template match="fm:project/fm:Version">
    <xsl:value-of select="."/>
  </xsl:template>
  
</xsl:stylesheet>