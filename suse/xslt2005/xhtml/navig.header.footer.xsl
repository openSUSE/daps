<?xml version="1.0" encoding="ASCII"?>
<!--
   Purpose:  Contains customizations for footer
-->

<xsl:stylesheet version="1.0"
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform" 
  xmlns:dp="urn:x-suse:xmlns:docproperties"
  xmlns="http://www.w3.org/1999/xhtml"
  exclude-result-prefixes="dp">

<xsl:template match="releaseinfo">
  <xsl:apply-templates/>
</xsl:template>
  

<!-- ==================================================================== -->

<!--<xsl:template name="check.header.link">
  <xsl:param name="node" select="."/>
  <xsl:param name="prev" select="/foo"/>
  <xsl:param name="next" select="/foo"/>

  <xsl:variable name="homes" select="(/*[1] | key('id', $rootid) )"/>
   <!-\- last() gets either the key(...) node or the root nodes, if key()
        does not return a result node
   -\->
  <xsl:variable name="home" select="$homes[last()]"/>
  <xsl:variable name="up" select="parent::*"/>
  
  
  <xsl:choose>
    <xsl:when test="generate-id($node/ancestor-or-self::book) = generate-id(ancestor-or-self::book) 
                    and count($node)&gt;0">0</xsl:when>
    <xsl:otherwise>1</xsl:otherwise>
  </xsl:choose>

</xsl:template>-->

<xsl:template name="get.roottitle">
  <xsl:param name="book" select="ancestor-or-self::book"/>
</xsl:template>


<!-- ==================================================================== -->

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
    
    
    <xsl:if test="$suppress.navigation = '0' and
                  $suppress.header.navigation = '0'">
      <!-- FIXME: Watch for $rootid -->
      
      <div class="nav{$orientation}">
        <xsl:if test="$orientation = 'footer' and $footer.rule != 0">
          <hr/>
        </xsl:if>
        
        <table width="100%" summary="Navigation {$orientation}" border="0" class="bctable">
          <tr>
            <td width="80%">
              <xsl:call-template name="breadcrumbs.navigation">
                <xsl:with-param name="prev" select="$prev"/>
                <xsl:with-param name="next" select="$next"/>
                <xsl:with-param name="debug" select="$orientation = 'header'"/>
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
        
        <xsl:if test="$orientation = 'header' and $header.rule != 0">
          <hr/>
        </xsl:if>
      </div>
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
    
    <xsl:if test="$generate.breadcrumbs != 0">
      <div class="breadcrumbs">
        <p>
          <xsl:apply-templates select="$setdiff"  mode="breadcrumbs"/>
          <xsl:if test="$row2">
            <strong>
              <xsl:if test="count($prev) >0 and $isprev">
                <a accesskey="p">
                  <xsl:attribute name="title">
                    <xsl:apply-templates select="$prev" mode="object.title.markup"/>
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
              </xsl:if>
              
              <xsl:if test="count($next) >0 and $isnext">
                  <xsl:text> </xsl:text>
                  <a accesskey="n">
                    <xsl:attribute name="title">
                      <xsl:apply-templates select="$next" mode="object.title.markup"/>
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
        </p>
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
    <xsl:if test="following-sibling::*[
                    self::chapter|self::article|self::book
                    |self::part|self::preface|self::appendix|self::glossary
                    |self::sect1|self::bibliography]">
      <span class="breadcrumbs-sep">
        <xsl:copy-of select="$breadcrumbs.separator"/>
      </span>
    </xsl:if>
</xsl:template>

<!-- ==================================================================== -->
  
<xsl:template name="header.navigation">
  <xsl:param name="prev" select="/foo"/>
  <xsl:param name="next" select="/foo"/>
  <xsl:param name="nav.context"/>
  
  <!-- Generate header navigation, if link  -->
  <!--<xsl:if test="self::* != (key('id', $rootid) | /*)[1]">-->
    <xsl:call-template name="generate.link.line">
      <xsl:with-param name="nav.context" select="$nav.context"/>
      <xsl:with-param name="next" select="$next"/>
      <xsl:with-param name="prev" select="$prev"/>
      <xsl:with-param name="orientation" select="'header'"/>
    </xsl:call-template>
  <!--</xsl:if>-->
</xsl:template>


<xsl:template name="footer.navigation">
  <xsl:param name="prev" select="/foo"/>
  <xsl:param name="next" select="/foo"/>
  <xsl:param name="nav.context"/>

  <xsl:call-template name="generate.link.line">
    <xsl:with-param name="nav.context" select="$nav.context"/>
    <xsl:with-param name="next" select="$next"/>
    <xsl:with-param name="prev" select="$prev"/>
    <xsl:with-param name="orientation" select="'footer'"/>
  </xsl:call-template>

</xsl:template>

<!-- ==================================================================== -->


<!--<xsl:template name="user.header.content">
  <xsl:choose>
    <xsl:when test="self::set">
      <div class="logo">
        <xsl:text> LOGO </xsl:text>
      </div>
    </xsl:when>
    <xsl:otherwise>
      <!-\-<xsl:call-template name="breadcrumbs.navigation"/>-\->
    </xsl:otherwise>
  </xsl:choose>
</xsl:template>-->


  
<xsl:template name="user.footer.content">
  <!--<xsl:message> user.footer.content </xsl:message>-->
  
   <xsl:if test="ancestor-or-self::book/bookinfo/productnumber">
      <div class="userfootercontent">
       <xsl:comment>htdig_noindex</xsl:comment>
       <hr/>
       <center>
         <xsl:value-of select="ancestor-or-self::book/bookinfo/productname"/>
         <xsl:text> </xsl:text>
         <xsl:apply-templates select="ancestor-or-self::book" mode="titleabbrev.markup"/>
         <xsl:text> </xsl:text>
         <xsl:value-of select="ancestor-or-self::book/bookinfo/productnumber"/>
       </center>
       <xsl:comment>/htdig_noindex</xsl:comment>
      </div>
   </xsl:if>
</xsl:template>


<!-- Something that we can consider in the future: -->
<!--<xsl:template name="user.footer.navigation">
  <xsl:message>user.footer.navigation</xsl:message>
   <div class="userfooternavigation">
      <table width="100%" >
      <tbody>
         <tr width="50%">
         <td><a style="text-align:right;"
   href="http://www.suse.de/en/company/index.html">About SUSE</a>
         </td>
         <td width="50%"><a
   href="ln-copyright.html">Legal notice</a>
         </td>
         </tr>
      </tbody>
      </table>
   </div>
</xsl:template>
-->

</xsl:stylesheet>
