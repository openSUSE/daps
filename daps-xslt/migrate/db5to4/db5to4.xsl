<?xml version="1.0" encoding="UTF-8"?>
<!--
   Purpose:
     Migrate a DocBook5 document to DocBook4 (main stylesheet)

   Parameters:
     see param.xsl

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

  <xsl:import href="../../common/copy.xsl"/>
  <xsl:import href="param.xsl"/>

  <xsl:import href="db5to4-core.xsl"/>
  <xsl:import href="db5to4-info.xsl"/>
  <xsl:import href="pi.xsl"/>
  <xsl:import href="dm.xsl"/>
  <xsl:import href="block.xsl"/>
  <xsl:import href="inlines.xsl"/>

  <xsl:output indent="yes"/>

</xsl:stylesheet>