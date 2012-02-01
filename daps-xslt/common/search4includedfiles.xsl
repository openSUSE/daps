<?xml version="1.0" encoding="UTF-8"?>
<!--
   Purpose:
     Prints a list of files which are included by XIncludes, observing
     the @xml:base attribute and the rootid parameter     

   Parameters:
     * separator (default: " ")
       Split each filename with the content of this parameter
       
     * terminator (default: "\n")
       Terminate the list with the content of this parameter
     
     * rootid (imported)
       Applies stylesheet only to part of the document

   Input:
     DocBook 4/Novdoc document
     
   Output:
     Text, prints a list of (included) files separated by $separator
     and terminated by $terminator
   
   See also:
     * xml:base Specification
       http://www.w3.org/TR/xmlbase/
   
   Author:    Thomas Schraitle <toms@opensuse.org>
   Copyright: 2012, Thomas Schraitle
   
-->


<xsl:stylesheet version="1.0"
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:xi="http://www.w3.org/2001/XInclude"
  xmlns:xi3="http://www.w3.org/2003/XInclude">

<xsl:import href="rootid.xsl"/>
<xsl:output method="text"/>

<xsl:param name="separator"><xsl:text> </xsl:text></xsl:param>
<xsl:param name="terminator"><xsl:text>&#10;</xsl:text></xsl:param>


<xsl:template match="/">
  <xsl:apply-imports/>
  <xsl:value-of select="$terminator"/>
</xsl:template>


<xsl:template name="rootid.process">
  <xsl:apply-templates select="key('id',$rootid)" mode="xmlbase" />
</xsl:template>


<xsl:template name="normal.process">
  <xsl:apply-templates mode="xmlbase"/>
</xsl:template>


<xsl:template match="/"  mode="xmlbase">
   <xsl:apply-templates  mode="xmlbase"/>
</xsl:template>

<xsl:template match="*"  mode="xmlbase">
   <xsl:apply-templates select="@xml:base"  mode="xmlbase"/>
   <xsl:apply-templates  mode="xmlbase"/>
</xsl:template>

<xsl:template match="text()"  mode="xmlbase"/>

<xsl:template match="@xml:base"  mode="xmlbase">
   <xsl:value-of select="concat(., $separator)"/>
</xsl:template>

</xsl:stylesheet>