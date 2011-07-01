<?xml version="1.0" encoding="UTF-8"?>
<!-- $Id: get-remarks.xsl 15487 2006-11-17 09:25:07Z toms $ -->
<!DOCTYPE xsl:stylesheet >
<xsl:stylesheet version="1.0"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform">

<xsl:import href="http://docbook.sourceforge.net/release/xsl/current/profiling/profile.xsl"/>

<xsl:output method="text"/>

<xsl:include href="../common/xpath.location.xsl"/>
  
  
<xsl:param name="filename"/>

<xsl:param name="print.title">1</xsl:param>
<xsl:param name="print.xpath">1</xsl:param>
<xsl:param name="remark.role"></xsl:param>

<xsl:template match="text()"/>

<xsl:template match="/">
  <xsl:choose>
   <xsl:when test="$remark.role">
      <xsl:for-each select="//remark[@role=$remark.role]">
         <xsl:apply-templates select="self::remark">
            <xsl:with-param name="pos" select="position()"/>
         </xsl:apply-templates>
      </xsl:for-each>
   </xsl:when>
   <xsl:otherwise>
      <xsl:for-each select="//remark">
         <xsl:apply-templates select="self::remark">
            <xsl:with-param name="pos" select="position()"/>
         </xsl:apply-templates>
      </xsl:for-each>
   </xsl:otherwise>
  </xsl:choose>

</xsl:template>


<xsl:template match="remark">
  <xsl:param name="pos" select="0"/>

  <xsl:value-of select="concat('[', $pos, '] ')"/>

  <xsl:if test="$print.xpath = '1'">
    <xsl:call-template name="xpath.location"/>
    <xsl:text>&#10;</xsl:text>
  </xsl:if>
  <xsl:if test="$print.title = '1' ">
    <xsl:call-template name="gettitle"/>
    <xsl:text>&#10;  </xsl:text>
  </xsl:if>

  <xsl:if test="@role">
    <xsl:value-of select="concat('role=&quot;', @role, '&quot;: ')"/>
  </xsl:if>
  <xsl:value-of select="."/>
  <xsl:text>&#10;&#10;</xsl:text>
</xsl:template>


<xsl:template match="remark/text()">
  <xsl:value-of select="."/>
</xsl:template>


<xsl:template name="gettitle">
   <xsl:param name="context" select=".."/>
   <xsl:param name="title"></xsl:param>

   <xsl:variable name="locname" select="local-name($context)"/>

<!--    <xsl:message> NAME: <xsl:value-of select="name($context)"/></xsl:message> -->
   <xsl:choose>
     <xsl:when test="$locname = 'chapter' or
                     $locname = 'preface' or
                     $locname = 'part' or
                     $locname = 'appendix' or
                     $locname = 'glossary' or
                     $locname = 'bibliography' or
                     $locname = 'sect1' or
                     $locname = 'sect2' or
                     $locname = 'sect3' or
                     $locname = 'sect4' or
                     $locname = 'note' or
                     $locname = 'warning' or
                     $locname = 'tip' or
                     $locname = 'caution' or
                     $locname = 'figure' or
                     $locname = 'table' or
                     $locname = 'example' or
                     $locname = 'variablelist' or
                     $locname = 'itemizedlist' or
                     $locname = 'orderdlist' " >
         <xsl:text>  </xsl:text>
         <xsl:value-of select="normalize-space($context/title)"/>
         <xsl:if test="$context/@id">
          <xsl:value-of select="concat('  &quot;', $context/@id, '&quot;')"/>
         </xsl:if>
     </xsl:when>
     <xsl:otherwise>

         <xsl:call-template name="gettitle">
            <xsl:with-param name="context" select="$context/.."/>
         </xsl:call-template>
     </xsl:otherwise>
   </xsl:choose>
</xsl:template>

<!--
<xsl:template name="xpath.location">
  <xsl:param name="node" select="."/>
  <xsl:param name="path" select="''"/>

  <xsl:variable name="fo-sib"
    select="count($node/following-sibling::*[name(.) = name($node)])"/>
  <xsl:variable name="prec-sib"
    select="count($node/preceding-sibling::*[name(.) = name($node)])"/>

  <xsl:variable name="next.path">
    <xsl:value-of select="local-name($node)"/>
    <xsl:if test="$path != ''">
      <xsl:if test="$prec-sib >0">
        <xsl:value-of select="concat('[', $prec-sib+1, ']')"/>
      </xsl:if>
      <xsl:text>/</xsl:text>
    </xsl:if>
    <xsl:value-of select="$path"/>
  </xsl:variable>

  <xsl:choose>
    <xsl:when test="$node/parent::*">
      <xsl:call-template name="xpath.location">
        <xsl:with-param name="node" select="$node/parent::*"/>
        <xsl:with-param name="path" select="$next.path"/>
      </xsl:call-template>
    </xsl:when>
    <xsl:otherwise>
      <xsl:text>/</xsl:text>
      <xsl:value-of select="$next.path"/>
    </xsl:otherwise>
  </xsl:choose>
</xsl:template>
-->


</xsl:stylesheet>
