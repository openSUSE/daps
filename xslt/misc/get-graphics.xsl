<?xml version="1.0" encoding="utf-8"?>
<!--
 $Id: get-graphics.xsl 42943 2009-07-10 09:15:05Z toms $
-->

<!--
  This stylesheets lists all graphics files that are included
  inside an imageobject. It doesn't distinguish between
  different formats
-->

<xsl:stylesheet version="1.0"
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform">

<xsl:import href="rootid.xsl"/>

<xsl:output method="text" encoding="UTF-8"/>


<!-- 
  Contains the preferred format. Match with imageobject/@role
  The parameter can contain also an empty string. In this case,
  every graphic file located in mediaobject is returned.
-->
<xsl:param name="preferred.mediaobject.role">html</xsl:param>


<xsl:template match="text()"/>


<xsl:template match="imageobject[@role]">
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

<xsl:template match="imagedata">
	<xsl:value-of select="concat(@fileref,' ')"/>
</xsl:template>

</xsl:stylesheet>
