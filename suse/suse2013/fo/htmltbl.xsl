<?xml version="1.0" encoding="UTF-8"?>
<!--
  Purpose:
    Style theads to look more similar to how they look in the HTML layout.

  Authors:    Stefan Knorr <sknorr@suse.de>
  Copyright:  2013, Stefan Knorr

-->
<!DOCTYPE xsl:stylesheet
[
  <!ENTITY % fonts SYSTEM "fonts.ent">
  <!ENTITY % colors SYSTEM "colors.ent">
  <!ENTITY % metrics SYSTEM "metrics.ent">
  %fonts;
  %colors;
  %metrics;
]>
<xsl:stylesheet version="1.0"
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:fo="http://www.w3.org/1999/XSL/Format">

<xsl:template match="thead" mode="htmlTable">
  <fo:table-header start-indent="0pt" end-indent="0pt"
    background-color="&light-gray-old;">
    <xsl:apply-templates mode="htmlTable"/>
  </fo:table-header>
</xsl:template>

</xsl:stylesheet>
