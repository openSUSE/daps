<?xml version="1.0" encoding="UTF-8"?>
<!-- $Id:  $ -->

<xsl:stylesheet version="1.0"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:fo="http://www.w3.org/1999/XSL/Format">

<!-- The color of our flyer; usually SUSE green -->
<xsl:param name="flyer.color">
  <xsl:variable name="pi">
    <xsl:choose>
      <xsl:when test="count(key('id', $rootid)) = 0">
        <xsl:call-template name="pi-attribute">
          <xsl:with-param name="pis"
            select="(/processing-instruction('suse-quickstart') | 
                     /*/processing-instruction('suse-quickstart'))[1]"/>
          <xsl:with-param name="attribute">color</xsl:with-param>
        </xsl:call-template>
      </xsl:when>
      <xsl:otherwise>
        <xsl:call-template name="pi-attribute">
          <xsl:with-param name="pis" select="key('id', $rootid)//processing-instruction('suse-quickstart')[1]"/>
          <xsl:with-param name="attribute">color</xsl:with-param>
        </xsl:call-template>
      </xsl:otherwise>
    </xsl:choose>    
  </xsl:variable>
  <!--<xsl:message>flyer.color:<xsl:value-of select="$pi"/></xsl:message>-->
  <xsl:choose>
   <xsl:when test="$pi = 'suse'">#70B926</xsl:when>
   <xsl:when test="$pi = 'dark-suse'">#0D5148</xsl:when>
   <xsl:when test="$pi = 'novell'">#f90823</xsl:when>
   <xsl:when test="$pi = 'daps'">#65a9d7</xsl:when>
   <!-- Default is now SUSE -->
   <xsl:otherwise>#70B926</xsl:otherwise>
  </xsl:choose> 
</xsl:param>

<!-- The URl to be printed at the top of the doc; usually www.suse.com -->
<xsl:param name="flyer.url">
  <xsl:variable name="pi">
    <xsl:choose>
      <xsl:when test="count(key('id', $rootid)) = 0">
        <xsl:call-template name="pi-attribute">
          <xsl:with-param name="pis"
            select="(/processing-instruction('suse-quickstart') | 
                     /*/processing-instruction('suse-quickstart'))[1]"/>
          <xsl:with-param name="attribute">url</xsl:with-param>
        </xsl:call-template>
      </xsl:when>
      <xsl:otherwise>
        <xsl:call-template name="pi-attribute">
          <xsl:with-param name="pis" select="key('id', $rootid)//processing-instruction('suse-quickstart')[1]"/>
          <xsl:with-param name="attribute">url</xsl:with-param>
        </xsl:call-template>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:variable>
  <!--<xsl:message>** flyer.url:<xsl:value-of select="$pi"/></xsl:message>-->
  
 <xsl:choose>
   <xsl:when test="$pi = ''">www.suse.com</xsl:when>
   <xsl:otherwise><xsl:value-of select="$pi"/></xsl:otherwise>
  </xsl:choose> 
</xsl:param>


<!-- Given by the Makefiles -->
<xsl:param name="styleroot"/>

<!-- Pointer to our logo -->
<xsl:param name="booktitlepage.color.logo" select="concat($styleroot, 'images/logos/suse-logo.svg')"/>
   

<!-- Our Layout -->
<xsl:param name="paper.type">A4</xsl:param>
<xsl:param name="page.width">
  <xsl:choose>
    <xsl:when test="$paper.type = 'novell'">21.75cm</xsl:when>
    <xsl:when test="$paper.type = 'A4' or $paper.type = 'a4'">210mm</xsl:when>
    <xsl:otherwise></xsl:otherwise>
  </xsl:choose>
</xsl:param>
<xsl:param name="page.height">
  <xsl:choose>
    <xsl:when test="$paper.type = 'novell'">27.9cm</xsl:when>
    <xsl:when test="$paper.type = 'A4' or $paper.type = 'a4'">297mm</xsl:when>
    <xsl:otherwise></xsl:otherwise>
  </xsl:choose>
</xsl:param>
<xsl:param name="double.sided">0</xsl:param>

<xsl:param name="header.rule" select="0"/>
<xsl:param name="footer.rule" select="0"/>

<xsl:param name="page.margin.outer">1.5cm</xsl:param>
<xsl:param name="page.margin.inner">1.5cm</xsl:param>

<xsl:param name="page.margin.top">10mm</xsl:param>
<xsl:param name="page.margin.bottom">5mm</xsl:param>
<xsl:param name="region.before.extent">0pt</xsl:param>

<xsl:param name="body.margin.top">0pt</xsl:param>
<xsl:param name="body.margin.bottom">10mm</xsl:param>
<xsl:param name="region.after.extent">1em</xsl:param>
<xsl:param name="body.start.indent">0pt</xsl:param>

<xsl:param name="column.count.body">
  <xsl:variable name="pi">
    <xsl:choose>
      <xsl:when test="count(key('id', $rootid)) = 0">
        <xsl:call-template name="pi-attribute">
          <xsl:with-param name="pis"
            select="(/processing-instruction('suse-quickstart') | 
                     /*/processing-instruction('suse-quickstart'))[1]"/>
          <xsl:with-param name="attribute">columns</xsl:with-param>
        </xsl:call-template>
      </xsl:when>
      <xsl:otherwise>
        <xsl:call-template name="pi-attribute">
          <xsl:with-param name="pis" select="key('id', $rootid)//processing-instruction('suse-quickstart')[1]"/>
          <xsl:with-param name="attribute">columns</xsl:with-param>
        </xsl:call-template>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:variable>
  
  <xsl:choose>
   <xsl:when test="normalize-space($pi) ='yes' or $pi=''">2</xsl:when>
   <xsl:otherwise>1</xsl:otherwise>
  </xsl:choose>
</xsl:param>
<xsl:param name="column.gap.body" select="'1.2cm'"/>

<xsl:param name="title.margin.left" select="'0pt'"/>

<xsl:param name="alignment">left</xsl:param>

<xsl:param name="draft.watermark.image" select="concat($styleroot, 'images/draft.png')"/>

<xsl:param name="refentry.pagebreak" select="0"/>

<!-- Add other variable definitions here -->
<xsl:param name="shade.verbatim">0</xsl:param>
<!-- <xsl:param name="callout.unicode.start.character" select="10122"/> -->
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


<xsl:param name="chapter.autolabel" select="0"/>
<!-- Activate numbering of sections -->
<xsl:param name="section.label.includes.component.label" select="1"/>
<xsl:param name="section.autolabel" select="0"/>
<xsl:param name="section.autolabel.max.depth" select="2"/>
<xsl:param name="autotoc.label.separator" select="' '"/>
<xsl:param name="toc.indent.width">15</xsl:param>
<xsl:param name="appendix.autolabel" select="'A'"/>

<!-- Control generation of ToCs and LoTs -->
<xsl:param name="generate.toc"/>

<xsl:param name="toc.section.depth">1</xsl:param>

<!-- Format variablelists lists as blocks? -->
<xsl:param name="variablelist.as.blocks" select="1"/>

<!-- Present glossarys using blocks instead of lists? -->
<xsl:param name="glossary.as.blocks" select="1"/>

<!-- Default punctuation character on a run-in-head -->
<xsl:param name="runinhead.default.title.end.punct" select="''"/>

<!-- Default width of tables -->
<xsl:param name="default.table.width">100%</xsl:param>
<xsl:param name="table.frame.border.style">none</xsl:param>
<xsl:param name="table.cell.border.style">none</xsl:param>


<!--<xsl:param name="autotoc.label.separator" select="'
'"></xsl:param>-->

<!-- Use blocks for glosslists? -->
<xsl:param name="glosslist.as.blocks" select="1"/>

<xsl:param name="menuchoice.separator"> &#x2192; </xsl:param>
<xsl:param name="menuchoice.menu.separator"> &#x2192; </xsl:param>
<xsl:param name="preferred.mediaobject.role">fo</xsl:param>
<xsl:param name="ulink.hyphenate">&#x200B;</xsl:param>
<xsl:param name="ulink.show" select="1"/>

<xsl:param name="img.src.path">../.images/print/</xsl:param>

<xsl:param name="local.l10n.xml" select="document('../../common/l10n/l10n.xml')"/>

<xsl:param name="insert.xref.page.number">yes</xsl:param>

<!-- Should I markup paras with @arch? -->
<xsl:param name="para.use.arch" select="1"/>


<!-- Characters for the hyphenation algorithm:
    Contains characters hyhenated before or after other text
-->
<xsl:param name="ulink.hyphenate.before.chars"
    >.,%?&amp;#\~+{_</xsl:param>
<xsl:param name="ulink.hyphenate.after.chars"
    >/:@=};</xsl:param>
  
<xsl:param name="warn.xrefs.into.diff.lang" select="1"/>  

<xsl:param name="debug.fonts" select="1"/>
  
<!-- Should the SUSE processing instruction be resolved? -->
<xsl:param name="resolve.suse-pi" select="1"/>


<!-- Overwrite the body font family with Sans Serif -->
<xsl:param name="body.font.family" select="$sans.font.family"/>

<!-- Overwrite dingbat fonts -->
<xsl:param name="dingbat.font.family">
  <xsl:value-of select="$sans.font.family"/>
</xsl:param>

 <!-- Should XEP use PDF annotations?  -->
  <xsl:param name="use.xep.annotate.pdf" select="1"/>
</xsl:stylesheet>
