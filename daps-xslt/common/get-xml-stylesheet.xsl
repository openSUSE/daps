<?xml version="1.0" encoding="ISO-8859-1"?>
<!--
   Purpose:
     Print content of a 'xml-stylesheet' processing instruction
     
   Parameters:
     None
       
   Input:
     DocBook 4/Novdoc document
     
   Output:
     Text content of the 'xml-stylesheet' processing instruction
     (detects this PI only in the root node!)
   
   Author:    Thomas Schraitle <toms@opensuse.org>
   Copyright: 2012, Thomas Schraitle
   
-->

<xsl:stylesheet
    version="1.0"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform">

<xsl:import href="http://docbook.sourceforge.net/release/xsl/current/lib/lib.xsl"/>

<xsl:output method="text"/>

<xsl:template match="*"/>


<xsl:template match="/processing-instruction('xml-stylesheet')[1]">
   <!--<xsl:message> PI: xml-stylesheet <xsl:value-of select="."/>
   </xsl:message>-->
   <xsl:call-template name="pi-attribute">
      <xsl:with-param name="pis" select="self::processing-instruction('xml-stylesheet')"/>
      <xsl:with-param name="attribute">href</xsl:with-param>
   </xsl:call-template>
</xsl:template>

</xsl:stylesheet>