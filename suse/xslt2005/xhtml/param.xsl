<?xml version="1.0"?>
<!-- 
   Purpose:  Contains all parameters for (X)HTML
-->


<xsl:stylesheet version="1.0"
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns="http://www.w3.org/1999/xhtml">

<xsl:param name="html.stylesheet">susebooks.css</xsl:param>

<xsl:param name="chunk.fast" select="1"/>
<xsl:param name="chunk.section.depth" select="0"/>
 
<!-- Navigational graphics -->
<xsl:param name="navig.graphics" select="1"/>
<xsl:param name="navig.graphics.path">navig/</xsl:param>
<xsl:param name="navig.graphics.extension" select="'.png'"/>

<xsl:param name="admon.graphics" select="1"/>
<xsl:param name="admon.graphics.path">admon/</xsl:param>
<xsl:param name="admon.graphic.width" select="32"/>
<!-- The width of admonition graphics -->
<!--<xsl:param name="admon.graphic.width">25</xsl:param>-->
<xsl:param name="admon.style" select="''"/>

<xsl:param name="callout.graphics.path">callouts/</xsl:param>

<!-- Prefix path for every filename, has to end with "/" -->
<xsl:param name="graphics.path">images/</xsl:param>

<xsl:param name="draft.watermark.image">style_images/draft_html.png</xsl:param>

<!--

<xsl:param name="callout.unicode" select="1"/>
<xsl:param name="callout.graphics" select="'0'"/>
-->

<xsl:param name="use.id.as.filename" select="1"/>

<!-- Generate a list of all HTML files? -->
<!-- <xsl:param name="generate.manifest" select="1"/> -->

<xsl:param name="root.filename">index</xsl:param>

<xsl:param name="header.rule" select="false()"/>
<xsl:param name="footer.rule" select="false()"/>

<xsl:param name="toc.section.depth" select="1"/>
<xsl:param name="section.autolabel" select="1"/>
<xsl:param name="section.label.includes.component.label" select="1"/>
<xsl:param name="generate.toc">
book     toc,title,figure,table,example
article  toc,title
appendix toc,title
chapter  toc,title
part     toc,title
set      toc,title
</xsl:param>

<xsl:param name="img.src.path">images/</xsl:param><!-- DB XSL Version >=1.67.1 -->
<xsl:param name="base.dir">./html/</xsl:param>

<xsl:param name="idvalue.sep" select="' '"/>

<!-- Use customized language files -->
<xsl:param name="local.l10n.xml" select="document('../common/l10n/l10n.xml')"/>

<xsl:param name="generate.legalnotice.link" select="1"/>

<!-- Output permalinks?                                      -->
<xsl:param name="generate.permalink" select="1"/>


<!-- Should manifest file be saved in the current directory 0=yes, 1=no -->
<!-- <xsl:param name="manifest.in.base.dir" select="1"/> -->

<!-- Should I markup paras with @arch? -->
<xsl:param name="para.use.arch" select="'1'"/>

<!-- Should information from SVN properties be used? yes|no -->
<xsl:param name="use.meta" select="0"/>

<!-- Display minitocs from Provo? display=1, suppress=0 -->
<xsl:param name="provo.minitoc" select="'0'"/>

<!-- Should I generate breadcrumbs navigation?  -->
<xsl:param name="generate.breadcrumbs" select="1"/>
<!-- Separator between separate links: -->
<xsl:param name="breadcrumbs.separator"> &gt; </xsl:param>
<!-- Navigation "Icons" for breadcrumbs: -->
<xsl:param name="breadcrumbs.prev">&#9664;<!--&#9668;--></xsl:param>
<xsl:param name="breadcrumbs.next">&#9654;<!--&#9658;--></xsl:param>

<!--  Output a warning, if chapter/@lang is different from book/@lang ? -->
<xsl:param name="warn.xrefs.into.diff.lang" select="1"/>

<!-- Show remarks? 0=no, 1=yes -->
<xsl:param name="show.comments" select="1"/>
  
</xsl:stylesheet>
