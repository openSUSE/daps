<?xml version="1.0" encoding="ISO-8859-1"?>
<!-- $Id:  $ -->
<xsl:stylesheet version="1.0"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:fo="http://www.w3.org/1999/XSL/Format"
    xmlns:exsl="http://exslt.org/common"
    exclude-result-prefixes="exsl">

<!-- Import the current version of the stylesheets  -->
<xsl:import href="http://docbook.sourceforge.net/release/xsl/current/fo/docbook.xsl"/>

<xsl:import href="../../profiling/suse-pi.xsl"/>
<xsl:import href="../../fo/fonts.xsl"/>

<xsl:import href="../../fo/hyphenate-url.xsl"/> 

<xsl:import href="../../fo/admon.xsl"/>
<xsl:import href="../../fo/pi.xsl"/>
<!--<xsl:import href="../../fo/verbatim.xsl"/>-->
<xsl:import href="../../fo/xref.xsl"/>
<xsl:import href="../../fo/mode-object.title.markup.xsl"/>
   
 <xsl:output method="xml" indent="yes" encoding="UTF-8"/>


 <xsl:include href="param.xsl"/>
 <xsl:include href="attributesets.xsl"/>
 <xsl:include href="component.xsl"/>
 <xsl:include href="lists.xsl"/>
 <xsl:include href="sections.xsl"/> 
 <xsl:include href="inline.xsl"/>
 <xsl:include href="synop.xsl"/>
 
 <xsl:include href="footer.xsl"/>
 <xsl:include href="header.xsl"/>
 

<!-- Use cropmarks? -->
<xsl:param name="use.xep.cropmarks" select="1"/>

<!-- Use extensions -->
<xsl:param name="xep.extensions">1</xsl:param>
<xsl:param name="fop.extensions">0</xsl:param>

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
