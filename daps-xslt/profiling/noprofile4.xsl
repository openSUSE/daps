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
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform">

<xsl:import href="../common/copy.xsl"/>
<xsl:import href="../lib/create-doctype.xsl"/>
  

<xsl:template match="/">
  <xsl:copy-of select="/processing-instruction('xml-stylesheet')"/>
  <xsl:text>&#10;</xsl:text>
  <xsl:call-template name="create.db45.doctype"/>
  <xsl:apply-templates/>
</xsl:template>

</xsl:stylesheet>

