<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE xsl:stylesheet>

<xsl:stylesheet version="1.0"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:exslt="http://exslt.org/common"
    exclude-result-prefixes="exslt">


<xsl:template match="text()[normalize-space(.)][../*]" mode="copy-node-normalize">
  <textnode><xsl:value-of select="."/></textnode>
</xsl:template>

<xsl:template match="@*|node()" mode="copy-node-normalize">
  <xsl:copy>
    <xsl:apply-templates select="@*|node()" mode="copy-node-normalize"/>
  </xsl:copy>
</xsl:template>

<!-- ==================================================================== -->
<xsl:template match="screen/text()" mode="screen-copy-node-normal">
  <textnode><xsl:value-of select="."/></textnode>
</xsl:template>

<xsl:template match="text()" mode="screen-copy-node-normal">
  <xsl:value-of select="."/>
</xsl:template>

<xsl:template match="@*|node()" mode="screen-copy-node-normal">
  <xsl:copy>
    <xsl:apply-templates select="@*|node()" mode="screen-copy-node-normal"/>
  </xsl:copy>
</xsl:template>


<!-- ==================================================================== -->
<xsl:template match="text()" mode="copy-node-normal">
  <textnode><xsl:value-of select="."/></textnode>
</xsl:template>

<xsl:template match="@*|node()[not(text())]" mode="copy-node-normal">
  <xsl:copy>
    <xsl:apply-templates select="@*|node()" mode="copy-node-normal"/>
  </xsl:copy>
</xsl:template>

<!-- ==================================================================== -->

<xsl:template match="text()" mode="copy-node">
  <xsl:value-of select="."/>
</xsl:template>

<xsl:template match="@*|node()" mode="copy-node">
  <xsl:copy>
    <xsl:apply-templates select="@*|node()" mode="copy-node"/>
  </xsl:copy>
</xsl:template>

</xsl:stylesheet>