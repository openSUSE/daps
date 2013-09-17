<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0"
  xmlns:fm="http://freshmeat.net/projects/freshmeat-submit/"
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  exclude-result-prefixes="fm">
  
  <xsl:strip-space elements="fm:*"/>
  
  <xsl:param name="DAPS.VERSION" select="string(document('')//fm:Version[1])"/>

  <fm:project>
    <fm:Project>DAPS</fm:Project>
    <fm:Version>1.1.7</fm:Version>
  </fm:project>

</xsl:stylesheet>