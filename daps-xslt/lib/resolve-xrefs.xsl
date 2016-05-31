<?xml version="1.0" encoding="UTF-8"?>
<!--

   Purpose:
     
     
   Parameters:
     
       
   Input:
     DocBook 4/5/Novdoc document
   
   Dependencies:
     - DocBook XSL stylesheets: common/l10n.xsl

   Implementation Details:
     
     
   Output:
     Reduced XML which contains only a fraction of the original document
   
   Author:    Thomas Schraitle <toms@opensuse.org>
   Copyright (C) 2016 SUSE Linux GmbH

-->
<xsl:stylesheet version="1.0"
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:d="http://docbook.org/ns/docbook"
  exclude-result-prefixes="d">

 <xsl:import href="http://docbook.sourceforge.net/release/xsl/current/common/l10n.xsl"/>

 <!-- Default Hooks -->
 <xsl:template name="xref.same.book">
  <xsl:param name="target"/>
  <xsl:param name="this.book"/>
  <xsl:param name="target.book"/>

  <xsl:element name="xref" namespace="{namespace-uri(/*)}">
     <xsl:copy-of select="@*"/>
     <xsl:attribute name="role">internalbook</xsl:attribute>
   </xsl:element>
 </xsl:template>
  
 
 <xsl:template name="xref.different.book">
  <xsl:param name="target"/>
  <xsl:param name="this.book"/>
  <xsl:param name="target.book"/>
  <xsl:variable name="target.book.info" select="$target.book/bookinfo/title |
                                                $target.book/d:info/d:title"/>
  <xsl:variable name="title">
   <xsl:apply-templates select="$target" mode="xref.target">
    <xsl:with-param name="target.book.info" select="$target.book.info"/>
   </xsl:apply-templates>
  </xsl:variable>
  
  <!--<xsl:message>target/title:
   new-title=<xsl:value-of select="$title"/>
   target=<xsl:value-of select="local-name($target)"/>
        </xsl:message>-->
  
  <xsl:element name="phrase" namespace="{namespace-uri(/*)}">
   <xsl:attribute name="role">
    <xsl:text>externalbook-</xsl:text>
    <xsl:value-of select="@linkend"/>
   </xsl:attribute>
   <xsl:value-of select="$title"/>
  </xsl:element>
 </xsl:template>



  <xsl:template match="xref | d:xref" name="xref" mode="process.root" priority="2">
    <xsl:variable name="targets" select="key('id',@linkend)"/>
    <xsl:variable name="target" select="$targets[1]"/>
    <xsl:variable name="refelem" select="local-name($target)"/>
    <xsl:variable name="target.book" select="$target/ancestor-or-self::book|
                                             $target/ancestor-or-self::d:book"/>
    <xsl:variable name="this.book" select="ancestor-or-self::book|
                                           ancestor-or-self::d:book"/>
    <xsl:variable name="target.book.info" select="$target.book/bookinfo/title |
                                                  $target.book/d:info/d:title"/>

    <xsl:choose>
      <xsl:when test="generate-id($target.book) = generate-id($this.book)">
        <!-- xref points into the same book
             we need to use xsl:element here to take into account the DB5
             namespace (or no namespace at all for DB4)
        -->
        <xsl:call-template name="xref.same.book">
         <xsl:with-param name="target" select="$target"/>
         <xsl:with-param name="target.book" select="$target.book"/>
         <xsl:with-param name="this.book" select="$this.book"/>
        </xsl:call-template>
      </xsl:when>
      <xsl:otherwise>
        <!-- xref points into another book -->
       <xsl:call-template name="xref.different.book">
        <xsl:with-param name="target" select="$target"/>
        <xsl:with-param name="target.book" select="$target.book"/>
        <xsl:with-param name="this.book" select="$this.book"/>
       </xsl:call-template>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <!-- Output warning message, if an element cannot be found -->
  <xsl:template match="*" mode="xref.target">
    <xsl:message>Unknown DocBook4 element <xsl:value-of select="local-name(.)"/> for xref.target</xsl:message>
  </xsl:template>
  <xsl:template match="d:*" mode="xref.target">
    <xsl:message>Unknown DocBook5 element <xsl:value-of select="local-name(.)"/> for xref.target</xsl:message>
  </xsl:template>

  <!-- DocBook4 template rules in xref.target mode -->
  <xsl:template match="chapter|appendix|preface|part|
                       sect1|sect2|sect3|sect4|sect5"  mode="xref.target">
    <xsl:param name="target" select="."/>
    <xsl:param name="target.book.info"/>
    <xsl:variable name="title" select="(title|*/title)[1]"/>
    <xsl:variable name="target.ancestor.division"
      select="($target/ancestor-or-self::chapter |
               $target/ancestor-or-self::appendix |
               $target/ancestor-or-self::preface )[1]"/>

    <xsl:call-template name="gentext.startquote"/>
    <xsl:value-of select="normalize-space($title)"/>
    <xsl:call-template name="gentext.endquote"/>
    <xsl:text> (</xsl:text>
    <xsl:if test="$target/self::sect1 or
                  $target/self::sect2 or
                  $target/self::sect3 or
                  $target/self::sect4">
      <xsl:call-template name="gentext">
        <xsl:with-param name="key" select="local-name($target)"/>
      </xsl:call-template>
      <xsl:call-template name="gentext.startquote"/>
      <xsl:value-of select="($target.ancestor.division/title | $target.ancestor.division/*/title)[1]"/>
      <xsl:call-template name="gentext.endquote"/>
      <xsl:text>, </xsl:text>
    </xsl:if>
    <xsl:text>↑</xsl:text>
    <xsl:value-of select="normalize-space($target.book.info)"/>
    <xsl:text>)</xsl:text>
  </xsl:template>
  <xsl:template match="article" mode="xref.target">
    <xsl:param name="target" select="."/>
    <xsl:param name="target.book.info"/>
    <xsl:variable name="title" select="(title|articleinfo/title)[1]"/>
    <xsl:call-template name="gentext.startquote"/>
    <xsl:value-of select="normalize-space($title)"/>
    <xsl:call-template name="gentext.endquote"/>
    <xsl:text> (</xsl:text>
    <xsl:text>↑</xsl:text>
    <xsl:value-of select="normalize-space($target.book.info)"/>
    <xsl:text>)</xsl:text>
  </xsl:template>
  <xsl:template match="book" mode="xref.target">
    <xsl:param name="target" select="."/>
    <xsl:param name="target.book.info"/>
    <xsl:variable name="title" select="(title|bookinfo/title)[1]"/>
    <xsl:text>↑</xsl:text>
    <xsl:call-template name="gentext.startquote"/>
    <xsl:value-of select="normalize-space($title)"/>
    <xsl:call-template name="gentext.endquote"/>
  </xsl:template>

  <xsl:template match="varlistentry" mode="xref.target">
    <xsl:param name="target" select="."/>
    <xsl:param name="target.book.info"/>
    <xsl:variable name="anctitle"
          select="($target/ancestor-or-self::*[title])[last()]"/>

    <xsl:call-template name="gentext.startquote"/>
    <xsl:value-of select="normalize-space(term)"/>
    <xsl:call-template name="gentext.endquote"/>
    <xsl:text> (</xsl:text>
      <xsl:call-template name="gentext">
        <xsl:with-param name="key" select="local-name($anctitle)"/>
      </xsl:call-template>
      <xsl:text> </xsl:text>
      <xsl:call-template name="gentext.startquote"/>
      <xsl:value-of select="($anctitle/title | $anctitle/*/title)[1]"/>
      <xsl:call-template name="gentext.endquote"/>
      <xsl:text>, </xsl:text>
    <xsl:text>↑</xsl:text>
    <xsl:value-of select="normalize-space($target.book.info)"/>
    <xsl:text>)</xsl:text>
  </xsl:template>


  <!-- DocBook5 template rules in xref.target mode -->
  <xsl:template match="d:chapter|d:appendix|d:preface|d:part|
                       d:sect1|d:sect2|d:sect3|d:sect4|d:sect5" mode="xref.target">
    <xsl:param name="target" select="."/>
    <xsl:param name="target.book.info"/>
    <xsl:variable name="title" select="(d:title|*/d:title)[1]"/>
    <xsl:variable name="target.ancestor.division"
      select="($target/ancestor-or-self::d:chapter |
               $target/ancestor-or-self::d:appendix |
               $target/ancestor-or-self::d:preface )[1]"/>

    <xsl:call-template name="gentext.startquote"/>
    <xsl:value-of select="normalize-space($title)"/>
    <xsl:call-template name="gentext.endquote"/>
    <xsl:text> (</xsl:text>
    <xsl:if test="$target/self::d:sect1 or
                  $target/self::d:sect2 or
                  $target/self::d:sect3 or
                  $target/self::d:sect4">
      <xsl:call-template name="gentext">
        <xsl:with-param name="key" select="local-name($target)"/>
      </xsl:call-template>
      <xsl:text> </xsl:text>
      <xsl:call-template name="gentext.startquote"/>
      <xsl:value-of select="$target.ancestor.division/d:title"/>
      <xsl:call-template name="gentext.endquote"/>
      <xsl:text>, </xsl:text>
    </xsl:if>
    <xsl:text>↑</xsl:text>
    <xsl:value-of select="normalize-space($target.book.info)"/>
    <xsl:text>)</xsl:text>
  </xsl:template>

  <xsl:template match="d:article" mode="xref.target">
    <xsl:param name="target" select="."/>
    <xsl:param name="target.book.info"/>
    <xsl:variable name="title" select="(d:title|d:info/d:title)[1]"/>
    <xsl:call-template name="gentext.startquote"/>
    <xsl:value-of select="normalize-space($title)"/>
    <xsl:call-template name="gentext.endquote"/>
    <xsl:text> (</xsl:text>
    <xsl:text>↑</xsl:text>
    <xsl:value-of select="normalize-space($target.book.info)"/>
    <xsl:text>)</xsl:text>
  </xsl:template>

  <xsl:template match="d:book" mode="xref.target">
    <xsl:param name="target" select="."/>
    <xsl:param name="target.book.info"/>
    <xsl:variable name="title" select="(d:title|d:info/d:title)[1]"/>
    <xsl:text>↑</xsl:text>
    <xsl:call-template name="gentext.startquote"/>
    <xsl:value-of select="normalize-space($title)"/>
    <xsl:call-template name="gentext.endquote"/>
  </xsl:template>

  <xsl:template match="d:varlistentry" mode="xref.target">
    <xsl:param name="target" select="."/>
    <xsl:param name="target.book.info"/>
    <xsl:variable name="anctitle" 
          select="($target/ancestor-or-self::*[d:title])[last()]"/>
    <xsl:call-template name="gentext.startquote"/>
    <xsl:value-of select="normalize-space(d:term)"/>
    <xsl:call-template name="gentext.endquote"/>
    
    <xsl:text> (</xsl:text>
      <xsl:call-template name="gentext">
        <xsl:with-param name="key" select="local-name($anctitle)"/>
      </xsl:call-template>
      <xsl:text> </xsl:text>
      <xsl:call-template name="gentext.startquote"/>
      <xsl:value-of select="($anctitle/d:title | $anctitle/d:info/d:title)[1]"/>
      <xsl:call-template name="gentext.endquote"/>
      <xsl:text>, </xsl:text>
    <xsl:text>↑</xsl:text>
    <xsl:value-of select="normalize-space($target.book.info)"/>
    <xsl:text>)</xsl:text>
  </xsl:template>

</xsl:stylesheet>