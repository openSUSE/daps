<?xml version="1.0" encoding="ASCII"?>
<!--
   Purpose:  Contains customizations for footer
-->


<xsl:stylesheet version="1.0"
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform" 
  xmlns:dp="urn:x-suse:xmlns:docproperties"
  xmlns="http://www.w3.org/1999/xhtml">

<xsl:template match="releaseinfo">
  <xsl:apply-templates/>
</xsl:template>
  

<!-- ==================================================================== -->

<xsl:template name="check.header.link">
  <xsl:param name="node" select="/foo"/>

  <xsl:choose>
    <xsl:when test="generate-id($node/ancestor-or-self::book) = generate-id(ancestor-or-self::book) and                     count($node)&gt;0">
        <xsl:value-of select="0"/>
    </xsl:when>
    <xsl:otherwise>
        <xsl:value-of select="1"/>
    </xsl:otherwise>
  </xsl:choose>

</xsl:template>


<xsl:template name="get.roottitle">
  <xsl:param name="book" select="ancestor-or-self::book"/>
  <xsl:text>FIXME</xsl:text>
  <!--<xsl:call-template name="suse-pi"/>-->
</xsl:template>


<xsl:template name="bg.navigation">
  <xsl:param name="node" select="."/>
  
  <xsl:if test="$generate.bgnavi != 0">
    <!--<xsl:message>BG: <xsl:value-of select="name()"/></xsl:message>-->
    <div class="bgnavi">
      <p class="title">Quick Navigation:</p>
      <xsl:choose>
        <xsl:when test="/article">
          <p class="bg-sect1">
          <xsl:for-each select="ancestor-or-self::article/sect1">
              <xsl:apply-templates select="." mode="bgnavi">
                <xsl:with-param name="node" select="$node"/>
              </xsl:apply-templates>
          </xsl:for-each>
          </p>
        </xsl:when>
        <xsl:when test="ancestor-or-self::article">
          <p class="bg-sect1">
          <xsl:for-each select="ancestor-or-self::article">
              <xsl:apply-templates select="." mode="bgnavi">
                <xsl:with-param name="node" select="$node"/>
              </xsl:apply-templates>
          </xsl:for-each>
          </p>
          <p class="bg-section">
            <xsl:apply-templates select="ancestor-or-self::article/sect1" mode="bgnavi">
              <xsl:with-param name="node" select="$node"/>
            </xsl:apply-templates>
          </p>
        </xsl:when>
        <xsl:otherwise>
          <p class="bg-part">
            <xsl:for-each select="ancestor-or-self::book/part">
              <xsl:apply-templates select="." mode="bgnavi">
                <xsl:with-param name="node" select="$node"/>
              </xsl:apply-templates>
            </xsl:for-each>
            
          </p>
          <p class="bg-chapter">
            <xsl:apply-templates select="ancestor-or-self::part/chapter" mode="bgnavi">
              <xsl:with-param name="node" select="$node"/>
            </xsl:apply-templates>
          </p>
        </xsl:otherwise>
      </xsl:choose>
    </div>
  </xsl:if>
</xsl:template>

<xsl:template match="text()" mode="bgnavi"/>

<xsl:template match="part" mode="bgnavi">
  <xsl:param name="node" select="."/>
  
  <span>
    <xsl:choose>
        <xsl:when test="generate-id(.) = generate-id($node/ancestor-or-self::part)">
          <xsl:attribute name="class">bg-part-current</xsl:attribute>
          <xsl:apply-templates select="self::part" mode="division.number"/>
        </xsl:when>
        <xsl:otherwise>
          <xsl:attribute name="class">bg-part</xsl:attribute>
          <a>
            <xsl:attribute name="href">
              <xsl:call-template name="href.target">
                <xsl:with-param name="object" select="."/>
              </xsl:call-template>
            </xsl:attribute>
            <xsl:attribute name="title">
              <xsl:apply-templates select="." mode="object.title.markup"/>
            </xsl:attribute>
            <xsl:apply-templates select="self::part" mode="division.number"/>
          </a>
        </xsl:otherwise>
      </xsl:choose>
  </span>
  <xsl:text> </xsl:text>
</xsl:template>

<xsl:template match="chapter" mode="bgnavi">
  <xsl:param name="node" select="."/>
  <xsl:variable name="num">
    <xsl:apply-templates select="self::chapter" mode="label.markup"/>
  </xsl:variable>
  
    <span>
      <xsl:choose>
        <xsl:when test="generate-id(.) = generate-id($node/ancestor-or-self::chapter)">
          <xsl:attribute name="class">bg-chapter-current</xsl:attribute>
          <xsl:value-of select="$num"/>
        </xsl:when>
        <xsl:otherwise>
          <xsl:attribute name="class">bg-chapter</xsl:attribute>
          <a>
            <xsl:attribute name="href">
              <xsl:call-template name="href.target">
                <xsl:with-param name="object" select="."/>
              </xsl:call-template>
            </xsl:attribute>
            <xsl:attribute name="title">
              <xsl:apply-templates select="." mode="object.title.markup"/>
            </xsl:attribute>
            <xsl:value-of select="$num"/>
          </a>
        </xsl:otherwise>
      </xsl:choose>
    </span>
  <xsl:text> </xsl:text>
</xsl:template>

<xsl:template match="article" mode="bgnavi">
   <xsl:param name="node" select="."/>
   <xsl:variable name="num">
    <xsl:apply-templates select="self::article" mode="label.markup"/>
   </xsl:variable>
  
  <span>
    <xsl:choose>
      <xsl:when test="generate-id(.) = generate-id($node/ancestor-or-self::sect1)">
        <xsl:attribute name="class">bg-article-current</xsl:attribute>
        <xsl:value-of select="$num"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:attribute name="class">bg-article</xsl:attribute>
        <a>
          <xsl:attribute name="href">
            <xsl:call-template name="href.target">
              <xsl:with-param name="object" select="."/>
            </xsl:call-template>
          </xsl:attribute>
          <xsl:attribute name="title">
            <xsl:apply-templates select="." mode="object.title.markup"/>
          </xsl:attribute>
          <xsl:value-of select="$num"/>
        </a>
        <xsl:text> </xsl:text>
      </xsl:otherwise>
    </xsl:choose>
  </span>
</xsl:template>

<xsl:template match="sect1" mode="bgnavi">
  <xsl:param name="node" select="."/>
  <xsl:variable name="num">
    <xsl:apply-templates select="self::sect1" mode="label.markup"/>
  </xsl:variable>

    <span>
      <xsl:choose>
        <xsl:when test="generate-id(.) = generate-id($node/ancestor-or-self::sect1)">
          <xsl:attribute name="class">bg-sect1-current</xsl:attribute>
          <xsl:value-of select="$num"/>
        </xsl:when>
        <xsl:otherwise>
          <xsl:attribute name="class">bg-sect1</xsl:attribute>
          <a>
            <xsl:attribute name="href">
              <xsl:call-template name="href.target">
                <xsl:with-param name="object" select="."/>
              </xsl:call-template>
            </xsl:attribute>
            <xsl:attribute name="title">
              <xsl:apply-templates select="." mode="object.title.markup"/>
            </xsl:attribute>
            <xsl:value-of select="$num"/>
          </a>
          <xsl:text> </xsl:text>
        </xsl:otherwise>
      </xsl:choose>
    </span>
</xsl:template>


<xsl:template name="generate.link.line">
    <xsl:param name="prev" select="/foo"/>
    <xsl:param name="next" select="/foo"/>
    <xsl:param name="nav.context"/>
    <xsl:param name="orientation"/>
    
    <xsl:if test="$suppress.navigation = '0' and
                  $suppress.header.navigation = '0' and not(self::set)">
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
            <!--<td width="20%">
              <xsl:call-template name="bg.navigation"/>
            </td>-->
          </tr>
        </table>
        <xsl:if test="$use.meta != 0">
          <!--
              On every structural element (like chapter, preface, ...) we
              have a xml:base attribute pointing to the filename
              If it isn't available, we point to the book filename
          -->
          <xsl:variable name="xmlbase.filename">
             <xsl:variable name="_xmlbase" select="(ancestor-or-self::chapter|                         ancestor-or-self::preface|                         ancestor-or-self::appendix|                         ancestor-or-self::glossary)/@xml:base"/>
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
  <xsl:variable name="next.book" select="$next/ancestor-or-self::book"/>
  <xsl:variable name="prev.book" select="$prev/ancestor-or-self::book"/>
  <xsl:variable name="this.book" select="ancestor-or-self::book"/>
    
  <xsl:variable name="prevresult">
    <xsl:call-template name="check.header.link">
      <xsl:with-param name="node" select="$prev"/>
    </xsl:call-template>
  </xsl:variable>
    
    
    <xsl:if test="$generate.breadcrumbs != 0">
      <div class="breadcrumbs">
        <p>
          <xsl:for-each select="ancestor::*">
            <xsl:element name="a" namespace="http://www.w3.org/1999/xhtml">
              <xsl:attribute name="href">
                <xsl:call-template name="href.target">
                  <xsl:with-param name="object" select="."/>
                  <xsl:with-param name="context" select="."/>
                </xsl:call-template>
              </xsl:attribute>
              <xsl:apply-templates select="." mode="title.markup"/>
            </xsl:element>
            <span class="breadcrumbs-sep"><xsl:copy-of select="$breadcrumbs.separator"/></span>
          </xsl:for-each>
          <xsl:if test="self::* != /*">
            <strong>
              <xsl:if test="$prevresult=0">
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
<!--
<xsl:if test="$debug">
              <xsl:message>breadcrumbs.navigation:
    Element:  <xsl:value-of select="local-name(.)"/>
    prev:     <xsl:value-of select="local-name($prev)"/>
    next:     <xsl:value-of select="local-name($next)"/>
    rootid:   <xsl:value-of select="$rootid"/>
    this.book:    <xsl:value-of select="generate-id($this.book)"/>
    prev.book:    <xsl:value-of select="generate-id($prev.book)"/>
    next.book:    <xsl:value-of select="concat(generate-id($next.book),
      ' ', count($next[$this.book]), 
      ' ', local-name($next),
      ' ', local-name(following-sibling::*[1]))"/>
    following-sibling: <xsl:value-of select="count(following-sibling::*[1])"/>
    prevresult:   <xsl:value-of select="$prevresult"/>
</xsl:message>
</xsl:if>
-->
              <xsl:choose>
                <xsl:when test="count(following-sibling::*[1])">
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
                </xsl:when>
                <xsl:otherwise>
                  <!--<a accesskey="n" class="end">
                    <span>&#x2d;&#x2d;&#x2d;</span>
                  </a>-->
                </xsl:otherwise>
              </xsl:choose>
              
            </strong>
          </xsl:if>
        </p>
      </div>
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


<xsl:template name="user.header.content">
  <xsl:choose>
    <xsl:when test="self::set">
      <div class="logo">
        <xsl:text> LOGO </xsl:text>
      </div>
    </xsl:when>
    <xsl:otherwise>
      <!--<xsl:call-template name="breadcrumbs.navigation"/>-->
    </xsl:otherwise>
  </xsl:choose>
  
</xsl:template>


  
<xsl:template name="user.footer.content">
  <!--<xsl:message> user.footer.content </xsl:message>-->
  
   <xsl:if test="/book/bookinfo/productnumber">
      <div class="userfootercontent">
       <xsl:comment>htdig_noindex</xsl:comment>
       <hr/>
       <center>
         <xsl:value-of select="/book/bookinfo/productname"/>
         <xsl:text> </xsl:text>
         <xsl:value-of select="/book/bookinfo/titleabbrev"/>
         <xsl:text> </xsl:text>
         <xsl:value-of select="/book/bookinfo/productnumber"/>
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
