<?xml version="1.0" encoding="UTF-8"?>
<!--
   Purpose:
     Post process a DocBook document produced by AsciiDoc(tor)

   Parameters:
     None

   Input:
     A DocBook 5 document

   Output:
     Changed DocBook 5 document

     Currently, the following corrections are made:
     * simpara -> para
     * sidebar -> note
     * literallayout[@class='monospaced'] -> screen

   Author:    Thomas Schraitle <toms@opensuse.org>
   Copyright (C) 2018 SUSE Linux GmbH

-->
<!DOCTYPE xsl:stylesheet
[
   <!ENTITY db5ns "http://docbook.org/ns/docbook">
]>
<xsl:stylesheet version="1.0"
 xmlns:d="&db5ns;"
 xmlns="&db5ns;"
 xmlns:xsl="http://www.w3.org/1999/XSL/Transform">

 <xsl:import href="../common/copy.xsl"/>
 <xsl:output indent="yes"/>

 <xsl:template match="d:guibutton|d:guimenuitem|d:guisubmenu">
   <xsl:element name="guimenu" namespace="&db5ns;">
    <xsl:copy-of select="@*"/>
    <xsl:apply-templates/>
   </xsl:element>
 </xsl:template>

 <xsl:template match="d:sidebar">
   <xsl:element name="note" namespace="&db5ns;">
    <xsl:copy-of select="@*"/>
    <xsl:apply-templates/>
   </xsl:element>
 </xsl:template>

 <xsl:template match="d:simpara">
  <xsl:element name="para" namespace="&db5ns;">
   <xsl:copy-of select="@*"/>
   <xsl:apply-templates/>
  </xsl:element>
 </xsl:template>

 <xsl:template match="d:literallayout[@class='monospaced']|d:programlisting">
  <xsl:element name="screen" namespace="&db5ns;">
   <xsl:copy-of select="@*[local-name()!='class']"/>
   <xsl:apply-templates/>
  </xsl:element>
 </xsl:template>

<xsl:template match="d:imagedata">
 <xsl:copy>
  <xsl:copy-of select="@*[local-name() != 'contentwidth']"/>
  <xsl:choose>
   <xsl:when test="@width">
    <xsl:copy-of select="@width"/>
   </xsl:when>
   <xsl:otherwise>
    <xsl:attribute name="width">
     <xsl:value-of select="@contentwidth"/>
    </xsl:attribute>
   </xsl:otherwise>
  </xsl:choose>
 </xsl:copy>
</xsl:template>

</xsl:stylesheet>
