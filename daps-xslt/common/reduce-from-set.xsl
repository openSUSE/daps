<?xml version="1.0" encoding="UTF-8"?>
<!--
   Purpose:
     Extract a division and all its descendants by providing a ID;
     if no rootid parameter is given, the complete set is copied.
     
   Parameters:
     * rootid
       Applies stylesheet only to part of the document
       
   Input:
     DocBook 4/5/Novdoc document
   
   Dependencies:
     - DocBook XSL stylesheets: common/l10n.xsl

   Implementation Details:
     Currently, the main task is done by the xref template rule: It
     checks if the link goes outside the current book or not.
     Furthermore, it distinguishes between DB4 and DB5. The actual resolving
     mechanism is done in the xref.target mode, separately for DB4 and DB5.
     
   Output:
     Reduced XML which contains only a fraction of the original document
   
   Author:    Thomas Schraitle <toms@opensuse.org>
   Copyright (C) 2012-2015 SUSE Linux GmbH
   
-->

<!DOCTYPE xsl:stylesheet
[
  <!ENTITY db5ns "http://docbook.org/ns/docbook">
]>

<xsl:stylesheet version="1.0" 
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:d="http://docbook.org/ns/docbook"
  exclude-result-prefixes="d">
  
  <xsl:import href="rootid.xsl"/>
  <xsl:import href="../lib/create-doctype.xsl"/>

  <xsl:import href="http://docbook.sourceforge.net/release/xsl/current/common/l10n.xsl"/>

  <xsl:param name="l10n.gentext.language"/>
  <xsl:param name="l10n.gentext.use.xref.language" select="0"/>

<!-- fs 2014-11-21:
     This always generates a NovDoc Header, which is no good on systems where
     NovDoc is not installed. The header should be generated in compliance
     with the original MAIN. This will also be needed for DocBook5.

     As a workaround I will use a standard Docbook 4.5 Header for now - Novdoc
     will work with it anyway, since it is backwards compatible to DocBook4
  
  <xsl:output method="xml" encoding="UTF-8" 
     doctype-public="-//Novell//DTD NovDoc XML V1.0//EN"
     doctype-system="novdocx.dtd"/>
     
     See https://sourceforge.net/p/daps/tickets/249/
         https://github.com/openSUSE/daps/issues/248
-->

  <!-- No xsl:output here! We create the DOCTYPE header manually *sigh* -->


  <xsl:template match="/">
    <xsl:variable name="pi" select="processing-instruction('xml-stylesheet')"/>
    <xsl:choose>
      <xsl:when test="/d:*">
        <!-- We don't need a DOCTYPE header for DocBook >5, skip it -->
      </xsl:when>
      
      <xsl:when test="contains($pi, 'novdoc-profile')">
        <xsl:call-template name="create.novdoc.doctype">
          <xsl:with-param name="rootnode" select="*[1]"/>
        </xsl:call-template>
      </xsl:when>
      <xsl:when test="contains($pi, 'docbook4')">
        <xsl:call-template name="create.db45.doctype">
          <xsl:with-param name="rootnode" select="*[1]"/>
        </xsl:call-template>
      </xsl:when>
      
      <xsl:otherwise>
        <!-- we can't be sure here: -->
        <xsl:message>WARNING: Could not determin DocBook or Novdoc version. No PI xml-stylesheets found! Using DocBook V4 header.</xsl:message>
        <xsl:call-template name="create.db45.doctype">
          <xsl:with-param name="rootnode" select="*[1]"/>
        </xsl:call-template>
      </xsl:otherwise>
    </xsl:choose>
    <xsl:call-template name="process.rootid.node"/>
  </xsl:template>

  <xsl:template name="rootid.process">
    <xsl:variable name="title" select="(key('id', $rootid)/d:title |
                                       key('id', $rootid)/d:info/d:title |
                                       key('id', $rootid)/bookinfo/title)[1]"/>
    <xsl:message>
      <xsl:text>Reducing book to rootid="</xsl:text>
      <xsl:value-of select="$rootid"/>
      <xsl:text>" </xsl:text>
      <xsl:value-of select="name(key('id', $rootid))"/>
      <xsl:text> title="</xsl:text>
      <xsl:value-of select="normalize-space($title)"/>
      <xsl:text>"</xsl:text>
    </xsl:message>
    <xsl:apply-templates select="key('id',$rootid)" mode="process.root"/>
  </xsl:template>
  
  <xsl:template name="normal.process">
    <!-- No rootid parameter given, copy the complete tree -->
    <xsl:copy-of select="/"/>
  </xsl:template>

  <xsl:template match="node()" mode="process.root">
    <xsl:copy>
      <xsl:copy-of select="@*"/>
      <xsl:apply-templates mode="process.root"/>
    </xsl:copy>
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
        <xsl:element name="xref" namespace="{namespace-uri(/*)}">
          <xsl:copy-of select="@*"/>
        </xsl:element>
      </xsl:when>
      <xsl:otherwise>
        <!-- xref points into another book -->
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
