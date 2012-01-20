<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0"
 xmlns:xsl="http://www.w3.org/1999/XSL/Transform">

 <xsl:import href="copy.xsl"/>

 <!--
   Don't copy remark and XML comments
 -->
 
 <xsl:template match="comment()"/>
 
 <xsl:template match="remark"/>
 
 <xsl:template match="remark[@role='trans']">
  <xsl:apply-imports/>
 </xsl:template>
 
</xsl:stylesheet>
