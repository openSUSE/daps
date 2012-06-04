<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0"
  xmlns:exsl="http://exslt.org/common"
  xmlns="http://www.w3.org/1999/xhtml"
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  exclude-result-prefixes="exsl">
  
  <xsl:param name="base.dir">./drupal/html/</xsl:param>
  
  <xsl:param name="chunker.output.doctype-public"/>
  <xsl:param name="chunker.output.doctype-system"/>
  <xsl:param name="chunker.output.omit-xml-declaration" select="'yes'"/>
  
  <xsl:param name="img.src.path">images/</xsl:param>
  
  <xsl:param name="use.id.as.filename" select="1"/>
  
  <xsl:param name="generate.manifest" select="1"/>
  <xsl:param name="manifest.in.base.dir" select="1"/>
  
  
</xsl:stylesheet>