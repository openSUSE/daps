<?xml version="1.0" encoding="ASCII"?>
<!-- 
   Purpose:  Contains HTML specific adaptions
-->

<xsl:stylesheet version="1.0"
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns="http://www.w3.org/1999/xhtml">


<xsl:template name="html.head">
  <xsl:param name="prev" select="/foo"/>
  <xsl:param name="next" select="/foo"/>
  <xsl:variable name="this" select="."/>
  <xsl:variable name="home" select="/*[1]"/>
  <xsl:variable name="up" select="parent::*"/>
  
  <head>
    <xsl:call-template name="system.head.content"/>
    <xsl:call-template name="head.content"/>

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


<xsl:template name="head.content">
  <xsl:param name="node" select="."/>
  <xsl:param name="title">
    <xsl:apply-templates select="$node" mode="object.title.markup.textonly"/>
  </xsl:param>
  <xsl:variable name="productname">
   <xsl:apply-templates select="ancestor-or-self::book/bookinfo/productname"/>
  </xsl:variable>
  <xsl:variable name="productnumber">
   <xsl:apply-templates select="ancestor-or-self::book/bookinfo/productnumber"/>
  </xsl:variable>
  
  <title>
    <xsl:choose>
      <xsl:when test="ancestor-or-self::book/bookinfo/productname and not(ancestor-or-self::book/title)">
         <xsl:if test="string($productname) != ''">
            <xsl:value-of select="string($productname)"/>
         </xsl:if>
         <xsl:if test="string($productnumber) != ''">
            <xsl:text> </xsl:text>
            <xsl:value-of select="string($productnumber)"/>
            <xsl:text>: </xsl:text>
         </xsl:if>
         <xsl:copy-of select="$title"/>
      </xsl:when>
      <xsl:otherwise>
         <xsl:copy-of select="$title"/>
      </xsl:otherwise>
    </xsl:choose>
  </title>

  <xsl:if test="$html.stylesheet != ''">
    <xsl:call-template name="output.html.stylesheets">
      <xsl:with-param name="stylesheets" select="normalize-space($html.stylesheet)"/>
    </xsl:call-template>
  </xsl:if>

  <xsl:if test="$link.mailto.url != ''">
    <link rev="made" href="{$link.mailto.url}"/>
  </xsl:if>

  <xsl:if test="$html.base != ''">
    <base href="{$html.base}"/>
  </xsl:if>

  <meta name="generator" content="DocBook XSL Stylesheets V{$VERSION}"/>

  <xsl:if test="$generate.meta.abstract != 0">
    <xsl:variable name="info" select="(articleinfo|
                                       bookinfo|
                                       prefaceinfo|
                                       chapterinfo|
                                       appendixinfo|
                                       sectioninfo|
                                       sect1info|
                                       sect2info|
                                       sect3info|
                                       sect4info|
                                       sect5info|
                                       referenceinfo|
                                       refentryinfo|
                                       partinfo|
                                       info|
                                       docinfo)[1]"/>
    <xsl:if test="$info and $info/abstract">
      <meta name="description">
        <xsl:attribute name="content">
          <xsl:for-each select="$info/abstract[1]/*">
            <xsl:value-of select="."/>
            <xsl:if test="position() &lt; last()">
              <xsl:text> </xsl:text>
            </xsl:if>
          </xsl:for-each>
        </xsl:attribute>
      </meta>
    </xsl:if>
  </xsl:if>

  <xsl:if test="($draft.mode = 'yes' or 
                 ($draft.mode = 'maybe' and ancestor-or-self::*[@status][1]/@status = 'draft')) and
                 $draft.watermark.image != ''">
    <style type="text/css"><xsl:text>
body { background-image: url('</xsl:text>
<xsl:value-of select="$draft.watermark.image"/><xsl:text>');
       background-repeat: repeat-y;
       background-position: top left;
       padding-left: 70px;
       /* The following properties make the watermark "fixed" on the page. */
       /* I think that's just a bit too distracting for the reader... */
       /* background-attachment: fixed; */
       /* background-position: center center; */
     }</xsl:text>
    </style>
  </xsl:if>
  <xsl:apply-templates select="." mode="head.keywords.content"/>
</xsl:template>

</xsl:stylesheet>
