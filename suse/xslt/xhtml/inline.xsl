<?xml version="1.0" encoding="ASCII"?>
<!-- 
   Purpose:  Contains templates for inline elements like remark
-->

<xsl:stylesheet version="1.0"
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns="http://www.w3.org/1999/xhtml">


<xsl:template name="inline.sansseq">
  <xsl:param name="content">
    <xsl:call-template name="anchor"/>
    <xsl:call-template name="simple.xlink">
      <xsl:with-param name="content">
        <xsl:apply-templates/>
      </xsl:with-param>
    </xsl:call-template>
  </xsl:param>
  <span class="{local-name(.)}">
    <xsl:call-template name="generate.html.title"/>
    <xsl:if test="@dir">
      <xsl:attribute name="dir">
        <xsl:value-of select="@dir"/>
      </xsl:attribute>
    </xsl:if>
    <xsl:copy-of select="$content"/>
    <xsl:call-template name="apply-annotations"/>
  </span>
</xsl:template>


<xsl:template xmlns:l="http://docbook.sourceforge.net/xmlns/l10n/1.0" match="keycap">
   <xsl:param name="key.contents" select="."/>
   <xsl:variable name="key.length" select="string-length($key.contents)"/>

   <xsl:choose>
       <xsl:when test="@function and @function!=''">
         <xsl:call-template name="inline.sansseq">
            <xsl:with-param name="content">
               <xsl:call-template name="gentext.template">
                  <xsl:with-param name="context" select="local-name()"/>
                  <xsl:with-param name="name" select="@function"/>
               </xsl:call-template>
            </xsl:with-param>
         </xsl:call-template>
       </xsl:when>
       <xsl:otherwise>
         <xsl:call-template name="inline.sansseq"/>
       </xsl:otherwise>
   </xsl:choose>
</xsl:template>


<xsl:template match="para[parent::abstract | parent::answer | parent::appendix | parent::article | parent::authorblurb |                         parent::bibliodiv | parent::bibliography | parent::blockquote |                         parent::callout | parent::caption | parent::caution | parent::chapter | parent::colophon | parent::constraintdef |                         parent::dedication |                         parent::entry | parent::epigraph | parent::example |                         parent::footnote | parent::formalpara |                         parent::glossary | parent::glossdef | parent::glossdiv |                         parent::highlights |                         parent::important | parent::index | parent::indexdiv | parent::informalexample | parent::itemizedlist |                         parent::legalnotice | parent::listitem |                         parent::msgexplan | parent::msgtext |                         parent::note |                         parent::orderedlist |                         parent::partintro | parent::personblurb | parent::preface | parent::printhistory | parent::procedure |                         parent::qandadiv | parent::qandaset | parent::question |                         parent::refsect1 | parent::refsect2 | parent::refsect3 | parent::refsection | parent::refsynopsisdiv | parent::revdescription |                         parent::sect1 | parent::sect2 | parent::sect3 | parent::sect4 |  parent::sect5 |                         parent::section | parent::setindex | parent::sidebar | parent::simplesect | parent::step |                         parent::taskprerequisites | parent::taskrelated | parent::tasksummary | parent::td | parent::textobject | parent::th | parent::tip |                         parent::variablelist |                         parent::warning]">

   <xsl:choose>
     <xsl:when test="not(@arch)">
       <xsl:apply-imports/>
     </xsl:when>
     <xsl:when test="$para.use.arch='1'">
       <xsl:call-template name="paragraph">
          <xsl:with-param name="class" select="'profarch'"/>
          <xsl:with-param name="content">
            <xsl:variable name="arch">
               <!-- Change here the appearance of your attributes
                    TODO: Move it into common
               -->
               <xsl:choose>
                 <xsl:when test="@arch = 'zseries'">System&#160;z</xsl:when>
                 <xsl:otherwise><xsl:value-of select="@arch"/></xsl:otherwise>
               </xsl:choose>
             </xsl:variable>
             <xsl:if test="position() = 1 and parent::listitem">
             <xsl:call-template name="anchor">
                <xsl:with-param name="node" select="parent::listitem"/>
             </xsl:call-template>
             </xsl:if>

             <xsl:call-template name="anchor"/>
             
             <span class="profarch"><xsl:value-of select="concat('&#9658;',                        translate($arch, $profile.separator, ' '), ': ')"/></span>
             <xsl:apply-templates/>
             <span class="profarch">&#9668;</span>
          </xsl:with-param>
       </xsl:call-template>
     </xsl:when>
     <xsl:otherwise>
       <xsl:apply-imports/>
     </xsl:otherwise>
   </xsl:choose>
</xsl:template>


<xsl:template match="remark">
    <xsl:if test="$show.comments != 0">
      <xsl:variable name="num">
        <xsl:number format=".1" level="any" from="chapter"/>
      </xsl:variable>
      <xsl:variable name="id">
        <xsl:value-of select="ancestor-or-self::chapter/@id"/>
        <xsl:value-of select="$num"/>
      </xsl:variable>
      
      <!--<xsl:message>comment: <xsl:value-of select="$id"/> 
      <xsl:number level="any" format=" #1"/>
      <xsl:number format=" #1" level="any" from="chapter"/>
      </xsl:message>-->
      
      <em id="{$id}" class="remark">
        <span class="identifier">
          <xsl:text>#</xsl:text>
          <xsl:value-of select="$id"/>
          <xsl:text>: </xsl:text>
        </span>
        <xsl:call-template name="inline.charseq"/>
      </em>
    </xsl:if>
</xsl:template>
  
</xsl:stylesheet>
