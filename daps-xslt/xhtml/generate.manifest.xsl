<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE xsl:stylesheet
[
  <!ENTITY db "http://docbook.sourceforge.net/release/xsl/current/xhtml">
]>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  version="1.0">
  
  <xsl:import href="&db;/docbook.xsl"/>
  <xsl:import href="&db;/chunk-common.xsl"/>
  <xsl:include href="&db;/chunk-code.xsl"/>
  
  <xsl:param name="generate.manifest" select="1"/>
  <xsl:param name="manifest">MANIFEST</xsl:param>

  <xsl:template match="/">
    <xsl:call-template name="generate.manifest"/>
  </xsl:template>
  
</xsl:stylesheet>