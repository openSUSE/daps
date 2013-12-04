<?xml version="1.0" encoding="UTF-8"?>
<!--
  Purpose:
    Transform DocBook's block elements

  Author:     Thomas Schraitle <toms@opensuse.org>,
              Stefan Knorr <sknorr@suse.de>
  Copyright:  2012, 2013, Thomas Schraitle, Stefan Knorr

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
      <!-- We are only interested in a "normal" processing, but suppress
           titles anyway -->
      <!--<xsl:call-template name="sidebar.titlepage"/>-->
      <xsl:apply-templates select="*[not(self::title)]"/>
    </div>
  </xsl:template>

  <xsl:template name="readable.arch.string">
    <xsl:param name="input"/>
    <xsl:param name="zseries-replaced">
      <xsl:call-template name="string-replace">
        <xsl:with-param name="input" select="$input"/>
        <xsl:with-param name="search-string">zseries</xsl:with-param>
        <xsl:with-param name="replace-string">System z</xsl:with-param>
      </xsl:call-template>
    </xsl:param>
    <xsl:call-template name="string-replace">
      <xsl:with-param name="input" select="$zseries-replaced"/>
      <xsl:with-param name="search-string">;</xsl:with-param>
      <xsl:with-param name="replace-string">, </xsl:with-param>
    </xsl:call-template>
  </xsl:template>

  <xsl:template match="para[@arch]">
    <xsl:variable name="arch">
      <xsl:call-template name="readable.arch.string">
        <xsl:with-param name="input" select="@arch"/>
      </xsl:call-template>
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
    <xsl:with-param name="arch">
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
    <xsl:param name="arch"/>

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

        <xsl:if test="$arch != ''">
          <strong class="arch">
            <xsl:value-of select="$arch"/>
          </strong>
          <span class="arch-arrow-start">
          </span>
        </xsl:if>

        <xsl:copy-of select="$content"/>

        <xsl:if test="$arch != ''">
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
