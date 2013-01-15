<?xml version="1.0" encoding="UTF-8"?>
<!-- 
   Purpose:
     Transform DocBook document into single XHTML file
     
   Parameters:
     Too many to list here, see:
     http://docbook.sourceforge.net/release/xsl/current/doc/html/index.html
       
   Input:
     DocBook 4/5 document
     
   Output:
     Single XHTML file
     
   See Also:
     * http://doccookbook.sf.net/html/en/dbc.common.dbcustomize.html
     * http://sagehill.net/docbookxsl/CustomMethods.html#WriteCustomization

   Authors:    Thomas Schraitle <toms@opensuse.org>,
               Stefan Knorr <sknorr@suse.de>
   Copyright:  2012, 2013, Thomas Schraitle, Stefan Knorr

-->

<xsl:stylesheet version="1.0"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:exsl="http://exslt.org/common"
    xmlns="http://www.w3.org/1999/xhtml"
    exclude-result-prefixes="exsl">

 <xsl:import href="http://docbook.sourceforge.net/release/xsl/current/xhtml/docbook.xsl"/>

 <xsl:include href="../common/titles.xsl"/>
 <xsl:include href="../common/navigation.xsl"/>

 <xsl:include href="param.xsl"/>
 <xsl:include href="create-permalink.xsl"/>

 <xsl:include href="autotoc.xsl"/>
 <xsl:include href="autobubbletoc.xsl"/> 
 <xsl:include href="lists.xsl"/>
 <xsl:include href="callout.xsl"/>
 <xsl:include href="verbatim.xsl"/>
 <xsl:include href="component.xsl"/>
 <xsl:include href="glossary.xsl"/>
 <xsl:include href="formal.xsl"/>
 <xsl:include href="sections.xsl"/>
 <xsl:include href="division.xsl"/>
 <xsl:include href="inline.xsl"/>
 <xsl:include href="xref.xsl"/>
 <xsl:include href="html.xsl"/>
 <xsl:include href="admon.xsl"/>
 <xsl:include href="block.xsl"/>
 <xsl:include href="qandaset.xsl"/>
 <xsl:include href="titlepage.xsl"/>
 <xsl:include href="titlepage.templates.xsl"/>


 <xsl:include href="../common/string-replace.xsl"/>
 <xsl:include href="metadata.xsl"/>
 

<!-- Actual templates start here -->

  <xsl:template name="clearme">
    <xsl:param name="wrapper">div</xsl:param>
    <xsl:element name="{$wrapper}" namespace="http://www.w3.org/1999/xhtml">
      <xsl:attribute name="class">clearme</xsl:attribute>
    </xsl:element>
  </xsl:template>
 
 <!-- Adapt head.contents to...
 + generate more useful page titles ("Chapter x. Chapter Name" -> "Chapter Name | Book Name")
 + remove the inline styles for draft mode, so they can be substituted by styles 
   in the real stylesheet
 -->
 <xsl:template name="head.content">
  <xsl:param name="node" select="."/>
  <xsl:param name="title">
    <xsl:choose>
      <xsl:when test="(bookinfo | articleinfo | setinfo)/title">
        <xsl:apply-templates select="(bookinfo | articleinfo | setinfo)/title" mode="title.markup.textonly"/>
      </xsl:when>
      <xsl:when test="title | refmeta/refentrytitle">
        <xsl:apply-templates select="(title | refmeta/refentrytitle)[last()]" mode="title.markup.textonly"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:call-template name="gentext">
          <xsl:with-param name="key" select="local-name(.)"/>
        </xsl:call-template>
      </xsl:otherwise>
    </xsl:choose>
    <xsl:if test="not(self::book or self::article or self::set)">
      <xsl:copy-of select="$head.content.title.separator"/>
      <xsl:choose>
        <xsl:when test="(ancestor::book | ancestor::article)[last()]/*[contains(local-name(), 'info')]/title">
          <xsl:apply-templates select="(ancestor::book | ancestor::article)[last()]/*[contains(local-name(), 'info')]/title"
           mode="title.markup.textonly"/>
        </xsl:when>
        <xsl:otherwise>
          <xsl:apply-templates select="(ancestor::book | ancestor::article)[last()]/title" mode="title.markup.textonly"/>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:if>
  </xsl:param>
   
  <title><xsl:copy-of select="$title"/></title>

  <xsl:if test="$html.base != ''">
    <base href="{$html.base}"/>
  </xsl:if>

  <!-- Insert links to CSS files or insert literal style elements -->
  <xsl:call-template name="generate.css"/>

  <xsl:if test="$html.stylesheet != ''">
    <xsl:call-template name="output.html.stylesheets">
      <xsl:with-param name="stylesheets" select="normalize-space($html.stylesheet)"/>
    </xsl:call-template>
  </xsl:if>

  <xsl:if test="$html.script != ''">
    <xsl:call-template name="output.html.scripts">
      <xsl:with-param name="scripts" select="normalize-space($html.script)"/>
    </xsl:call-template>
  </xsl:if>

  <xsl:if test="$link.mailto.url != ''">
    <link rev="made" href="{$link.mailto.url}"/>
  </xsl:if>

  <meta name="generator" content="DocBook {$DistroTitle} V{$VERSION}"/>

  <xsl:if test="$generate.meta.abstract != 0">
    <xsl:variable name="info" select="(articleinfo|bookinfo|prefaceinfo|chapterinfo|appendixinfo|
              sectioninfo|sect1info|sect2info|sect3info|sect4info|sect5info
             |referenceinfo
             |refentryinfo
             |partinfo
             |info
             |docinfo)[1]"/>
    <xsl:if test="$info and $info/abstract">
      <meta name="description">
        <xsl:attribute name="content">
          <xsl:for-each select="$info/abstract[1]/*">
            <xsl:value-of select="normalize-space(.)"/>
            <xsl:if test="position() &lt; last()">
              <xsl:text> </xsl:text>
            </xsl:if>
          </xsl:for-each>
        </xsl:attribute>
      </meta>
    </xsl:if>
  </xsl:if>

    <xsl:apply-templates select="." mode="head.keywords.content"/>
  </xsl:template>

  <xsl:template match="refentry" mode="titleabbrev.markup">
    <xsl:value-of select="refmeta/refentrytitle[text()]"/>
  </xsl:template>

  <xsl:template match="appendix|article|book|bibliography|chapter|part|preface|glossary|sect1|set|refentry"
                mode="breadcrumbs">
    <xsl:param name="class">crumb</xsl:param>
    <xsl:param name="context">header</xsl:param>

    <xsl:variable name="title">
      <xsl:apply-templates select="." mode="titleabbrev.markup"/>
    </xsl:variable>

    <xsl:element name="a" namespace="http://www.w3.org/1999/xhtml">
      <xsl:call-template name="generate.class.attribute">
        <xsl:with-param name="class" select="$class"/>
      </xsl:call-template>
      <xsl:attribute name="href">
        <xsl:call-template name="href.target">
          <xsl:with-param name="object" select="."/>
          <xsl:with-param name="context" select="."/>
        </xsl:call-template>
      </xsl:attribute>
      <xsl:attribute name="accesskey">
          <xsl:text>c</xsl:text>
      </xsl:attribute>
      <span class="book2-icon"> </span>
      <xsl:if test="$context = 'fixed-header'">
        <xsl:call-template name="gentext">
          <xsl:with-param name="key">showcontentsoverview</xsl:with-param>
        </xsl:call-template>
        <xsl:call-template name="gentext">
          <xsl:with-param name="key">admonseparator</xsl:with-param>
        </xsl:call-template>
      </xsl:if>
      <xsl:value-of select="string($title)"/>
    </xsl:element>
  </xsl:template>

  <xsl:template name="breadcrumbs.navigation">
    <xsl:param name="prev"/>
    <xsl:param name="next"/>
    <xsl:param name="context">header</xsl:param>
    <xsl:param name="debug"/>
    
    <xsl:if test="$generate.breadcrumbs != 0">
      <div class="crumbs">
            <xsl:apply-templates select="." mode="breadcrumbs">
              <xsl:with-param name="class">single-crumb</xsl:with-param>
              <xsl:with-param name="context" select="$context"/>
            </xsl:apply-templates>
      </div>
    </xsl:if>
  </xsl:template>

  <!-- ===================================================== -->
  <xsl:template name="pickers">
    <xsl:if test="$generate.pickers != 0">
    <div id="_pickers">
      <div id="_language-picker" class="inactive">
        <a id="_language-picker-button" href="#">
          <span class="picker">
            <xsl:call-template name="gentext">
              <xsl:with-param name="key">LocalisedLanguageName</xsl:with-param>
            </xsl:call-template>
          </span>
        </a>
        <div class="bubble-corner active-contents"> </div>
        <div class="bubble active-contents">
          <h6>
            <xsl:call-template name="gentext">
              <xsl:with-param name="key">selectlanguage</xsl:with-param>
            </xsl:call-template>
          </h6>
          <a class="selected" href="#">
            <xsl:call-template name="gentext">
              <xsl:with-param name="key">LocalisedLanguageName</xsl:with-param>
            </xsl:call-template>
          </a>
        </div>
      </div>
      <div id="_format-picker" class="inactive">
        <a id="_format-picker-button" href="#">
          <span class="picker">Web Page</span>
        </a>
        <div class="bubble-corner active-contents"> </div>
        <div class="bubble active-contents">
          <h6>
            <xsl:call-template name="gentext">
              <xsl:with-param name="key">selectformat</xsl:with-param>
            </xsl:call-template>
          </h6>
          <xsl:call-template name="picker.selection"/>
          <a href="#">
            <xsl:call-template name="gentext">
              <xsl:with-param name="key">formatpdf</xsl:with-param>
            </xsl:call-template>
          </a>
          <a href="#">
            <xsl:call-template name="gentext">
              <xsl:with-param name="key">formatepub</xsl:with-param>
            </xsl:call-template>
          </a>
        </div>
      </div>
    </div>
    </xsl:if>
  </xsl:template>

  <xsl:template name="picker.selection">
    <a href="#">
      <xsl:call-template name="gentext">
        <xsl:with-param name="key">formathtml</xsl:with-param>
      </xsl:call-template>
    </a>
    <a class="selected" href="#">
      <xsl:call-template name="gentext">
        <xsl:with-param name="key">formatsinglehtml</xsl:with-param>
      </xsl:call-template>
    </a>
  </xsl:template>
  
    <xsl:template name="create.header.logo">
    <div id="_logo">
      <img src="{$daps.header.logo}" alt="{$daps.header.logo.alt}"/>
    </div>
  </xsl:template>
  
    <xsl:template name="create.header.buttons">
    <xsl:param name="prev"/>
    <xsl:param name="next"/>

    <div class="buttons">
      <a class="top-button button" href="#">
        <xsl:call-template name="gentext">
          <xsl:with-param name="key">totopofpage</xsl:with-param>
        </xsl:call-template>
      </a>
      <xsl:call-template name="create.header.buttons.nav">
        <xsl:with-param name="prev" select="$prev"/>
        <xsl:with-param name="next" select="$next"/>
      </xsl:call-template>
      <xsl:call-template name="clearme"/>
    </div>
  </xsl:template>

  <xsl:template name="create.header.buttons.nav">
    <xsl:param name="prev"/>
    <xsl:param name="next"/>
    <!-- This is a stub, intentionally.
         The version in chunk-common does something, though. -->
  </xsl:template>

  <xsl:template name="fixed-header-wrap">
    <xsl:param name="prev"/>
    <xsl:param name="next"/>
    <xsl:param name="nav.context"/>
    
    <div id="_fixed-header-wrap" class="inactive">
      <div id="_fixed-header">
        <xsl:call-template name="breadcrumbs.navigation">
          <xsl:with-param name="prev" select="$prev"/>
          <xsl:with-param name="next" select="$next"/>
          <xsl:with-param name="context">fixed-header</xsl:with-param>
        </xsl:call-template>
        <xsl:call-template name="create.header.buttons">
          <xsl:with-param name="prev" select="$prev"/>
          <xsl:with-param name="next" select="$next"/>
        </xsl:call-template>
        <xsl:call-template name="clearme"/>
      </div>
      <div class="active-contents bubble">
        <div class="bubble-container">
          <div id="_bubble-toc">
            <xsl:call-template name="bubble-toc"/>
          </div>
          <xsl:call-template name="clearme"/>
        </div>
      </div>
    </div>
  </xsl:template>

  <xsl:template name="share.and.print">
    <xsl:param name="prev" select="/foo"/>
    <xsl:param name="next" select="/foo"/>
    <xsl:param name="nav.context"/>
    
    <div id="_share-print">
      <xsl:if test="$generate.sharelinks != 0">
        <div class="online-contents share">
          <strong><xsl:call-template name="gentext">
              <xsl:with-param name="key">sharethispage</xsl:with-param>
            </xsl:call-template>
          </strong>
          <!-- &#x2022; = &bull; -->
          <span id="_share-fb">
            <xsl:call-template name="gentext">
              <xsl:with-param name="key">shareviafacebook</xsl:with-param>
            </xsl:call-template>
          </span> &#x2022; 
          <span id="_share-gp">
            <xsl:call-template name="gentext">
              <xsl:with-param name="key">shareviagoogleplus</xsl:with-param>
            </xsl:call-template>
          </span> &#x2022; 
          <span id="_share-tw">
            <xsl:call-template name="gentext">
              <xsl:with-param name="key">shareviatwitter</xsl:with-param>
            </xsl:call-template>
          </span> &#x2022; 
          <span id="_share-mail">
            <xsl:call-template name="gentext">
              <xsl:with-param name="key">shareviaemail</xsl:with-param>
            </xsl:call-template>
          </span>
        </div>
      </xsl:if>
      <div class="print"><span id="_print-button">
        <xsl:call-template name="gentext">
          <xsl:with-param name="key">printthispage</xsl:with-param>
        </xsl:call-template></span></div>
      <xsl:call-template name="clearme"/>
    </div>
  </xsl:template>

  <xsl:template name="body.class.attribute">
    <xsl:choose>
      <xsl:when test="($draft.mode = 'yes' or
                    ($draft.mode = 'maybe' and
                    ancestor-or-self::*[@status][1]/@status = 'draft'))
                    and $draft.watermark.image != ''">
        <xsl:attribute name="class">draft offline single</xsl:attribute>
      </xsl:when>
      <xsl:otherwise>
        <xsl:attribute name="class">offline single</xsl:attribute>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

<xsl:template match="*" mode="process.root">
  <xsl:param name="prev"/>
  <xsl:param name="next"/>
  <xsl:param name="nav.context"/>
  <xsl:param name="content">
    <xsl:apply-imports/>
  </xsl:param>
  <xsl:variable name="doc" select="self::*"/>
  <xsl:variable name="lang">
    <xsl:apply-templates select="(ancestor-or-self::*/@lang)[last()]" mode="html.lang.attribute"/>
  </xsl:variable>
  <xsl:call-template name="user.preroot"/>
  <xsl:call-template name="root.messages"/>

  <html lang="{$lang}" xml:lang="{$lang}">
    <xsl:call-template name="root.attributes"/>
    <head>
      <xsl:call-template name="system.head.content">
        <xsl:with-param name="node" select="$doc"/>
      </xsl:call-template>
      <xsl:call-template name="head.content">
        <xsl:with-param name="node" select="$doc"/>
      </xsl:call-template>
      <xsl:call-template name="user.head.content">
        <xsl:with-param name="node" select="$doc"/>
      </xsl:call-template>
    </head>
    <body>
      <xsl:call-template name="body.attributes"/>
      <xsl:call-template name="body.class.attribute"/>
      <div id="_outer-wrap">
        <div id="_white-bg">
          <div id="_header">
            <xsl:call-template name="create.header.logo"/>
            <xsl:call-template name="pickers"/>
            <xsl:call-template name="breadcrumbs.navigation">
              <xsl:with-param name="prev" select="$prev"/>
              <xsl:with-param name="next" select="$next"/>
            </xsl:call-template>
            <xsl:call-template name="clearme"/>
          </div>
        </div>

        <xsl:call-template name="fixed-header-wrap">
          <xsl:with-param name="next" select="$next"/>
          <xsl:with-param name="prev" select="$prev"/>
        </xsl:call-template>

        <!-- Necessary? -->
        <xsl:call-template name="user.header.navigation">
          <xsl:with-param name="prev" select="$prev"/>
          <xsl:with-param name="next" select="$next"/>
          <xsl:with-param name="nav.context" select="$nav.context"/>
        </xsl:call-template>

        <xsl:call-template name="user.header.content"/>
          <div id="_content">
            <xsl:call-template name="metadata"/>

            <xsl:apply-templates select="."/>

            <div class="page-bottom">
              <xsl:call-template name="share.and.print">
                <xsl:with-param name="prev" select="$prev"/>
                <xsl:with-param name="next" select="$next"/>
                <xsl:with-param name="nav.context" select="$nav.context"/>
              </xsl:call-template>
            </div>
          </div>
          
          <div id="_inward"></div>
        </div>
        
        <div id="_footer-wrap">
        <xsl:call-template name="user.footer.content"/>
        
        <xsl:call-template name="user.footer.navigation">
          <xsl:with-param name="prev" select="$prev"/>
          <xsl:with-param name="next" select="$next"/>
          <xsl:with-param name="nav.context" select="$nav.context"/>
        </xsl:call-template>
        </div>
      </body>
    </html>
  <xsl:value-of select="$html.append"/>
  
  <!-- Generate any css files only once, not once per chunk -->
  <xsl:call-template name="generate.css.files"/>
</xsl:template>

  <xsl:template name="user.head.content">
    <xsl:param name="node" select="."/>
    <xsl:if test="$daps.header.js.library != ''">
      <xsl:call-template name="make.script.link">
        <xsl:with-param name="script.filename" select="$daps.header.js.library"/>
      </xsl:call-template>
    </xsl:if>
    <xsl:if test="$daps.header.js.custom != ''">
      <xsl:call-template name="make.script.link">
        <xsl:with-param name="script.filename" select="$daps.header.js.custom"/>
      </xsl:call-template>
    </xsl:if>
  </xsl:template>
  
  <xsl:template name="user.footer.content">
    <div id="_footer">
      <p>© 2012 SUSE</p>
      <ul>
        <li>
          <a href="http://www.suse.com/company/careers/" target="_top">
            <xsl:call-template name="gentext">
              <xsl:with-param name="key">susecareers</xsl:with-param>
            </xsl:call-template>
          </a>
        </li>
        <li>
          <a href="http://www.suse.com/company/legal/" target="_top">
            <xsl:call-template name="gentext">
              <xsl:with-param name="key">suselegal</xsl:with-param>
            </xsl:call-template>
          </a>
        </li>
        <li>
          <a href="http://www.suse.com/company/" target="_top">
            <xsl:call-template name="gentext">
              <xsl:with-param name="key">suseabout</xsl:with-param>
            </xsl:call-template>
          </a>
        </li>
        <li>
          <a href="http://www.suse.com/ContactsOffices/contacts_offices.jsp"
            target="_top">
            <xsl:call-template name="gentext">
              <xsl:with-param name="key">susecontact</xsl:with-param>
            </xsl:call-template>
          </a>
        </li>
      </ul>
    </div>
    
  </xsl:template>

</xsl:stylesheet>
