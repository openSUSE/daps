<?xml version="1.0" encoding="UTF-8"?>
<!-- $Id: catalog_xml2sgml.xsl 2205 2005-10-06 07:32:50Z toms $ -->
<xsl:stylesheet version="1.0"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:cat="urn:oasis:names:tc:entity:xmlns:xml:catalog">

<xsl:output method="text"/>


<xsl:param name="use.xml.dcl" select="1"/>


<xsl:template match="/">
   <xsl:text>-- Catalog --&#10;</xsl:text>
   <xsl:apply-templates/>
</xsl:template>


<xsl:template match="cat:catalog">
   <xsl:text>OVERRIDE YES&#10;</xsl:text>
   <xsl:if test="$use.xml.dcl">
      <xsl:text>SGMLDECL "xml.dcl"&#10;</xsl:text>
   </xsl:if>
   <xsl:apply-templates/>
</xsl:template>


<xsl:template match="cat:public">
   <xsl:text>PUBLIC </xsl:text>
   <xsl:value-of select="concat('&quot;', @publicId, '&quot;&#10;')"/>
   <xsl:text>         "</xsl:text>
   <xsl:call-template name="correctURI">
      <xsl:with-param name="uri" select="@uri"/>
   </xsl:call-template>
   <xsl:text>"</xsl:text>
   <xsl:apply-templates/>
</xsl:template>


<xsl:template match="cat:*">
   <xsl:message>WARNING: No template rule for <xsl:value-of select="local-name(.)"/>!</xsl:message>
</xsl:template>


<xsl:template match="cat:system">
   <xsl:text>SYSTEM </xsl:text>
   <xsl:value-of select="concat('&quot;', @systemId, '&quot;&#10;')"/>
   <xsl:text>       "</xsl:text>
   <xsl:call-template name="correctURI">
      <xsl:with-param name="uri" select="@uri"/>
   </xsl:call-template>
   <xsl:text>"</xsl:text>
   <xsl:apply-templates/>
</xsl:template>


<xsl:template match="cat:group">
   <xsl:if test="@xml:base">
      <xsl:text>BASE </xsl:text>
      <xsl:text>     "</xsl:text>
      <xsl:call-template name="correctURI">
         <xsl:with-param name="uri" select="@uri"/>
      </xsl:call-template>
      <xsl:text>"</xsl:text>
   </xsl:if>
   <xsl:apply-templates/>
</xsl:template>


<xsl:template match="cat:nextCatalog">
   <xsl:text>CATALOG </xsl:text>
   <xsl:text>        "</xsl:text>
   <xsl:call-template name="correctURI">
      <xsl:with-param name="uri" select="@catalog"/>
   </xsl:call-template>
   <xsl:text>"</xsl:text>

   <xsl:apply-templates/>
</xsl:template>


<xsl:template name="correctURI">
   <xsl:param name="uri" />

   <xsl:choose>
      <xsl:when test="starts-with(@uri, 'file://')">
         <xsl:value-of select="substring-after(@uri, 'file://')"/>
      </xsl:when>
      <xsl:when test="starts-with(@uri, 'file:')">
         <xsl:value-of select="substring-after(@uri, 'file:')"/>
      </xsl:when>
<!--      <xsl:when test="starts-with(@uri, 'http://')">
         <xsl:value-of select="substring-after(@uri, 'file://')"/>
      </xsl:when>-->
      <xsl:otherwise>
         <xsl:value-of select="@uri"/>
      </xsl:otherwise>
   </xsl:choose>
</xsl:template>

</xsl:stylesheet>