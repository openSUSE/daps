<?xml version="1.0" encoding="UTF-8"?>
<!-- $Id: param.xsl 43437 2009-08-05 12:07:33Z toms $ -->

<xsl:stylesheet version="1.0"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:fo="http://www.w3.org/1999/XSL/Format"
>

<!-- Metadata -->
<xsl:param name="metadata.producer">SUSE Linux Products GmbH</xsl:param>

<!-- Our Layout -->
<xsl:param name="paper.type">NOVELL/SUSE Layout:</xsl:param>
<xsl:param name="page.height">612pt</xsl:param>
<xsl:param name="page.width">504pt</xsl:param>
<xsl:param name="double.sided">1</xsl:param>

<xsl:param name="header.rule" select="0"/>
<xsl:param name="footer.rule" select="0"/>

<xsl:param name="page.margin.outer">90pt</xsl:param>
<xsl:param name="page.margin.inner">54pt</xsl:param>

<xsl:param name="page.margin.top">54pt</xsl:param>
<xsl:param name="page.margin.bottom">24pt</xsl:param>
<xsl:param name="region.before.extent">0pt</xsl:param>

<xsl:param name="body.margin.top">0pt</xsl:param>
<xsl:param name="body.margin.bottom">30pt</xsl:param>
<xsl:param name="region.after.extent">1em</xsl:param>
<xsl:param name="body.start.indent">0pt</xsl:param>

<xsl:param name="title.margin.left" select="'0pt'"/>

<xsl:param name="alignment">left</xsl:param>

<!-- Path to stylesheets -->
<xsl:param name="styleroot"></xsl:param>

<xsl:param name="draft.watermark.image" select="concat($styleroot, 'images/draft.png')"/>

<!--  -->
<xsl:param name="booktitlepage.bw.logo" select="concat($styleroot, 'images/logos/suse-logo-bw.svg')"/>
<xsl:param name="booktitlepage.color.logo" select="concat($styleroot, 'images/logos/suse-logo.svg')"/>

<xsl:param name="booktitlepage.url">www.suse.com</xsl:param>


<!-- Font sizes for Legal Text with sect1[@role='legal'] -->
<xsl:param name="legal.body.size" select="$body.font.master div 1.75"/>
<xsl:param name="legal.title.size" select="$body.font.master div 1.5"/>


<!-- Add other variable definitions here -->
<xsl:param name="shade.verbatim">0</xsl:param>
<xsl:param name="callout.unicode">0</xsl:param>
<xsl:param name="callout.graphics">1</xsl:param>
<xsl:param name="callout.xep.graphics.extension">.pdf</xsl:param>
<xsl:param name="callout.fop.graphics.extension">.svg</xsl:param>
<xsl:param name="callout.graphics.extension">
   <xsl:choose>
      <xsl:when test="$fop1.extensions != 0">
         <xsl:value-of select="$callout.fop.graphics.extension"/>
      </xsl:when>
      <xsl:otherwise>
         <xsl:value-of select="$callout.xep.graphics.extension"/>
      </xsl:otherwise>
   </xsl:choose>
</xsl:param>
<xsl:param name="callout.graphics.path" select="concat($styleroot, 'images/callouts/')"/>
  
<!--<xsl:param name="callout.unicode.start.character">10102</xsl:param>-->
<!--<xsl:param name="callout.unicode.font">TomsCallouts</xsl:param>-->
<xsl:param name="callout.unicode.number.limit">30</xsl:param>
<!-- <xsl:param name="callout.unicode.start.character" select="10122"/> -->

<!-- Activate numbering of sections -->
<xsl:param name="section.label.includes.component.label" select="1"/>
<xsl:param name="section.autolabel" select="1"/>
<xsl:param name="refsection.autolabel" select="0"/><!-- Not available in DB XSL -->
<xsl:param name="section.autolabel.max.depth" select="3"/>
<xsl:param name="autotoc.label.separator" select="' '"/>
<xsl:param name="toc.indent.width">15</xsl:param>
<xsl:param name="appendix.autolabel" select="'A'"/>

<!-- Control generation of ToCs and LoTs -->
<xsl:param name="generate.toc">
/appendix toc,title
article/appendix  nop
/article  toc,title
book      toc,title
chapter   nop
part      nop
/preface  nop
qandadiv  toc
qandaset  toc
reference toc,title
/sect1    toc
/sect2    toc
/sect3    toc
/sect4    toc
/sect5    toc
/section  toc
set       nop
</xsl:param>


<!-- Added parameter for FOP 1 with standard value.
     Only necessary for DocBook stylesheets 
     version < 1.71.0 -->
<xsl:param name="fop1.extensions" select="0"/>

<!-- Both parameters (refentry.generate.name and refentry.generate.title) 
     are mutually exclusive. If you set one parameter to 1 you have to set
     the other to 0.
-->
<!-- Output NAME header before 'RefName'(s)? -->
<xsl:param name="refentry.generate.name" select="0"/>
<!-- Output title before 'RefName'(s)? -->
<xsl:param name="refentry.generate.title" select="1"/>

<!-- Print title with manvolume in brackets? -->
<xsl:param name="refentry.usemanvolume" select="1"/> 
 
 
<!-- FO formatter dependend index generation -->
<xsl:param name="generate.fop.index" select="0"/>
<xsl:param name="generate.xep.index" select="1"/>

<xsl:param name="indexfile"></xsl:param>


<!-- Do you want an index? -->
<xsl:param name="generate.index">
  <xsl:choose>
    <xsl:when test="$fop1.extensions != 0">
      <xsl:value-of select="$generate.fop.index"/>
    </xsl:when>
   <xsl:when test="$xep.extensions != 0">
      <xsl:value-of select="$generate.xep.index"/>
   </xsl:when>
   <xsl:otherwise>
     <xsl:message>Neither FOP nor XEP used. Disableing index.</xsl:message>
     <xsl:text>0</xsl:text>
   </xsl:otherwise>
  </xsl:choose>
</xsl:param>

<!--  -->
<xsl:param name="toc.section.depth">1</xsl:param>

<!-- Format variablelists lists as blocks? -->
<xsl:param name="variablelist.as.blocks" select="1"/>

<!-- Present glossarys using blocks instead of lists? -->
<xsl:param name="glossary.as.blocks" select="1"/>

<!-- Default punctuation character on a run-in-head -->
<xsl:param name="runinhead.default.title.end.punct" select="''"/>

<!-- Should I number procedure substeps recursivly? -->
<xsl:param name="procedure.number.recursive" select="1"/>

<!-- Default width of tables -->
<xsl:param name="default.table.width">100%</xsl:param>
<xsl:param name="default.table.frame">topbot</xsl:param>
<xsl:param name="table.frame.border.style">solid</xsl:param>
<xsl:param name="table.cell.border.style">dotted</xsl:param>

<!-- Should information from SVN properties be used? yes|no -->
<xsl:param name="use.meta" select="0"/>

<!--<xsl:param name="autotoc.label.separator" select="'
'"></xsl:param>-->

<!-- Use blocks for glosslists? -->
<xsl:param name="glosslist.as.blocks" select="1"/>

<xsl:param name="menuchoice.separator"> > </xsl:param>
<xsl:param name="menuchoice.menu.separator"> > </xsl:param>
<xsl:param name="preferred.mediaobject.role">fo</xsl:param>
<xsl:param name="ulink.hyphenate">
<xsl:choose>
  <xsl:when test="$xep.extensions != 0 or $axf.extensions != 0">&#x200B;</xsl:when>
  <xsl:when test="$fop1.extensions != 0"></xsl:when><!-- See also bnc#706452​ -->
  <xsl:otherwise/>
</xsl:choose>
</xsl:param>
<xsl:param name="ulink.show" select="0"/>

<xsl:param name="img.src.path">../.images/print/</xsl:param>

<xsl:param name="admon.graphics">
   <xsl:choose>
      <xsl:when test="name(/*)='article'">1</xsl:when>
      <xsl:otherwise>0</xsl:otherwise>
   </xsl:choose>
</xsl:param>
<xsl:param name="admon.graphics.extension">.svg</xsl:param>
<xsl:param name="admon.graphics.path" select="concat($styleroot, 'images/')"/>


<xsl:param name="local.l10n.xml" select="document('../common/l10n/l10n.xml')"/>

<!-- format.print = 1: print, 0: online -->
<xsl:param name="format.print">1</xsl:param>

<xsl:param name="insert.xref.page.number">yes</xsl:param>

<!-- Should I markup paras with @arch? -->
<xsl:param name="para.use.arch" select="1"/>

<!--  Output a warning, if chapter/@lang is different from book/@lang ? -->
<xsl:param name="warn.xrefs.into.diff.lang" select="1"/>

<!-- Characters for the hyphenation algorithm: 
     Contains characters hyhenated before or after other text 
-->
<xsl:param name="ulink.hyphenate.before.chars"
   >.,%?&amp;#\~+{_-</xsl:param>
<xsl:param name="ulink.hyphenate.after.chars"
   >/:@=};</xsl:param>
<xsl:param name="hyphenate.verbatim" select="1"/>

<!-- Debug Parameters -->
<xsl:param name="debug.fonts" select="1"/>

<!--  -->
<xsl:param name="orderedlist.label.width">1em</xsl:param>


</xsl:stylesheet>
