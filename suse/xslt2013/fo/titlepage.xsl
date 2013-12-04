<?xml version="1.0" encoding="UTF-8"?>
<!--
  Purpose:
    Don't add the text "Abstract" before abstracts on title pages.

  Author(s):  Stefan Knorr <sknorr@suse.de>

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
<xsl:stylesheet  version="1.0"
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:fo="http://www.w3.org/1999/XSL/Format">

<xsl:template match="abstract" mode="titlepage.mode">
  <fo:block xsl:use-attribute-sets="abstract.properties">
    <fo:block xsl:use-attribute-sets="abstract.title.properties">
      <xsl:if test="title|info/title">
        <xsl:apply-templates select="title|info/title"/>
      </xsl:if>
    </fo:block>
    <xsl:apply-templates select="*[not(self::title)]" mode="titlepage.mode"/>
  </fo:block>
</xsl:template>


</xsl:stylesheet>
