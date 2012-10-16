<?xml version="1.0" encoding="UTF-8"?>
<!-- $Id: $ -->
<!DOCTYPE xsl:stylesheet
[
  <!ENTITY comment.block.parents
       "parent::answer|parent::appendix|parent::article|parent::bibliodiv|
        parent::bibliography|parent::blockquote|parent::caution|parent::chapter|
        parent::glossary|parent::glossdiv|parent::important|parent::index|
        parent::indexdiv|parent::listitem|parent::note|parent::orderedlist|
        parent::partintro|parent::preface|parent::procedure|parent::qandadiv|
        parent::qandaset|parent::question|parent::refentry|parent::refnamediv|
        parent::refsect1|parent::refsect2|parent::refsect3|parent::refsection|
        parent::refsynopsisdiv|parent::sect1|parent::sect2|parent::sect3|parent::sect4|
        parent::sect5|parent::section|parent::setindex|parent::sidebar|
        parent::simplesect|parent::taskprerequisites|parent::taskrelated|
        parent::tasksummary|parent::warning">

  <!ENTITY para.parent "parent::abstract | parent::answer | parent::appendix | parent::article | parent::authorblurb |  
                        parent::bibliodiv | parent::bibliography | parent::blockquote | 
                        parent::callout | parent::caption | parent::caution | parent::chapter | parent::colophon | parent::constraintdef |  
                        parent::dedication | 
                        parent::entry | parent::epigraph | parent::example | 
                        parent::footnote | parent::formalpara | 
                        parent::glossary | parent::glossdef | parent::glossdiv | 
                        parent::highlights |
                        parent::important | parent::index | parent::indexdiv | parent::informalexample | parent::itemizedlist |  
                        parent::legalnotice | parent::listitem | 
                        parent::msgexplan | parent::msgtext | 
                        parent::note | 
                        parent::orderedlist | 
                        parent::partintro | parent::personblurb | parent::preface | parent::printhistory | parent::procedure | 
                        parent::qandadiv | parent::qandaset | parent::question | 
                        parent::refsect1 | parent::refsect2 | parent::refsect3 | parent::refsection | parent::refsynopsisdiv | parent::revdescription | 
                        parent::sect1 | parent::sect2 | parent::sect3 | parent::sect4 |  parent::sect5 | 
                          parent::section | parent::setindex | parent::sidebar | parent::simplesect | parent::step |  
                        parent::taskprerequisites | parent::taskrelated | parent::tasksummary | parent::td | parent::textobject | parent::th | parent::tip |
                        parent::variablelist | 
                        parent::warning">

  <!ENTITY ltrif "&#x25c4;">
  <!ENTITY rtrif "&#x25ba;">
]>

<xsl:stylesheet version="1.0"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:fo="http://www.w3.org/1999/XSL/Format"
    xmlns:svg="http://www.w3.org/2000/svg"
    xmlns:exslt="http://exslt.org/common"
    xmlns:rx="http://www.renderx.com/XSL/Extensions"
    exclude-result-prefixes="exslt"
>

<!-- ==================================================================== -->
<xsl:template name="inline.sansseq">
  <xsl:param name="content">
    <xsl:apply-templates/>
  </xsl:param>
  <fo:inline font-family="{$sans.font.family}">
    <xsl:if test="@id">
      <xsl:attribute name="id">
        <xsl:value-of select="@id"/>
      </xsl:attribute>
    </xsl:if>
    <xsl:if test="@dir">
      <xsl:attribute name="direction">
        <xsl:choose>
          <xsl:when test="@dir = 'ltr' or @dir = 'lro'">ltr</xsl:when>
          <xsl:otherwise>rtl</xsl:otherwise>
        </xsl:choose>
      </xsl:attribute>
    </xsl:if>
    <xsl:copy-of select="$content"/>
  </fo:inline>
</xsl:template>

<xsl:template name="inline.sansboldseq">
  <xsl:param name="content">
    <xsl:apply-templates/>
  </xsl:param>
  <fo:inline font-family="{$sans.font.family}" font-weight="bold">
    <xsl:if test="@id">
      <xsl:attribute name="id">
        <xsl:value-of select="@id"/>
      </xsl:attribute>
    </xsl:if>
    <xsl:if test="@dir">
      <xsl:attribute name="direction">
        <xsl:choose>
          <xsl:when test="@dir = 'ltr' or @dir = 'lro'">ltr</xsl:when>
          <xsl:otherwise>rtl</xsl:otherwise>
        </xsl:choose>
      </xsl:attribute>
    </xsl:if>
    <xsl:copy-of select="$content"/>
  </fo:inline>
</xsl:template>


<xsl:template name="inline.italicseq">
  <xsl:param name="content">
    <xsl:apply-templates/>
  </xsl:param>
  <fo:inline font-style="italic">
    <xsl:if test="@id">
      <xsl:attribute name="id">
        <xsl:value-of select="@id"/>
      </xsl:attribute>
    </xsl:if>
    <xsl:if test="@dir">
      <xsl:attribute name="direction">
        <xsl:choose>
          <xsl:when test="@dir = 'ltr' or @dir = 'lro'">ltr</xsl:when>
          <xsl:otherwise>rtl</xsl:otherwise>
        </xsl:choose>
      </xsl:attribute>
    </xsl:if>
    <xsl:copy-of select="$content"/>
  </fo:inline>
</xsl:template>


<!-- ==================================================================== -->
<!-- As discussed in our conf call from 9 Jun 2005 -->
<xsl:template match="guimenu">
  <xsl:call-template name="inline.italicseq"/>
</xsl:template>


<xsl:template match="keycap">
   <xsl:param name="key.contents" select="."/>
   <xsl:variable name="key.length" select="string-length($key.contents)"/>

   <fo:inline xsl:use-attribute-sets="keycap.properties">
     <xsl:choose>
       <xsl:when test="@function">
         <xsl:call-template name="inline.sansseq">
            <xsl:with-param name="content">
               <xsl:call-template name="gentext.template">
                  <xsl:with-param name="context" select="'msgset'"/>
                  <xsl:with-param name="name">
                     <xsl:value-of select="@function"/>
                  </xsl:with-param>
               </xsl:call-template>
            </xsl:with-param>
         </xsl:call-template>
       </xsl:when>
       <xsl:otherwise>
          <xsl:call-template name="inline.sansseq"/>
       </xsl:otherwise>
     </xsl:choose>
   </fo:inline>
</xsl:template>


<xsl:template match="command">
   <xsl:call-template name="inline.monoseq"/>
</xsl:template>


<xsl:template match="keycombo">
  <xsl:variable name="action" select="@action"/>
  <xsl:variable name="joinchar">
    <xsl:choose>
      <xsl:when test="$action='seq'"> &#x2013; </xsl:when>
      <xsl:when test="$action='press'"> + </xsl:when>
      <xsl:when test="$action='other'"></xsl:when>
      <xsl:otherwise> + </xsl:otherwise>
    </xsl:choose>
  </xsl:variable>
  <xsl:for-each select="*">
    <xsl:if test="position()>1"><xsl:value-of select="$joinchar"/></xsl:if>
    <xsl:apply-templates select="."/>
  </xsl:for-each>
</xsl:template>


<xsl:template match="filename">
  <!--<xsl:variable name="rtf">
     <xsl:apply-templates select="self::filename" mode="copy-node-normal"/>
  </xsl:variable>

  <fo:inline xsl:use-attribute-sets="filename.properties">
     <xsl:apply-templates select="exslt:node-set($rtf)/*" mode="hyphenate-url"/>
  </fo:inline>-->

  <xsl:choose>
     <xsl:when test="count(*) = 0">
        <fo:inline xsl:use-attribute-sets="filename.properties">
           <xsl:apply-templates select="." mode="hyphenate-url"/>
        </fo:inline>
     </xsl:when>
     <xsl:otherwise>
        <!--<xsl:message> FILENAME </xsl:message>-->
        <fo:inline xsl:use-attribute-sets="filename.properties">
          <xsl:apply-templates select="." mode="hyphenate-url"/>
        </fo:inline>
     </xsl:otherwise>
  </xsl:choose>

</xsl:template>

<xsl:template match="filename" mode="hyphenate-url">
    <xsl:apply-templates mode="hyphenate-url"/>
</xsl:template>

<xsl:template match="replaceable"  mode="hyphenate-url">
   <fo:inline font-style="italic"><xsl:apply-templates mode="hyphenate-url"/></fo:inline>
</xsl:template>


<xsl:template match="*"  mode="hyphenate-url">
   <xsl:message> WARNING: Unknown element <xsl:value-of select="name()"/> in hyphenate-url mode.</xsl:message>
   <xsl:apply-templates mode="hyphenate-url"/>
</xsl:template>


<xsl:template match="text()" mode="hyphenate-url">
  <xsl:call-template name="hyphenate-url">
     <xsl:with-param name="url" select="."/>
  </xsl:call-template> 
</xsl:template>

<xsl:template match="ulink" name="ulink">

  <xsl:choose>
    <xsl:when test="$ulink.show != 0">
      <!-- Yes, show the URI -->
      <xsl:choose>
       <xsl:when test="count(child::node())=0">
         <fo:basic-link>
           <xsl:attribute name="external-destination">
             <xsl:call-template name="fo-external-image">
               <xsl:with-param name="filename" select="@url"/>
             </xsl:call-template>
           </xsl:attribute>
           <fo:inline xsl:use-attribute-sets="ulink.properties">
             <xsl:call-template name="hyphenate-url">
               <xsl:with-param name="url" select="@url"/>
             </xsl:call-template>
           </fo:inline>
         </fo:basic-link>
       </xsl:when>
       <xsl:when test="string(.) = @url">
         <fo:basic-link>
           <xsl:attribute name="external-destination">
             <xsl:call-template name="fo-external-image">
               <xsl:with-param name="filename" select="@url"/>
             </xsl:call-template>
           </xsl:attribute>
           <fo:inline xsl:use-attribute-sets="ulink.properties">
             <xsl:call-template name="hyphenate-url">
               <xsl:with-param name="url" select="@url"/>
             </xsl:call-template>
           </fo:inline>
         </fo:basic-link>
       </xsl:when>
       <xsl:when test="$ulink.footnotes != 0 and not(ancestor::footnote)">
        <fo:footnote>
          <xsl:call-template name="ulink.footnote.number"/>
          <fo:footnote-body xsl:use-attribute-sets="footnote.properties">
            <fo:block>
              <xsl:call-template name="ulink.footnote.number"/>
              <xsl:text> </xsl:text>
              <fo:inline>
                <xsl:value-of select="@url"/>
              </fo:inline>
            </fo:block>
          </fo:footnote-body>
        </fo:footnote>
       </xsl:when>
       <xsl:otherwise>
         <fo:inline>
           <xsl:apply-templates/>
         </fo:inline>
        <fo:inline> [</fo:inline>
        <fo:basic-link>
           <xsl:attribute name="external-destination">
             <xsl:call-template name="fo-external-image">
               <xsl:with-param name="filename" select="@url"/>
             </xsl:call-template>
           </xsl:attribute>
           <fo:inline xsl:use-attribute-sets="ulink.properties">
             <xsl:call-template name="hyphenate-url">
               <xsl:with-param name="url" select="@url"/>
             </xsl:call-template>
           </fo:inline>
         </fo:basic-link>
         <fo:inline>]</fo:inline>
       </xsl:otherwise>
      </xsl:choose>
    </xsl:when>
    <xsl:otherwise>
      <!-- No, don't show the URI -->
        <fo:basic-link>
           <xsl:attribute name="external-destination">
             <xsl:call-template name="fo-external-image">
               <xsl:with-param name="filename" select="@url"/>
             </xsl:call-template>
           </xsl:attribute>
           <xsl:choose>
             <xsl:when test="count(child::node())=0 or string(.) = @url">
               <fo:inline xsl:use-attribute-sets="ulink.properties">
                  <xsl:call-template name="hyphenate-url">
                     <xsl:with-param name="url" select="@url"/>
                  </xsl:call-template>
               </fo:inline>
             </xsl:when>
             <xsl:otherwise>
               <fo:inline>
                  <xsl:apply-templates/>
               </fo:inline>
             </xsl:otherwise>
           </xsl:choose>
       </fo:basic-link>
    </xsl:otherwise>
  </xsl:choose>
</xsl:template>

<xsl:template match="remark">
    <xsl:if test="$show.comments != 0">
      <xsl:choose>
        <xsl:when test="$xep.extensions != 0 and $use.xep.annotate.pdf != 0">
          <!-- See http://www.renderx.com/reference.html#PDF%20Note%20Annotations -->
          <fo:inline>
            <rx:pdf-comment content="{string(.)}" title="Comment">
              <!-- Attribute color, opacity -->
              <rx:pdf-sticky-note icon-type="comment"/>
            </rx:pdf-comment>
          </fo:inline>
        </xsl:when>
        <xsl:otherwise>
          <fo:inline xsl:use-attribute-sets="remark.properties">
            <xsl:call-template name="inline.charseq"/>
          </fo:inline>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:if>
</xsl:template>

<xsl:template match="remark[&comment.block.parents;]">
  <xsl:if test="$show.comments != 0">
    <xsl:choose>
      <xsl:when test="$xep.extensions != 0 and $use.xep.annotate.pdf != 0">
        <!-- See http://www.renderx.com/reference.html#PDF%20Note%20Annotations -->
        <fo:block>
          <fo:inline>
          <rx:pdf-comment content="{string(.)}" title="Comment">
            <!-- Attribute color, opacity -->
            <rx:pdf-sticky-note icon-type="comment"/>
          </rx:pdf-comment>
          </fo:inline>
        </fo:block>
      </xsl:when>
      <xsl:otherwise>
        <fo:block xsl:use-attribute-sets="remark.properties">
          <xsl:call-template name="inline.charseq"/>
        </fo:block>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:if>
</xsl:template>

<xsl:template match="productname" priority="10">
  <xsl:call-template name="inline.charseq"/> 
  <!-- <xsl:if test="@class">
    <xsl:call-template name="dingbat">
      <xsl:with-param name="dingbat" select="@class"/>
    </xsl:call-template>
  </xsl:if> -->
</xsl:template>

</xsl:stylesheet>
