<?xml version="1.0"?>
<!--
   Purpose:
     Creates DOCTYPE header manually

   Input:
     DocBook 4/5 document

   Output:
     DocBook 4/5 document with PI *before* DOCTYPE declaration
     (needed due to a bug in xsltproc)

   Author:    Thomas Schraitle <toms@opensuse.org>
   Copyright (C) 2012-2015 SUSE Linux GmbH

-->
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                version="1.0">

<xsl:import href="base-profile.xsl"/>
<xsl:import href="../lib/create-doctype.xsl"/>
  

<xsl:template name="pre.rootnode">
  <xsl:copy-of select="/processing-instruction('xml-stylesheet')"/>
  <xsl:text>&#10;</xsl:text>
  <xsl:call-template name="create.db45.doctype"/>
</xsl:template>


<xsl:template match="/processing-instruction('xml-stylesheet')"
              name="xml-stylesheet"
              mode="profile" />


</xsl:stylesheet>

