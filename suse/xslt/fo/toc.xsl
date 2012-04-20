<?xml version="1.0" encoding="UTF-8"?>
<!-- $Id: toc.xsl 43787 2009-08-25 13:31:36Z toms $ -->
<xsl:stylesheet version="1.0"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:fo="http://www.w3.org/1999/XSL/Format">


<xsl:template name="keep-with-next-or-not">
  <xsl:choose>
    <xsl:when test="$xep.extensions != 0">
      <xsl:attribute name="keep-with-next">always</xsl:attribute>
    </xsl:when>
    <!-- Do nothing for FOP 1.x -->
    <xsl:when test="$fop1.extensions != 0"/>
  </xsl:choose>
</xsl:template>


  <xsl:template name="toc.line">
    <xsl:param name="node" select="."/>
    <xsl:apply-templates select="$node" mode="toc.line"/>
  </xsl:template>



<xsl:template match="preface|glossary|bibliography" mode="toc.line">
  <xsl:variable name="id">
    <xsl:call-template name="object.id"/>
  </xsl:variable>
  
  <fo:block text-align-last="justify" 
      space-before="27pt -1em"
      space-after="16pt -1.5em"
      xsl:use-attribute-sets="toc.title.chapapp.properties">
      <fo:basic-link internal-destination="{$id}">
        <xsl:apply-templates select="." mode="title.markup"/>
        <fo:leader leader-pattern="space"/>
        <fo:page-number-citation ref-id="{$id}"/>
      </fo:basic-link>
  </fo:block>
</xsl:template>

<xsl:template match="preface/sect1|preface/section" mode="toc.line">
  <!-- Nothing to do here -->
</xsl:template>


<xsl:template match="book|article|part" mode="toc.line">
  <xsl:variable name="id">
    <xsl:call-template name="object.id"/>
  </xsl:variable>
  <xsl:message>toc.line: <xsl:value-of select="local-name(.)"/></xsl:message>
   
  <fo:list-block 
      space-before="27pt -1em"
      space-after="16pt -1em"
      provisional-distance-between-starts="18pt"
      provisional-label-separation="3pt">
      <fo:list-item xsl:use-attribute-sets="toc.title.part.properties">
        <fo:list-item-label end-indent="label-end()">
          <fo:block>
            <xsl:apply-templates select="." mode="label.markup"/>
            <xsl:value-of select="$autotoc.label.separator"/>
          </fo:block>
        </fo:list-item-label>
        <fo:list-item-body start-indent="body-start()">
          <fo:block text-align-last="justify">
            <fo:basic-link internal-destination="{$id}">
              <xsl:apply-templates select="." mode="title.markup"/>
              <fo:leader leader-pattern="space"/>
              <fo:page-number-citation ref-id="{$id}" />
            </fo:basic-link>
          </fo:block>
        </fo:list-item-body>
      </fo:list-item>
    </fo:list-block>
  
</xsl:template>

<xsl:template match="chapter|appendix" mode="toc.line">
  <xsl:variable name="id">
    <xsl:call-template name="object.id"/>
  </xsl:variable>
   
  <fo:list-block
      provisional-distance-between-starts="18pt"
      provisional-label-separation="3pt"
      space-before="27pt -1em"
      space-after="2pt">
    <xsl:call-template name="keep-with-next-or-not"/>
      <fo:list-item xsl:use-attribute-sets="toc.title.chapapp.properties">
        <fo:list-item-label end-indent="label-end()">
          <fo:block>
            <xsl:apply-templates select="." mode="label.markup"/>
            <xsl:value-of select="$autotoc.label.separator"/>
          </fo:block>
        </fo:list-item-label>
        <fo:list-item-body start-indent="body-start()">
          <fo:block text-align-last="justify">
            <fo:basic-link internal-destination="{$id}">
              <xsl:apply-templates select="." mode="title.markup"/>
              <fo:leader leader-pattern="space"/>
              <fo:page-number-citation ref-id="{$id}" />
            </fo:basic-link>
          </fo:block>
        </fo:list-item-body>
      </fo:list-item>
    </fo:list-block>
  
</xsl:template>

<xsl:template match="chapter/sect1|chapter/section
                     |appendix/sect1|appendix/section
                     |article/sect1|article/section" mode="toc.line">
  <xsl:variable name="id">
    <xsl:call-template name="object.id"/>
  </xsl:variable>
  <xsl:message>toc.line: <xsl:value-of select="local-name(.)"/></xsl:message>
  
  <fo:list-block
    provisional-distance-between-starts="27pt"
    provisional-label-separation="3pt">
   <fo:list-item xsl:use-attribute-sets="toc.title.section.properties">
    <fo:list-item-label end-indent="label-end()">
      <fo:block>
        <xsl:apply-templates select="." mode="label.markup"/>
      </fo:block>      
    </fo:list-item-label>
    <fo:list-item-body start-indent="body-start()">
      <fo:block>
        <fo:block text-align-last="justify">
            <fo:basic-link internal-destination="{$id}">
              <xsl:apply-templates select="." mode="title.markup"/>
              <fo:leader leader-pattern="dots" leader-pattern-width="1em"/>
              <fo:page-number-citation ref-id="{$id}" />
            </fo:basic-link>
          </fo:block>
      </fo:block>
    </fo:list-item-body>
   </fo:list-item>
  </fo:list-block>
</xsl:template>

<xsl:template match="refentry" mode="toc.line">
  <xsl:variable name="id">
    <xsl:call-template name="object.id"/>
  </xsl:variable>
  <xsl:message>toc.line: <xsl:value-of select="local-name(.)"/></xsl:message>
  
    <fo:block xsl:use-attribute-sets="toc.title.section.properties"
       text-align-last="justify">
      <fo:basic-link internal-destination="{$id}">
        <xsl:apply-templates select="." mode="title.markup"/>
        <fo:leader leader-pattern="dots" leader-pattern-width="1em"/>
        <fo:page-number-citation ref-id="{$id}"/>
      </fo:basic-link>
    </fo:block>
</xsl:template>

<xsl:template match="*" mode="toc.line">
    <xsl:message>*** Unknown element "<xsl:value-of
      select="local-name()"/>" for toc.line</xsl:message>
</xsl:template>
  
</xsl:stylesheet>
