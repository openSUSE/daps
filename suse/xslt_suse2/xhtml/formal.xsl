<?xml version="1.0" encoding="UTF-8"?>
<!-- 
  Purpose:
     Splitting formal-wise titles into number and title

   Author(s):    Thomas Schraitle <toms@opensuse.org>
   Copyright: 2012, Thomas Schraitle

-->
<xsl:stylesheet version="1.0"
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:exsl="http://exslt.org/common"
  xmlns="http://www.w3.org/1999/xhtml"
  exclude-result-prefixes="exsl">


  <xsl:template
    match="procedure|example|table|figure|variablelist|itemizedlist|orderedlist"
    mode="object.label.template">
    <xsl:call-template name="gentext.template">
      <xsl:with-param name="context" select="'styles'"/>
      <xsl:with-param name="name" select="concat( local-name(),'-label')"/>
    </xsl:call-template>
  </xsl:template>
  
  <xsl:template match="procedure|example|table|figure|variablelist|itemizedlist|orderedlist"
    mode="object.title.template">
    <xsl:call-template name="gentext.template">
      <xsl:with-param name="context" select="'styles'"/>
      <xsl:with-param name="name" select="concat( local-name(),'-title')"/>
    </xsl:call-template>
  </xsl:template>
  

  <xsl:template name="create.formal.title">
    <xsl:param name="node" select="."/>
    <xsl:variable name="label.template">
      <xsl:apply-templates select="$node" mode="object.label.template"/>
    </xsl:variable>
    
    <xsl:if test="$label.template != ''">
      <span class="number">
        <xsl:call-template name="substitute-markup">
          <xsl:with-param name="template" select="$label.template"/>
        </xsl:call-template>
        <xsl:text> </xsl:text>
      </span>
    </xsl:if>
    <span class="name">
      <xsl:apply-templates select="$node" mode="title.markup">
        <xsl:with-param name="allow-anchors" select="1"/>
      </xsl:apply-templates>
      <xsl:text> </xsl:text>
    </span>
  </xsl:template>
  
  <!-- ===================================================== -->
  <xsl:template name="formal.object.heading">
  <xsl:param name="object" select="."/>
  <xsl:param name="title">
    <xsl:call-template name="create.formal.title">
      <xsl:with-param name="node" select="$object"/>
    </xsl:call-template>
  </xsl:param>
    
    <div class="{concat(local-name(),'-title-wrap')}">
      <p class="{concat(local-name(), '-title')}">
        <xsl:copy-of select="$title"/>
        <xsl:call-template name="create.permalink">
          <xsl:with-param name="object" select="$object"/>
        </xsl:call-template>
      </p>
    </div>
  </xsl:template>

</xsl:stylesheet>
