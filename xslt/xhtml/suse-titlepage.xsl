<?xml version="1.0" encoding="ASCII"?>
<!-- 
   Purpose:  Contains titlepage specific structure
-->

<xsl:stylesheet version="1.0"
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:date="http://exslt.org/dates-and-times"
  xmlns="http://www.w3.org/1999/xhtml"
  extension-element-prefixes="date"
  exclude-result-prefixes="date">
  
<xsl:template name="titlepage.timestamp">
  <xsl:variable name="format">
    <xsl:call-template name="gentext.template">
      <xsl:with-param name="context" select="'datetime'"/>
      <xsl:with-param name="name" select="'titlepage.format'"/>
      </xsl:call-template>
  </xsl:variable>
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
  
  <div class="buildtime">
    <p>
      <xsl:call-template name="gentext">
        <xsl:with-param name="key">PubDate</xsl:with-param>
      </xsl:call-template>
      <xsl:text> </xsl:text>
      <xsl:call-template name="datetime.format">
        <xsl:with-param name="date" select="$date"/>
        <xsl:with-param name="format" select="$format"/>
        <xsl:with-param name="padding" select="1"/>
      </xsl:call-template>
    </p>
  </div>
</xsl:template>

<!-- This stylesheet was created by template/titlepage.xsl; do not edit it by hand. -->
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

  <xsl:call-template name="titlepage.timestamp"/>

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
  <xsl:apply-templates mode="article.titlepage.recto.auto.mode" select="articleinfo/revision"/>
  <xsl:apply-templates mode="article.titlepage.recto.auto.mode" select="artheader/revision"/>
  <xsl:apply-templates mode="article.titlepage.recto.auto.mode" select="info/revision"/>
  <xsl:apply-templates mode="article.titlepage.recto.auto.mode" select="articleinfo/revhistory"/>
  <xsl:apply-templates mode="article.titlepage.recto.auto.mode" select="artheader/revhistory"/>
  <xsl:apply-templates mode="article.titlepage.recto.auto.mode" select="info/revhistory"/>
  <xsl:apply-templates mode="article.titlepage.recto.auto.mode" select="articleinfo/abstract"/>
  <xsl:apply-templates mode="article.titlepage.recto.auto.mode" select="artheader/abstract"/>
  <xsl:apply-templates mode="article.titlepage.recto.auto.mode" select="info/abstract"/>
</xsl:template>


<xsl:template name="book.titlepage.recto">
  <xsl:apply-templates mode="book.titlepage.recto.auto.mode" select="bookinfo/productname"/>
  <xsl:apply-templates mode="book.titlepage.recto.auto.mode" select="info/productname"/>
  <xsl:choose>
    <xsl:when test="bookinfo/titleabbrev">
      <xsl:apply-templates mode="book.titlepage.recto.auto.mode" select="bookinfo/titleabbrev"/>
    </xsl:when>
    <xsl:when test="info/titleabbrev">
      <xsl:apply-templates mode="book.titlepage.recto.auto.mode" select="info/titleabbrev"/>
    </xsl:when>
    <xsl:when test="titleabbrev">
      <xsl:apply-templates mode="book.titlepage.recto.auto.mode" select="titleabbrev"/>
    </xsl:when>
    <xsl:when test="title">
      <xsl:apply-templates mode="book.titlepage.recto.auto.mode" select="title"/>
    </xsl:when>
    <xsl:when test="bookinfo/title">
      <xsl:apply-templates mode="book.titlepage.recto.auto.mode" select="bookinfo/title"/>
    </xsl:when>
  </xsl:choose>
  
  <xsl:choose>
    <xsl:when test="bookinfo/subtitle">
      <xsl:apply-templates mode="book.titlepage.recto.auto.mode" select="bookinfo/subtitle"/>
    </xsl:when>
    <xsl:when test="info/subtitle">
      <xsl:apply-templates mode="book.titlepage.recto.auto.mode" select="info/subtitle"/>
    </xsl:when>
    <xsl:when test="subtitle">
      <xsl:apply-templates mode="book.titlepage.recto.auto.mode" select="subtitle"/>
    </xsl:when>
  </xsl:choose>

  
  <xsl:call-template name="titlepage.timestamp"/>
  
  <xsl:apply-templates mode="book.titlepage.recto.auto.mode" select="bookinfo/authorgroup"/>
  <xsl:apply-templates mode="book.titlepage.recto.auto.mode" select="info/authorgroup"/>
  <xsl:apply-templates mode="book.titlepage.recto.auto.mode" select="bookinfo/legalnotice"/>
  <xsl:apply-templates mode="book.titlepage.recto.auto.mode" select="info/legalnotice"/>
</xsl:template>



<xsl:template name="book.titlepage.verso">
</xsl:template>

<xsl:template name="book.titlepage.separator">
   <hr/>
</xsl:template>

<xsl:template name="book.titlepage.before.recto">
</xsl:template>

<xsl:template name="book.titlepage.before.verso">
</xsl:template>

<xsl:template name="book.titlepage">
  <!--<xsl:message>**** book.titlepage: <xsl:value-of select="name(.)"/>
  title:         <xsl:value-of select="bookinfo/title"/>
  productname:   <xsl:value-of select="bookinfo/productname"/>
  productnumber: <xsl:value-of select="bookinfo/productnumber"/>
  </xsl:message>-->
  <div class="titlepage">
    <div>
      <xsl:call-template name="book.titlepage.before.recto"/>
      <xsl:call-template name="book.titlepage.recto"/>
    </div>
    <div>
      <xsl:call-template name="book.titlepage.before.verso"/>
      <xsl:call-template name="book.titlepage.verso"/>
    </div>
    <xsl:call-template name="book.titlepage.separator"/>
  </div>
</xsl:template>

<xsl:template match="*" mode="book.titlepage.recto.mode">
  <!-- if an element isn't found in this mode, -->
  <!-- try the generic titlepage.mode -->
  <xsl:apply-templates select="." mode="titlepage.mode"/>
</xsl:template>

<xsl:template match="*" mode="book.titlepage.verso.mode">
  <!-- if an element isn't found in this mode, -->
  <!-- try the generic titlepage.mode -->
  <xsl:apply-templates select="." mode="titlepage.mode"/>
</xsl:template>

<xsl:template match="productname" mode="book.titlepage.recto.auto.mode">
   <div xsl:use-attribute-sets="book.titlepage.recto.style">
      <xsl:apply-templates select="." mode="book.titlepage.recto.mode"/>
   </div>
</xsl:template>

<xsl:template match="titleabbrev" mode="book.titlepage.recto.auto.mode">
   <div xsl:use-attribute-sets="book.titlepage.recto.style">
      <xsl:apply-templates select="." mode="book.titlepage.recto.mode"/>
   </div>
</xsl:template>

<xsl:template match="authorgroup" mode="book.titlepage.recto.auto.mode">
   <div xsl:use-attribute-sets="book.titlepage.recto.style">
      <xsl:apply-templates select="." mode="book.titlepage.recto.mode"/>
   </div>
</xsl:template>

<xsl:template match="legalnotice" mode="book.titlepage.recto.auto.mode">
   <div xsl:use-attribute-sets="book.titlepage.recto.style">
      <xsl:apply-templates select="." mode="book.titlepage.recto.mode"/>
   </div>
</xsl:template>

</xsl:stylesheet>
