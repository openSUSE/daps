<?xml version="1.0" encoding="UTF-8"?>
<!--
   Purpose:
     Create a grayscale version of a color SVG.

   Parameters:
     * colornames.filename (default: "colornames.xml")
       Contains names and RGB values of colors

   Input:
     SVG document

   Output:
     Grayscale SVG document

   Author:    Thomas Schraitle <toms@opensuse.org>
   Copyright (C) 2012-2016 SUSE Linux GmbH

-->

<xsl:stylesheet version="1.0"
 xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
 xmlns:math="http://xsltsl.org/math"
 xmlns:svg="http://www.w3.org/2000/svg"
 xmlns:exsl="http://exslt.org/common"
 xmlns:c="http://www.suse.de/ns/colornames"
 exclude-result-prefixes="exsl c math">

 <xsl:import href="../common/math.xsl"/>
 <xsl:import href="svg2svg.xsl"/>

 <xsl:output method="xml" cdata-section-elements="svg:style"/>

 <xsl:param name="colornames.filename">colornames.xml</xsl:param>
 <xsl:variable name="color.nodes" select="document($colornames.filename)/*/*"/>

 <xsl:template name="color2gray">
  <xsl:param name="color" select="."/>

  <xsl:variable name="hexvalue">
   <xsl:call-template name="math:cvt-decimal-hex">
    <xsl:with-param name="value">
     <xsl:choose>
      <xsl:when test="string-length($color) = 3">
       <xsl:call-template name="medianfromhex">
        <xsl:with-param name="delimiter" select="1"/>
        <xsl:with-param name="hexvalue" select="$color"/>
       </xsl:call-template>
      </xsl:when>
      <xsl:otherwise>
       <xsl:call-template name="medianfromhex">
        <xsl:with-param name="delimiter" select="2"/>
        <xsl:with-param name="hexvalue" select="$color"/>
       </xsl:call-template>
      </xsl:otherwise>
     </xsl:choose>
    </xsl:with-param>
   </xsl:call-template>
  </xsl:variable>

  <xsl:value-of select="concat('#', $hexvalue, $hexvalue, $hexvalue)"/>
 </xsl:template>


 <xsl:template name="medianfromhex">
  <xsl:param name="hexvalue"/>
  <xsl:param name="delimiter" select="2"/>

  <xsl:variable name="first">
   <xsl:call-template name="math:cvt-hex-decimal">
    <xsl:with-param name="value"
     select="substring($hexvalue, 1, $delimiter)"/>
   </xsl:call-template>
  </xsl:variable>
  <xsl:variable name="second">
   <xsl:call-template name="math:cvt-hex-decimal">
    <xsl:with-param name="value"
     select="substring($hexvalue, $delimiter+1, $delimiter)"/>
   </xsl:call-template>
  </xsl:variable>
  <xsl:variable name="third">
   <xsl:call-template name="math:cvt-hex-decimal">
    <xsl:with-param name="value"
     select="substring($hexvalue, 2*$delimiter+1, $delimiter)"/>
   </xsl:call-template>
  </xsl:variable>

  <xsl:value-of select="floor(($first + $second + $third) div 3)"/>

 </xsl:template>

 <xsl:template match="@*|node()">
  <xsl:copy>
   <xsl:apply-templates select="@*|node()"/>
  </xsl:copy>
 </xsl:template>

 <xsl:template match="/">
  <xsl:if test="not(function-available('exsl:node-set'))">
   <xsl:message terminate="yes">color2gray.xsl: EXSLT function node-set not
    available!</xsl:message>
  </xsl:if>
  <xsl:variable name="svg">
   <xsl:apply-templates mode="svg"/>
  </xsl:variable>

  <xsl:comment> This SVG file was converted from color to gray </xsl:comment>
  <xsl:comment> with svg.color2grayscale.xsl                   </xsl:comment>
  <xsl:apply-templates select="exsl:node-set($svg)/*"/>

 </xsl:template>

 <xsl:template match="@fill|@stroke">

  <xsl:choose>
   <xsl:when test=". = 'none'">
    <xsl:attribute name="{name()}">none</xsl:attribute>
   </xsl:when>
    <xsl:when test="starts-with(., 'url(')">
      <xsl:attribute name="{name()}">
        <xsl:value-of select="."/>
      </xsl:attribute>
    </xsl:when>
   <xsl:when test="starts-with(., '#')">
    <xsl:attribute name="{name()}">
     <xsl:call-template name="color2gray">
      <xsl:with-param name="color" select="substring(., 2)"/>
     </xsl:call-template>
    </xsl:attribute>
   </xsl:when>
    <xsl:when test="starts-with(., 'rgb(')">
      <!-- 
         Procedure:
         1. Get a normalized string from the attribute
         2. Throw away the 'rgb(' and ')'
         3. Extract the first, second, and third values
         4. Calculate the mean value: sum all three values and divide it
            through 3
         5. Create the attribute
      -->
      <xsl:variable name="norm" select="normalize-space(.)"/>
      <xsl:variable name="values" 
                    select="substring($norm,
                            5, string-length($norm) -5)"/>
      <xsl:variable name="first" select="substring-before($values, ',')"/>
      <xsl:variable name="x" select="normalize-space(substring-after($values, ','))"/>
      <xsl:variable name="second" select="substring-before($x, ',')" />
      <xsl:variable name="third" select="normalize-space(substring-after($x, ','))" />

      <!-- Extract the percent value, if found
          TODO: Maybe output a warning/error when no percent sign is
          found? What expects the SVG or CSS specification(s)?
      -->
      <xsl:variable name="_f">
        <xsl:choose>
          <xsl:when test="contains($first, '%')">
            <xsl:value-of select="substring-before($first, '%')"/>
          </xsl:when>
          <xsl:otherwise>
            <xsl:value-of select="$first"/>
          </xsl:otherwise>
        </xsl:choose>        
      </xsl:variable>
      <xsl:variable name="_s">
        <xsl:choose>
          <xsl:when test="contains($second, '%')">
            <xsl:value-of select="substring-before($second, '%')"/>
          </xsl:when>
          <xsl:otherwise>
            <xsl:value-of select="$second"/>
          </xsl:otherwise>
        </xsl:choose>        
      </xsl:variable>
      <xsl:variable name="_t">
        <xsl:choose>
          <xsl:when test="contains($third, '%')">
            <xsl:value-of select="substring-before($third, '%')"/>
          </xsl:when>
          <xsl:otherwise>
            <xsl:value-of select="$third"/>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:variable>
      
      <xsl:variable name="mean" select="concat((($_f + $_s + $_t) div 3)
        , '%')"/>

      <!--<xsl:message>fill with "<xsl:value-of select="."/>"
        values = '<xsl:value-of select="$values"/>'
        first  = '<xsl:value-of select="$first"/>' '<xsl:value-of
          select="$_f"/>'
        second = '<xsl:value-of select="$second"/>' '<xsl:value-of
          select="$_s"/>'     
        third  = '<xsl:value-of select="$third"/>' '<xsl:value-of
        select="$_t"/>'
        mean = '<xsl:value-of select="$mean"/>'
      </xsl:message>-->

      <xsl:attribute name="{name()}">
        <xsl:text>rgb(</xsl:text>
        <xsl:value-of select="concat($mean, ',', $mean, ',', $mean)"/>
        <xsl:text>)</xsl:text>
     </xsl:attribute>
    </xsl:when>
   <xsl:otherwise>
     <xsl:attribute name="{name()}">
     <xsl:choose>
       <xsl:when test="$color.nodes[@name=current()]/@grayvalue != ''">
           <xsl:text>#</xsl:text>
           <xsl:value-of select="$color.nodes[@name=current()]/@grayvalue"/>
       </xsl:when>
       <xsl:otherwise>
         <xsl:value-of select="."/>
       </xsl:otherwise>
     </xsl:choose>
     </xsl:attribute>
   </xsl:otherwise>
  </xsl:choose>
 </xsl:template>

</xsl:stylesheet>
