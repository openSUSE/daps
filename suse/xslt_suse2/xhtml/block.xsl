<?xml version="1.0" encoding="UTF-8"?>
<!-- 
   Purpose:
     Transform DocBook's block elements
     
   Author:    Thomas Schraitle <toms@opensuse.org>
   Copyright: 2012, Thomas Schraitle
     
-->
<xsl:stylesheet version="1.0"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:exsl="http://exslt.org/common"
    xmlns="http://www.w3.org/1999/xhtml"
    xmlns:t="http://nwalsh.com/docbook/xsl/template/1.0"
    xmlns:l="http://docbook.sourceforge.net/xmlns/l10n/1.0"
    exclude-result-prefixes="exsl l t">
  
  <xsl:template match="abstract">
    <div class="myownabstract">
      <xsl:call-template name="common.html.attributes"/>
      <xsl:call-template name="id.attribute"/>
      <xsl:call-template name="anchor"/>
      <!-- We are only interested in a "normal" pocessing, but suppress
        titles anyway
      -->
      <!--<xsl:call-template name="sidebar.titlepage"/>-->
      <xsl:apply-templates select="*[not(self::title)]"/>
    </div>
  </xsl:template>
  
</xsl:stylesheet>