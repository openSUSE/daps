<?xml version="1.0" encoding="UTF-8"?>
<!-- 
  
   Purpose:
     Prepares the DocBook document for EPUB and inserts a path for all
     images at the beginning of each graphic name.
  
     It copies all elements, attributes, comments, processing instruction
     except for the @fileref attribute in imagedata element which is inside
     an imageobject with @role=$preferred.mediaobject.role.
  
     All imageobject elements which contains everything else than @role =
     $preferred.mediaobject.role will be discarded.
     
   Parameters:
     * rootid
       Applies stylesheet only to part of the document
       
     * rootid.debug (default: 0)
       Controls some log messages (0=no, 1=yes)
       
     * img.src.path
       Image paths to be added before @fileref in imagedata
       
     * preferred.mediaobject.role
       Prefers imageobjects which contains @role attribute with value
       from this parameter
     
     * use.role.for.mediaobject
       Should @role in imageobjects be used? 1=yes, 0=no
       
   Keys:
     * id (applys to: @id|@xml:id)
       Creates an index for all elements with IDs (derived from
       rootid.xsl)
       
   Input:
     DocBook 4/Novdoc document
     
   Output:
     DocBook 4/Novdoc document with corrected @fileref in imagedata
   
   Author:    Thomas Schraitle <toms@opensuse.org>
   Copyright: 2013, Thomas Schraitle
-->
<!DOCTYPE xsl:stylesheet
[
  <!ENTITY db "http://docbook.sourceforge.net/release/xsl/current">
]>
<xsl:stylesheet version="1.0"
  xmlns:xlink="http://www.w3.org/1999/xlink"
  xmlns:db="http://docbook.org/ns/docbook"
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform" >


  <xsl:import href="&db;/common/common.xsl"/>
  <xsl:import href="../common/rootid.xsl"/>
  <xsl:import href="../common/copy.xsl"/>

  <xsl:output method="xml" indent="yes" encoding="UTF-8"/>


<!-- Parameters                                                 -->
<!-- ALWAYS use a trailing slash! -->
<xsl:param name="img.src.path"/>
<xsl:param name="preferred.mediaobject.role">html</xsl:param>
<xsl:param name="use.role.for.mediaobject" select="1"/>


<xsl:template match="@spacing">
    <xsl:choose>
      <xsl:when test=". = 'compact'"/>
      <xsl:otherwise>
        <xsl:copy-of select="."/>
      </xsl:otherwise>
    </xsl:choose>
</xsl:template>
  
  

<xsl:template match="mediaobject">
  <xsl:variable name="olist" select="imageobject"/>
  <xsl:variable name="object.index">
    <xsl:call-template name="select.mediaobject.index">
      <xsl:with-param name="olist" select="$olist"/>
      <xsl:with-param name="count" select="1"/>
    </xsl:call-template>
  </xsl:variable>
  
  <xsl:variable name="object" select="$olist[position() = $object.index]"/>

  <xsl:copy>
    <xsl:apply-templates select="$object"/>
  </xsl:copy>
</xsl:template>

  <xsl:template match="imagedata">
    <xsl:copy>
      <xsl:copy-of select="@*"/>
      <xsl:attribute name="fileref">
        <xsl:value-of select="concat($img.src.path, @fileref)"/>
      </xsl:attribute>
    </xsl:copy>
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

</xsl:stylesheet>
