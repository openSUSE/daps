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
   Copyright: 2015, Thomas Schraitle

-->
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                version="1.0">

<xsl:import href="base-profile.xsl"/>
<xsl:import href="../lib/create-doctype.xsl"/>
  

<xsl:template name="pre.rootnode">
  <xsl:apply-templates select="/processing-instruction('xml-stylesheet')" mode="profile"/>
  <xsl:call-template name="create.db45.doctype">
    <!--<xsl:with-param name="rootnode" select="local-name(/*)"/>-->
  </xsl:call-template>
</xsl:template>

</xsl:stylesheet>

