<?xml version="1.0" encoding="ISO-8859-1"?>
<!-- $Id: docbook.xsl 1694 2005-08-19 09:47:27Z toms $ -->
<xsl:stylesheet version="1.0"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:fo="http://www.w3.org/1999/XSL/Format"
>

<!-- Import the current version of the stylesheets  -->
<xsl:import href="http://docbook.sourceforge.net/release/xsl/current/fo/docbook.xsl"/>

<xsl:output method="xml" indent="yes" encoding="UTF-8"/>


<!-- Use cropmarks? -->
<xsl:param name="use.xep.cropmarks" select="0"/>

<!-- Use extensions -->
<xsl:param name="xep.extensions">1</xsl:param>
<xsl:param name="fop.extensions">0</xsl:param>

<xsl:param name="paper.type">A4</xsl:param>
<xsl:param name="double.sided" select="0"/>
<xsl:param name="body.start.indent">0pt</xsl:param>

<xsl:param name="title.margin.left" select="'0pt'"/>

<xsl:param name="body.margin.top">0pt</xsl:param>
<!-- <xsl:param name="body.margin.bottom">2em</xsl:param> -->
<xsl:param name="region.after.extent">4.5em</xsl:param>

<!-- Page margin dimensions -->
<xsl:param name="page.margin.top">4em</xsl:param>
<xsl:param name="page.margin.bottom">8em</xsl:param>


<!-- URL to a watermark image -->
<xsl:param name="draft.watermark.image" select="''"/>

<!-- Format variablelists lists as blocks? -->
<xsl:param name="variablelist.as.blocks" select="1"/>

<!-- Use blocks for glosslists? -->
<xsl:param name="glosslist.as.blocks" select="1"/>

<!-- Should a page reference be created? -->
<xsl:param name="insert.xref.page.number">yes</xsl:param>

<!-- Print a header rule? 0=no, 1=yes -->
<xsl:param name="header.rule" select="0"/>


<!-- ========================================================== -->
<xsl:template match="/">
  <xsl:if test="$use.xep.cropmarks != 0 and $xep.extensions != 0">
   <xsl:processing-instruction
      name="xep-pdf-crop-offset">1cm</xsl:processing-instruction>
   <xsl:processing-instruction
      name="xep-pdf-bleed">3.5mm</xsl:processing-instruction>
   <xsl:processing-instruction
      name="xep-pdf-crop-mark-width">0.5pt</xsl:processing-instruction>
  </xsl:if>
  <xsl:if test="$xep.extensions != 0">
     <xsl:processing-instruction
     name="xep-pdf-view-mode">show-bookmarks</xsl:processing-instruction>
  </xsl:if>
  <xsl:apply-imports/>
</xsl:template>



<xsl:template name="article.titlepage.recto">
   <fo:table margin-top="6cm" width="100%">
      <fo:table-column column-width="36%"  padding-right="3em"/>
      <fo:table-column column-width="3%"/>
      <fo:table-column column-width="60%" />
      <fo:table-body text-align="center" font-size="140%">
        <fo:table-row height="2em">
          <fo:table-cell>
           <fo:block font-weight="bold" text-align="right"
            >executive summary :</fo:block>
          </fo:table-cell>
          <fo:table-cell/>
          <fo:table-cell>
            <fo:block text-align="left">
               <xsl:value-of select="articleinfo/title"/>
            </fo:block>
         </fo:table-cell>
        </fo:table-row>
        <fo:table-row height="2em">
         <fo:table-cell>
            <fo:block font-weight="bold"
                      text-align="right">version date/time :</fo:block>
         </fo:table-cell>
         <fo:table-cell/>
         <fo:table-cell>
            <fo:block text-align="left">
               <xsl:value-of select="articleinfo/date"/>
            </fo:block>
         </fo:table-cell>
        </fo:table-row>
        <fo:table-row height="2em">
         <fo:table-cell>
            <fo:block
                      font-weight="bold" text-align="right">author :</fo:block>
         </fo:table-cell>
         <fo:table-cell/>
         <fo:table-cell>
            <fo:block text-align="left">
               <xsl:apply-templates select="articleinfo/author"/>
            </fo:block>
         </fo:table-cell>
        </fo:table-row>
        <fo:table-row height="2em">
         <fo:table-cell/>
         <fo:table-cell/>
         <fo:table-cell>
            <fo:block>
               <xsl:apply-templates select="articleinfo/abstract"/>
           </fo:block>
         </fo:table-cell>
        </fo:table-row>
      </fo:table-body>
   </fo:table>
</xsl:template>


<xsl:template name="article.titlepage.verso">
   <fo:block break-before='page'>
      <fo:leader leader-pattern="space" leader-pattern-width="0pt"/>
   </fo:block>
</xsl:template>


<xsl:template name="header.content"/>

<xsl:template name="footer.table">
  <xsl:param name="pageclass" select="''"/>
  <xsl:param name="sequence" select="''"/>
  <xsl:param name="position" select="''"/>
  <xsl:param name="gentext-key" select="''"/>

  <xsl:choose>
   <xsl:when test="$sequence != 'first'"><!-- Is this correct? -->
   <fo:table width="100%" border-top="1pt solid black" padding-top="1em">
      <fo:table-column column-width="20%" />
      <fo:table-column column-width="1%"/>
      <fo:table-column column-width="78%" />
      <fo:table-body text-align="left">
        <fo:table-row>
          <fo:table-cell>
           <fo:block font-weight="bold" text-align="right"
            >executive summary :</fo:block>
          </fo:table-cell>
          <fo:table-cell/>
          <fo:table-cell>
            <fo:block text-align="left">
               <xsl:value-of select="/article/articleinfo/title"/>
            </fo:block>
         </fo:table-cell>
        </fo:table-row>
        <fo:table-row>
         <fo:table-cell>
            <fo:block font-weight="bold"
                      text-align="right">version date/time :</fo:block>
         </fo:table-cell>
         <fo:table-cell/>
         <fo:table-cell>
            <fo:block text-align="left">
               <xsl:value-of select="articleinfo/date"/>
            </fo:block>
         </fo:table-cell>
        </fo:table-row>
        <fo:table-row>
         <fo:table-cell>
            <fo:block
                      font-weight="bold" text-align="right">author :</fo:block>
         </fo:table-cell>
         <fo:table-cell/>
         <fo:table-cell>
            <fo:block text-align-last="justify">
              <xsl:apply-templates select="articleinfo/author"/>
               <fo:leader leader-pattern="space"/>
               page <fo:page-number/> of <fo:page-number-citation ref-id="endofdoc"/>
            </fo:block>
         </fo:table-cell>
        </fo:table-row>
      </fo:table-body>
   </fo:table>
   </xsl:when>
  </xsl:choose>
</xsl:template>


<xsl:template match="article">
  <xsl:variable name="id">
    <xsl:call-template name="object.id"/>
  </xsl:variable>

  <xsl:variable name="master-reference">
    <xsl:call-template name="select.pagemaster"/>
  </xsl:variable>

  <fo:page-sequence hyphenate="{$hyphenate}"
                    master-reference="{$master-reference}">
    <xsl:attribute name="language">
      <xsl:call-template name="l10n.language"/>
    </xsl:attribute>
    <xsl:attribute name="format">
      <xsl:call-template name="page.number.format">
        <xsl:with-param name="master-reference" select="$master-reference"/>
      </xsl:call-template>
    </xsl:attribute>
    <xsl:attribute name="initial-page-number">
      <xsl:call-template name="initial.page.number">
        <xsl:with-param name="master-reference" select="$master-reference"/>
      </xsl:call-template>
    </xsl:attribute>

    <xsl:attribute name="force-page-count">
      <xsl:call-template name="force.page.count">
        <xsl:with-param name="master-reference" select="$master-reference"/>
      </xsl:call-template>
    </xsl:attribute>

    <xsl:attribute name="hyphenation-character">
      <xsl:call-template name="gentext">
        <xsl:with-param name="key" select="'hyphenation-character'"/>
      </xsl:call-template>
    </xsl:attribute>
    <xsl:attribute name="hyphenation-push-character-count">
      <xsl:call-template name="gentext">
        <xsl:with-param name="key" select="'hyphenation-push-character-count'"/>
      </xsl:call-template>
    </xsl:attribute>
    <xsl:attribute name="hyphenation-remain-character-count">
      <xsl:call-template name="gentext">
        <xsl:with-param name="key" select="'hyphenation-remain-character-count'"/>
      </xsl:call-template>
    </xsl:attribute>

    <xsl:apply-templates select="." mode="running.head.mode">
      <xsl:with-param name="master-reference" select="$master-reference"/>
    </xsl:apply-templates>

    <xsl:apply-templates select="." mode="running.foot.mode">
      <xsl:with-param name="master-reference" select="$master-reference"/>
    </xsl:apply-templates>

    <fo:flow flow-name="xsl-region-body">
      <xsl:call-template name="set.flow.properties">
        <xsl:with-param name="element" select="local-name(.)"/>
        <xsl:with-param name="master-reference" select="$master-reference"/>
      </xsl:call-template>

      <fo:block id="{$id}">
        <xsl:call-template name="article.titlepage"/>
      </fo:block>

      <xsl:variable name="toc.params">
        <xsl:call-template name="find.path.params">
          <xsl:with-param name="table" select="normalize-space($generate.toc)"/>
        </xsl:call-template>
      </xsl:variable>

      <xsl:if test="contains($toc.params, 'toc')">
        <xsl:call-template name="component.toc"/>
        <xsl:call-template name="component.toc.separator"/>
      </xsl:if>
      <xsl:apply-templates/>
      <fo:block id="endofdoc"/>
    </fo:flow>
  </fo:page-sequence>
</xsl:template>


</xsl:stylesheet>
