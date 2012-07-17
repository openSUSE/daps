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
  
  <!-- Should I generate breadcrumbs navigation?  -->
  <xsl:param name="generate.breadcrumbs" select="1"/>
  <!-- Separator between separate links: -->
  <xsl:param name="breadcrumbs.separator"> &gt; </xsl:param>
  <!-- Should I generate breadcrumbs navigation?  -->
  <xsl:param name="generate.bgnavi" select="1"/>
  <!-- Navigation "Icons" for breadcrumbs: -->
  <xsl:param name="breadcrumbs.prev">&#9664;<!--&#9668;--></xsl:param>
  <xsl:param name="breadcrumbs.next">&#9654;<!--&#9658;--></xsl:param>
  <!-- Should information from SVN properties be used? yes|no -->
  <xsl:param name="use.meta" select="0"/>
  
</xsl:stylesheet>