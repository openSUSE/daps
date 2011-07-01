<?xml version="1.0" encoding="UTF-8"?>
<!-- -->
<!DOCTYPE xsl:stylesheet
[
  <!ENTITY db "http://docbook.sourceforge.net/release/xsl/current/">
]>
<xsl:stylesheet version="1.0" 
  xmlns:xlink='http://www.w3.org/1999/xlink'
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:saxon="http://icl.com/saxon"
  xmlns:lxslt="http://xml.apache.org/xslt"
  xmlns:redirect="http://xml.apache.org/xalan/redirect"
  xmlns:exsl="http://exslt.org/common"
  extension-element-prefixes="saxon redirect lxslt exsl"
  exclude-result-prefixes="xlink">

  
  <xsl:import href="../html/chunk.xsl"/>
  
  <xsl:output method="xml" encoding="UTF-8" 
     indent="yes"
     doctype-public="-//Novell//DTD NovDoc XML V1.0//EN"
     doctype-system="novdocx.dtd"/>
  
  <xsl:param name="ulink.type">externalbook</xsl:param>


  <xsl:template match="*"/>

  <xsl:template match="/">
    <xsl:choose>
      <xsl:when test="$rootid !=''">
        <xsl:variable name="rootidname" select="local-name(key('id',$rootid))"/>
        <!--<xsl:message>*** <xsl:value-of select="$rootidname"/></xsl:message>
        <xsl:if test="$rootidname != 'book' or 
                      $rootidname != 'article' or 
                      $rootidname != 'reference'">
          <xsl:message>
            <xsl:text>WARNING: Rootid=</xsl:text>
            <xsl:value-of select="$rootid"/>
            <xsl:text> points to a not allowed root element! </xsl:text>
            <xsl:value-of select="$rootidname"/>
          </xsl:message>
        </xsl:if>-->
        <xsl:if test="count(key('id',$rootid)) = 0">
          <xsl:message terminate="yes">
            <xsl:text>ID '</xsl:text>
            <xsl:value-of select="$rootid"/>
            <xsl:text>' not found in document.</xsl:text>
          </xsl:message>
        </xsl:if>
        <xsl:variable name="title" 
          select="(key('id', $rootid)/bookinfo/title |
                   key('id', $rootid)/title | 
                   key('id', $rootid)/articleinfo/title)[1]"/>
        <xsl:message>
           <xsl:text>Reducing to rootid="</xsl:text>
           <xsl:value-of select="$rootid"/>
           <xsl:text>" </xsl:text>
           <xsl:value-of select="$rootidname"/>
           <xsl:text> title="</xsl:text>
           <xsl:value-of select="normalize-space($title)"/>
           <xsl:text>"</xsl:text>
        </xsl:message>
        <xsl:apply-templates 
          select="key('id',$rootid)"
          mode="process.root"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:message terminate="yes">ERROR: No rootid given. Nothing to do.</xsl:message>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  
  <xsl:template match="node()" mode="process.root">
    <xsl:copy>
      <xsl:copy-of select="@*"/>
      <xsl:apply-templates mode="process.root"/>
    </xsl:copy>
  </xsl:template>


  <xsl:template match="book|article" mode="process.root">
    <xsl:if test="preceding-sibling::processing-instruction('provo')">
      <xsl:processing-instruction name="provo">
        <xsl:value-of select="preceding-sibling::processing-instruction('provo')"/>
      </xsl:processing-instruction>
      <xsl:text>&#10;</xsl:text>
    </xsl:if>
    <xsl:element name="{local-name()}">
      <xsl:copy-of select="@*"/>
      <xsl:apply-templates mode="process.root"/>
    </xsl:element>
  </xsl:template>
  

<xsl:template match="xref" name="xref" mode="process.root" priority="2">
  <xsl:param name="xhref" select="@xlink:href"/>
  <!-- is the @xlink:href a local idref link? -->
  <xsl:param name="xlink.idref">
    <xsl:if test="starts-with($xhref,'#')
                  and (not(contains($xhref,'&#40;'))
                  or starts-with($xhref, '#xpointer&#40;id&#40;'))">
      <xsl:call-template name="xpointer.idref">
        <xsl:with-param name="xpointer" select="$xhref"/>
      </xsl:call-template>
   </xsl:if>
  </xsl:param>
  <xsl:param name="xlink.targets" select="key('id',$xlink.idref)"/>
  <xsl:param name="linkend.targets" select="key('id',@linkend)"/>
  <xsl:param name="target" select="($xlink.targets | $linkend.targets)[1]"/>
  <xsl:param name="refelem" select="local-name($target)"/>

  <xsl:variable name="target.book" select="$target/ancestor-or-self::book"/>
  <xsl:variable name="this.book" select="ancestor-or-self::book"/>
  
  <xsl:variable name="xrefstyle">
    <xsl:choose>
      <xsl:when test="@role and not(@xrefstyle) 
                      and $use.role.as.xrefstyle != 0">
        <xsl:value-of select="@role"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:value-of select="@xrefstyle"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:variable>

  <xsl:variable name="content">
      <xsl:choose>
        <xsl:when test="@endterm">
          <xsl:variable name="etargets" select="key('id',@endterm)"/>
          <xsl:variable name="etarget" select="$etargets[1]"/>
          <xsl:choose>
            <xsl:when test="count($etarget) = 0">
              <xsl:message>
                <xsl:value-of select="count($etargets)"/>
                <xsl:text>Endterm points to nonexistent ID: </xsl:text>
                <xsl:value-of select="@endterm"/>
              </xsl:message>
              <xsl:text>???</xsl:text>
            </xsl:when>
            <xsl:otherwise>
              <xsl:apply-templates select="$etarget" mode="endterm"/>
            </xsl:otherwise>
          </xsl:choose>
        </xsl:when>
  
        <xsl:when test="$target/@xreflabel">
          <xsl:call-template name="xref.xreflabel">
            <xsl:with-param name="target" select="$target"/>
          </xsl:call-template>
        </xsl:when>
  
        <xsl:when test="$target">
          <xsl:if test="not(parent::citation)">
            <xsl:apply-templates select="$target" mode="xref-to-prefix"/>
          </xsl:if>
  
          <xsl:apply-templates select="$target" mode="xref-to">
            <xsl:with-param name="referrer" select="."/>
            <xsl:with-param name="xrefstyle" select="$xrefstyle"/>
          </xsl:apply-templates>
  
          <xsl:if test="not(parent::citation)">
            <xsl:apply-templates select="$target" mode="xref-to-suffix"/>
          </xsl:if>
        </xsl:when>
        <xsl:otherwise>
          <xsl:message>
            <xsl:text>ERROR: xref linking to </xsl:text>
            <xsl:value-of select="@linkend|@xlink:href"/>
            <xsl:text> has no generated link text.</xsl:text>
          </xsl:message>
          <xsl:text>???</xsl:text>
        </xsl:otherwise>
      </xsl:choose>
  </xsl:variable>

  <xsl:variable name="fn">
    <!-- FIXME: Add provo dirname -->
    <xsl:apply-templates select="$target" mode="chunk-filename"/>
  </xsl:variable>
  
  
  <xsl:choose>
    <xsl:when test="generate-id($target.book) = generate-id($this.book)">
      <!-- xref points into the same book -->
      <xsl:copy-of select="self::xref"/>
    </xsl:when>
    <xsl:otherwise>
      <!-- Convert xref into a ulink.
           Mind the step: the url is a *relative* link.
      -->
      <ulink type="{$ulink.type}">
          <xsl:attribute name="url">
            <xsl:value-of select="$fn"/>
          </xsl:attribute>
        <xsl:attribute name="role">
          <xsl:value-of select="$target.book/@lang"/>
        </xsl:attribute>
        <xsl:value-of select="$content"/>
      </ulink>
    </xsl:otherwise>
  </xsl:choose>
</xsl:template>


</xsl:stylesheet>
