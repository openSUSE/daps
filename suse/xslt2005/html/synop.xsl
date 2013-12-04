<?xml version="1.0" encoding="UTF-8"?>
<!-- $Id: $ -->
<xsl:stylesheet
	version="1.0"
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
  

<xsl:template match="synopfragment">
  <xsl:variable name="snum">
    <xsl:apply-templates select="." mode="synopfragment.number"/>
  </xsl:variable>
  <!-- You can't introduce another <p> here, because you're
       already in a <p> from cmdsynopsis-->
  <span class="{local-name()}">
    <xsl:variable name="id">
      <xsl:call-template name="object.id"/>
    </xsl:variable>
    <a name="{$id}">
      <xsl:text>(</xsl:text>
      <xsl:value-of select="$snum"/>
      <xsl:text>)</xsl:text>
    </a>
    <xsl:text> </xsl:text>
    <xsl:apply-templates/>
  </span>
</xsl:template>

</xsl:stylesheet>