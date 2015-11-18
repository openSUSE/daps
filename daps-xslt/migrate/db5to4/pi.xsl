<?xml version="1.0" encoding="UTF-8"?>
<!--
   Purpose:
     Template rules for processing instructions

   Input:
     Valid DocBook5


   Author:    Thomas Schraitle <toms@opensuse.org>
   Copyright:  2015 SUSE Linux GmbH

-->
<xsl:stylesheet version="1.0"
  xmlns:d="http://docbook.org/ns/docbook"
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:xi="http://www.w3.org/2001/XInclude"
  xmlns:xlink="http://www.w3.org/1999/xlink"
  xmlns:html="http://www.w3.org/1999/xhtml"
  xmlns:exsl="http://exslt.org/common"
  exclude-result-prefixes="d xi xlink exsl html">

  <!-- =================================================================== -->
  <!--
    Copy root PI, but not PI below root
  -->
  <xsl:template match="/processing-instruction('xml-stylesheet')">
    <xsl:copy-of select="."/>
    <xsl:text>&#10;</xsl:text>
  </xsl:template>

  <xsl:template match="processing-instruction('xml-stylesheet')"/>

  <!-- Don't copy xml-model PI (mostly used by XML editors) -->
  <xsl:template match="/processing-instruction('xml-model')"/>

</xsl:stylesheet>