<?xml version="1.0" encoding="UTF-8"?>
<!-- $Id: $ -->
<xsl:stylesheet version="1.0"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:fo="http://www.w3.org/1999/XSL/Format">

<xsl:template match="glossentry/glossterm" mode="glossary.as.blocks">
  <xsl:variable name="id">
    <xsl:call-template name="object.id"/>
  </xsl:variable>
  <fo:inline id="{$id}" xsl:use-attribute-sets="glossterm.properties">
    <xsl:apply-templates/>
  </fo:inline>
  <xsl:if test="following-sibling::glossterm">, </xsl:if>
</xsl:template>


</xsl:stylesheet>
