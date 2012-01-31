<?xml version="1.0"?>
<!--
   Purpose:
     Overview of document structure with title and ID
     
   Parameters:
     * separator (default: " ")
       Separates the different parts of the output
     * endseparator (default: "&#10;")
       Separator at the end of a line
      
   Input:
     DocBook document
     
   Output:
     Text output in the form
      ELEMENT: TITLE ID
      
   
   Author:    Thomas Schraitle <toms@opensuse.org>
   Copyright: 2012, Thomas Schraitle
   
-->
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  version="1.0">

  <xsl:import href="rootid.xsl"/>

  <xsl:output method="text" encoding="UTF-8"/>
  <xsl:param name="separator" select="' '"/>
  <xsl:param name="endseparator" select="'&#10;'"/>


  <xsl:template match="text()"/>


  <xsl:template
    match="set|article|book|part|chapter|appendix|preface|sect1|sect2|sect3|sect4">
    <xsl:param name="indent" select="''"/>
    <xsl:choose>
      <xsl:when test="@xml:base">
        <xsl:call-template name="getbasename"/>
      </xsl:when>
    </xsl:choose>
    <xsl:choose>
      <xsl:when test="@id">
        <xsl:value-of select="$indent"/>
        <xsl:call-template name="gettitle_id"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:value-of
          select="concat($indent, name(.), ': ', normalize-space(title), ' (**Missing ID**)', '&#10;')"
        />
      </xsl:otherwise>
    </xsl:choose>
    <xsl:apply-templates>
      <xsl:with-param name="indent" select="concat($indent, '  ')"/>
    </xsl:apply-templates>
  </xsl:template>

  <!-- ****************************************** -->

  <xsl:template name="gettitle_id">
    <xsl:param name="node" select="."/>
    <xsl:value-of
      select="concat(name(.), ': ', normalize-space(title), ' (',$node/@id,')', '&#10;')"
    />
  </xsl:template>

  <xsl:template name="getbasename">
    <xsl:param name="node" select="."/>
    <xsl:value-of
      select="concat('-----', $node/@xml:base, '-----', '&#10;')"/>
  </xsl:template>

</xsl:stylesheet>
