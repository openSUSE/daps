<?xml version="1.0" encoding="UTF-8"?>
<!--
   Purpose:
     Lists all xrefs that point to another book in the set
     
   Parameters:
     * rootid
       Applies stylesheet only to part of the document
       
   Input:
     DocBook 4/Novdoc document
     
   Output:
     Text, in the following format:
       xref: linkend=X title=Y
     Whereas X and Y are placeholders for the respective content
   
   Author:    Thomas Schraitle <toms@opensuse.org>
   Copyright (C) 2012-2015 SUSE Linux GmbH
   
-->

<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0">


<xsl:import href="rootid.xsl"/>
<xsl:output method="text"/>

<!--<xsl:template match="*"/>-->
<xsl:template match="text()"/>


<xsl:template match="xref">
  <xsl:variable name="targets" select="key('id',@linkend)"/>
  <xsl:variable name="target" select="$targets[1]"/>
  <xsl:variable name="refelem" select="local-name($target)"/>
  <xsl:variable name="target.book" select="$target/ancestor-or-self::book"/>
  <xsl:variable name="this.book" select="ancestor-or-self::book"/>

  <xsl:choose>
    <xsl:when test="(generate-id($target.book) = generate-id($this.book)) or
                     not(/set) or /article">
      <!-- the default -->
    </xsl:when>
    <xsl:otherwise>
      <xsl:text>xref: linkend=</xsl:text>
      <xsl:value-of select="@linkend"/>
      <xsl:text> title=</xsl:text>
      <xsl:value-of select="normalize-space($target/title)"/>
      <xsl:text>&#10;</xsl:text>
      <!--<xsl:message>xref: linkend="<xsl:value-of 
      select="@linkend"/>" title=»<xsl:value-of 
      select="normalize-space($target/title)"/>« </xsl:message> -->     
    </xsl:otherwise>
  </xsl:choose>

</xsl:template>

</xsl:stylesheet>
