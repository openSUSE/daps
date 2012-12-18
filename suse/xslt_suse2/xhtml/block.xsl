<?xml version="1.0" encoding="UTF-8"?>
<!-- 
   Purpose:
     Transform DocBook's block elements
     
   Author:    Thomas Schraitle <toms@opensuse.org>
   Copyright: 2012, Thomas Schraitle
     
-->

<xsl:stylesheet version="1.0"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:exsl="http://exslt.org/common"
    xmlns="http://www.w3.org/1999/xhtml"
    xmlns:t="http://nwalsh.com/docbook/xsl/template/1.0"
    xmlns:l="http://docbook.sourceforge.net/xmlns/l10n/1.0"
    exclude-result-prefixes="exsl l t">
  
  <xsl:template match="abstract">
    <div class="myownabstract">
      <xsl:call-template name="common.html.attributes"/>
      <xsl:call-template name="id.attribute"/>
      <xsl:call-template name="anchor"/>
      <!-- We are only interested in a "normal" pocessing, but suppress
        titles anyway
      -->
      <!--<xsl:call-template name="sidebar.titlepage"/>-->
      <xsl:apply-templates select="*[not(self::title)]"/>
    </div>
  </xsl:template>

  <xsl:template match="para[@arch]">
    <xsl:variable name="arch">
      <xsl:choose>
         <xsl:when test="@arch = 'zseries'">System&#xa0;z</xsl:when>
         <xsl:otherwise><xsl:value-of select="@arch"/></xsl:otherwise>
      </xsl:choose>
   </xsl:variable>
    <xsl:call-template name="paragraph">
    <xsl:with-param name="class">
      <xsl:if test="@role and $para.propagates.style != 0">
        <xsl:value-of select="@role"/>
      </xsl:if>
    </xsl:with-param>
    <xsl:with-param name="content">
      <xsl:if test="position() = 1 and parent::listitem">
        <xsl:call-template name="anchor">
          <xsl:with-param name="node" select="parent::listitem"/>
        </xsl:call-template>
      </xsl:if>
      <xsl:call-template name="anchor"/>
      <xsl:apply-templates/>
    </xsl:with-param>
    <xsl:with-param name="archi">
      <xsl:if test="$para.use.arch">
        <xsl:value-of select="$arch"/>
      </xsl:if>
    </xsl:with-param>
  </xsl:call-template>
  </xsl:template>

<!-- Same as upstream version, but can also handle paragraphs with an
     architecture assigned to them. -->

  <xsl:template name="paragraph">
    <xsl:param name="class" select="''"/>
    <xsl:param name="content"/>
    <xsl:param name="archi"/>

    <xsl:variable name="p">
      <p>
        <xsl:call-template name="id.attribute"/>
        <xsl:choose>
          <xsl:when test="$class != ''">
            <xsl:call-template name="common.html.attributes">
              <xsl:with-param name="class" select="$class"/>
            </xsl:call-template>
          </xsl:when>
          <xsl:otherwise>
            <xsl:call-template name="common.html.attributes">
              <xsl:with-param name="class" select="''"/>
            </xsl:call-template>
          </xsl:otherwise>
        </xsl:choose>

        <xsl:if test="$archi != ''">
          <strong class="arch">
            <xsl:value-of select="$archi"/>
          </strong>
          <span class="arch-arrow-start">
          </span>
        </xsl:if>

        <xsl:copy-of select="$content"/>

        <xsl:if test="$archi != ''">
          <span class="arch-arrow-end">
          </span>
        </xsl:if>

      </p>
    </xsl:variable>

    <xsl:choose>
      <xsl:when test="$html.cleanup != 0">
        <xsl:call-template name="unwrap.p">
          <xsl:with-param name="p" select="$p"/>
        </xsl:call-template>
      </xsl:when>
      <xsl:otherwise>
        <xsl:copy-of select="$p"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

</xsl:stylesheet>
