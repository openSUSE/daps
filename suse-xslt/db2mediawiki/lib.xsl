<?xml version="1.0" encoding="UTF-8"?>
<!-- $Id: lib.xsl 10194 2006-06-08 13:38:26Z toms $ -->
<xsl:stylesheet
	version="1.0"
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform">


<xsl:template name="hierarchy.level">
   <xsl:param name="node" select="."/>

   <xsl:choose>
     <xsl:when test="name($node)='chapter'">1</xsl:when>
     <xsl:when test="name($node)='appendix'">1</xsl:when>
     <xsl:when test="name($node)='sect1'">2</xsl:when>
     <xsl:when test="name($node)='sect2'">3</xsl:when>
     <xsl:when test="name($node)='sect3'">4</xsl:when>
     <xsl:when test="name($node)='sect4'">5</xsl:when>
     <xsl:otherwise>1</xsl:otherwise>
   </xsl:choose>

</xsl:template>


<xsl:template name="comment">
   <xsl:param name="text"/>

   <xsl:text>&lt;!--</xsl:text>
   <xsl:value-of select="$text"/>
   <xsl:text>--&gt;&#10;</xsl:text>
</xsl:template>


<xsl:template name="comment.with.title">
   <xsl:param name="node" select="."/>
   <xsl:call-template name="comment">
      <xsl:with-param name="text">
         <xsl:choose>
            <xsl:when test="$node/title">
               <xsl:value-of select="normalize-space($node/title)"/>
            </xsl:when>
            <xsl:when test="$node/subtitle">
               <xsl:value-of select="normalize-space($node/subtitle)"/>
            </xsl:when>
            <xsl:when test="$node/titleabbrev">
               <xsl:value-of select="normalize-space($node/titleabbrev)"/>
            </xsl:when>
            <xsl:when test="$node/info/title">
               <xsl:value-of select="normalize-space($node/info/title)"/>
            </xsl:when>
            <xsl:when test="$node/info/subtitle">
               <xsl:value-of select="normalize-space($node/info/subtitle)"/>
            </xsl:when>
            <xsl:when test="$node/info/titleabbrev">
               <xsl:value-of select="normalize-space($node/info/titleabbrev)"/>
            </xsl:when>
         </xsl:choose>
      </xsl:with-param>
   </xsl:call-template>
</xsl:template>


<xsl:template name="call.block.wikitemplate">
   <xsl:param name="template"/>
   <xsl:param name="content"/>

   <xsl:text>&#10;{{</xsl:text>
   <xsl:if test="$wiki.template.prefix">
      <xsl:value-of select="$wiki.template.prefix"/>
      <xsl:text>:</xsl:text>
   </xsl:if>
   <xsl:value-of select="$template"/>
   <xsl:text>|</xsl:text>
   <xsl:value-of select="$content"/>
   <xsl:text>}}&#10;</xsl:text>
</xsl:template>

<xsl:template name="call.inline.wikitemplate">
   <xsl:param name="template"/>
   <xsl:param name="content"/>

   <xsl:text>{{</xsl:text>
   <xsl:if test="$wiki.template.prefix">
      <xsl:value-of select="$wiki.template.prefix"/>
      <xsl:text>:</xsl:text>
   </xsl:if>
   <xsl:value-of select="$template"/>
   <xsl:text>|</xsl:text>
   <xsl:value-of select="$content"/>
   <xsl:text>}}</xsl:text>
</xsl:template>


<xsl:template name="create.wiki">
   <xsl:param name="node" select="."/>
   <xsl:param name="content" />

   <xsl:call-template name="call.inline.wikitemplate">
      <xsl:with-param name="template" select="name($node)"/>
      <xsl:with-param name="content" select="$content"/>
   </xsl:call-template>
</xsl:template>

</xsl:stylesheet>