<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0"
  xmlns:exsl="http://exslt.org/common"
  xmlns:t="urn:x-suse:toms:ns:testcases"
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
  
  <!-- This should be better resolved through catalogs -->
  <xsl:import href="../../../../../suse/suse2013/fo/docbook.xsl"/>
  
  <xsl:template match="/">
    <xsl:variable name="context" select="/t:testcases/t:scenario[1]/t:context[1]/node()[not(self::text())]"/>
    
    <xsl:apply-templates select="exsl:node-set($context)"/>
  </xsl:template>
  
</xsl:stylesheet>