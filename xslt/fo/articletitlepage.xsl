<?xml version="1.0" encoding="UTF-8"?>
<!-- $Id: articletitlepage.xsl 43595 2009-08-13 06:25:57Z toms $ -->
<!DOCTYPE xsl:stylesheet >
<xsl:stylesheet version="1.0"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:fo="http://www.w3.org/1999/XSL/Format"
    xmlns:svg="http://www.w3.org/2000/svg">



<xsl:template name="article.titlepage.recto">
  <xsl:choose>
    <xsl:when test="articleinfo/title">
      <xsl:apply-templates mode="article.titlepage.recto.auto.mode" select="articleinfo/title"/>
    </xsl:when>
    <xsl:when test="artheader/title">
      <xsl:apply-templates mode="article.titlepage.recto.auto.mode" select="artheader/title"/>
    </xsl:when>
    <xsl:when test="info/title">
      <xsl:apply-templates mode="article.titlepage.recto.auto.mode" select="info/title"/>
    </xsl:when>
    <xsl:when test="title">
      <xsl:apply-templates mode="article.titlepage.recto.auto.mode" select="title"/>
    </xsl:when>
  </xsl:choose>

  <xsl:choose>
    <xsl:when test="articleinfo/subtitle">
      <xsl:apply-templates mode="article.titlepage.recto.auto.mode" select="articleinfo/subtitle"/>
    </xsl:when>
    <xsl:when test="artheader/subtitle">
      <xsl:apply-templates mode="article.titlepage.recto.auto.mode" select="artheader/subtitle"/>
    </xsl:when>
    <xsl:when test="info/subtitle">
      <xsl:apply-templates mode="article.titlepage.recto.auto.mode" select="info/subtitle"/>
    </xsl:when>
    <xsl:when test="subtitle">
      <xsl:apply-templates mode="article.titlepage.recto.auto.mode" select="subtitle"/>
    </xsl:when>
  </xsl:choose>

  <xsl:apply-templates mode="article.titlepage.recto.auto.mode" select="articleinfo/corpauthor"/>
  <xsl:apply-templates mode="article.titlepage.recto.auto.mode" select="artheader/corpauthor"/>
  <xsl:apply-templates mode="article.titlepage.recto.auto.mode" select="info/corpauthor"/>
  <xsl:apply-templates mode="article.titlepage.recto.auto.mode" select="articleinfo/authorgroup"/>
  <xsl:apply-templates mode="article.titlepage.recto.auto.mode" select="artheader/authorgroup"/>
  <xsl:apply-templates mode="article.titlepage.recto.auto.mode" select="info/authorgroup"/>
  <xsl:apply-templates mode="article.titlepage.recto.auto.mode" select="articleinfo/author"/>
  <xsl:apply-templates mode="article.titlepage.recto.auto.mode" select="artheader/author"/>
  <xsl:apply-templates mode="article.titlepage.recto.auto.mode" select="info/author"/>
  <xsl:apply-templates mode="article.titlepage.recto.auto.mode" select="articleinfo/othercredit"/>
  <xsl:apply-templates mode="article.titlepage.recto.auto.mode" select="artheader/othercredit"/>
  <xsl:apply-templates mode="article.titlepage.recto.auto.mode" select="info/othercredit"/>
  <xsl:apply-templates mode="article.titlepage.recto.auto.mode" select="articleinfo/releaseinfo"/>
  <xsl:apply-templates mode="article.titlepage.recto.auto.mode" select="artheader/releaseinfo"/>
  <xsl:apply-templates mode="article.titlepage.recto.auto.mode" select="info/releaseinfo"/>
  <xsl:apply-templates mode="article.titlepage.recto.auto.mode" select="articleinfo/copyright"/>
  <xsl:apply-templates mode="article.titlepage.recto.auto.mode" select="artheader/copyright"/>
  <xsl:apply-templates mode="article.titlepage.recto.auto.mode" select="info/copyright"/>
  <xsl:apply-templates mode="article.titlepage.recto.auto.mode" select="articleinfo/legalnotice"/>
  <xsl:apply-templates mode="article.titlepage.recto.auto.mode" select="artheader/legalnotice"/>
  <xsl:apply-templates mode="article.titlepage.recto.auto.mode" select="info/legalnotice"/>
  <xsl:apply-templates mode="article.titlepage.recto.auto.mode" select="articleinfo/pubdate"/>
  <xsl:apply-templates mode="article.titlepage.recto.auto.mode" select="artheader/pubdate"/>
  <xsl:apply-templates mode="article.titlepage.recto.auto.mode" select="info/pubdate"/>
<!--   <xsl:apply-templates mode="article.titlepage.recto.auto.mode" select="articleinfo/revision"/> -->
<!--   <xsl:apply-templates mode="article.titlepage.recto.auto.mode" select="artheader/revision"/> -->
<!--   <xsl:apply-templates mode="article.titlepage.recto.auto.mode" select="info/revision"/> -->
<!--   <xsl:apply-templates mode="article.titlepage.recto.auto.mode" select="articleinfo/revhistory"/> -->
<!--   <xsl:apply-templates mode="article.titlepage.recto.auto.mode" select="artheader/revhistory"/> -->
<!--   <xsl:apply-templates mode="article.titlepage.recto.auto.mode" select="info/revhistory"/> -->
  <xsl:apply-templates mode="article.titlepage.recto.auto.mode" select="articleinfo/abstract"/>
  <xsl:apply-templates mode="article.titlepage.recto.auto.mode" select="artheader/abstract"/>
  <xsl:apply-templates mode="article.titlepage.recto.auto.mode" select="info/abstract"/>

</xsl:template>


<!--<xsl:template name="article.titlepage.separator">
  <fo:block break-after="page">
  <fo:leader leader-pattern="space" leader-length="0pt"/> </fo:block>
</xsl:template>-->

<xsl:template name="article.titlepage.before.verso">
   <fo:block space-after="4em"/>
   <xsl:apply-templates select="articleinfo/mediaobject"/>
</xsl:template>

<xsl:template name="article.titlepage.verso">
  <fo:block break-after="page">
  <fo:leader leader-pattern="space" leader-length="0pt"/> </fo:block>
  <xsl:apply-templates mode="article.titlepage.recto.auto.mode" select="articleinfo/revhistory"/>
  <xsl:apply-templates mode="article.titlepage.recto.auto.mode" select="artheader/revhistory"/>
  <xsl:apply-templates mode="article.titlepage.recto.auto.mode" select="info/revhistory"/>

</xsl:template>


<xsl:template match="article/articleinfo/legalnotice" mode="titlepage.mode">
  <xsl:variable name="id">
    <xsl:call-template name="object.id"/>
  </xsl:variable>

  <!-- New page -->
  <fo:block break-after="page">
  <fo:leader leader-pattern="space" leader-length="0pt"/> </fo:block>

   <xsl:apply-imports/>
  <!--<fo:block id="{$id}" font-size="9pt">
    <xsl:if test="title"> <!- - FIXME: add param for using default title? - ->
      <xsl:call-template name="formal.object.heading"/>
    </xsl:if>
    <xsl:apply-templates mode="titlepage.mode"/>
  </fo:block>-->
</xsl:template>


<xsl:template match="title" mode="article.titlepage.recto.auto.mode">
 <fo:block xsl:use-attribute-sets="article.titlepage.recto.style"
         role="article.titlepage.recto.auto.mode"
         margin-top="3cm"
         keep-with-next.within-column="always"
         font-size="24.8832pt" font-weight="bold">
   <xsl:call-template name="component.title">
    <xsl:with-param name="node" select="ancestor-or-self::article[1]"/>
   </xsl:call-template>
 </fo:block>
</xsl:template>



</xsl:stylesheet>
