<?xml version="1.0" encoding="UTF-8"?>
<!-- -->
<!DOCTYPE xsl:stylesheet
[
  <!ENTITY db "http://docbook.sourceforge.net/release/xsl/current/">
]>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">


<!--  <xsl:include href="&db;fo/param.xsl"/>
  <xsl:include href="&db;lib/lib.xsl"/>
  <xsl:include href="&db;common/common.xsl"/>
  <xsl:include href="&db;common/gentext.xsl"/>
  <xsl:include href="&db;fo/xref.xsl"/>-->
  
  <xsl:output method="xml" encoding="UTF-8" doctype-public="-//Novell//DTD NovDoc XML V1.0//EN"
    doctype-system="novdocx.dtd"/>


  <xsl:param name="rootid" select="''"/>
  <xsl:key name="id" match="*" use="@id|@xml:id"/>
  <xsl:param name="rootelement" select="key('id', $rootid)"/>

  <xsl:template match="/">
    <xsl:choose>
      <xsl:when test="$rootid !=''">
        <xsl:if test="name($rootelement) != 'book'">
          <xsl:message terminate="yes">ERROR: Rootid=<xsl:value-of select="$rootid"/> is not a book
            element!</xsl:message>
        </xsl:if>
        <xsl:if test="count(key('id',$rootid)) = 0">
          <xsl:message terminate="yes">
            <xsl:text>ID '</xsl:text>
            <xsl:value-of select="$rootid"/>
            <xsl:text>' not found in document.</xsl:text>
          </xsl:message>
        </xsl:if>

        <xsl:message>
    Reducing book to rootid="<xsl:value-of select="$rootid"/>" <xsl:value-of
            select="name(key('id', $rootid))"/> title="<xsl:value-of
              select="normalize-space(key('id', $rootid)/bookinfo/title)"/>"
        </xsl:message>
        <xsl:apply-templates select="key('id',$rootid)" mode="process.root"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:message terminate="yes">ERROR: No rootid given. Nothing to do.</xsl:message>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  
  <xsl:template match="*" mode="process.root">
    <xsl:copy>
      <xsl:copy-of select="@*"/>
      <xsl:apply-templates mode="process.root"/>
    </xsl:copy>
  </xsl:template>

  
  <xsl:template match="xref" name="xref" mode="process.root" priority="2">
    <xsl:variable name="targets" select="key('id',@linkend)"/>
    <xsl:variable name="target" select="$targets[1]"/>
    <xsl:variable name="refelem" select="local-name($target)"/>
    <xsl:variable name="target.book" select="$target/ancestor-or-self::book"/>
    <xsl:variable name="this.book" select="ancestor-or-self::book"/>

    <xsl:choose>
      <xsl:when test="generate-id($target.book) = generate-id($this.book)">
        <!-- xref points into the same book -->
        <xref>
          <xsl:copy-of select="@*"/>
        </xref>
      </xsl:when>
      <xsl:otherwise>
        <!-- xref points into another book -->
        <!--<xsl:message>target/title:
        <xsl:value-of select="normalize-space($target/title)"/>
        </xsl:message>-->
        <xsl:text>&#8220;</xsl:text>
        <xsl:value-of select="normalize-space($target/title)"/>
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
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>


</xsl:stylesheet>
