<?xml version="1.0" encoding="ISO-8859-1"?>
<!-- $Id: get-xml-stylesheet.xsl 110 2005-05-18 11:01:48Z toms $ -->
<xsl:stylesheet
    version="1.0"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform">

<xsl:import href="http://docbook.sourceforge.net/release/xsl/current/lib/lib.xsl"/>

<xsl:output method="text"/>

<xsl:template match="*">
</xsl:template>


<xsl:template match="/processing-instruction('xml-stylesheet')[1]">
   <!--<xsl:message> PI: xml-stylesheet <xsl:value-of select="."/>
   </xsl:message>-->
   <xsl:call-template name="pi-attribute">
      <xsl:with-param name="pis" select="self::processing-instruction('xml-stylesheet')"/>
      <xsl:with-param name="attribute">href</xsl:with-param>
   </xsl:call-template>
</xsl:template>


</xsl:stylesheet>