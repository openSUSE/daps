<?xml version="1.0" encoding="UTF-8"?>
<!--
  Purpose:
    Restyle article titlepage

  Author(s):  Stefan Knorr <sknorr@suse.de>,
              Thomas Schraitle <toms@opensuse.org>

  Copyright:  2013, Stefan Knorr, Thomas Schraitle

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
  
  <!-- Article ==================================================== -->
  <xsl:template match="title" mode="article.titlepage.recto.auto.mode">
    <fo:block
      xsl:use-attribute-sets="article.titlepage.recto.style"
      keep-with-next.within-column="always">
      <xsl:call-template name="component.title">
        <xsl:with-param name="node" select="ancestor-or-self::article[1]"/>
      </xsl:call-template>
    </fo:block>
  </xsl:template>
  
  <xsl:template match="author|corpauthor|authorgroup"
    mode="article.titlepage.recto.auto.mode">
    <fo:block
      xsl:use-attribute-sets="article.titlepage.recto.style" space-before="0.5em"
      font-size="&x-large;pt">
      <xsl:apply-templates select="." mode="article.titlepage.recto.mode"/>
    </fo:block>
  </xsl:template>

</xsl:stylesheet>