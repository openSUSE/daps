<?xml version='1.0' encoding="UTF-8"?>
<!--
   Purpose:
     Extract language from @lang or @xml:lang attributes
     
   Parameters:
     * allowed.roots (string)
       String of allowed root elements, separated by spaces.
       Use the local name (without any namespace prefixes).
       
   Input:
     DocBook 4 or DocBook 5 documents with book, article, or
     chapter as root element.
     
   Output:
     String of the found language
      If the root element is not equal to book or book doesn't 
      contain a lang attribute, it will print an error.
   
   Author:    Thomas Schraitle <toms@opensuse.org>
   Copyright (C) 2012-2015 SUSE Linux GmbH
   
-->
<xsl:stylesheet version="1.0"
   xmlns:db="http://docbook.org/ns/docbook"
   xmlns:xsl="http://www.w3.org/1999/XSL/Transform">

<xsl:output method="text"/>

<xsl:param name="allowed.roots">appendix article bibliography book chapter
 glossary glossdiv part preface qandaset reference refsect1 refsect2 refsect3
 refsection sect1 sect2 sect3 sect4 sect5 section set</xsl:param>


<xsl:template match="/">
   <xsl:variable name="root" select="local-name(*[1])"/>
   <xsl:variable name="id" select="(*[1]/@xml:id|*[1]/@id)[1]"/>

   <xsl:choose>
     <xsl:when test="contains($allowed.roots, $root)">
       <xsl:apply-templates />
     </xsl:when>
     <xsl:otherwise>
       <xsl:message terminate="yes">
         <xsl:text>ERROR: Inappropriate root element! Allowed elements are:&#10;       </xsl:text>
         <xsl:value-of select="normalize-space($allowed.roots)"/>
         <xsl:text>&#10;       Found </xsl:text>
         <xsl:value-of select="name(*[1])"/>
         <xsl:if test="$id != ''">
          <xsl:text> with id=</xsl:text>
          <xsl:value-of select="$id"/>
         </xsl:if>
       </xsl:message>
     </xsl:otherwise>
   </xsl:choose>
</xsl:template>


<xsl:template match="/*">
 <xsl:variable name="lang" select="(@xml:lang|@lang)[1]"/>
   <xsl:choose>
    <xsl:when test="$lang != ''">
     <xsl:value-of select="$lang"/>
     <xsl:text>&#10;</xsl:text>
    </xsl:when>
    <xsl:otherwise>
     <xsl:message terminate="yes">ERROR: Element '<xsl:value-of select="name()"/>' doesn't contain attribute lang!</xsl:message>
    </xsl:otherwise>
   </xsl:choose>
</xsl:template>

</xsl:stylesheet>
