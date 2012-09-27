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

  <xsl:template name="clearme">
    <xsl:param name="wrapper">div</xsl:param>
    <xsl:element name="{$wrapper}" namespace="http://www.w3.org/1999/xhtml">
      <xsl:attribute name="class">clearme</xsl:attribute>
    </xsl:element>
  </xsl:template>


  <!-- ===================================================== -->
  <xsl:template
    match="appendix|article|book|bibliography|chapter|part|preface|glossary|sect1|set"
                mode="breadcrumbs">
    <xsl:param name="class">crumb</xsl:param>
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
      <xsl:apply-templates select="." mode="title.markup"/>
    </xsl:element>
  </xsl:template>
  
  <xsl:template name="breadcrumbs.navigation">
    <xsl:param name="prev"/>
    <xsl:param name="next"/>
    <xsl:param name="debug"/>

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


    <xsl:if test="$generate.breadcrumbs != 0">
      <div class="crumbs">
        <!-- TODO: Do we need always an icon? -->
             <a href="{concat($root.filename, $html.ext)}"
               class="book-link"
               title="Documentation">
                  <span class="book-icon">&nbsp;</span>
             </a>
        <!-- <xsl:if test="$rootid = '' or 
                      generate-id(key('id', $rootid)) = generate-id($home)">-->
          <span><xsl:copy-of select="$daps.breadcrumbs.sep"/></span>
        <!--</xsl:if>-->
        
        <!--<xsl:message> >> Begin For loop:</xsl:message>-->
        <xsl:for-each select="$setdiff">
          <xsl:apply-templates select="." mode="breadcrumbs"/>
          <xsl:if test="position() != last()">
            <span><xsl:copy-of select="$daps.breadcrumbs.sep"/></span>
          </xsl:if>
        </xsl:for-each>
        <!--<xsl:message> >> End For loop:</xsl:message>-->
      </div>
    </xsl:if>
  </xsl:template>

  <!-- ===================================================== -->
  <xsl:template name="pickers">
    <xsl:if test="$generate.pickers != 0">
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
    </xsl:if>
  </xsl:template>

  <!-- ===================================================== -->
  <xsl:template name="create.header.logo">
    <div id="_logo">
      <img src="{$daps.header.logo}" alt="{$daps.header.logo.alt}"/>
    </div>
  </xsl:template>

  <xsl:template name="create.header.buttons">
    <xsl:param name="prev"/>
    <xsl:param name="next"/>

    <div class="buttons">
      <a class="top-button button" href="#">Top</a>
      <div class="button">
        <xsl:call-template name="header.navigation">
          <xsl:with-param name="next" select="$next"/>
          <xsl:with-param name="prev" select="$prev"/>
          <!--<xsl:with-param name="nav.context" select="$nav.context"/>-->
        </xsl:call-template>
      </div>
      <xsl:call-template name="clearme"/>
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
        <xsl:call-template name="create.header.buttons">
          <xsl:with-param name="prev" select="$prev"/>
          <xsl:with-param name="next" select="$next"/>
        </xsl:call-template>
        <xsl:call-template name="clearme"/>
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
            <xsl:call-template name="clearme"/>
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
    
    <xsl:variable name="rootnode"  select="generate-id(/*) = generate-id(.)"/>
    
    <div id="_toolbar-wrap">
      <div id="_toolbar">
        <xsl:choose>
          <xsl:when test="$rootnode">
            <!-- We don't need it for a set -->
            <div id="_toc-area" class="inactive"> </div>
          </xsl:when>
          <xsl:otherwise>
            <div id="_toc-area" class="inactive">
              <a id="_toc-area-button" class="tool"
                onclick="activate('_toc-area'); return false;" title="Contents">
                <xsl:attribute name="href">
                  <xsl:call-template name="href.target">
                    <!-- FIXME: -->
                    <xsl:with-param name="object" select="/*"/>
                  </xsl:call-template>
                </xsl:attribute>
                <span class="tool-spacer">
                  <span class="toc-icon"> </span>
                  <xsl:call-template name="clearme">
                    <xsl:with-param name="wrapper">span</xsl:with-param>
                  </xsl:call-template>
                </span>
                <span class="tool-label">Contents</span>
              </a>
              <div class="active-contents bubble-corner"> </div>
              <div class="active-contents bubble">
                <div class="bubble-container">
                  <h6>
                    <xsl:apply-templates mode="title.markup"
                      select="(ancestor-or-self::book | ancestor-or-self::article)[1]"/>
                  </h6>
                  <div class="bubble-toc">
                    <xsl:call-template name="bubble-toc"/>
                  </div>
                  <xsl:call-template name="clearme"/>
                </div>
              </div>
            </div>
          </xsl:otherwise>
        </xsl:choose>
        
        <xsl:choose>
          <xsl:when test="$rootnode">
            <!-- We don't need it for a set -->
            <div id="_nav-area" class="inactive"></div>
          </xsl:when>
          <xsl:otherwise>
            <div id="_nav-area" class="inactive">
              <div class="tool">
                <span class="nav-inner">
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
          </xsl:otherwise>
        </xsl:choose>
        
        <xsl:call-template name="create-find-area">
          <xsl:with-param name="next" select="$next"/>
          <xsl:with-param name="prev" select="$prev"/>
          <xsl:with-param name="nav.context" select="$nav.context"/>
        </xsl:call-template>
        
      </div>
    </div>
  </xsl:template>
  
  <!-- ===================================================== -->
  <xsl:template name="header.navigation">
    <xsl:param name="prev" select="/foo"/>
    <xsl:param name="next" select="/foo"/>
    <xsl:param name="nav.context"/>
    
    <xsl:variable name="needs.navig">
      <xsl:call-template name="is.node.in.navig">
        <xsl:with-param name="next" select="$next"/>
        <xsl:with-param name="prev" select="$prev"/>
      </xsl:call-template>
    </xsl:variable>
    <xsl:variable name="isnext">
      <xsl:call-template name="is.next.node.in.navig">
        <xsl:with-param name="next" select="$next"/>
      </xsl:call-template>
    </xsl:variable>
    <xsl:variable name="isprev">
      <xsl:call-template name="is.prev.node.in.navig">
        <xsl:with-param name="prev" select="$prev"/>
      </xsl:call-template>
    </xsl:variable>
  
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
     <xsl:if test="$needs.navig">
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
    <xsl:attribute name="onload">init();</xsl:attribute>
  </xsl:template>
  
    <xsl:template name="_content.onclick.attribute">
    <!-- TODO: Add parameter to control it -->
    <xsl:attribute name="onclick">deactivate(); return true;</xsl:attribute>
  </xsl:template>
  
  <xsl:template name="body.class.attribute">
    <xsl:if test="($draft.mode = 'yes' or
                  ($draft.mode = 'maybe' and
                  ancestor-or-self::*[@status][1]/@status = 'draft'))
                  and $draft.watermark.image != ''">
      <xsl:attribute name="class">draft</xsl:attribute>
    </xsl:if>
  </xsl:template>
  
  <!-- ===================================================== -->
  <xsl:template name="chunk-element-content">
    <xsl:param name="prev"/>
    <xsl:param name="next"/>
    <xsl:param name="nav.context"/>
    <xsl:param name="content">
      <xsl:apply-imports/>
    </xsl:param>
    <xsl:variable name="lang">
      <xsl:apply-templates select="(ancestor-or-self::*/@lang)[last()]" mode="html.lang.attribute"/>
    </xsl:variable>

    <!--<xsl:call-template name="log.message">
      <xsl:with-param name="level">Info</xsl:with-param>
      <xsl:with-param name="message">object.title.markup.textonly=<xsl:apply-templates select="." mode="title.markup.textonly"/>
      </xsl:with-param>
    </xsl:call-template>-->

    <xsl:call-template name="user.preroot"/>

    <html lang="{$lang}" xml:lang="{$lang}">
      <xsl:call-template name="root.attributes"/>
      <xsl:call-template name="html.head">
        <xsl:with-param name="prev" select="$prev"/>
        <xsl:with-param name="next" select="$next"/>
      </xsl:call-template>

      <body>
        <xsl:call-template name="body.attributes"/>
        <xsl:call-template name="body.onload.attribute"/>
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
          
          <xsl:call-template name="toolbar-wrap">
            <xsl:with-param name="next" select="$next"/>
            <xsl:with-param name="prev" select="$prev"/>
          </xsl:call-template>
          
          <xsl:call-template name="fixed-header-wrap">
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
          <div id="_content">
            <xsl:call-template name="_content.onclick.attribute"/>
            <xsl:if test="$use.meta != 0">
              <!--
                On every structural element (like chapter, preface, ...) we
                have a xml:base attribute pointing to the filename
                If it isn't available, we point to the book filename
              -->
              <xsl:variable name="xmlbase.filename">
                <xsl:variable name="_xmlbase" 
                  select="(ancestor-or-self::chapter|
                  ancestor-or-self::preface|
                  ancestor-or-self::appendix|
                  ancestor-or-self::glossary)/@xml:base"/>
                <xsl:choose>
                  <xsl:when test="$_xmlbase != ''">
                    <xsl:value-of select="$_xmlbase"/>
                  </xsl:when>
                  <xsl:otherwise>
                    <xsl:value-of select="ancestor-or-self::book/@xml:base"/>
                  </xsl:otherwise>
                </xsl:choose>
              </xsl:variable>
              <xsl:comment>htdig_noindex</xsl:comment>
              <xsl:call-template name="getmetadata">
                <xsl:with-param name="filename" select="$xmlbase.filename"/>
              </xsl:call-template>
              <xsl:comment>/htdig_noindex</xsl:comment>
            </xsl:if>
            <xsl:copy-of select="$content"/>
          </div>
          
          <div id="_inward"></div>
        </div>
        
        <div id="_footer-wrap">
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
  
  
  <xsl:template name="user.head.content">
    <xsl:param name="node" select="."/>
    
    <xsl:if test="$daps.header.js != ''">
      <xsl:call-template name="make.script.link">
        <xsl:with-param name="script.filename" select="$daps.header.js"/>
      </xsl:call-template>
    </xsl:if>
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
