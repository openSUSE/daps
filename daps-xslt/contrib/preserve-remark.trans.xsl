<?xml version="1.0" encoding="UTF-8"?>
<!--
   Purpose:
     Preserve remark[@role='trans'] but not remark only
     
   Parameters:
       
   Input:
     DocBook 4/Novdoc document
     
   Output:
     DocBook 4 document with preserved remark[@role='trans'] but 
     not remark
   
   Author:    Thomas Schraitle <toms@opensuse.org>
   Copyright: 2012, Thomas Schraitle
   
-->
<xsl:stylesheet version="1.0"
 xmlns:xsl="http://www.w3.org/1999/XSL/Transform">

 <xsl:import href="copy.xsl"/>

 <xsl:template match="comment()"/>
 
 <xsl:template match="remark"/>
 
 <xsl:template match="remark[@role='trans']">
  <xsl:apply-imports/>
 </xsl:template>
 
</xsl:stylesheet>
