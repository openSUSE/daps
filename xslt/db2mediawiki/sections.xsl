<?xml version="1.0" encoding="UTF-8"?>
<!-- $Id: sections.xsl 6597 2006-02-27 07:45:20Z toms $ -->
<xsl:stylesheet version="1.0"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:fo="http://www.w3.org/1999/XSL/Format"
>


<xsl:template name="section.heading">
   <xsl:text>&#10;</xsl:text>
   <xsl:apply-templates mode="title"/>
   <xsl:if test="@id and $add.id.as.comments">
      <xsl:call-template name="comment">
         <xsl:with-param name="text" select="concat('id=', @id)"/>
      </xsl:call-template>
   </xsl:if>
</xsl:template>

<xsl:template match="*|text()" mode="title"/>

<!-- *********************************************************** -->

<xsl:template match="sect1">
   <xsl:call-template name="section.heading"/>
   <xsl:apply-templates/>
</xsl:template>

<xsl:template match="sect1" mode="wiki">
   <xsl:call-template name="section.heading"/>
   <xsl:apply-templates mode="wiki"/>
</xsl:template>

<xsl:template match="sect1/title"/>
<xsl:template match="sect1/title" mode="wiki"/>

<xsl:template match="sect1/title" mode="title" name="sect1title">
   <xsl:text>&#10;=</xsl:text>
   <xsl:value-of select="normalize-space(.)"/>
   <xsl:text>=&#10;</xsl:text>
</xsl:template>


<!-- *********************************************************** -->

<xsl:template match="sect2">
   <xsl:call-template name="section.heading"/>
   <xsl:apply-templates />
</xsl:template>

<xsl:template match="sect2" mode="wiki">
   <xsl:call-template name="section.heading"/>
   <xsl:apply-templates mode="wiki"/>
</xsl:template>

<xsl:template match="sect2/title"/>
<xsl:template match="sect2/title" mode="wiki"/>

<xsl:template match="sect2/title" mode="title" name="sect2title">
   <xsl:text>&#10;==</xsl:text>
   <xsl:value-of select="normalize-space(.)"/>
   <xsl:text>==&#10;</xsl:text>
</xsl:template>


<!-- *********************************************************** -->

<xsl:template match="sect3">
   <xsl:call-template name="section.heading"/>
   <xsl:apply-templates />
</xsl:template>

<xsl:template match="sect3" mode="wiki">
   <xsl:call-template name="section.heading"/>
   <xsl:apply-templates mode="wiki"/>
</xsl:template>

<xsl:template match="sect3/title"/>
<xsl:template match="sect3/title" mode="wiki"/>

<xsl:template match="sect3/title" mode="title" name="sect3title">
   <xsl:text>&#10;===</xsl:text>
   <xsl:value-of select="normalize-space(.)"/>
   <xsl:text>===&#10;</xsl:text>
</xsl:template>


<!-- *********************************************************** -->

<xsl:template match="sect4">
   <xsl:call-template name="section.heading"/>
   <xsl:apply-templates />
</xsl:template>

<xsl:template match="sect4" mode="wiki">
   <xsl:call-template name="section.heading"/>
   <xsl:apply-templates mode="wiki"/>
</xsl:template>

<xsl:template match="sect4/title"/>
<xsl:template match="sect4/title" mode="wiki"/>

<xsl:template match="sect4/title" mode="title" name="sect4title">
   <xsl:text>&#10;====</xsl:text>
   <xsl:value-of select="normalize-space(.)"/>
   <xsl:text>====&#10;</xsl:text>
</xsl:template>

<!-- *********************************************************** -->
<xsl:template match="bridgehead">
   <xsl:variable name="anc" select="ancestor::sect1|
                                    ancestor::sect2|
                                    ancestor::sect3|
                                    ancestor::sect4"/>
   <xsl:choose>
      <xsl:when test="$anc[sect4]">
         <xsl:call-template name="sect4title"/>
      </xsl:when>
      <xsl:when test="$anc[sect3]">
         <xsl:call-template name="sect3title"/>
      </xsl:when>
      <xsl:when test="$anc[sect2]">
         <xsl:call-template name="sect2title"/>
      </xsl:when>
      <xsl:when test="$anc[sect1]">
         <xsl:call-template name="sect1title"/>
      </xsl:when>
      <xsl:otherwise>
         <xsl:message>WARNING: I do not know how to render this bridgehead with id="<xsl:value-of
            select="@id"/>"</xsl:message>
         <xsl:value-of select="."/>
      </xsl:otherwise>
   </xsl:choose>
   <xsl:if test="@id and $add.id.as.comments">
      <xsl:call-template name="comment">
         <xsl:with-param name="text" select="concat('id=', @id)"/>
      </xsl:call-template>
   </xsl:if>
</xsl:template>

</xsl:stylesheet>
