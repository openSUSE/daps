<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0"
  xmlns:fo="http://www.w3.org/1999/XSL/Format"
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
  
  <!-- <xsl:import href="http://docbook.sourceforge.net/release/xsl/current/fo/docbook.xsl"/> -->
  <xsl:import href="file:///usr/share/xml/docbook/stylesheet/nwalsh/current//fo/docbook.xsl"/>
  
  <!-- 
           Parameter
  -->
  <!-- Define indentation of body text area -->
  <xsl:param name="body.start.indent">0pt</xsl:param>

  <!-- Define page dimensions -->
  <xsl:param name="paper.type">A4</xsl:param>

  <!-- Enable FOP 1.0 -->
  <xsl:param name="fop1.extension" select="1"/> 

  <!-- Fonts -->
  <xsl:param name="sans.font.family">DejaVuiSans</xsl:param>
  <xsl:param name="title.font.family">DejaVuSans</xsl:param>
  <xsl:param name="body.font.family">DejaVuSerif</xsl:param>
  <xsl:param name="monospace.font.family">DejaVuSansMono</xsl:param>

  <!-- 
           Attribute Sets
  -->
  <xsl:attribute-set name="table.properties">
    <xsl:attribute name="text-align">left</xsl:attribute>
  </xsl:attribute-set>

  <!-- 
           Templates
  -->
  <xsl:template match="ulink[@role='small']">
    <xsl:param name="url" select="@url"/>

    <xsl:variable name ="ulink.url">
      <xsl:call-template name="fo-external-image">
        <xsl:with-param name="filename" select="$url"/>
      </xsl:call-template>
    </xsl:variable>

    <fo:basic-link xsl:use-attribute-sets="xref.properties"
                 external-destination="{$ulink.url}">
      <xsl:apply-templates/>
    </fo:basic-link>
    <xsl:call-template name="hyperlink.url.display">
      <xsl:with-param name="url" select="$url"/>
      <xsl:with-param name="ulink.url" select="$ulink.url"/>
    </xsl:call-template>
  </xsl:template>
</xsl:stylesheet>
