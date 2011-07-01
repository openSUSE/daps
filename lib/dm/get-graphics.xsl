<?xml version="1.0" encoding="utf-8"?>
<!--
 $Id: get-graphics.xsl 30264 2008-04-10 10:38:17Z toms $
-->

<!--
  This stylesheets lists all graphics files that are included
  inside an imageobject. It doesn't distinguish between
  different formats
-->

<xsl:stylesheet version="1.0"
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform">

<xsl:output method="text" encoding="ISO-8859-1"/>

<xsl:param name="rootid"/>

<!-- 
  Contains the preferred format. Match with imageobject/@role
  The parameter can contain also an empty string. In this case,
  every graphic file located in mediaobject is returned.
-->
<xsl:param name="preferred.mediaobject.role">html</xsl:param>

<xsl:key name="id" match="*" use="@id|@xml:id"/>


<xsl:template match="/">
  <xsl:choose>
    <xsl:when test="$rootid != ''">
      <xsl:choose>
        <xsl:when test="count(key('id',$rootid)) = 0">
          <xsl:message terminate="yes">
            <xsl:text>ID '</xsl:text>
            <xsl:value-of select="$rootid"/>
            <xsl:text>' not found in document.</xsl:text>
          </xsl:message>
        </xsl:when>
        <xsl:otherwise>
          <xsl:apply-templates select="key('id',$rootid)//imageobject" />
        </xsl:otherwise>
      </xsl:choose>
    </xsl:when>
    <xsl:otherwise>
      <xsl:apply-templates select="//imageobject"/>
    </xsl:otherwise>
  </xsl:choose>
  <xsl:text>&#10;</xsl:text>
</xsl:template>


<xsl:template match="*|text()"/>


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
