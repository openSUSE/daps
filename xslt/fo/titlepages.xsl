<?xml version="1.0" encoding="UTF-8"?>
<!-- $Id: titlepages.xsl 38344 2009-01-13 12:47:03Z toms $ -->
<!DOCTYPE xsl:stylesheet >
<xsl:stylesheet version="1.0"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:axf="http://www.antennahouse.com/names/XSL/Extensions"
    xmlns:fo="http://www.w3.org/1999/XSL/Format">


<xsl:template name="debug.filename">
  <xsl:param name="node" select="."/>
  <xsl:variable name="xmlbase"
    select="ancestor-or-self::*[self::chapter or
                                self::appendix or
                                self::part or
                                self::reference or
                                self::preface or
                                self::glossary or
                                self::sect1 or
                                self::sect2 or
                                self::sect3 or
                                self::sect4]/@xml:base"/>
  
  <xsl:if test="$draft.mode = 'yes' and $xmlbase != '' and $use.meta != 0">
   <fo:block font-family="{$sans.font.family}" 
     clear="both" background-color="lightgrey" color="white">
    Filename:  <fo:inline font-family="{$monospace.font.family}">
      &quot;<xsl:value-of select="$xmlbase"/>&quot;</fo:inline>
   </fo:block>
  </xsl:if>
</xsl:template>

<xsl:template name="id.block">
  <xsl:param name="node" select="."/>
   <xsl:if test="$draft.mode = 'yes' and $use.meta != 0">
     <fo:block font-family="{$sans.font.family}"
       clear="both" background-color="lightgrey" color="white">
       <xsl:text>ID: </xsl:text>
       <xsl:choose>
         <xsl:when test="@id">
           <xsl:text>#</xsl:text>
           <xsl:call-template name="object.id"/>
         </xsl:when>
         <xsl:otherwise>- No ID found -</xsl:otherwise>
       </xsl:choose>
     </fo:block>
   </xsl:if>
</xsl:template>

<!-- ==================================================================== -->
<xsl:template name="chapter.titlepage.separator">
  <xsl:call-template name="debug.filename"/>
  <xsl:call-template name="id.block"/>
</xsl:template>


<xsl:template match="title" mode="chapter.titlepage.recto.auto.mode">
  <fo:block xsl:use-attribute-sets="chapter.titlepage.recto.style"
            margin-left="{$title.margin.left}"
            font-family="{$title.font.family}">
    <xsl:call-template name="chapappendix.title">
      <xsl:with-param name="node"
        select="ancestor-or-self::chapter[1]"/>
    </xsl:call-template>
  </fo:block>
</xsl:template>

<!-- ==================================================================== -->
<xsl:template name="appendix.titlepage.separator">
  <xsl:call-template name="debug.filename"/>
  <xsl:call-template name="id.block"/>
</xsl:template>


<xsl:template match="title" mode="appendix.titlepage.recto.auto.mode">
  <fo:block xsl:use-attribute-sets="appendix.titlepage.recto.style"
            margin-left="{$title.margin.left}"
            font-family="{$title.font.family}">
    <xsl:call-template name="chapappendix.title">
      <xsl:with-param name="node" select="ancestor-or-self::appendix[1]"/>
    </xsl:call-template>
  </fo:block>
</xsl:template>

<!-- ==================================================================== -->
<xsl:template name="preface.titlepage.separator">
  <xsl:call-template name="debug.filename"/>
  <xsl:call-template name="id.block"/>
</xsl:template>

<xsl:template match="title" mode="preface.titlepage.recto.auto.mode">
  <fo:block xsl:use-attribute-sets="preface.titlepage.recto.style"
            margin-left="{$title.margin.left}"
            font-family="{$title.font.family}">
    <xsl:call-template name="chapappendix.title">
      <xsl:with-param name="node" select="ancestor-or-self::preface[1]"/>
    </xsl:call-template>
  </fo:block>
</xsl:template>

<!-- ==================================================================== -->
<xsl:template name="glossary.titlepage.separator">
  <xsl:call-template name="debug.filename"/>
  <xsl:call-template name="id.block"/>
</xsl:template>

<xsl:template name="part.titlepage.separator">
  <xsl:call-template name="debug.filename"/>
  <xsl:call-template name="id.block"/>
</xsl:template>


<xsl:template name="set.titlepage.separator">
  <xsl:call-template name="debug.filename"/>
  <xsl:call-template name="id.block"/>
</xsl:template>


<!-- ==================================================================== -->
<xsl:template name="sect1.titlepage.separator">
  <xsl:call-template name="debug.filename"/>
  <xsl:call-template name="id.block"/>
</xsl:template>

<xsl:template name="sect2.titlepage.separator">
  <xsl:call-template name="debug.filename"/>
  <xsl:call-template name="id.block"/>
</xsl:template>

<xsl:template name="sect3.titlepage.separator">
  <xsl:call-template name="debug.filename"/>
  <xsl:call-template name="id.block"/>
</xsl:template>

<xsl:template name="sect4.titlepage.separator">
  <xsl:call-template name="debug.filename"/>
  <xsl:call-template name="id.block"/>
</xsl:template>

<!-- ==================================================================== -->
<xsl:template name="chapappendix.title">
  <xsl:param name="node" select="."/>
  <xsl:variable name="nodepi" select="$node"/>
  <xsl:variable name="id">
    <xsl:call-template name="object.id">
      <xsl:with-param name="object" select="$node"/>
    </xsl:call-template>
  </xsl:variable>

  <fo:table width="100%"
            xsl:use-attribute-sets="chap.title-label.properties">
   <fo:table-column column-number="1" column-width="100%"/>
   <fo:table-column column-number="2" column-width="90pt - 9.5mm"/>
   <fo:table-body>
    <fo:table-cell><fo:block margin-right="2em"
      xsl:use-attribute-sets="chap.title.properties"
    ><xsl:apply-templates select="$nodepi" mode="title.markup"/></fo:block>
    </fo:table-cell>
    <fo:table-cell><fo:block
         xsl:use-attribute-sets="chap.label.properties"
      ><xsl:apply-templates select="$nodepi" mode="label.markup"
      /></fo:block>
    </fo:table-cell>
   </fo:table-body>
  </fo:table>

<!--  <xsl:if test="$draft.mode = 'yes' and $use.meta != 0">
    <xsl:message> FILENAMES activated <xsl:value-of select="concat(name(), ' ', ../@xml:base)"/></xsl:message>
    <fo:block>Filename: &quot;<xsl:value-of select="../@xml:base"/>&quot;
    </fo:block>
  </xsl:if>-->

</xsl:template>


<xsl:template name="table.of.contents.titlepage.recto">
  <fo:block xsl:use-attribute-sets="table.of.contents.titlepage.recto.style"
   space-before.minimum="1em"
   space-before.optimum="1.5em"
   space-before.maximum="2em"
   space-after="0.5em"
   margin-left="{$title.margin.left}"
   margin-top="154pt - 54pt -1.1em"
   start-indent="0pt"
   font-size="18pt"
   font-weight="bold"
   font-family="{$title.fontset}">
   <xsl:call-template name="gentext">
     <xsl:with-param name="key" select="'TableofContents'"/>
   </xsl:call-template></fo:block>
</xsl:template>


<!-- ==================================================================== -->
<xsl:template match="legalnotice" mode="titlepage.mode">
  <xsl:variable name="id">
    <xsl:call-template name="object.id"/>
  </xsl:variable>

  <fo:block id="{$id}" font-size="9pt">
    <xsl:if test="title"> <!-- FIXME: add param for using default title? -->
      <xsl:call-template name="formal.object.heading"/>
    </xsl:if>
    <xsl:apply-templates mode="titlepage.mode"/>
  </fo:block>
</xsl:template>


<xsl:template match="legalnotice/literallayout" mode="titlepage.mode">
<!--   <xsl:param name="suppress-numbers" select="'0'"/> -->

  <xsl:variable name="id"><xsl:call-template name="object.id"/></xsl:variable>

  <!-- FIXME: Doesn't work, but I don't know why -->
  <xsl:variable name="addendum">
    <xsl:choose>
      <xsl:when test="/book/bookinfo/productname">
         <xsl:text>&#10;&#10;</xsl:text>
         <xsl:value-of select="/book/bookinfo/productname"/>
      </xsl:when>
      <xsl:when test="/book/bookinfo/title">
         <xsl:text>&#10;&#10;</xsl:text>
         <xsl:value-of select="/book/bookinfo/title"/>
      </xsl:when>
      <xsl:when test="/book/title">
         <xsl:text>&#10;&#10;</xsl:text>
         <xsl:value-of select="/book/title"/>
      </xsl:when>
    </xsl:choose>
    <xsl:if test="/book/bookinfo/invpartnumber">
      <xsl:text>&#10;</xsl:text>
      <xsl:value-of select="/book/bookinfo/invpartnumber"/>
    </xsl:if>
  </xsl:variable>

  <fo:block id="{$id}"
                    wrap-option='no-wrap'
                    white-space-collapse='false'
                    white-space-treatment='preserve'
                    text-align='start'
                    font-family="{$sans.font.family}"
                    linefeed-treatment="preserve"
                    xsl:use-attribute-sets="verbatim.properties">
    <xsl:apply-templates/>

    <xsl:copy-of select="$addendum"/>
  </fo:block>
</xsl:template>


</xsl:stylesheet>
