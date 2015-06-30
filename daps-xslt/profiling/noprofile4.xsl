<?xml version="1.0"?>
<!--
   Purpose:
     Copy all nodes

   Input:
     DocBook 4/Novdoc document

   Output:
     DocBook 4 document with DOCTYPE declaration for 4.5

   Author:    Thomas Schraitle <toms@opensuse.org>
   Copyright (C) 2015 SUSE Linux GmbH

-->
<xsl:stylesheet version="1.0"
                xmlns:xi="http://www.w3.org/2001/XInclude"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform">

<xsl:import href="../common/copy.xsl"/>
<xsl:import href="../lib/create-doctype.xsl"/>
<xsl:import href="xinclude-parse-text.xsl"/>

<xsl:template match="/">
  <xsl:copy-of select="/processing-instruction('xml-stylesheet')"/>
  <xsl:text>&#10;</xsl:text>
  <xsl:call-template name="create.db45.doctype"/>
  <xsl:apply-templates/>
</xsl:template>
  
  <!-- Rewrite only xi:include elements which contains parse='text' attribute.
       DAPS handles that and copies all relevant files
  -->
  <xsl:template match="xi:include[@parse='text']">
    <xsl:call-template name="xinclude-text"/>
  </xsl:template>

</xsl:stylesheet>

