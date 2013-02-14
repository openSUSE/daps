<?xml version="1.0" encoding="UTF-8"?>
<!-- 
  This file prepares the DocBook document for EPUB
  It inserts a path for all images at the beginning
  of each graphic name.
  
  It copies all elements, attributes, comments, processing instruction
  except for the @fileref attribute in imagedata element which is inside
  an imageobject with @role="html".
  
  All imageobject elements which contains everything else than @role =
  "html" will be discarded.
-->

<xsl:stylesheet version="1.0"
  xmlns:xlink="http://www.w3.org/1999/xlink"
  xmlns:db="http://docbook.org/ns/docbook"
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform" >

<xsl:import href="../common/rootid.xsl"/>

<xsl:output method="xml" encoding="UTF-8"/>


<!-- ALWAYS use a trailing slash! -->
<xsl:param name="img.src.path"/>


<xsl:template match="node() | @*">
  <xsl:copy>
    <xsl:apply-templates select="@* | node()"/>
  </xsl:copy>
</xsl:template>


<xsl:template
  match="imagedata[ancestor::imageobject[@role='html']]/@fileref"
  name="imagedata-fileref">
  <xsl:attribute name="fileref">
    <xsl:value-of select="concat($img.src.path, .)"/>  
  </xsl:attribute>
</xsl:template>

<!-- Do not copy images for FO-->
<xsl:template match="imageobject[@role != 'html']"/>


<xsl:template match="@spacing">
  <xsl:choose>
    <xsl:when test=". = 'compact'"/>
    <xsl:otherwise>
      <xsl:copy-of select="."/>
    </xsl:otherwise>
  </xsl:choose>
</xsl:template>


<xsl:template match="xref" name="xref">
    <xsl:variable name="targets" select="key('id',@linkend)"/>
    <xsl:variable name="target" select="$targets[1]"/>
    <xsl:variable name="refelem" select="local-name($target)"/>
    <xsl:variable name="target.book" select="$target/ancestor-or-self::book"/>
    <xsl:variable name="this.book" select="ancestor-or-self::book"/>

    <!--<xsl:message>xref
     @linkend = <xsl:value-of select="@linkend"/>
   refelement = <xsl:value-of select="$refelem"/>
    </xsl:message>-->

    <xsl:choose>
      <xsl:when test="generate-id($target.book) = generate-id($this.book)">
        <!-- xref points into the same book -->
        <xsl:copy-of select="self::xref"/>
      </xsl:when>
      <xsl:otherwise>
        <phrase>
          <xsl:attribute name="role">
            <xsl:text>externalbook-</xsl:text>
            <xsl:value-of select="@linkend"/>
          </xsl:attribute>
        <xsl:text>&#8220;</xsl:text>
          <xsl:choose>
            <xsl:when test="$target/title">
              <xsl:value-of select="normalize-space($target/title)"/>
            </xsl:when>
            <xsl:when test="$target/bookinfo/title">
              <xsl:value-of select="normalize-space($target/bookinfo/title)"/>
            </xsl:when>
          </xsl:choose>
          
          <xsl:text>&#8221; (</xsl:text>
        <xsl:if
          test="$target/self::sect1 or
          $target/self::sect2 or
          $target/self::sect3 or
          $target/self::sect4">
          <xsl:text>Chapter &#8220;</xsl:text>
          <xsl:value-of select="($target/ancestor-or-self::chapter |
            $target/ancestor-or-self::appendix |
            $target/ancestor-or-self::preface)[1]/title"/>
          <xsl:text>&#8221;, </xsl:text>
        </xsl:if>
        <xsl:text>&#x2191;</xsl:text>
        <xsl:value-of select="normalize-space($target.book/bookinfo/title)"/>
        <xsl:text>)</xsl:text>
        </phrase>
      </xsl:otherwise>
    </xsl:choose>
</xsl:template>

<!-- Support for DocBook 5 -->
<xsl:template match="db:xref">
  <xsl:call-template name="xref"/>
</xsl:template>
  
<xsl:template match="db:imageobject[@role != 'html']"/>

<xsl:template match="db:imagedata[ancestor::db:imageobject[@role='html']]/@fileref">
  <xsl:call-template name="imagedata-fileref"/>
</xsl:template>

</xsl:stylesheet>
