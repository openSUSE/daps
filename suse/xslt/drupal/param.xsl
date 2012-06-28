<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0"
  xmlns:exsl="http://exslt.org/common"
  xmlns="http://www.w3.org/1999/xhtml"
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  exclude-result-prefixes="exsl">
  
  <xsl:import href="../xhtml/param.xsl"/>
  
  <!--<xsl:param name="base.dir"/>-->
  
  <xsl:param name="chunker.output.doctype-public"/>
  <xsl:param name="chunker.output.doctype-system"/>
  <xsl:param name="chunker.output.omit-xml-declaration" select="'yes'"/>
  
  <!-- That is done in Drupal -->
  <xsl:param name="suppress.footer.navigation" select="1"/>
  <xsl:param name="suppress.header.navigation" select="1"/>

  <!-- Don't use admon graphics -->
  <xsl:param name="admon.graphics" select="0"/>
  <!--
  <xsl:param name="callout.unicode" select="1"/>
  <xsl:param name="callout.graphics" select="0"/>
  -->
  
</xsl:stylesheet>