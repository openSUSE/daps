<?xml version="1.0" encoding="ASCII"?>
<!--
    Purpose:
    Rework the structure of Q and A sections to include fewer tables.

    Author:     Stefan Knorr <sknorr@suse.de>
    Copyright:  2012, Stefan Knorr
-->

<xsl:stylesheet version="1.0"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:exsl="http://exslt.org/common"
    xmlns="http://www.w3.org/1999/xhtml"
    exclude-result-prefixes="exsl">


<xsl:template match="qandaset">
  <xsl:variable name="title" select="(blockinfo/title|info/title|title)[1]"/>
  <xsl:variable name="preamble" select="*[local-name(.) != 'title'
                                      and local-name(.) != 'titleabbrev'
                                      and local-name(.) != 'qandadiv'
                                      and local-name(.) != 'qandaentry']"/>
  <xsl:variable name="toc">
    <xsl:call-template name="pi.dbhtml_toc"/>
  </xsl:variable>

  <xsl:variable name="toc.params">
    <xsl:call-template name="find.path.params">
      <xsl:with-param name="table" select="normalize-space($generate.toc)"/>
    </xsl:call-template>
  </xsl:variable>

  <div>
    <xsl:apply-templates select="." mode="common.html.attributes"/>
    <xsl:apply-templates select="$title"/>
    <xsl:if test="not($title)">
      <xsl:call-template name="id.attribute">
        <xsl:with-param name="force" select="1"/>
      </xsl:call-template>
    </xsl:if>
    <xsl:if test="((contains($toc.params, 'toc') and $toc != '0') or $toc = '1')
            and not(ancestor::answer and not($qanda.nested.in.toc=0))">
      <xsl:call-template name="process.qanda.toc"/>
    </xsl:if>
    <xsl:apply-templates select="$preamble"/>
    <xsl:call-template name="process.qandaset"/>
  </div>
</xsl:template>


<xsl:template name="process.qandaset">
  <xsl:apply-templates select="qandaentry|qandadiv"/>
</xsl:template>


<xsl:template match="qandadiv">
  <xsl:variable name="preamble" select="*[local-name(.) != 'title'
                                      and local-name(.) != 'titleabbrev'
                                      and local-name(.) != 'qandadiv'
                                      and local-name(.) != 'qandaentry']"/>

  <xsl:if test="blockinfo/title|info/title|title">
    <div class="qandadiv-title">
        <xsl:apply-templates select="(blockinfo/title|info/title|title)[1]"/>
    </div>
  </xsl:if>

  <xsl:variable name="toc">
    <xsl:call-template name="pi.dbhtml_toc"/>
  </xsl:variable>

  <xsl:variable name="toc.params">
    <xsl:call-template name="find.path.params">
      <xsl:with-param name="table" select="normalize-space($generate.toc)"/>
    </xsl:call-template>
  </xsl:variable>

  <xsl:if test="(contains($toc.params, 'toc') and $toc != '0') or $toc = '1'">
    <div class="toc">
        <xsl:call-template name="process.qanda.toc"/>
    </div>
  </xsl:if>
  <xsl:if test="$preamble">
    <div class="toc">
        <xsl:apply-templates select="$preamble"/>
    </div>
  </xsl:if>
  <xsl:apply-templates select="qandadiv|qandaentry"/>
</xsl:template>


<xsl:template match="qandaentry">
  <dl class="qandaentry">
    <xsl:call-template name="id.attribute">
      <xsl:with-param name="force" select="1"/>
    </xsl:call-template>

    <xsl:apply-templates/>
  </dl>
</xsl:template>

<xsl:template match="question">
  <dt class="question">
    <xsl:call-template name="id.attribute">
      <xsl:with-param name="force" select="1"/>
    </xsl:call-template>
    <xsl:apply-templates select="*[local-name(.) != 'label']"/>
  </dt>
</xsl:template>


<xsl:template match="answer">
  <dd class="answer">
    <xsl:call-template name="id.attribute">
      <xsl:with-param name="force" select="1"/>
    </xsl:call-template>
    <xsl:apply-templates select="*[local-name(.) != 'label'         and local-name(.) != 'qandaentry']"/>
  </dd>
</xsl:template>

<!-- ======================================================================= -->

<xsl:template match="qandaset/blockinfo/title|
                     qandaset/info/title|
                     qandaset/title">
  <xsl:variable name="qalevel">
    <xsl:call-template name="qanda.section.level"/>
  </xsl:variable>
  <xsl:element name="h{string(number($qalevel)+1)}" namespace="http://www.w3.org/1999/xhtml">
    <xsl:call-template name="id.attribute">
      <xsl:with-param name="force" select="1"/>
    </xsl:call-template>
    <xsl:apply-templates select="." mode="class.attribute"/>
    <xsl:apply-templates/>
  </xsl:element>
</xsl:template>

<xsl:template match="qandadiv/blockinfo/title|
                     qandadiv/info/title|
                     qandadiv/title">
  <xsl:variable name="qalevel">
    <xsl:call-template name="qandadiv.section.level"/>
  </xsl:variable>

  <xsl:element name="h{string(number($qalevel)+1)}" namespace="http://www.w3.org/1999/xhtml">
    <xsl:apply-templates select="." mode="class.attribute"/>
    <xsl:call-template name="id.attribute">
      <xsl:with-param name="node" select=".."/>
      <xsl:with-param name="force" select="1"/>
    </xsl:call-template>
    <xsl:apply-templates select="parent::qandadiv" mode="label.markup"/>
    <xsl:if test="$qandadiv.autolabel != 0">
      <xsl:apply-templates select="." mode="intralabel.punctuation"/>
      <xsl:text> </xsl:text>
    </xsl:if>
    <xsl:apply-templates/>
  </xsl:element>
</xsl:template>

</xsl:stylesheet>
