<?xml version="1.0" encoding="UTF-8"?>
<!--
   Purpose:
     Copies SVG document, but rewrite @style attribute to make it
     easier for other XSLT stylesheets to match for any style-related
     attributes
     
     For example, style="font-family:DejaVu-Sans;font-size:12pt" 
     is rewritten as single attributes 
     font-family="DejaVu-Sans" and font-size="12pt"
     
   Parameters:
     None
       
   Input:
     SVG document
     
   Output:
     SVG document without any @style attribute but with single
     attributes
   
   Author:    Thomas Schraitle <toms@opensuse.org>
   Copyright: 2012, Thomas Schraitle
   
-->
<!DOCTYPE xsl:stylesheet 
[
  <!ENTITY svgns "http://www.w3.org/2000/svg">
]>

<xsl:stylesheet version="1.0"
 xmlns:xsl="http://www.w3.org/1999/XSL/Transform" 
 xmlns:svg="&svgns;">

 <xsl:output method="xml" media-type="image/svg+xml"/>


 <xsl:template match="@*|node()" mode="svg">
  <xsl:copy>
   <xsl:apply-templates select="@*|node()" mode="svg"/>
  </xsl:copy>
 </xsl:template>


 <xsl:template name="extractsvgattributes">
  <xsl:param name="content"/>
  <xsl:param name="attnodes"/>
  
  <xsl:variable name="tail" select="substring-after($content, ':')"/>
  <xsl:variable name="head" select="substring-before($content, ':')"/>
  <xsl:variable name="attname" select="normalize-space($head)"/>
  
  <xsl:if test="$attname != ''">
   <xsl:choose>
    <!-- We don't want any style or attribute which starts with
       -inkscape...
    -->
    <xsl:when test="starts-with($attname, '-inkscape')"/>
    <xsl:when test="contains($tail, ';')">
     <xsl:attribute name="{$attname}">
      <xsl:value-of select="normalize-space(substring-before($tail, ';'))"/>
     </xsl:attribute>
     <!--  -->
     <xsl:call-template name="extractsvgattributes">
      <xsl:with-param name="content" select="substring-after($tail, ';')"/>
     </xsl:call-template>
    </xsl:when>
    <xsl:otherwise>
      <xsl:attribute name="{$attname}">
       <xsl:value-of select="$tail"/>
      </xsl:attribute>
    </xsl:otherwise>
   </xsl:choose>
  </xsl:if>
 </xsl:template>


 <xsl:template match="@style[parent::svg:*]" mode="svg"> 
  <xsl:call-template name="extractsvgattributes">
   <xsl:with-param name="content" select="normalize-space(.)"/>
  </xsl:call-template>
 </xsl:template>


 <xsl:template match="/">
  <xsl:comment> Created with svg.color2grayscale.xsl </xsl:comment>
  <xsl:apply-templates mode="svg"/>
 </xsl:template>

</xsl:stylesheet>
