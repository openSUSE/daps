<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE xsl:stylesheet 
[
  <!ENTITY % fontsizes SYSTEM "fontsizes.ent">
  %fontsizes;
]>
<!-- $Id: $ -->
<xsl:stylesheet version="1.0"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:fo="http://www.w3.org/1999/XSL/Format"
>
<xsl:attribute-set name="book.titlepage.verso.style">
  <xsl:attribute name="font-size">&LARGE;</xsl:attribute>
  <xsl:attribute name="font-family">
    <xsl:call-template name="genfont">
      <xsl:with-param name="font-family">sans.font.family</xsl:with-param>
    </xsl:call-template>
  </xsl:attribute>
</xsl:attribute-set>

<xsl:attribute-set name="chap.title-label.properties">
  <xsl:attribute name="margin-top">3.5em</xsl:attribute>
  <xsl:attribute name="font-family">
    <xsl:call-template name="genfont">
      <xsl:with-param name="font-family">sans.font.family</xsl:with-param>
    </xsl:call-template>
  </xsl:attribute>
</xsl:attribute-set>


<xsl:attribute-set name="chap.label.properties">
  <xsl:attribute name="font-weight">normal</xsl:attribute>
  <xsl:attribute name="text-align">left</xsl:attribute>
  <xsl:attribute name="font-size">&huge;</xsl:attribute><!-- deviation -->
  <!--<xsl:attribute name="padding-bottom">-13pt</xsl:attribute>--><!-- deviation -->
  <!--<xsl:attribute name="padding-right">-10pt</xsl:attribute>-->
</xsl:attribute-set>

<xsl:attribute-set name="chap.title.properties">
  <xsl:attribute name="font-weight">normal</xsl:attribute>
  <xsl:attribute name="text-align">left</xsl:attribute>
  <xsl:attribute name="font-size">&large;</xsl:attribute>
</xsl:attribute-set>

<xsl:attribute-set name="section.title.properties">
  <xsl:attribute name="font-weight">normal</xsl:attribute>
  <xsl:attribute name="font-family">
    <xsl:call-template name="genfont">
      <xsl:with-param name="font-family">sans.font.family</xsl:with-param>
    </xsl:call-template>
  </xsl:attribute>
</xsl:attribute-set>


<xsl:attribute-set name="section.title.level1.properties">
  <xsl:attribute name="font-weight">normal</xsl:attribute>
  <xsl:attribute name="font-size">&Large;</xsl:attribute>
  <xsl:attribute name="space-after.minimum">0.1em</xsl:attribute>
  <xsl:attribute name="space-after.optimum">0.125em</xsl:attribute>
  <xsl:attribute name="space-after.maximum">0.125em</xsl:attribute>
  <xsl:attribute name="padding-bottom">0em</xsl:attribute>
  <xsl:attribute name="margin-bottom">-.3em</xsl:attribute>
</xsl:attribute-set>

<xsl:attribute-set name="section.title.level2.properties">
  <xsl:attribute name="font-weight">normal</xsl:attribute>
  <xsl:attribute name="font-size">&large;</xsl:attribute>
  <xsl:attribute name="space-after.minimum">0.1em</xsl:attribute>
  <xsl:attribute name="space-after.optimum">0.125em</xsl:attribute>
  <xsl:attribute name="space-after.maximum">0.125em</xsl:attribute>
  <xsl:attribute name="padding-bottom">0em</xsl:attribute>
  <xsl:attribute name="margin-bottom">-.35em</xsl:attribute>
</xsl:attribute-set>

<xsl:attribute-set name="section.title.level3.properties">
  <xsl:attribute name="font-size">(&normal; + &large;) div 2</xsl:attribute>
  <xsl:attribute name="space-after.minimum">0.1em</xsl:attribute>
  <xsl:attribute name="space-after.optimum">0.125em</xsl:attribute>
  <xsl:attribute name="space-after.maximum">0.125em</xsl:attribute>
  <xsl:attribute name="space-before.minimum">&Largespace;</xsl:attribute>
  <xsl:attribute name="space-before.optimum">&LARGEspace;</xsl:attribute>
  <xsl:attribute name="padding-bottom">0em</xsl:attribute>
  <xsl:attribute name="margin-bottom">-.4em</xsl:attribute>
</xsl:attribute-set>

<xsl:attribute-set name="section.title.level4.properties">
  <xsl:attribute name="font-size">&normal;</xsl:attribute>
  <xsl:attribute name="font-style">oblique</xsl:attribute>
  <xsl:attribute name="space-after.minimum">0.1em</xsl:attribute>
  <xsl:attribute name="space-after.optimum">0.1em</xsl:attribute>
  <xsl:attribute name="space-after.maximum">0.1em</xsl:attribute>
  <xsl:attribute name="space-before.minimum">&largespace;</xsl:attribute>
  <xsl:attribute name="space-before.optimum">&Largespace;</xsl:attribute>
  <xsl:attribute name="padding-bottom">0em</xsl:attribute>
  <xsl:attribute name="margin-bottom">-.5em</xsl:attribute>
</xsl:attribute-set>


<!-- ==================================================================== -->
<!-- Part, Chapter, Appendix, Preface, Glossary                           -->

<xsl:attribute-set name="part.titlepage.recto.style">
  <xsl:attribute name="margin-top">108pt + 3em</xsl:attribute>
  <xsl:attribute name="font-weight">normal</xsl:attribute>
  <xsl:attribute name="font-size">&LARGE;</xsl:attribute>
  <xsl:attribute name="font-family"><xsl:value-of select="$title.fontset"/></xsl:attribute>
  <xsl:attribute name="text-align">center</xsl:attribute>
</xsl:attribute-set>


<xsl:attribute-set name="component.title.properties">
  <xsl:attribute name="font-weight">normal</xsl:attribute>
  <xsl:attribute name="font-size">&LARGE;</xsl:attribute>
  <xsl:attribute name="space-before">5em</xsl:attribute>
  <xsl:attribute name="space-before.conditionality">retain</xsl:attribute>
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
<!-- Code below used to customize formal titles (figure, table...)        -->
<xsl:attribute-set name="formal.title.properties" >
  <xsl:attribute name="font-weight">normal</xsl:attribute>
  <xsl:attribute name="font-style">normal</xsl:attribute>
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
  <xsl:attribute name="wrap-option">wrap</xsl:attribute>
  <xsl:attribute name="hyphenate">false</xsl:attribute>
<!--   <xsl:attribute name="hyphenation-character">&#x25BA;</xsl:attribute> -->
  <xsl:attribute name="font-size">&normal;</xsl:attribute>
</xsl:attribute-set>

<xsl:attribute-set name="monospace.properties">
  <xsl:attribute name="hyphenate">false</xsl:attribute>
</xsl:attribute-set>


<!-- ==================================================================== -->
<!-- Code below used to customize Chapter/Section/TOC titles.             -->

<xsl:attribute-set name="common.section.title.properties">
  <xsl:attribute name="hyphenate">false</xsl:attribute>
  <xsl:attribute name="font-weight">normal</xsl:attribute>
</xsl:attribute-set>


<xsl:attribute-set name="refentry.title.level1.properties">
   <xsl:attribute name="font-size">&LARGE;</xsl:attribute>
</xsl:attribute-set>
<xsl:attribute-set name="refentry.title.level2.properties">
   <xsl:attribute name="font-size">&Large;</xsl:attribute>
</xsl:attribute-set>
<xsl:attribute-set name="refentry.title.level3.properties">
   <xsl:attribute name="font-size">&large;</xsl:attribute>
</xsl:attribute-set>
<xsl:attribute-set name="refentry.title.level4.properties"> 
   <xsl:attribute name="font-size">&normal;</xsl:attribute>
</xsl:attribute-set>
<xsl:attribute-set name="refentry.title.level5.properties"> 
   <xsl:attribute name="font-size">&normal;</xsl:attribute>
</xsl:attribute-set>



<!-- ==================================================================== -->
<!--
 I don't use attribute sets for Chapter and TOC since some of parameters
 (font-size) are hard-coded in templates.
-->
<xsl:attribute-set name="list.of.tables.titlepage.recto.style">
  <xsl:attribute name="margin-top">162pt -54pt</xsl:attribute>
</xsl:attribute-set>

<xsl:attribute-set name="toc.title.properties">
   <xsl:attribute name="font-family">
      <xsl:value-of select="$sans.font.family"/>
   </xsl:attribute>
   <xsl:attribute name="text-align-last">justify</xsl:attribute>
</xsl:attribute-set>

<xsl:attribute-set name="toc.title.part.properties"
   use-attribute-sets="toc.title.properties">
   <xsl:attribute name="font-family">
      <xsl:value-of select="$sans.font.family"/>
   </xsl:attribute>
   <xsl:attribute name="font-weight">500</xsl:attribute>
   <xsl:attribute name="font-size">&large;</xsl:attribute>
   <xsl:attribute name="space-before">&Largespace;</xsl:attribute>
   <xsl:attribute name="space-after">0.25em</xsl:attribute>
   <xsl:attribute name="keep-with-next.within-line">always</xsl:attribute>
   <xsl:attribute name="keep-with-next.within-column">always</xsl:attribute>
</xsl:attribute-set>
<xsl:attribute-set name="toc.title.chapapp.properties"
   use-attribute-sets="toc.title.properties">
   <xsl:attribute name="font-family">
      <xsl:value-of select="$sans.font.family"/>
   </xsl:attribute>
   <xsl:attribute name="font-weight">normal</xsl:attribute>
   <xsl:attribute name="font-size">&largespace;</xsl:attribute>
    <xsl:attribute name="space-before">&Largespace;</xsl:attribute> 
   <xsl:attribute name="space-after">0.25em</xsl:attribute>
    <xsl:attribute name="keep-with-next.within-line">always</xsl:attribute> 
</xsl:attribute-set>

<xsl:attribute-set name="toc.title.section.properties"
   use-attribute-sets="toc.title.properties">
   <xsl:attribute name="font-family">
      <xsl:value-of select="$sans.font.family"/>
   </xsl:attribute>
   <xsl:attribute name="font-size">&normalspace;</xsl:attribute>
</xsl:attribute-set>


<!-- ==================================================================== -->
<!-- Table properties                                                     -->
<xsl:attribute-set name="table.cell.padding">
  <xsl:attribute name="padding-left">5pt</xsl:attribute>
  <xsl:attribute name="padding-right">5pt</xsl:attribute>
  <xsl:attribute name="padding-top">6pt</xsl:attribute>
  <xsl:attribute name="padding-bottom">6pt</xsl:attribute>
</xsl:attribute-set>

<xsl:attribute-set name="table.properties">
  <xsl:attribute name="text-align">left</xsl:attribute>
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
  <xsl:attribute name="margin-left">.75em</xsl:attribute>
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
  <xsl:attribute name="font-size">&normal;</xsl:attribute>
  <xsl:attribute name="padding-bottom">2pt</xsl:attribute>
</xsl:attribute-set>

<xsl:attribute-set name="formal.inline.number.properties">
  <xsl:attribute name="font-weight">normal</xsl:attribute>
</xsl:attribute-set>
<xsl:attribute-set name="formal.inline.title.properties">
  <xsl:attribute name="font-style">oblique</xsl:attribute>
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
           <xsl:when test="self::xref">red</xsl:when>
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


<xsl:attribute-set name="callout.spacing.properties">
   <xsl:attribute name="space-before.optimum">0.5em</xsl:attribute>
   <xsl:attribute name="space-before.minimum">0.25em</xsl:attribute>
   <xsl:attribute name="space-before.maximum">0.75em</xsl:attribute>
</xsl:attribute-set>

</xsl:stylesheet>
