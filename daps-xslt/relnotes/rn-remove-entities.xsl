<?xml version="1.0" encoding="UTF-8"?>
<!--
   Gets rid of entities in a DocBook file.

   Authors:   Thomas Schraitle <toms@opensuse.org>,
              Stefan Knorr <sknorr@suse.de>
   Copyright (C) 2012-2015 SUSE Linux GmbH
   
-->

<xsl:stylesheet 
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:exslt="http://exslt.org/common"
  version="1.0"
  exclude-result-prefixes="exslt">

  <xsl:output method="xml" indent="yes" encoding="UTF-8"/>

  <!-- Are the following two lines necessary? -->
  <xsl:strip-space elements="*"/>
  <xsl:preserve-space elements="screen computeroutput literallayout programlisting synopsis userinput"/>


  <!-- Change these parameters on the command line to adapt the file type/referenced entity file. -->
  <xsl:param name="target-xml-language" select="'&quot;-//OASIS//DTD DocBook XML V4.5//EN&quot; &quot;http://www.oasis-open.org/docbook/xml/4.5/docbookx.dtd&quot;'"/>
  <xsl:param name="entity-file" select="'release-notes.ent'"/>



  <xsl:template match="/">
    <xsl:text disable-output-escaping="yes">&lt;!DOCTYPE </xsl:text>
    <xsl:value-of select="local-name(/*[1])"/>
    <xsl:text disable-output-escaping="yes"> PUBLIC </xsl:text>
    <xsl:value-of select="$target-xml-language"/>
    <xsl:text disable-output-escaping="yes">
[
  &lt;!ENTITY % NOVDOC.DEACTIVATE.IDREF "INCLUDE">
  &lt;!ENTITY % entities SYSTEM "</xsl:text>
     <xsl:value-of select="$entity-file"/>
     <xsl:text disable-output-escaping="yes">">
  %entities;
]>
</xsl:text>
    <xsl:apply-templates/>
  </xsl:template>

<xsl:template match="node()">
  <xsl:copy>
    <!-- FIXME: Can we copy the attributes in any simpler way? -->
    <xsl:if test="@*">
      <xsl:copy-of select="@*"/>
    </xsl:if>
    <xsl:apply-templates/>
  </xsl:copy>
</xsl:template>

</xsl:stylesheet>
