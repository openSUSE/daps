<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:fo="http://www.w3.org/1999/XSL/Format">

<xsl:template match="processing-instruction('dbsbr') | 
                     processing-instruction('dblinebreak')">
  <fo:block/>
</xsl:template>

<xsl:template match="processing-instruction('suse')"
              mode="title.markup">
  <xsl:call-template name="suse-pi"/>
</xsl:template>

<xsl:template match="processing-instruction('suse')"
              mode="titlepage.mode">
  <xsl:call-template name="suse-pi"/>
</xsl:template>

<xsl:template match="processing-instruction('suse')"
              mode="titleabbrev.markup">
  <xsl:call-template name="suse-pi"/>
</xsl:template>


<!--<xsl:template match="title/processing-instruction('suse')" mode="object.title.markup">
  <xsl:call-template name="suse-pi"/>
</xsl:template>-->

<xsl:template match="processing-instruction('suse')">
  <xsl:call-template name="suse-pi"/>
</xsl:template>


<xsl:template match="part/title/processing-instruction('suse')">
  <xsl:message>FIXME: Some processing instruction inside a part/title <!-- 
  --> see <xsl:value-of select="normalize-space(..)"/>
  </xsl:message>
</xsl:template>

<!--<xsl:template match="processing-instruction('suse')" mode="toc">
  <xsl:call-template name="suse-pi"/>
</xsl:template>

<xsl:template match="processing-instruction('suse')" mode="object.xep.title.markup">
  <xsl:call-template name="suse-pi"/>
</xsl:template>-->


<xsl:template match="processing-instruction('suse')" mode="no.anchor.mode">
  <xsl:call-template name="suse-pi"/>
</xsl:template>


<xsl:template match="processing-instruction('suse')" mode="footer">
  <xsl:call-template name="suse-pi"/>
</xsl:template>

</xsl:stylesheet>
