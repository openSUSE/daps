<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE xsl:stylesheet 
[
  <!ENTITY % fontsizes SYSTEM "fontsizes.ent">
  %fontsizes;
]>
<xsl:stylesheet version="1.0"
  xmlns:fo="http://www.w3.org/1999/XSL/Format"
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform">

<xsl:template match="keycap">
  <xsl:text>[</xsl:text>
  <xsl:apply-imports/>
  <xsl:text>]</xsl:text>
</xsl:template>

<xsl:template match="command">
  <fo:inline font-weight="500">
    <xsl:apply-imports/>
  </fo:inline>
</xsl:template>
  
</xsl:stylesheet>
