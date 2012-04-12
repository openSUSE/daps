<?xml version="1.0" encoding="UTF-8"?>
<!-- $Id: fonts.xsl 2362 2005-11-21 14:12:00Z toms $ -->
<xsl:stylesheet version="1.0"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:fo="http://www.w3.org/1999/XSL/Format"
>


<xsl:attribute-set name="article.titlepage.recto.style">
  <xsl:attribute name="text-align">left</xsl:attribute>
  <xsl:attribute name="color">
    <xsl:value-of select="$flyer.color"/>
  </xsl:attribute>
  <xsl:attribute name="font-family">
    <xsl:value-of select="$sans.font.family"/>
  </xsl:attribute>
  <xsl:attribute name="font-weight">normal</xsl:attribute>
</xsl:attribute-set>

<xsl:attribute-set name="article.subtitlepage.recto.style"
                   use-attribute-sets="article.titlepage.recto.style">
</xsl:attribute-set>


<xsl:attribute-set name="abstract.titlepage.recto.style">
   <xsl:attribute name="margin-left">3em</xsl:attribute>
   <xsl:attribute name="margin-right">3em</xsl:attribute>
   <xsl:attribute name="space-after">2em</xsl:attribute>
</xsl:attribute-set>


<xsl:attribute-set name="copyright.flyer.properties">
   <xsl:attribute name="font-size">
     <xsl:value-of select="$body.font.master div ( 1.2 * 1.2 )"/>
     <xsl:text>pt</xsl:text>
   </xsl:attribute>
   <xsl:attribute name="text-align">left</xsl:attribute>
</xsl:attribute-set>

<xsl:attribute-set name="section.title.properties">
  <xsl:attribute name="hyphenate">false</xsl:attribute>
  <xsl:attribute name="color">
    <xsl:value-of select="$flyer.color"/>
  </xsl:attribute>
</xsl:attribute-set>

<xsl:attribute-set name="section.title.level1.properties">
   <xsl:attribute name="font-size">
     <xsl:value-of select="$body.font.master * 1.2 * 1.2"/>
     <xsl:text>pt</xsl:text>
   </xsl:attribute>
   <xsl:attribute name="space-after.optimum">0.25em</xsl:attribute>
   <xsl:attribute name="space-after.precedence">1</xsl:attribute>
</xsl:attribute-set>

<xsl:attribute-set name="section.title.level2.properties">
   <xsl:attribute name="font-size">
     <xsl:value-of select="$body.font.master *1.2"/>
     <xsl:text>pt</xsl:text>
   </xsl:attribute>
   <xsl:attribute name="font-variant">small-caps</xsl:attribute>
   <xsl:attribute name="space-after.optimum">0.25em</xsl:attribute>
   <xsl:attribute name="space-after.precedence">1</xsl:attribute>
</xsl:attribute-set>

<xsl:attribute-set name="refsect1.titlepage.recto.style">
  <xsl:attribute name="border-top">
    <xsl:text>2pt solid </xsl:text>
    <xsl:value-of select="$flyer.color"/>
  </xsl:attribute>
  <xsl:attribute name="padding-top">-5pt</xsl:attribute>
  <!--<xsl:attribute name="color">white</xsl:attribute>-->
  <!--<xsl:attribute name="background-color">
    <xsl:text>gray</xsl:text>
  </xsl:attribute>-->
  <xsl:attribute name="space-before">1.5em</xsl:attribute>
  <xsl:attribute name="space-after.precedence">2</xsl:attribute>
</xsl:attribute-set>

<xsl:attribute-set name="section.title.level3.properties">
   <xsl:attribute name="font-size">
     <xsl:value-of select="$body.font.master"/>
     <xsl:text>pt</xsl:text>
   </xsl:attribute>
   <xsl:attribute name="space-after.optimum">0.25em</xsl:attribute>
   <xsl:attribute name="space-after.precedence">1</xsl:attribute>
</xsl:attribute-set>

<xsl:attribute-set name="list.item.spacing">
  <xsl:attribute name="space-before.optimum">0.25em</xsl:attribute>
  <xsl:attribute name="space-before.minimum">0.2em</xsl:attribute>
  <xsl:attribute name="space-before.maximum">0.5em</xsl:attribute>
</xsl:attribute-set>


<xsl:attribute-set name="ulink.properties">
  <xsl:attribute name="font-family">
    <xsl:value-of select="$monospace.font.family"/>
  </xsl:attribute>
  <xsl:attribute name="hyphenate">false</xsl:attribute>
</xsl:attribute-set>


<xsl:attribute-set name="filename.properties"
                   use-attribute-sets="ulink.properties">
  <xsl:attribute name="color">black</xsl:attribute>
</xsl:attribute-set>


<xsl:attribute-set name="keycap.properties">
  <xsl:attribute name="color">#555555</xsl:attribute>
</xsl:attribute-set>


<xsl:attribute-set name="figure.title.properties">
  <xsl:attribute name="font-style">italic</xsl:attribute>
  <xsl:attribute name="space-before.optimum">1em</xsl:attribute>
  <xsl:attribute name="space-after.optimum">.25em</xsl:attribute>
  <xsl:attribute name="space-after.precedence">1</xsl:attribute>
  <xsl:attribute name="keep-with-next.within-column">always</xsl:attribute>
  <!--<xsl:attribute name="role">figure.title.properties</xsl:attribute>-->
</xsl:attribute-set>


<xsl:attribute-set name="procedure.title.properties">
  <xsl:attribute name="font-style">italic</xsl:attribute>
  <xsl:attribute name="space-after.optimum">.25em</xsl:attribute>
  <xsl:attribute name="space-after.precedence">1</xsl:attribute>
</xsl:attribute-set>

<xsl:attribute-set name="admonition.title.properties">
 <xsl:attribute name="font-size">
  <xsl:value-of select="$body.font.master"/>
  <xsl:text>pt</xsl:text>
 </xsl:attribute>
 <xsl:attribute name="role">admonition.title.properties</xsl:attribute>
</xsl:attribute-set>

<xsl:attribute-set name="nongraphical.admonition.properties">
 <xsl:attribute name="space-after.precedence">10</xsl:attribute>
 <xsl:attribute name="space-after.minimum">0.75em</xsl:attribute>
 <xsl:attribute name="space-after.optimum">1em</xsl:attribute>
 <xsl:attribute name="space-after.maximum">1.2em</xsl:attribute>
</xsl:attribute-set>


<xsl:attribute-set name="admonition.properties">
 <xsl:attribute name="space-before.precedence">10</xsl:attribute>
 <xsl:attribute name="space-before.minimum">0.05em</xsl:attribute>
 <xsl:attribute name="space-before.optimum">0.1em</xsl:attribute>
 <xsl:attribute name="space-before.maximum">0.25em</xsl:attribute>
 <xsl:attribute name="role">admonition.properties</xsl:attribute>
</xsl:attribute-set>


<xsl:attribute-set name="formal.title.properties">
   <xsl:attribute name="font-weight">normal</xsl:attribute>
   <xsl:attribute name="font-size">
     <xsl:value-of select="$body.font.master"/>
     <xsl:text>pt</xsl:text>
   </xsl:attribute>
</xsl:attribute-set>

<xsl:attribute-set name="formal.inline.number.properties" >
  <xsl:attribute name="font-weight">bold</xsl:attribute>
  <xsl:attribute name="font-family">
    <xsl:value-of select="$sans.font.family"/>
  </xsl:attribute>
</xsl:attribute-set>
<xsl:attribute-set name="formal.inline.title.properties" >
  <xsl:attribute name="font-weight">normal</xsl:attribute>
</xsl:attribute-set>

<xsl:attribute-set name="footnote.sep.leader.properties">
<!--   <xsl:attribute name="color"></xsl:attribute> -->
  <xsl:attribute name="leader-pattern">space</xsl:attribute>
  <xsl:attribute name="leader-length">0pt</xsl:attribute>
</xsl:attribute-set>

<xsl:attribute-set name="remark.properties">
   <xsl:attribute name="color">red</xsl:attribute>
   <xsl:attribute name="font-style">italic</xsl:attribute>
   <xsl:attribute name="border-left">3pt solid red</xsl:attribute>
   <xsl:attribute name="border-right">3pt solid red</xsl:attribute>
   <xsl:attribute name="padding-left">2pt</xsl:attribute>
</xsl:attribute-set>
  
  <xsl:attribute-set name="remark.inline.properties">
  <xsl:attribute name="color">red</xsl:attribute>
  <xsl:attribute name="font-style">italic</xsl:attribute>
</xsl:attribute-set>
  
</xsl:stylesheet>