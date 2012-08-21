<?xml version="1.0" encoding="UTF-8"?>

<xsl:stylesheet version="1.0"
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:fo="http://www.w3.org/1999/XSL/Format">


<xsl:param name="paper.layout">pocket</xsl:param>
<xsl:param name="paper.type">SUSE Pocket Layout:</xsl:param>
<xsl:param name="page.height">180mm</xsl:param><!-- 187mm -->
<xsl:param name="page.width">125mm</xsl:param><!-- 131mm -->
<xsl:param name="double.sided">1</xsl:param>

<xsl:param name="header.rule" select="0"/>
<xsl:param name="footer.rule" select="0"/>

<xsl:param name="page.margin.outer">10mm</xsl:param><!-- 12mm -->
<xsl:param name="page.margin.inner">15.5mm</xsl:param>

<xsl:param name="page.margin.top">10mm</xsl:param>
<xsl:param name="page.margin.bottom">6mm</xsl:param><!-- 22mm - 13.6mm -->
<xsl:param name="region.before.extent">0pt</xsl:param>

<xsl:param name="body.margin.top">0pt</xsl:param>
<xsl:param name="body.margin.bottom">6.5mm</xsl:param><!-- 13.6mm -->
<xsl:param name="region.after.extent">1em</xsl:param>
<xsl:param name="body.start.indent">0pt</xsl:param>

<xsl:param name="body.font.master">7.5</xsl:param>

<xsl:param name="alignment">justify</xsl:param>

<xsl:param name="direction.align.start">
  <xsl:choose>
    <!-- FOP does not support writing-mode="rl-tb" -->
    <xsl:when test="$fop.extensions != 0">left</xsl:when>
    <xsl:when test="$fop1.extensions != 0">left</xsl:when>
    <xsl:when test="starts-with($writing.mode, 'lr')">left</xsl:when>
    <xsl:when test="starts-with($writing.mode, 'rl')">right</xsl:when>
    <xsl:when test="starts-with($writing.mode, 'tb')">top</xsl:when>
    <xsl:otherwise>left</xsl:otherwise>
  </xsl:choose>
</xsl:param>

</xsl:stylesheet>
