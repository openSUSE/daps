<?xml version="1.0" encoding="UTF-8"?>
<!-- 
  
  Run it as follows:

  $ xsltproc -xinclude chunk.xsl YOUR_XML_FILE.xml

-->

<!DOCTYPE xsl:stylesheet
[
  <!ENTITY www "http://docbook.sourceforge.net/release/xsl/current/xhtml">
]>
<xsl:stylesheet version="1.0"
  xmlns:exsl="http://exslt.org/common"
  xmlns="http://www.w3.org/1999/xhtml"
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  exclude-result-prefixes="exsl">
  
  <xsl:import href="&www;/chunk.xsl"/>
  <!--<xsl:import href="&www;/chunk-common.xsl"/>
  <xsl:include href="&www;/manifest.xsl"/>
  <xsl:include href="&www;/chunk-code.xsl"/>-->

  <xsl:include href="param.xsl"/>
  
  <xsl:template name="chunk-element-content">
  <xsl:param name="prev"/>
  <xsl:param name="next"/>
  <xsl:param name="nav.context"/>
  <xsl:param name="content">
    <xsl:apply-imports/>
  </xsl:param>

  <!--<xsl:message>chunk-element-content: <xsl:value-of select="local-name()"/></xsl:message>-->
  <xsl:copy-of select="$content"/>
</xsl:template>

  <xsl:template name="generate.manifest" priority="10">
  <xsl:param name="node" select="/"/>
  <xsl:call-template name="write.text.chunk">
    <xsl:with-param name="filename">
      <xsl:if test="$manifest.in.base.dir != 0">
        <xsl:value-of select="$chunk.base.dir"/>
      </xsl:if>
      <xsl:value-of select="$manifest"/>
    </xsl:with-param>
    <xsl:with-param name="method" select="'text'"/>
    <xsl:with-param name="content">
      <xsl:apply-templates select="$node" mode="enumerate-files"/>
    </xsl:with-param>
    <xsl:with-param name="encoding" select="$chunker.output.encoding"/>
  </xsl:call-template>
</xsl:template>
  
  <xsl:template match="set|book|part|preface|chapter|appendix
                       |article|topic|reference|refentry
                       |sect1|sect2|sect3|sect4|sect5|section
                       |book/glossary|article/glossary|part/glossary
                       |book/bibliography|article/bibliography|part/bibliography
                       |colophon" mode="enumerate-files">
  <xsl:variable name="ischunk"><xsl:call-template name="chunk"/></xsl:variable>
  <xsl:if test="$ischunk='1'">
    <xsl:variable name="title">
      <xsl:apply-templates select="." mode="title.markup"/>
    </xsl:variable>
    
    <xsl:value-of select="concat(local-name(.), $manifest.separator)"/>
    
    <xsl:call-template name="make-relative-filename">
      <xsl:with-param name="base.dir" select="''"/>
      <xsl:with-param name="base.name">
        <xsl:apply-templates mode="chunk-filename" select="."/>
      </xsl:with-param>
    </xsl:call-template>
    
    <xsl:value-of select="concat($manifest.separator, $title, '&#10;')"/>
  </xsl:if>
  <xsl:apply-templates select="*" mode="enumerate-files"/>
</xsl:template>
  
  
  
</xsl:stylesheet>