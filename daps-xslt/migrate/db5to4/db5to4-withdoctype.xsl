<?xml version="1.0" encoding="UTF-8"?>
<!--
   Purpose:
     Migrate a DocBook5 document to DocBook4 (main stylesheet with outputs
     the DOCTYPE declaration)

   Parameters:
     see param.xsl

   Input:
     Valid DocBook5

   Author:    Thomas Schraitle <toms@opensuse.org>
   Copyright:  2015 SUSE Linux GmbH

-->
<xsl:stylesheet version="1.0"
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform">

  <xsl:import href="db5to4.xsl"/>
  <xsl:output
    doctype-public="-//OASIS//DTD DocBook XML V4.5//EN"
    doctype-system="http://www.docbook.org/xml/4.5/docbookx.dtd"/>

</xsl:stylesheet>