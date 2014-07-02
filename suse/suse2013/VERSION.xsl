<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0"
  xmlns:fm="http://freshmeat.net/projects/freshmeat-submit/"
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  exclude-result-prefixes="fm">

  <xsl:strip-space elements="fm:*"/>

  <xsl:param name="STYLE.NAME" select="string(document('')//fm:Project[1])"/>
  <xsl:param name="STYLE.VERSION" select="string(document('')//fm:Version[1])"/>

  <fm:project>
    <fm:Project>SUSE XSL Stylesheets</fm:Project>
    <!-- The version number is updated automatically when packaging -->
    <fm:Version>2.0</fm:Version>
  </fm:project>

</xsl:stylesheet>
