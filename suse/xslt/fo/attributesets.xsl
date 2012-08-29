<?xml version="1.0" encoding="UTF-8"?>
<!-- $Id: attributesets.xsl 43480 2009-08-10 09:20:34Z toms $ -->
<xsl:stylesheet version="1.0"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:fo="http://www.w3.org/1999/XSL/Format"
>


<!-- ==================================================================== -->
<!-- Part, Chapter, Appendix, Preface, Glossary                           -->

<xsl:attribute-set name="part.titlepage.recto.style">
  <xsl:attribute name="margin-top">108pt + 3em</xsl:attribute>
</xsl:attribute-set>

<xsl:attribute-set name="chap.title-label.properties">
  <xsl:attribute name="display-align">after</xsl:attribute>
  <xsl:attribute name="alignment-adjust">baseline</xsl:attribute>
  <xsl:attribute name="margin-top">154pt -54pt -0.5em</xsl:attribute>
</xsl:attribute-set>

<xsl:attribute-set name="chap.label.properties">
  <xsl:attribute name="font-size">62pt</xsl:attribute><!-- deviation -->
  <xsl:attribute name="font-weight">bold</xsl:attribute>
  <xsl:attribute name="text-align">right</xsl:attribute>
  <xsl:attribute name="padding-bottom">-13pt</xsl:attribute><!-- deviation -->
  <xsl:attribute name="padding-right">-10pt</xsl:attribute>
</xsl:attribute-set>

<xsl:attribute-set name="chap.title.properties">
  <xsl:attribute name="font-size">22.5pt</xsl:attribute>
  <xsl:attribute name="font-weight">bold</xsl:attribute>
  <xsl:attribute name="hyphenate">false</xsl:attribute>
  <xsl:attribute name="padding-right">10pt</xsl:attribute>
</xsl:attribute-set>


<xsl:attribute-set name="chapter.titlepage.recto.style">
  <xsl:attribute name="text-align">left</xsl:attribute>
</xsl:attribute-set>

<xsl:attribute-set name="appendix.titlepage.recto.style"
                   use-attribute-sets="chapter.titlepage.recto.style"/>

<xsl:attribute-set name="preface.titlepage.recto.style"
                   use-attribute-sets="chapter.titlepage.recto.style"/>

<xsl:attribute-set name="glossary.titlepage.recto.style"
                   use-attribute-sets="chapter.titlepage.recto.style"/>


<!-- ==================================================================== -->
<xsl:attribute-set name="article.titlepage.recto.style">
  <xsl:attribute name="text-align">center</xsl:attribute>
</xsl:attribute-set>


<!-- ==================================================================== -->
<!-- In case you need a shorter index: -->
<!--<xsl:attribute-set name="index.div.title.properties">
  <xsl:attribute name="font-size">12pt</xsl:attribute>
</xsl:attribute-set>

<xsl:attribute-set name="index.entry.properties">
 <xsl:attribute name="font-size">8pt</xsl:attribute>
</xsl:attribute-set>-->
  
<!-- ==================================================================== -->
<!-- Code below used to customize formal titles (figure, table...)        -->
<xsl:attribute-set name="formal.title.properties" >
  <xsl:attribute name="font-weight">bold</xsl:attribute>
  <xsl:attribute name="font-style">italic</xsl:attribute>
  <xsl:attribute name="font-size">
    <xsl:value-of select="$body.font.master"/>
    <xsl:text>pt</xsl:text>
  </xsl:attribute>
  <xsl:attribute name="text-align">left</xsl:attribute>
  <xsl:attribute name="hyphenate">false</xsl:attribute>
  <xsl:attribute name="space-after.minimum">0.4em</xsl:attribute>
  <xsl:attribute name="space-after.optimum">0.6em</xsl:attribute>
  <xsl:attribute name="space-after.maximum">0.8em</xsl:attribute>
  <xsl:attribute name="space-before">18pt</xsl:attribute>
</xsl:attribute-set>


<!-- ==================================================================== -->
<!-- Code below used to customize verbatim appearance                     -->
<xsl:attribute-set name="shade.verbatim.style">
  <xsl:attribute name="background-color">#F0F0F0</xsl:attribute>
  <xsl:attribute name="padding">0pt 6pt 0pt 6pt</xsl:attribute>
  <xsl:attribute name="margin">0pt</xsl:attribute>
  <xsl:attribute name="line-stacking-strategy">font-height</xsl:attribute>
</xsl:attribute-set>

<xsl:attribute-set name="monospace.verbatim.properties">
  <xsl:attribute name="white-space-treatment">preserve</xsl:attribute>
  <xsl:attribute name="space-before.minimum">0pt</xsl:attribute>
  <xsl:attribute name="space-before.optimum">6pt</xsl:attribute>
  <xsl:attribute name="space-before.maximum">6pt</xsl:attribute>
  <xsl:attribute name="space-after.minimum">0pt</xsl:attribute>
  <xsl:attribute name="space-after.optimum">6pt</xsl:attribute>
  <xsl:attribute name="space-after.maximum">6pt</xsl:attribute>
<!--  <xsl:attribute name="hyphenate">false</xsl:attribute>-->
  <xsl:attribute name="wrap-option">wrap</xsl:attribute>
   <xsl:attribute name="hyphenation-character">&#x23CE;</xsl:attribute><!-- &#x25ca; -->

  <xsl:attribute name="font-size"
   ><xsl:value-of select="0.75*$body.font.master"/>pt</xsl:attribute>
</xsl:attribute-set>

<xsl:attribute-set name="monospace.properties">
  <xsl:attribute name="hyphenate">false</xsl:attribute>
</xsl:attribute-set>


<!-- ==================================================================== -->
<!-- Code below used to customize Chapter/Section/TOC titles.             -->

<xsl:attribute-set name="common.section.title.properties">
  <xsl:attribute name="hyphenate">false</xsl:attribute>
</xsl:attribute-set>

<xsl:attribute-set name="section.title.level1.properties"
 use-attribute-sets="common.section.title.properties">
  <xsl:attribute name="font-size">21pt</xsl:attribute>
  <xsl:attribute name="space-before.minimum">10pt</xsl:attribute>
  <xsl:attribute name="space-before.optimum">18pt</xsl:attribute>
</xsl:attribute-set>
<xsl:attribute-set name="section.title.level2.properties"
 use-attribute-sets="common.section.title.properties">
  <xsl:attribute name="font-size">18pt</xsl:attribute>
  <xsl:attribute name="space-before.minimum">8pt</xsl:attribute>
  <xsl:attribute name="space-before.optimum">16.5pt</xsl:attribute>
</xsl:attribute-set>
<xsl:attribute-set name="section.title.level3.properties"
 use-attribute-sets="common.section.title.properties">
  <xsl:attribute name="font-size">15pt</xsl:attribute>
  <xsl:attribute name="space-before.minimum">13pt</xsl:attribute>
  <xsl:attribute name="space-before.optimum">23.5pt</xsl:attribute>
</xsl:attribute-set>
<xsl:attribute-set name="section.title.level4.properties"
 use-attribute-sets="common.section.title.properties">
  <xsl:attribute name="font-size">12.5pt</xsl:attribute>
  <xsl:attribute name="font-weight">normal</xsl:attribute>
  <xsl:attribute name="space-before.minimum">10pt</xsl:attribute>
  <xsl:attribute name="space-before.optimum">12pt</xsl:attribute>
</xsl:attribute-set>

<xsl:attribute-set name="section.title.level5.properties"
 use-attribute-sets="common.section.title.properties">
  <xsl:attribute name="font-size">11pt</xsl:attribute>
  <xsl:attribute name="font-weight">normal</xsl:attribute>
  <xsl:attribute name="space-before.minimum">7pt</xsl:attribute>
  <xsl:attribute name="space-before.optimum">9pt</xsl:attribute>
</xsl:attribute-set>


<xsl:attribute-set name="refentry.title.level1.properties">
   <xsl:attribute name="font-size">25pt</xsl:attribute>
</xsl:attribute-set>
<xsl:attribute-set name="refentry.title.level2.properties">
   <xsl:attribute name="font-size">21pt</xsl:attribute>
</xsl:attribute-set>
<xsl:attribute-set name="refentry.title.level3.properties">
   <xsl:attribute name="font-size">18pt</xsl:attribute>
</xsl:attribute-set>
<xsl:attribute-set name="refentry.title.level4.properties"> 
   <xsl:attribute name="font-size">15pt</xsl:attribute>
</xsl:attribute-set>
<xsl:attribute-set name="refentry.title.level5.properties"> 
   <xsl:attribute name="font-size">12.5pt</xsl:attribute>
</xsl:attribute-set>


<!-- ==================================================================== -->
<!--
 I don't use attribute sets for Chapter and TOC since some of parameters
 (font-size) are hard-coded in templates.
-->
<xsl:attribute-set name="list.of.tables.titlepage.recto.style">
  <xsl:attribute name="margin-top">162pt -54pt</xsl:attribute>
</xsl:attribute-set>

<xsl:attribute-set name="toc.line.properties">
  <xsl:attribute name="text-align-last">justify</xsl:attribute>
  <xsl:attribute name="text-align">start</xsl:attribute>
  <xsl:attribute name="hyphenate">false</xsl:attribute>
  <xsl:attribute name="end-indent">3* <xsl:value-of select="concat($toc.indent.width, 'pt')"/></xsl:attribute>
  <xsl:attribute name="last-line-end-indent"><xsl:value-of select="concat('-', $toc.indent.width, 'pt')"/></xsl:attribute>
  <xsl:attribute name="font-size">
    <xsl:choose>
      <xsl:when test="self::part"><xsl:value-of select="1.44 * $body.font.master"/>pt</xsl:when>
      <xsl:when test="self::chapter or 
                      self::preface or 
                      self::glossary or 
                      self::appendix"><xsl:value-of select="1.2 * $body.font.master"/>pt</xsl:when>
      <xsl:when test="self::sect1"><xsl:value-of select="$body.font.master"/>pt</xsl:when>
    </xsl:choose>
  </xsl:attribute>
  <xsl:attribute name="keep-with-next">
    <xsl:choose>
      <xsl:when test="self::part or
                      self::chapter or
                      self::preface or 
                      self::glossary or
                      self::appendix">always</xsl:when>
      <xsl:otherwise>auto</xsl:otherwise>
    </xsl:choose>
  </xsl:attribute>
  <xsl:attribute name="space-before">
    <xsl:choose>
      <xsl:when test="self::part">18pt</xsl:when>
      <xsl:when test="self::chapter or self::appendix or self::glossary">12pt</xsl:when>
      <xsl:otherwise><xsl:value-of select=".5 * $body.font.master"/>pt</xsl:otherwise>
    </xsl:choose>
  </xsl:attribute>
  <xsl:attribute name="font-weight">
    <xsl:choose>
      <xsl:when test="self::part">bold</xsl:when>
      <xsl:when test="self::chapter or 
                      self::preface or 
                      self::glossary or 
                      self::appendix">bold</xsl:when>
      <xsl:when test="self::sect1">normal</xsl:when>
    </xsl:choose>
  </xsl:attribute>
  <xsl:attribute name="font-family"><xsl:value-of select="$sans.font.family"/></xsl:attribute>
</xsl:attribute-set>


<!-- ==================================================================== -->
<!-- Table properties                                                     -->
<xsl:attribute-set name="table.cell.padding">
  <xsl:attribute name="padding-left">10pt</xsl:attribute>
  <xsl:attribute name="padding-right">10pt</xsl:attribute>
  <xsl:attribute name="padding-top">6pt</xsl:attribute>
  <xsl:attribute name="padding-bottom">6pt</xsl:attribute>
</xsl:attribute-set>

<xsl:attribute-set name="table.properties">
  <xsl:attribute name="keep-together.within-column">auto</xsl:attribute>
</xsl:attribute-set>

<xsl:attribute-set name="table.tbody.properties">
</xsl:attribute-set>


<!-- ==================================================================== -->
<!-- Admonition properties                                                -->
<xsl:attribute-set name="admonition.properties">
  <xsl:attribute name="font-family">
    <xsl:value-of select="$sans.font.family"></xsl:value-of>
  </xsl:attribute>
  <xsl:attribute name="border-bottom">.5pt solid black</xsl:attribute>
  <xsl:attribute name="margin-left">0pt</xsl:attribute>
  <xsl:attribute name="margin-right">0pt</xsl:attribute>
  <xsl:attribute name="padding-bottom">3pt</xsl:attribute>
  <xsl:attribute name="padding-left">5pt</xsl:attribute>
  <xsl:attribute name="padding-right">5pt</xsl:attribute>
</xsl:attribute-set>
<xsl:attribute-set name="admonition.title.properties">
  <xsl:attribute name="hyphenate">false</xsl:attribute>
  <xsl:attribute name="border-top">.5pt solid black</xsl:attribute>
  <xsl:attribute name="margin-left">0pt</xsl:attribute>
  <xsl:attribute name="margin-right">0pt</xsl:attribute>
  <xsl:attribute name="padding-top">3pt</xsl:attribute>
  <xsl:attribute name="padding-left">5pt</xsl:attribute>
  <xsl:attribute name="padding-right">5pt</xsl:attribute>
  <xsl:attribute name="font-family">
    <xsl:value-of select="$sans.font.family"></xsl:value-of>
  </xsl:attribute>
  <xsl:attribute name="font-size"><xsl:value-of select="$body.font.master"/>pt</xsl:attribute>
  <xsl:attribute name="text-align">left</xsl:attribute>
</xsl:attribute-set>
<xsl:attribute-set name="nongraphical.admonition.properties">
  <xsl:attribute name="margin-left">0pt</xsl:attribute>
  <xsl:attribute name="margin-right">0pt</xsl:attribute>
</xsl:attribute-set>


<!-- ==================================================================== -->
<!-- List properties                                                      -->
<xsl:attribute-set name="list.block.spacing">
  <!--<xsl:attribute name="margin-left">7.5pt</xsl:attribute>-->
</xsl:attribute-set>

<xsl:attribute-set name="varlistentry.block.properties">
  <xsl:attribute name="font-weight">bold</xsl:attribute>
</xsl:attribute-set>


<xsl:attribute-set name="procedure.label.properties">
  <xsl:attribute name="font-family">
    <xsl:value-of select="$sans.font.family"/>
  </xsl:attribute>
  <xsl:attribute name="font-weight">bold</xsl:attribute>
  <xsl:attribute name="text-align">right</xsl:attribute>
  <xsl:attribute name="font-size">10.5pt</xsl:attribute>
  <xsl:attribute name="padding-bottom">2pt</xsl:attribute>
</xsl:attribute-set>


<!-- ==================================================================== -->
<!-- Para properties                                                      -->
<!--<xsl:attribute-set name="normal.para.spacing">
</xsl:attribute-set>-->


<xsl:attribute-set name="glossterm.properties">
  <xsl:attribute name="font-family">
    <xsl:value-of select="$sans.font.family"/>
  </xsl:attribute>
</xsl:attribute-set>

<!-- ==================================================================== -->
<!-- Inline properties                                                    -->
<xsl:attribute-set name="formal.inline.number.properties" >
  <xsl:attribute name="font-weight">bold</xsl:attribute>
  <xsl:attribute name="font-family">
    <xsl:value-of select="$sans.font.family"/>
  </xsl:attribute>
</xsl:attribute-set>
<xsl:attribute-set name="formal.inline.title.properties" >
  <xsl:attribute name="font-weight">normal</xsl:attribute>
</xsl:attribute-set>


<xsl:attribute-set name="ulink.properties">
  <xsl:attribute name="font-family">
    <xsl:value-of select="$monospace.font.family"/>
  </xsl:attribute>
  <xsl:attribute name="hyphenate">false</xsl:attribute>
  <xsl:attribute name="color">
    <xsl:choose>
      <xsl:when test="$format.print='1'">
        <xsl:text>black</xsl:text>
      </xsl:when>
      <xsl:otherwise>
        <xsl:text>blue</xsl:text>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:attribute>
</xsl:attribute-set>


<xsl:attribute-set name="filename.properties"
                   use-attribute-sets="ulink.properties">
  <xsl:attribute name="color">inherit</xsl:attribute>
</xsl:attribute-set>

<xsl:attribute-set name="xref.properties">
<!--  <xsl:attribute name="font-family">
       <xsl:value-of select="$body.font.family"/>
  </xsl:attribute>-->
  <xsl:attribute name="color">
    <xsl:choose>
      <xsl:when test="$format.print='1'">
        <xsl:text>black</xsl:text>
      </xsl:when>
      <xsl:otherwise>
        <xsl:choose>
           <!-- <xsl:when test="self::xref">red</xsl:when> -->
           <xsl:when test="self::ulink">blue</xsl:when>
           <xsl:otherwise>black</xsl:otherwise>
        </xsl:choose>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:attribute>
</xsl:attribute-set>


<xsl:attribute-set name="root.properties">
   <xsl:attribute name="letter-spacing">normal</xsl:attribute>
</xsl:attribute-set>


<xsl:attribute-set name="remark.properties">
   <xsl:attribute name="color">purple</xsl:attribute>
   <xsl:attribute name="font-style">italic</xsl:attribute>
   <xsl:attribute name="border-left">3pt solid red</xsl:attribute>
   <xsl:attribute name="border-right">3pt solid red</xsl:attribute>
   <xsl:attribute name="padding-left">2pt</xsl:attribute>
</xsl:attribute-set>


<xsl:attribute-set name="remark.inline.properties">
  <xsl:attribute name="color">purple</xsl:attribute>
  <xsl:attribute name="font-style">italic</xsl:attribute>
</xsl:attribute-set>

<xsl:attribute-set name="status.inline.properties">
  <xsl:attribute name="color">purple</xsl:attribute>
  <xsl:attribute name="font-size">7pt</xsl:attribute>
  <xsl:attribute name="padding-left">.5em</xsl:attribute>
  <xsl:attribute name="padding-right">.5em</xsl:attribute>
</xsl:attribute-set>

<xsl:attribute-set name="callout.spacing.properties">
   <xsl:attribute name="space-before.optimum">0.5em</xsl:attribute>
   <xsl:attribute name="space-before.minimum">0.25em</xsl:attribute>
   <xsl:attribute name="space-before.maximum">0.75em</xsl:attribute>
</xsl:attribute-set>

</xsl:stylesheet>
