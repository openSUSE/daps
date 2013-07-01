<?xml version="1.0" encoding="UTF-8"?>
<!-- 
  
   Purpose:
     Prepares the DocBook document for EPUB and inserts a path for all
     images at the beginning of each graphic name.
  
     Copies all elements, attributes, comments, processing instruction
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
       
     * use.pi4date
       Should the PI <?dbtimestamp format="..."?> created instead of
       the current date? 0=no, 1=yes
       
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
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:date="http://exslt.org/dates-and-times"
  exclude-result-prefixes="db xlink date">


  <xsl:import href="&db;/common/common.xsl"/>
  <!--<xsl:import href="&db;/common/pi.xsl"/>
  <xsl:import href="&db;/lib/lib.xsl"/>-->
  <xsl:import href="../common/rootid.xsl"/>
  <xsl:import href="../common/copy.xsl"/>

  <xsl:output method="xml" indent="yes" encoding="UTF-8"/>
  <xsl:strip-space elements="date"/>

<!-- Parameters                                                 -->
<!-- ALWAYS use a trailing slash! -->
<xsl:param name="img.src.path"/>
<xsl:param name="preferred.mediaobject.role">html</xsl:param>
<xsl:param name="use.role.for.mediaobject" select="1"/>
<xsl:param name="use.pi4date" select="0"/>
<xsl:param name="stylesheet.result.type" select="'xhtml'"/>

<xsl:template match="@spacing">
    <xsl:choose>
      <xsl:when test=". = 'compact'"/>
      <xsl:otherwise>
        <xsl:copy-of select="."/>
      </xsl:otherwise>
    </xsl:choose>
</xsl:template>
  

<xsl:template match="bookinfo">
  <xsl:copy>
    <xsl:choose>
      <xsl:when test="not(date)">
        <xsl:call-template name="date">
          <xsl:with-param name="recreate" select="1"/>
        </xsl:call-template>
        <xsl:apply-templates/>
      </xsl:when>
      <xsl:when test="date[processing-instruction()]">
        <xsl:call-template name="date">
          <xsl:with-param name="recreate" select="1"/>
        </xsl:call-template>
        <xsl:apply-templates select="node()[not(self::date)]"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:call-template name="date"/>
        <xsl:apply-templates select="node()[not(self::date)]"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:copy>
</xsl:template>

<xsl:template name="date">
  <xsl:param name="node" select="."/>
  <xsl:param name="recreate" select="0"/>
  <xsl:param name="string" select="''"/>
  <xsl:variable name="contents" select="normalize-space(.)"/>

  <!-- Partly taken from epub3/epub3-element-mods.xsl -->
  <xsl:variable name="normalized" 
                select="translate($node, '0123456789', '##########')"/>

  <xsl:variable name="date.ok">
    <xsl:choose>
      <xsl:when test="$normalized = ''">0</xsl:when>
      <xsl:when test="string-length($string) = 4 and
                      $normalized = '####'">1</xsl:when>
      <xsl:when test="string-length($string) = 7 and
                      $normalized = '####-##'">1</xsl:when>
      <xsl:when test="string-length($string) = 10 and
                      $normalized = '####-##-##'">1</xsl:when>
      <xsl:when test="string-length($string) = 10 and
                      $normalized = '####-##-##'">1</xsl:when>
      <xsl:otherwise>0</xsl:otherwise>
    </xsl:choose>
  </xsl:variable>

    <date>
      <xsl:choose>
        <xsl:when test="$date.ok = 0">
          <xsl:message>
            <xsl:text>WARNING: wrong metadata date format. </xsl:text>
            <xsl:text>It must be in one of these forms: </xsl:text>
            <xsl:text>YYYY, YYYY-MM, or YYYY-MM-DD.</xsl:text>
            <xsl:text> Using current date.</xsl:text>
          </xsl:message>
          <xsl:choose>
            <xsl:when test="$use.pi4date != 0">
              <xsl:processing-instruction name="dbtimestamp">format="%Y-%m-%d"</xsl:processing-instruction>
            </xsl:when>
            <xsl:otherwise>
              <xsl:variable name="date">
                <xsl:choose>
                    <xsl:when test="function-available('date:date-time')">
                      <xsl:value-of select="date:date-time()"/>
                    </xsl:when>
                    <xsl:when test="function-available('date:dateTime')">
                      <!-- Xalan quirk -->
                      <xsl:value-of select="date:dateTime()"/>
                    </xsl:when>
                  </xsl:choose>
              </xsl:variable>
              <xsl:value-of select="date:year($date)"/>
              <xsl:text>-</xsl:text>
              <xsl:value-of select="date:month-in-year($date)"/>
              <xsl:text>-</xsl:text>
              <xsl:value-of select="date:day-in-month($date)"/>
            </xsl:otherwise>
          </xsl:choose>
          
        </xsl:when>
        <xsl:otherwise>
          <xsl:value-of select="$string"/>
        </xsl:otherwise>
      </xsl:choose>
    </date>
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
