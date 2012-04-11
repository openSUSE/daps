<?xml version="1.0" encoding="ASCII"?>
<!-- 
   Purpose:  Contains customizations to section titles
-->

<xsl:stylesheet version="1.0"
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform" 
  xmlns="http://www.w3.org/1999/xhtml">

<xsl:template name="debug.filename">
  <xsl:param name="node" select="."/>
  <xsl:variable name="xmlbase" 
    select="ancestor-or-self::*[self::chapter or 
                                self::appendix or
                                self::part or
                                self::reference or 
                                self::preface or
                                self::glossary or
                                self::sect1 or 
                                self::sect2 or
                                self::sect3 or
                                self::sect4]/@xml:base"/>
  
  <xsl:if test="$draft.mode = 'yes' and $xmlbase != ''">
   <div class="filenameblock">
    Filename:  <span>"<xsl:value-of select="$xmlbase"/>"</span>
   </div>
  </xsl:if>
</xsl:template>

<xsl:template name="addstatus">
  <xsl:param name="node" select=".."/>
  <xsl:param name="id"/>
  <xsl:param name="title"/>

   <xsl:if test="($draft.mode = 'yes' or $draft.mode = 'maybe') and $node/@status">
     <span class="status">
       <xsl:value-of select="$node/@status"/>
     </span>
   </xsl:if>
</xsl:template>

<xsl:template name="addos">
  <xsl:param name="node" select=".."/>
  <xsl:param name="id"/>
  <xsl:param name="title"/>

  <xsl:if test="($draft.mode = 'yes' or $draft.mode = 'maybe') and normalize-space($node/@os) = 'hidden'">
     <span class="os">
       <xsl:value-of select="$node/@os"/>
     </span>
   </xsl:if>
</xsl:template>

<xsl:template name="permalink">
  <xsl:param name="id"/>
  <xsl:param name="title"/>
  
  <!--<xsl:message>Permalink: <xsl:value-of 
    select="concat(name(), ': ', $title)"/></xsl:message>-->
  
  <xsl:if test="$generate.permalink != '0'">
  <span class="permalink">
      <a title="Copy Permalink">
        <!--<xsl:call-template name="generate.html.title"/>--> 
        <xsl:attribute name="href">
          <xsl:text>#</xsl:text>
          <xsl:value-of select="$id"/>
        </xsl:attribute>
        <xsl:text>&#182;</xsl:text>
      </a>
  </span>
  </xsl:if>
</xsl:template>


<xsl:template name="addid">
  <xsl:param name="node" select=".."/>
  
  <xsl:if test="$draft.mode = 'yes'">
     <div class="idblock">
       <xsl:text>ID: </xsl:text>
       <xsl:choose>
         <xsl:when test="$node/@id">
           <xsl:text>#</xsl:text>
           <xsl:call-template name="object.id">
             <xsl:with-param name="object" select="$node"/>
           </xsl:call-template>
         </xsl:when>
         <xsl:otherwise>- No ID found -</xsl:otherwise>
       </xsl:choose>
     </div>
   </xsl:if>
</xsl:template>


<xsl:template name="section.heading">
  <xsl:param name="section" select="."/>
  <xsl:param name="level" select="1"/>
  <xsl:param name="allow-anchors" select="1"/>
  <xsl:param name="title"/>
  <xsl:param name="class" select="'title'"/>

  <!--<xsl:message>Section <xsl:value-of select="$level"/>: <xsl:value-of
    select="normalize-space($title)"/>
  </xsl:message>-->

  <xsl:variable name="id">
    <xsl:choose>
      <!-- Make sure the subtitle doesn't get the same id as the title -->
      <xsl:when test="self::subtitle">
        <xsl:call-template name="object.id">
          <xsl:with-param name="object" select="."/>
        </xsl:call-template>
      </xsl:when>
      <!-- if title is in an *info wrapper, get the grandparent -->
      <xsl:when test="contains(local-name(..), 'info')">
        <xsl:call-template name="object.id">
          <xsl:with-param name="object" select="../.."/>
        </xsl:call-template>
      </xsl:when>
      <xsl:otherwise>
        <xsl:call-template name="object.id">
          <xsl:with-param name="object" select=".."/>
        </xsl:call-template>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:variable>
 <!-- HTML H level is one higher than section level -->
  <xsl:variable name="hlevel">
    <xsl:choose>
      <!-- highest valid HTML H level is H6; so anything nested deeper
           than 5 levels down just becomes H6 -->
      <xsl:when test="$level &gt; 5">6</xsl:when>
      <xsl:otherwise>
        <xsl:value-of select="$level + 1"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:variable>
  <xsl:element name="h{$hlevel}" namespace="http://www.w3.org/1999/xhtml">
    <xsl:attribute name="class"><xsl:value-of select="$class"/></xsl:attribute>
    <xsl:if test="$css.decoration != '0'">
      <xsl:if test="$hlevel&lt;3">
        <xsl:attribute name="style">clear: both</xsl:attribute>
      </xsl:if>
    </xsl:if>
    <xsl:if test="$allow-anchors != 0 and $generate.id.attributes = 0">
      <xsl:call-template name="anchor">
        <xsl:with-param name="node" select="$section"/>
        <xsl:with-param name="conditional" select="0"/>
      </xsl:call-template>
    </xsl:if>
    <xsl:if test="$generate.id.attributes != 0 and not(local-name(.) = 'appendix')">
      <xsl:attribute name="id"><xsl:value-of select="$id"/></xsl:attribute>
    </xsl:if>
    <xsl:copy-of select="$title"/>
    <xsl:call-template name="permalink">
      <xsl:with-param name="id" select="$id"/>
      <xsl:with-param name="title" select="$title"/>
    </xsl:call-template>
    <xsl:call-template name="addstatus">
      <xsl:with-param name="id" select="$id"/>
      <xsl:with-param name="title" select="$title"/>
    </xsl:call-template>
    <xsl:call-template name="addos">
      <xsl:with-param name="id" select="$id"/>
      <xsl:with-param name="title" select="$title"/>
    </xsl:call-template>
    <xsl:call-template name="debug.filename"/>
    <xsl:call-template name="addid"/>
  </xsl:element>
  
</xsl:template>
  
</xsl:stylesheet>
