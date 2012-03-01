<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0"
  xmlns="http://www.w3.org/1999/xhtml"
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
  
  
  <!--  -->
  <xsl:param name="generate.jsp.marker" select="1"/>
  
  <xsl:param name="html.stylesheet">susebooks.css</xsl:param>

  <xsl:param name="chunk.fast" select="1"/>
  <xsl:param name="chunk.section.depth" select="1"/>

  <xsl:param name="chunker.output.encoding">UTF-8</xsl:param>
  <xsl:param name="chunker.output.omit-xml-declaration" select="'yes'"/>
  
 <!-- <xsl:param name="root.filename">index</xsl:param>-->
  
  <xsl:param name="use.id.as.filename" select="1"/>

  <!-- Identifies the extension of generated HTML files  -->
  <xsl:param name="html.ext">.jsp</xsl:param>

  <!-- Should longdesc URIs be created? -->
  <xsl:param name="html.longdesc" select="0"/>

  <!-- Generate permalinks? -->
  <xsl:param name="generate.permalink" select="1"/>
  
  <!-- Do section labels include the component label? -->
  <xsl:param name="section.label.includes.component.label" select="1"/>
  
  <!-- Are sections enumerated? -->
  <xsl:param name="section.autolabel" select="1"/>
  
  <!-- Path to HTML/FO image files -->
  <xsl:param name="img.src.path">images/</xsl:param>
  
</xsl:stylesheet>