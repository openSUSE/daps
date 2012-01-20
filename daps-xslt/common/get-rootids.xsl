<?xml version="1.0" encoding="ISO-8859-1"?>
<!-- $Id: get-rootids.xsl 42941 2009-07-10 08:58:10Z toms $ -->
<xsl:stylesheet
    version="1.0"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform">

<xsl:import href="rootid.xsl"/>

<xsl:output method="text"/>

<xsl:template match="*"/>
<xsl:template match="text()"/>


<xsl:template match="set|article|book|part">
   <xsl:apply-templates />
</xsl:template>


<xsl:template match="chapter|appendix|preface|glossary">
   <xsl:call-template name="getid"/>
   <xsl:apply-templates />
</xsl:template>


<!-- ****************************************** -->
<xsl:template name="getid">
   <xsl:param name="node" select="."/>

   <xsl:choose>
      <xsl:when test="$node/@id">
         <xsl:value-of select="$node/@id"/>
         <xsl:text> </xsl:text>
      </xsl:when>
      <xsl:otherwise>
         <xsl:message> WARNING: <xsl:value-of select="name($node)"/> doesn't contain an id attribute!</xsl:message>
      </xsl:otherwise>
   </xsl:choose>
</xsl:template>


</xsl:stylesheet>
