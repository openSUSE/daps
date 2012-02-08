<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0"
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:fo="http://www.w3.org/1999/XSL/Format">

<xsl:import href="../../fo/docbook.xsl"/>

<xsl:output method="xml" indent="yes" encoding="UTF-8"/>

<xsl:include href="param.xsl"/>
<xsl:include href="attributesets.xsl"/>
<xsl:include href="fonts.xsl"/> 
<xsl:include href="titlepage.xsl"/>
<xsl:include href="booktitlepage.xsl"/>
<xsl:include href="inline.xsl"/>
<xsl:include href="lists.xsl"/>

<xsl:include href="footer.xsl"/>

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
      
    Used Layout = "<xsl:value-of select="$paper.layout"/>"
    
    Used Fonts for this Language:
    <xsl:value-of select="$paper.layout"/>.body.font.family = "<xsl:value-of select="$body.font.family"/>"
    <xsl:value-of select="$paper.layout"/>.sans.font.family = "<xsl:value-of select="$sans.font.family"/>"
    <xsl:value-of select="$paper.layout"/>.monospace.font.family = "<xsl:value-of select="$monospace.font.family"/>"
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
