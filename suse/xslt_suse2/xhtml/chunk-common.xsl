<?xml version="1.0" encoding="UTF-8"?>
<!-- 
   Purpose:
     Create structure of chunked contents
     
     
   See Also:
     * http://doccookbook.sf.net/html/en/dbc.common.dbcustomize.html
     * http://sagehill.net/docbookxsl/CustomMethods.html#WriteCustomization

   Author:    Thomas Schraitle <toms@opensuse.org>
   Copyright: 2012, Thomas Schraitle

-->

<!DOCTYPE xsl:stylesheet
[
  <!ENTITY www "http://docbook.sourceforge.net/release/xsl/current/xhtml">
  <!ENTITY nbsp "&#xa0;">
]>
<xsl:stylesheet version="1.0"  
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:exsl="http://exslt.org/common"
    xmlns="http://www.w3.org/1999/xhtml"
    xmlns:t="http://nwalsh.com/docbook/xsl/template/1.0"
    xmlns:l="http://docbook.sourceforge.net/xmlns/l10n/1.0"
    exclude-result-prefixes="exsl l t">
  
  <xsl:import href="&www;/chunk-common.xsl"/>
  

   <!-- ===================================================== -->
  <xsl:template match="chapter|appendix|article|book|part|glossary|sect1|bibliography"
                mode="breadcrumbs">
    <xsl:element name="a" namespace="http://www.w3.org/1999/xhtml">
      <xsl:attribute name="href">
        <xsl:call-template name="href.target">
          <xsl:with-param name="object" select="."/>
          <xsl:with-param name="context" select="."/>
        </xsl:call-template>
      </xsl:attribute>
      <xsl:apply-templates select="." mode="title.markup"/>
    </xsl:element>
  </xsl:template>
  
  <xsl:template name="breadcrumbs.navigation">
    <xsl:param name="prev"/>
    <xsl:param name="next"/>
    <xsl:param name="debug"/>
    <!-- The next.book, prev.book, and this.book variables contains the
       ancestor or self nodes for book or article, but only one node.
  -->
    <xsl:variable name="next.book"
      select="($next/ancestor-or-self::book |
             $next/ancestor-or-self::article)[last()]"/>
    <xsl:variable name="prev.book"
      select="($prev/ancestor-or-self::book |
             $prev/ancestor-or-self::article)[last()]"/>
    <xsl:variable name="this.book"
      select="(ancestor-or-self::book|ancestor-or-self::article)[last()]"/>

    <!-- Compare the current "book" ID (be it really a book or an article)
       with the "next" or "previous" book or article ID
  -->
    <xsl:variable name="isnext"
      select="generate-id($this.book) = generate-id($next.book)"/>
    <xsl:variable name="isprev"
      select="generate-id($this.book) = generate-id($prev.book)"/>

    <xsl:variable name="home" select="/*[1]"/>
    <xsl:variable name="up" select="parent::*"/>
    <xsl:variable name="row2"
      select="(count($prev) > 0 and $isprev) or
                                    (count($up) &gt; 0 and 
                                     generate-id($up) != generate-id($home) and 
                                     $navig.showtitles != 0) or
                                    (count($next) > 0 and $isnext)"/>

    <!-- 
     We use two node sets and calculate the set difference
     with the following, general XPath expression:
     
      setdiff = $node-set1[count(.|$node-set2) != count($node-set2)]
     
     $node-set1 contains the ancestors of all nodes, starting with the
     current node (but the current node is NOT included in the set)
     
     $node-set2 contains the ancestors of all nodes starting from the 
     node which points to the $rootid parameter
     
     For example:
     node-set1: {/, set, book, chapter}
     node-set2: {/, set, } 
     setdiff:   {        book, chapter}
     
  -->
    <xsl:variable name="ancestorrootnode"
      select="key('id', $rootid)/ancestor::*"/>
    <xsl:variable name="setdiff"
      select="ancestor::*[count(. | $ancestorrootnode) 
                                != count($ancestorrootnode)]"/>

    <!--<xsl:if test="$debug">
              <xsl:message>breadcrumbs.navigation:
    Element:  <xsl:value-of select="local-name(.)"/>
    prev:     <xsl:value-of select="local-name($prev)"/>
    next:     <xsl:value-of select="local-name($next)"/>
    rootid:   <xsl:value-of select="$rootid"/>
    isnext:   <xsl:value-of select="$isnext"/>
    isprev:   <xsl:value-of select="$isprev"/>
</xsl:message>
</xsl:if>-->

    <xsl:if test="$generate.breadcrumbs != 0">
      <div class="crumbs">
        <!-- TODO: Do we need an icon always? -->
        <!--<xsl:if test="$rootid = ''">-->
             <a href="{$root.filename}" title="Documentation">
                  <span class="book-icon">&nbsp;</span>
             </a>
          <span><xsl:copy-of select="$daps.breadcrumbs.sep"/></span>
        <!--</xsl:if>-->
        
        <xsl:for-each select="$setdiff">
          <xsl:apply-templates select="." mode="breadcrumbs"/>
          <xsl:if test="position() != last()">
            <span><xsl:copy-of select="$daps.breadcrumbs.sep"/></span>
          </xsl:if>
        </xsl:for-each>
      </div>
    </xsl:if>
  </xsl:template>

  <!-- ===================================================== -->
  <xsl:template name="pickers">
    <div class="pickers">
      <div id="_language-picker" class="inactive">
        <a id="_language-picker-button"
          onclick="activate('_language-picker')" href="#">
          <span class="picker">English</span>
        </a>
        <div class="bubble-corner active-contents"> </div>
        <div class="bubble active-contents">
          
        </div>
      </div>
      <div id="_format-picker" class="inactive">
        <a id="_format-picker-button"
          onclick="activate('_format-picker')" href="#">
          <span class="picker">Web Page</span>
        </a>
        <div class="bubble active-contents">
          <h6>Select a Format</h6>
          <a class="selected" href="#">Web Page</a>
          <a href="#">Single Web Page</a>
          <a href="#">PDF</a>
          <a href="#">E-Book (EBPU)</a>
        </div>
      </div>
    </div>
  </xsl:template>

  <!-- ===================================================== -->
  <xsl:template name="create.header.logo">
    <div id="_logo">
      <img src="{$daps.header.logo}" alt="{$daps.header.logo.alt}"/>
    </div>
  </xsl:template>

  <!-- ===================================================== -->
  <xsl:template name="fixed-header-wrap">
    <xsl:param name="prev"/>
    <xsl:param name="next"/>
    <xsl:param name="nav.context"/>
    
    <div id="_fixed-header-wrap">
      <div id="_fixed-header">
        <xsl:call-template name="breadcrumbs.navigation">
          <xsl:with-param name="prev" select="$prev"/>
          <xsl:with-param name="next" select="$next"/>
        </xsl:call-template>
        <a href="#" class="top-button" title="Go to top of page">Top</a>
        <div class="clearme"></div>
      </div>
    </div>
  </xsl:template>
  
  <xsl:template name="create-find-area">
    <xsl:param name="prev" select="/foo"/>
    <xsl:param name="next" select="/foo"/>
    
    <div id="_find-area" class="active">
      <div class="inactive-contents">
        <a href="#" id="_find-area-button" class="tool" title="Find"
          onclick="activate('_find-area')">
          <span class="pad-tools-50-out">
            <span class="pad-tools-50-in">
              <span class="tool-spacer">
                <span class="find-icon">&nbsp;</span>
              </span>
              <span class="tool-label">Find</span>
            </span>
          </span>
        </a>
      </div>
      <div class="active-contents">
        <form action="post">
          <div class="find-form">
            <input type="text" id="_find-input" value=""
              onfocus="unlabelInputFind();" onblur="labelInputFind();"/>
            <input type="image" id="_find-button" alt="Find"
              title="Find" src="style_images/blank.png"/>
            <label id="_find-input-label"
              onclick="document.getElementById('_find-input').focus(); return false;"
              >Find</label>
            <div class="clearme"></div>
          </div>
        </form>
      </div>
    </div>
  </xsl:template>
  
  
  <!-- ===================================================== -->
  <xsl:template name="toolbar-wrap">
    <xsl:param name="prev"/>
    <xsl:param name="next"/>
    <xsl:param name="nav.context"/>
    
    <div id="_toolbar-wrap">
      <div id="_toolbar">
        <div id="_toc-area" class="inactive">
          <a id="_toc-area-button" class="tool"><span class="toc-icon">&nbsp;</span></a> Contents
        </div>
                
        <div id="_nav-area" class="inactive">
          <!-- FIXME: style attr. needs to be moved to CSS file -->
          <div class="tool">
            <span style="float:right;">
              <span class="tool-label">Navigation</span><!-- FIXME: Add localization -->
              <!-- Add navigation -->
              <xsl:call-template name="header.navigation">
                <xsl:with-param name="next" select="$next"/>
                <xsl:with-param name="prev" select="$prev"/>
                <xsl:with-param name="nav.context" select="$nav.context"/>
              </xsl:call-template>
            </span>
          </div>
        </div>
        <xsl:call-template name="create-find-area">
          <xsl:with-param name="next" select="$next"/>
          <xsl:with-param name="prev" select="$prev"/>
          <xsl:with-param name="nav.context" select="$nav.context"/>
        </xsl:call-template>
        
      </div>
    </div>
  </xsl:template>
  
  <xsl:template name="header.navigation">
    <xsl:param name="prev" select="/foo"/>
    <xsl:param name="next" select="/foo"/>
    <xsl:param name="nav.context"/>
    
   <xsl:variable name="next.book" 
    select="($next/ancestor-or-self::book |
             $next/ancestor-or-self::article)[last()]"/>
  <xsl:variable name="prev.book"
    select="($prev/ancestor-or-self::book |
             $prev/ancestor-or-self::article)[last()]"/>
  <xsl:variable name="this.book" 
    select="(ancestor-or-self::book|ancestor-or-self::article)[last()]"/>
  
  <xsl:variable name="isnext"  select="generate-id($this.book) = generate-id($next.book)"/>
  <xsl:variable name="isprev"  select="generate-id($this.book) = generate-id($prev.book)"/>
  
  <xsl:variable name="home" select="/*[1]"/>
  <xsl:variable name="up" select="parent::*"/>
  <xsl:variable name="row2" select="(count($prev) > 0 and $isprev) or
                                    (count($up) &gt; 0 and 
                                     generate-id($up) != generate-id($home) and 
                                     $navig.showtitles != 0) or
                                    (count($next) > 0 and $isnext)"/>
  
  <!-- 
     We use two node sets and calculate the set difference
     with the following, general XPath expression:
     
      setdiff = $node-set1[count(.|$node-set2) != count($node-set2)]
     
     $node-set1 contains the ancestors of all nodes, starting with the
     current node (but the current node is NOT included in the set)
     
     $node-set2 contains the ancestors of all nodes starting from the 
     node which points to the $rootid parameter
     
     For example:
     node-set1: {/, set, book, chapter}
     node-set2: {/, set, } 
     setdiff:   {        book, chapter}
     
  -->
  <xsl:variable name="ancestorrootnode" select="key('id', $rootid)/ancestor::*"/>
  <xsl:variable name="setdiff" select="ancestor::*[count(. | $ancestorrootnode) 
                                != count($ancestorrootnode)]"/>
    
<!--<xsl:if test="$debug">
              <xsl:message>breadcrumbs.navigation:
    Element:  <xsl:value-of select="local-name(.)"/>
    prev:     <xsl:value-of select="local-name($prev)"/>
    next:     <xsl:value-of select="local-name($next)"/>
    rootid:   <xsl:value-of select="$rootid"/>
    isnext:   <xsl:value-of select="$isnext"/>
    isprev:   <xsl:value-of select="$isprev"/>
</xsl:message>
</xsl:if>-->
    
     <xsl:if test="$row2">
       <xsl:if test="count($prev) >0 and $isprev">
        <a accesskey="p" class="tool-spacer">
          <xsl:attribute name="title">
            <xsl:apply-templates select="$prev"
              mode="object.title.markup"/>
          </xsl:attribute>
          <xsl:attribute name="href">
            <xsl:call-template name="href.target">
              <xsl:with-param name="object" select="$prev"/>
            </xsl:call-template>
          </xsl:attribute>
          <span class="prev-icon">&#xa0;</span>
        </a>
       </xsl:if>
       <xsl:if test="count($next) >0 and $isnext">
        <a accesskey="n" class="tool-spacer">
          <xsl:attribute name="title">
            <xsl:apply-templates select="$next"
              mode="object.title.markup"/>
          </xsl:attribute>
          <xsl:attribute name="href">
            <xsl:call-template name="href.target">
              <xsl:with-param name="object" select="$next"/>
            </xsl:call-template>
          </xsl:attribute>
          <span class="next-icon">&#xa0;</span>
        </a>
       </xsl:if>
     </xsl:if>
  </xsl:template>


  <xsl:template name="body.onload.attribute">
    <!-- TODO: Add parameter to control it -->
    <xsl:attribute name="onload">show(); labelInputFind();</xsl:attribute>
  </xsl:template>
  

  <!-- ===================================================== -->
  
  <xsl:template name="chunk-element-content">
    <xsl:param name="prev"/>
    <xsl:param name="next"/>
    <xsl:param name="nav.context"/>
    <xsl:param name="content">
      <xsl:apply-imports/>
    </xsl:param>

    <xsl:call-template name="log.message">
      <xsl:with-param name="level">Info</xsl:with-param>
      <xsl:with-param name="message">chunkelement-content: <xsl:value-of select="local-name()"/></xsl:with-param>
    </xsl:call-template>

    <xsl:call-template name="user.preroot"/>

    <html>
      <xsl:call-template name="root.attributes"/>
      <xsl:call-template name="html.head">
        <xsl:with-param name="prev" select="$prev"/>
        <xsl:with-param name="next" select="$next"/>
      </xsl:call-template>

      <body>
        <xsl:call-template name="body.attributes"/>
        <xsl:call-template name="body.onload.attribute"/>
        <div id="_outer-wrap">
          <div id="_white-bg">
            <div id="_header">
              <xsl:call-template name="create.header.logo"/>
              <xsl:call-template name="pickers"/>
              <xsl:call-template name="breadcrumbs.navigation">
                <xsl:with-param name="prev" select="$prev"/>
                <xsl:with-param name="next" select="$next"/>
              </xsl:call-template>
              
            <div class="clearme"></div>
            </div>
          </div>
          <xsl:call-template name="fixed-header-wrap">
            <xsl:with-param name="next" select="$next"/>
            <xsl:with-param name="prev" select="$prev"/>
          </xsl:call-template>
          
          <xsl:call-template name="toolbar-wrap">
            <xsl:with-param name="next" select="$next"/>
            <xsl:with-param name="prev" select="$prev"/>
          </xsl:call-template>
          
          <xsl:call-template name="user.header.navigation">
            <xsl:with-param name="prev" select="$prev"/>
            <xsl:with-param name="next" select="$next"/>
            <xsl:with-param name="nav.context" select="$nav.context"/>
          </xsl:call-template>

        <!--<xsl:call-template name="header.navigation">
          <xsl:with-param name="prev" select="$prev"/>
          <xsl:with-param name="next" select="$next"/>
          <xsl:with-param name="nav.context" select="$nav.context"/>
        </xsl:call-template>-->

          <xsl:call-template name="user.header.content"/>

          <xsl:copy-of select="$content"/>
          <div id="_inward"></div>
        </div>
        
        <div id="_footerwrap">
        <xsl:call-template name="user.footer.content"/>

        <!--
        <xsl:call-template name="footer.navigation">
          <xsl:with-param name="prev" select="$prev"/>
          <xsl:with-param name="next" select="$next"/>
          <xsl:with-param name="nav.context" select="$nav.context"/>
        </xsl:call-template>
        -->

        <xsl:call-template name="user.footer.navigation">
          <xsl:with-param name="prev" select="$prev"/>
          <xsl:with-param name="next" select="$next"/>
          <xsl:with-param name="nav.context" select="$nav.context"/>
        </xsl:call-template>
        </div>
      </body>
    </html>
    <xsl:value-of select="$chunk.append"/>
  </xsl:template>
  

  <xsl:template name="user.footer.content">
    <div id="_footer">
      <p>© 2012 SUSE</p>
      <ul>
        <li>
          <a href="http://www.suse.com/company/careers/" target="_top"
            >Careers</a>
        </li>
        <li>
          <a href="http://www.suse.com/company/legal/" target="_top"
            >Legal</a>
        </li>
        <li>
          <a
            href="http://www.suse.com/common/inc/feedback_overlay.html?iframe=true"
            class="feedback">Feedback</a>
        </li>
        <li>
          <a href="http://www.suse.com/company/" target="_top">About</a>
        </li>
        <li>
          <a
            href="http://www.suse.com/ContactsOffices/contacts_offices.jsp"
            target="_top">Contact Us</a>
        </li>
      </ul>
      <p id="_suse_phone">+420-283-007-311</p>
    </div>
    
  </xsl:template>

</xsl:stylesheet>