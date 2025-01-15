<!-- 
   Purpose:
     Remove all xml:base attributes from the input without changing the
     formatting (especially useful for <screen> elements)

   Parameters:
     * None

   Input:
     DocBook document

   Output:
     A document without any xml:base attributes

   Author:    Tom Schraitle <toms@opensuse.org>
   Date:      2025, Jan

-->
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
  <xsl:output method="xml" indent="no"/>

  <!-- Just in case... -->
  <xsl:preserve-space elements="screen"/>

  <!-- Match and remove all xml:base attributes -->
  <xsl:template match="@xml:base"/>

  <!-- Copy all other elements and text nodes -->
  <xsl:template match="node()">
    <xsl:copy>
      <xsl:apply-templates/>
    </xsl:copy>
  </xsl:template>
</xsl:stylesheet>