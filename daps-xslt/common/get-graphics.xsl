<?xml version="1.0" encoding="utf-8"?>
<!--
   Purpose:
     Lists all graphics files that are included inside an imageobject. 
     It doesn't distinguish between different formats
     
   Parameters:
     * preferred.mediaobject.role (not implemented yet)
       
   
   Input:
     DocBook document
     
   Output:
     Text strings

   DocBook 5 compatible:
     yes

   Author:    Thomas Schraitle <toms@opensuse.org>
   Copyright (C) 2012-2015 SUSE Linux GmbH
   
-->


<xsl:stylesheet version="1.0"
  xmlns:d="http://docbook.org/ns/docbook"
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  exclude-result-prefixes="d">

<xsl:import href="rootid.xsl"/>

<xsl:output method="text" encoding="UTF-8"/>


<!-- 
  Contains the preferred format. Match with imageobject/@role
  The parameter can contain also an empty string. In this case,
  every graphic file located in mediaobject is returned.
-->
<xsl:param name="preferred.mediaobject.role">html</xsl:param>


<xsl:template match="text()"/>


<xsl:template match="imageobject[@role] | d:imageobject[@role]">
  <xsl:choose>
    <xsl:when test="$preferred.mediaobject.role = ''">
      <xsl:apply-templates/>
    </xsl:when>
    <xsl:when test="@role=$preferred.mediaobject.role">
      <xsl:apply-templates/>
    </xsl:when>
    <xsl:otherwise/>
  </xsl:choose>
</xsl:template>

<xsl:template match="imagedata|d:imagedata">
	<xsl:value-of select="concat(@fileref,' ')"/>
</xsl:template>

</xsl:stylesheet>
