<?xml version="1.0" encoding="UTF-8"?>
<!-- $Id: table.xsl 2154 2005-09-26 11:15:11Z toms $ -->
<xsl:stylesheet version="1.0"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:fo="http://www.w3.org/1999/XSL/Format"
    xmlns:rx="http://www.renderx.com/XSL/Extensions"
>

<!-- From $DB/fo/table.xsl -->

<!--<xsl:template name="border">
  <xsl:variable name="side" select="'top'"/>

  <xsl:attribute name="border-{$side}-width">
    <xsl:value-of select="$table.cell.border.thickness"/>
  </xsl:attribute>
  <xsl:attribute name="border-{$side}-style">
    <xsl:value-of select="$table.cell.border.style"/>
  </xsl:attribute>
  <xsl:attribute name="border-{$side}-color">
    <xsl:value-of select="$table.cell.border.color"/>
  </xsl:attribute>
</xsl:template>-->



<!-- frame='topbot' -->
<xsl:template name="table.frame">
<!--    <xsl:message> ******** table.frame: <xsl:value-of select="name(.)"/> </xsl:message> -->
<!--    <xsl:attribute name="border-left-style">none</xsl:attribute>
    <xsl:attribute name="border-right-style">none</xsl:attribute>
    <xsl:attribute name="border-top-style">
      <xsl:value-of select="$table.frame.border.style"/>
    </xsl:attribute>
    <xsl:attribute name="border-bottom-style">
      <xsl:value-of select="$table.frame.border.style"/>
    </xsl:attribute>
    <xsl:attribute name="border-top-width">
      <xsl:value-of select="$table.frame.border.thickness"/>
    </xsl:attribute>
    <xsl:attribute name="border-bottom-width">
      <xsl:value-of select="$table.frame.border.thickness"/>
    </xsl:attribute>
    <xsl:attribute name="border-top-color">
      <xsl:value-of select="$table.frame.border.color"/>
    </xsl:attribute>
    <xsl:attribute name="border-bottom-color">
      <xsl:value-of select="$table.frame.border.color"/>
    </xsl:attribute>-->
</xsl:template>


<xsl:template match="tbody">
  <xsl:variable name="tgroup" select="parent::*"/>

  <fo:table-body start-indent="0pt"
                 border-top="0.4pt solid black"
                 border-bottom="0.8pt solid black">
    <xsl:apply-templates select="row[1]">
      <xsl:with-param name="spans">
        <xsl:call-template name="blank.spans">
          <xsl:with-param name="cols" select="../@cols"/>
        </xsl:call-template>
      </xsl:with-param>
    </xsl:apply-templates>
  </fo:table-body>
</xsl:template>


<xsl:template match="thead">
  <xsl:variable name="tgroup" select="parent::*"/>

  <fo:table-header start-indent="0pt"
                   border-top="0.8pt solid black">
    <xsl:apply-templates select="row[1]">
      <xsl:with-param name="spans">
        <xsl:call-template name="blank.spans">
          <xsl:with-param name="cols" select="../@cols"/>
        </xsl:call-template>
      </xsl:with-param>
    </xsl:apply-templates>
  </fo:table-header>
</xsl:template>


</xsl:stylesheet>