<?xml version="1.0" encoding="UTF-8"?>
<!-- $Id: division.xsl 10194 2006-06-08 13:38:26Z toms $ -->
<xsl:stylesheet
	version="1.0"
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform">


<xsl:template match="set">
   <xsl:apply-templates/>
</xsl:template>

<xsl:template match="set" mode="wiki">
   <xsl:apply-templates mode="wiki"/>
</xsl:template>


<xsl:template match="book">
   <xsl:call-template name="comment.with.title">
     <xsl:with-param name="node" select="self::book"/>
   </xsl:call-template>
   <xsl:apply-templates/>
</xsl:template>

<xsl:template match="book" mode="wiki">
   <xsl:call-template name="comment.with.title">
     <xsl:with-param name="node" select="self::book"/>
   </xsl:call-template>
   <xsl:apply-templates mode="wiki"/>
</xsl:template>


<xsl:template match="bookinfo"/>
<xsl:template match="bookinfo" mode="wiki"/>


<xsl:template match="part">
   <xsl:apply-templates/>
</xsl:template>
<xsl:template match="part/title"/>

<xsl:template match="part" mode="wiki">
   <xsl:apply-templates mode="wiki"/>
</xsl:template>
<xsl:template match="part/title" mode="wiki"/>



<xsl:template match="chapter|appendix">
   <xsl:if test="@id and $add.id.as.comments">
      <xsl:call-template name="comment">
        <xsl:with-param name="node" select="@id"/>
      </xsl:call-template>
   </xsl:if>
   <xsl:apply-templates/>
   <xsl:text>&#10;</xsl:text>
</xsl:template>

<xsl:template match="chapter|appendix" mode="wiki">
   <xsl:if test="@id and $add.id.as.comments">
      <xsl:call-template name="comment">
        <xsl:with-param name="node" select="@id"/>
      </xsl:call-template>
   </xsl:if>
   <xsl:apply-templates mode="wiki"/>
   <xsl:text>&#10;</xsl:text>
</xsl:template>


<xsl:template match="chapter/title|appendix/title"/>
<xsl:template match="chapter/title|appendix/title" mode="wiki"/>


<xsl:template match="article">
   <xsl:if test="@id and $add.id.as.comments">
      <xsl:call-template name="comment">
        <xsl:with-param name="node" select="@id"/>
      </xsl:call-template>
   </xsl:if>
   <xsl:apply-templates/>
   <xsl:text>&#10;</xsl:text>
</xsl:template>

<xsl:template match="article" mode="wiki">
   <xsl:if test="@id and $add.id.as.comments">
      <xsl:call-template name="comment">
        <xsl:with-param name="node" select="@id"/>
      </xsl:call-template>
   </xsl:if>
   <xsl:apply-templates mode="wiki"/>
   <xsl:text>&#10;</xsl:text>
</xsl:template>


<xsl:template match="abstract">
   <xsl:param name="content">
      <xsl:apply-templates/>
   </xsl:param>

   <xsl:value-of select="normalize-space($content)"/>
</xsl:template>

<xsl:template match="abstract" mode="wiki">
   <xsl:param name="content">
      <xsl:apply-templates mode="wiki"/>
   </xsl:param>

   <xsl:value-of select="normalize-space($content)"/>
</xsl:template>


</xsl:stylesheet>