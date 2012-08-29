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
  
 <xsl:template name="generate.link.line">
    <xsl:param name="prev" select="/foo"/>
    <xsl:param name="next" select="/foo"/>
    <xsl:param name="nav.context"/>
    <xsl:param name="orientation"/>

    <xsl:variable name="homes" select="(/*[1] | key('id', $rootid) )"/>
    <!-- last() gets either the key(...) node or the root nodes, if key()
        does not return a result node
   -->
    <xsl:variable name="home" select="$homes[last()]"/>


    <!--<xsl:message>generate.link.line:
orientation: <xsl:value-of select="$orientation"/>
      prev:  <xsl:value-of select="count($prev)"/>
      next:  <xsl:value-of select="count($next)"/>
      homes: <xsl:value-of select="count($homes)"/>
      home:  <xsl:value-of select="local-name($home)"/>
      first home: <xsl:value-of select="local-name($homes[1])"/>
      last home:  <xsl:value-of select="local-name($homes[last()])"/>
    </xsl:message>-->


    <xsl:if
      test="$suppress.navigation = '0' and
            $suppress.header.navigation = '0'">
      <!-- FIXME: Watch for $rootid -->

      <div class="nav{$orientation}">
        <xsl:if test="$orientation = 'footer' and $footer.rule != 0">
          <hr/>
        </xsl:if>

        <table width="100%" summary="Navigation {$orientation}"
          border="0" class="bctable">
          <tr>
            <td width="80%">
              <xsl:call-template name="breadcrumbs.navigation">
                <xsl:with-param name="prev" select="$prev"/>
                <xsl:with-param name="next" select="$next"/>
                <xsl:with-param name="debug"
                  select="$orientation = 'header'"/>
              </xsl:call-template>
            </td>
          </tr>
        </table>
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
                <xsl:value-of select="ancestor-or-self::book/@xml:base"
                />
              </xsl:otherwise>
            </xsl:choose>
          </xsl:variable>
          <xsl:comment>htdig_noindex</xsl:comment>
          <xsl:call-template name="getmetadata">
            <xsl:with-param name="filename" select="$xmlbase.filename"/>
          </xsl:call-template>
          <xsl:comment>/htdig_noindex</xsl:comment>
        </xsl:if>

        <xsl:if test="$orientation = 'header' and $header.rule != 0">
          <hr/>
        </xsl:if>
      </div>
    </xsl:if>

  </xsl:template>

  <xsl:template match="*" mode="breadcrumbs">
    <xsl:element name="a" namespace="http://www.w3.org/1999/xhtml">
      <xsl:attribute name="href">
        <xsl:call-template name="href.target">
          <xsl:with-param name="object" select="."/>
          <xsl:with-param name="context" select="."/>
        </xsl:call-template>
      </xsl:attribute>
      <xsl:apply-templates select="." mode="title.markup"/>
    </xsl:element>
    <xsl:if
      test="following-sibling::*[
                    self::chapter|self::article|self::book
                    |self::part|self::preface|self::appendix|self::glossary
                    |self::sect1|self::bibliography]">
      <span><xsl:copy-of select="$daps.breadcrumbs.sep"/></span>
    </xsl:if>
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
        <xsl:if test="$rootid = ''">
             <a href="{$root.filename}" title="Documentation">
                  <span class="book-icon">&nbsp;</span>
             </a>
        </xsl:if>
          <xsl:apply-templates select="$setdiff" mode="breadcrumbs"/>
          <xsl:if test="$row2">
            <strong>
              <xsl:if test="count($prev) >0 and $isprev">
                <a accesskey="p">
                  <xsl:attribute name="title">
                    <xsl:apply-templates select="$prev"
                      mode="object.title.markup"/>
                  </xsl:attribute>
                  <xsl:attribute name="href">
                    <xsl:call-template name="href.target">
                      <xsl:with-param name="object" select="$prev"/>
                    </xsl:call-template>
                  </xsl:attribute>
                  <span><xsl:copy-of select="$breadcrumbs.prev"/></span>
                  <!--<xsl:call-template name="navig.content">
                    <xsl:with-param name="direction" select="'prev'"/>
                  </xsl:call-template>-->
                </a>
                <xsl:text> </xsl:text>
              </xsl:if> <xsl:if test="count($next) >0 and $isnext">
                <xsl:text> </xsl:text>
                <a accesskey="n">
                  <xsl:attribute name="title">
                    <xsl:apply-templates select="$next"
                      mode="object.title.markup"/>
                  </xsl:attribute>
                  <xsl:attribute name="href">
                    <xsl:call-template name="href.target">
                      <xsl:with-param name="object" select="$next"/>
                    </xsl:call-template>
                  </xsl:attribute>
                  <span><xsl:copy-of select="$breadcrumbs.next"/></span>
                  <!--<xsl:call-template name="navig.content">
                    <xsl:with-param name="direction" select="'next'"/>
                  </xsl:call-template>-->
                </a>
              </xsl:if>
            </strong>
          </xsl:if>
      </div>
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
        <div id="_outerwrap">
          <div id="_white-bg">
            
            <div id="_logo"><img src="{$daps.header.logo}"
              alt="{$daps.header.logo.alt}"/></div>
              
              <xsl:call-template name="breadcrumbs.navigation">
                <xsl:with-param name="prev" select="$prev"/>
                <xsl:with-param name="next" select="$next"/>
              </xsl:call-template>
              
              <!--<span>&nbsp;&#187;&nbsp;</span>
              <a href="book.opensuse.startup.html">Start-Up</a>
              <span>&nbsp;&#187;&nbsp;</span>
              <a href="part.reference.software.html">Managing and
                Updating Software</a>-->

            <div class="clearme"></div>
            
          </div>
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
          <div id="_toolbar-wrap">
            <div id="_toolbar">
                   <div class="toc-area inactive">
                        <a href="#contents" title="Contents"><span class="toc-icon">&nbsp;</span></a> Contents
                   </div>
                   <div class="search-area active">
                       <a href="#find" title="Find"><span class="find-icon">&nbsp;</span></a> Search
                   </div>
                   <div class="tools-area inactive">
                       <a href="#tools" title="Page Tools"><span class="tools-icon">&nbsp;</span></a> Tools
                   </div>
               </div>
          </div>
          
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