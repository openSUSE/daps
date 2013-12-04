<?xml version="1.0" encoding="UTF-8"?>
<!--
  Purpose:
    Formats refentrys.

  Authors:    Thomas Schraitle <toms@opensuse.org>,
              Stefan Knorr <sknorr@suse.de>
  Copyright:  2013, Thomas Schraitle, Stefan Knorr

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
  
  
  <xsl:template match="refname"/>
  
  
  <xsl:template match="refpurpose">
    <xsl:if test="node()">
      <xsl:apply-templates/>
    </xsl:if>
  </xsl:template>
  
</xsl:stylesheet>