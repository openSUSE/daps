<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0"
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:exsl="http://exslt.org/common"
  xmlns:exslt="http://exslt.org/common"
  xmlns="http://www.w3.org/1999/xhtml"
  exclude-result-prefixes="exsl exslt">
  
  <xsl:import href="docbook.xsl"/>
  <xsl:import href="http://docbook.sourceforge.net/release/xsl/current/xhtml/chunk-common.xsl"/>
  
    <xsl:output method="xml" 
    encoding="UTF-8" 
    indent="no"
    omit-xml-declaration="yes"
    doctype-public="-//W3C//DTD XHTML 1.0 Strict//EN" 
    doctype-system="http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd"/>


  <!-- chunk-code.xsl contains all the chunking templates that use
     a match attribute.  In a customization it should be referenced
     using <xsl:include> instead of <xsl:import>, and then add
     any customized chunking templates with match attributes. But be sure
     to add a priority="1" to such customized templates to resolve
     its conflict with the original, since they have the
     same import precedence.
     
     Using xsl:include prevents adding another layer
     of import precedence, which would cause any
     customizations that use xsl:apply-imports to wrongly
     apply the chunking version instead of the original
     non-chunking version to format an element.  -->

  <xsl:include href="http://docbook.sourceforge.net/release/xsl/current/xhtml/chunk-code.xsl"/>
  <xsl:include href="../xhtml/navig.header.footer.xsl"/>
  
</xsl:stylesheet>