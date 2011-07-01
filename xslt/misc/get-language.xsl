<?xml version='1.0' encoding="ISO-8859-1"?>
<!-- $Id: -->
<xsl:stylesheet version="1.0"
   xmlns:xsl="http://www.w3.org/1999/XSL/Transform">

<!--
    Prints the language of element book.
    If root element is not equal book or book doesn't contain a
    lang attribute, it will print an error.
-->

<xsl:output method="text"/>

<xsl:template match="/">
   <xsl:choose>
     <xsl:when test="book or article or set or chapter">
       <xsl:apply-templates select="book|article|set"/>
     </xsl:when>
     <xsl:otherwise>
       <xsl:message terminate="yes">
         <xsl:text>ERROR: Root Element is not a set, book, article or chapter!&#10;</xsl:text>
         <xsl:text>       Found </xsl:text>
         <xsl:value-of select="name(*[1])"/>
       </xsl:message>
     </xsl:otherwise>
   </xsl:choose>
</xsl:template>

<xsl:template match="book|article|set|chapter">
   <xsl:choose>
    <xsl:when test="@lang">
     <xsl:value-of select="@lang"/>
     <xsl:text>&#10;</xsl:text>
    </xsl:when>
    <xsl:otherwise>
     <xsl:message terminate="yes">ERROR: Element '<xsl:value-of select="name()"/>' doesn't contain attribute lang!</xsl:message>
    </xsl:otherwise>
   </xsl:choose>
</xsl:template>


</xsl:stylesheet>
