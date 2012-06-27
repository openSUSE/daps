<?xml version="1.0" encoding="ISO-8859-1"?>
<!-- $Id: chunk.xsl 10322 2006-06-27 08:17:07Z toms $ -->
<!DOCTYPE xsl:stylesheet
[
  <!ENTITY www "http://docbook.sourceforge.net/release/xsl/current/xhtml">
]>
<xsl:stylesheet
    version="1.0"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:exsl="http://exslt.org/common"
    xmlns="http://www.w3.org/1999/xhtml"
    xmlns:t="http://nwalsh.com/docbook/xsl/template/1.0"
    xmlns:l="http://docbook.sourceforge.net/xmlns/l10n/1.0"
    exclude-result-prefixes="exsl l t">



<xsl:import href="docbook.xsl"/> 
<xsl:import href="&www;/chunk-common.xsl"/>
<xsl:include href="&www;/manifest.xsl"/>
<xsl:include href="&www;/chunk-code.xsl"/>

<xsl:include href="navig.header.footer.xsl"/><!-- include it again to avoid import precedence problems -->

<xsl:template name="html.head">
    <xsl:param name="prev" select="/foo"/>
    <xsl:param name="next" select="/foo"/>
    <xsl:variable name="this" select="."/>
    <xsl:variable name="home" select="/*[1]"/>
    <xsl:variable name="up" select="parent::*"/>
    
    <xsl:message>html.head gefunden: <xsl:apply-templates select="$this" 
      mode="title.markup"/></xsl:message>
    <head>
      <xsl:call-template name="system.head.content"/>
      <xsl:call-template name="head.content"/>
      
      <!-- For Drupal -->
      <link rel="self">
        <xsl:attribute name="href">
          <xsl:call-template name="href.target">
            <xsl:with-param name="object" select="$this"/>
          </xsl:call-template>
        </xsl:attribute>        
        <xsl:attribute name="title">
          <xsl:apply-templates select="$this" 
            mode="title.markup"/>
        </xsl:attribute>
      </link>
      <xsl:if test="$home">
        <link rel="home">
          <xsl:attribute name="href">
            <xsl:call-template name="href.target">
              <xsl:with-param name="object" select="$home"/>
            </xsl:call-template>
          </xsl:attribute>
          <xsl:attribute name="title">
            <!-- Change: Take into account productname and productnumber -->
            <xsl:choose>
              <xsl:when test="/book/bookinfo/productname and not(/book/title)">
                <xsl:value-of select="normalize-space(/book/bookinfo/productname)"/>
                <xsl:if test="/book/bookinfo/productnumber">
                  <xsl:text> </xsl:text>
                  <xsl:value-of select="normalize-space(/book/bookinfo/productnumber)"/>
                </xsl:if>
              </xsl:when>
              <xsl:otherwise>
                <xsl:apply-templates select="$home" mode="object.title.markup.textonly"/>
              </xsl:otherwise>
            </xsl:choose>
          </xsl:attribute>
        </link>
      </xsl:if>
      
      <xsl:if test="$up">
        <link rel="up">
          <xsl:attribute name="href">
            <xsl:call-template name="href.target">
              <xsl:with-param name="object" select="$up"/>
            </xsl:call-template>
          </xsl:attribute>
          <xsl:attribute name="title">
            <xsl:apply-templates select="$up" mode="object.title.markup.textonly"/>
          </xsl:attribute>
        </link>
      </xsl:if>
      
      <xsl:if test="$prev">
        <link rel="previous">
          <xsl:attribute name="href">
            <xsl:call-template name="href.target">
              <xsl:with-param name="object" select="$prev"/>
            </xsl:call-template>
          </xsl:attribute>
          <xsl:attribute name="title">
            <xsl:apply-templates select="$prev" mode="object.title.markup.textonly"/>
          </xsl:attribute>
        </link>
      </xsl:if>
      
      <xsl:if test="$next">
        <link rel="next">
          <xsl:attribute name="href">
            <xsl:call-template name="href.target">
              <xsl:with-param name="object" select="$next"/>
            </xsl:call-template>
          </xsl:attribute>
          <xsl:attribute name="title">
            <xsl:apply-templates select="$next" mode="object.title.markup.textonly"/>
          </xsl:attribute>
        </link>
      </xsl:if>
      
      <xsl:if test="$html.extra.head.links != 0">
        <xsl:for-each select="//part|//reference |//preface|//chapter|//article|//refentry
          |//appendix[not(parent::article)]|appendix
          |//glossary[not(parent::article)]|glossary
          |//index[not(parent::article)]|index">
          <link rel="{local-name(.)}">
            <xsl:attribute name="href">
              <xsl:call-template name="href.target">
                <xsl:with-param name="context" select="$this"/>
                <xsl:with-param name="object" select="."/>
              </xsl:call-template>
            </xsl:attribute>
            <xsl:attribute name="title">
              <xsl:apply-templates select="." mode="object.title.markup.textonly"/>
            </xsl:attribute>
          </link>
        </xsl:for-each>
        
        <xsl:for-each select="section|sect1|refsection|refsect1">
          <link>
            <xsl:attribute name="rel">
              <xsl:choose>
                <xsl:when test="local-name($this) = 'section' or local-name($this) = 'refsection'">
                  <xsl:value-of select="'subsection'"/>
                </xsl:when>
                <xsl:otherwise>
                  <xsl:value-of select="'section'"/>
                </xsl:otherwise>
              </xsl:choose>
            </xsl:attribute>
            <xsl:attribute name="href">
              <xsl:call-template name="href.target">
                <xsl:with-param name="context" select="$this"/>
                <xsl:with-param name="object" select="."/>
              </xsl:call-template>
            </xsl:attribute>
            <xsl:attribute name="title">
              <xsl:apply-templates select="." mode="object.title.markup.textonly"/>
            </xsl:attribute>
          </link>
        </xsl:for-each>
        
        <xsl:for-each select="sect2|sect3|sect4|sect5|refsect2|refsect3">
          <link rel="subsection">
            <xsl:attribute name="href">
              <xsl:call-template name="href.target">
                <xsl:with-param name="context" select="$this"/>
                <xsl:with-param name="object" select="."/>
              </xsl:call-template>
            </xsl:attribute>
            <xsl:attribute name="title">
              <xsl:apply-templates select="." mode="object.title.markup.textonly"/>
            </xsl:attribute>
          </link>
        </xsl:for-each>
      </xsl:if>
      
      <xsl:call-template name="user.head.content"/>
    </head>
</xsl:template>
  

</xsl:stylesheet>
