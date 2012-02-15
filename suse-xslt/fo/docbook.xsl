<?xml version="1.0" encoding="UTF-8"?>
<!-- $Id: docbook.xsl 36008 2008-10-21 11:24:36Z toms $ -->
<xsl:stylesheet version="1.0"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:fo="http://www.w3.org/1999/XSL/Format"
>

<!-- Import the current version of the stylesheets  -->
<!--<xsl:import href="cropmarks.xsl"/>-->
<xsl:import href="http://docbook.sourceforge.net/release/xsl/current/fo/docbook.xsl"/>
<xsl:import href="param.xsl"/>

<xsl:output method="xml" indent="yes" encoding="UTF-8"/>

<xsl:include href="../profiling/suse-pi.xsl"/>
<xsl:include href="attributesets.xsl"/>
<xsl:include href="fonts.xsl"/>
<xsl:include href="../common/copy-nodes.xsl"/>
<xsl:include href="../common/common.xsl"/>
<xsl:include href="../common/titles.xsl"/>
<xsl:include href="../common/l10n.xsl"/>


<!-- <xsl:include href="autoidx-kosek.xsl"/> -->
<!-- <xsl:include href="autoidx.xsl"/> -->
<xsl:include href="lists.xsl"/>
<!--<xsl:include href="callout.xsl"/>-->
<xsl:include href="verbatim.xsl"/>
<xsl:include href="xref.xsl"/>
<xsl:include href="table.xsl"/>
<xsl:include href="sections.xsl"/>
<xsl:include href="inline.xsl"/>

<xsl:include href="footer.xsl"/>
<xsl:include href="header.xsl"/>
<xsl:include href="hyphenate-url.xsl"/>
<xsl:include href="index.xsl"/>
<xsl:include href="toc.xsl"/>
<xsl:include href="refentry.xsl"/>
<xsl:include href="admon.xsl"/>
<xsl:include href="component.xsl"/>
<xsl:include href="glossary.xsl"/>
<xsl:include href="block.xsl"/>

<xsl:include href="redefinitions.xsl"/>
<xsl:include href="booktitlepage.xsl"/>
<xsl:include href="articletitlepage.xsl"/>
<xsl:include href="titlepages.xsl"/>

<xsl:include href="pi.xsl"/>
<!--<xsl:include href="fop1.xsl"/>-->
<xsl:include href="xep.xsl"/>


<!-- Use cropmarks? -->
<xsl:param name="use.xep.cropmarks" select="1"/>

<!-- Use extensions -->
<xsl:param name="xep.extensions">1</xsl:param>
<xsl:param name="fop.extensions">0</xsl:param>
<xsl:param name="fop1.extensions">0</xsl:param>


<xsl:template match="/">
   <xsl:variable name="rootidname">
     <xsl:choose>
        <xsl:when test="name(key('id', $rootid))">
           <xsl:value-of select="name(key('id', $rootid))"/>
        </xsl:when>
        <xsl:otherwise>
           <xsl:value-of select="name(/*)"/>
        </xsl:otherwise>
     </xsl:choose>
   </xsl:variable>

   <xsl:if test="$styleroot = ''">
     <xsl:message>
       <xsl:text>WARNING: Please set path to your stylesheets </xsl:text>
       <xsl:text>with the --styleroot parameter or via STYLEROOT in the config
    file</xsl:text>
     </xsl:message>
   </xsl:if>
  
  <!--<xsl:message>
    styleroot = <xsl:value-of select="$styleroot"/>
  </xsl:message>-->

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

   <xsl:choose>
      <xsl:when test="$rootidname = 'article' or
                $rootidname = 'chapter' or
                $rootidname = 'appendix' or
                $rootidname = 'set' or
                $rootidname = 'book' or
                $rootidname = 'preface' or
                $rootidname = 'glossary' or
                $rootidname = 'part' or
                $rootidname = 'reference'">
         <xsl:apply-imports/>
      </xsl:when>
      <xsl:otherwise>
         <xsl:message terminate="yes">
        <xsl:text>&#10; ERROR: The element »</xsl:text>
        <xsl:value-of select="$rootidname"/>
        <xsl:text>« can not be used for the rootid feature!&#10;&#10;</xsl:text>
     </xsl:message>
      </xsl:otherwise>
   </xsl:choose>
</xsl:template>


<xsl:template name="root.messages">
  
  <xsl:if test="$debug.fonts != 0">
    <xsl:message>DEBUG: Information about fonts:
    detected language = "<xsl:call-template name="l10n.language">
          <xsl:with-param name="target"
            select="(/* | key('id', $rootid))[last()]"/>
        </xsl:call-template>"
    
    Used Extension = "<xsl:choose>
      <xsl:when test="$xep.extensions != 0">XEP</xsl:when>
      <xsl:when test="$fop1.extensions != 0">FOP > 0.9x</xsl:when>
      <xsl:when test="$fop.extensions != 0">FOP 0.2</xsl:when>
      <xsl:otherwise>Unknown</xsl:otherwise>
    </xsl:choose>"
    
    Used Fonts for this Language:
    body.font.family = "<xsl:value-of select="$body.font.family"/>"
    sans.font.family = "<xsl:value-of select="$sans.font.family"/>"
    monospace.font.family = "<xsl:value-of select="$monospace.font.family"/>"
    </xsl:message>
  </xsl:if>
  
  <xsl:if test="$projectfile = ''">
    <xsl:message>WARNING: Parameter for projectfile is empty!</xsl:message>
  </xsl:if>
  
  <!-- Explicitly insert the original message, xsl:apply-imports don't
    work here
  -->
  <xsl:message>
    <xsl:text>Making </xsl:text>
    <xsl:value-of select="$page.orientation"/>
    <xsl:text> pages on </xsl:text>
    <xsl:value-of select="$paper.type"/>
    <xsl:text> paper (</xsl:text>
    <xsl:value-of select="$page.width"/>
    <xsl:text>x</xsl:text>
    <xsl:value-of select="$page.height"/>
    <xsl:text>)</xsl:text>
  </xsl:message>  
</xsl:template>

</xsl:stylesheet>
