<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0"
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:fo="http://www.w3.org/1999/XSL/Format">
  
 <xsl:template name="qandaset.toc"/>
  
  <xsl:template name="book.titlepage.recto">
    
    <fo:block text-align="center" space-before="10em"
      space-before.conditionality="retain" space-before.precedence="10">
      <fo:external-graphic src="manager.svg">
    <xsl:attribute name="src">
      <!--<xsl:call-template name="image.src">
      <xsl:with-param name="filename">manager.svg</xsl:with-param>
    </xsl:call-template>-->
      <xsl:value-of select='concat("url(&apos;", 
                                        "../../xslt/fo/manager.svg",
                                        "&apos;)")'/>
    </xsl:attribute>
  </fo:external-graphic>
    </fo:block>  
    
  <xsl:choose>
    <xsl:when test="bookinfo/title">
      <xsl:apply-templates mode="book.titlepage.recto.auto.mode" select="bookinfo/title"/>
    </xsl:when>
    <xsl:when test="info/title">
      <xsl:apply-templates mode="book.titlepage.recto.auto.mode" select="info/title"/>
    </xsl:when>
    <xsl:when test="title">
      <xsl:apply-templates mode="book.titlepage.recto.auto.mode" select="title"/>
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

  <xsl:apply-templates mode="book.titlepage.recto.auto.mode" select="bookinfo/corpauthor"/>
  <xsl:apply-templates mode="book.titlepage.recto.auto.mode" select="info/corpauthor"/>
  <xsl:apply-templates mode="book.titlepage.recto.auto.mode" select="bookinfo/authorgroup"/>
  <xsl:apply-templates mode="book.titlepage.recto.auto.mode" select="info/authorgroup"/>
  <xsl:apply-templates mode="book.titlepage.recto.auto.mode" select="bookinfo/author"/>
  <xsl:apply-templates mode="book.titlepage.recto.auto.mode" select="info/author"/>
  <xsl:apply-templates mode="book.titlepage.recto.auto.mode" select="bookinfo/itermset"/>
  <xsl:apply-templates mode="book.titlepage.recto.auto.mode" select="info/itermset"/>
</xsl:template>

  
  
  <xsl:template name="book.titlepage.verso">
  <xsl:choose>
    <xsl:when test="bookinfo/title">
      <xsl:apply-templates mode="book.titlepage.verso.auto.mode" select="bookinfo/title"/>
    </xsl:when>
    <xsl:when test="info/title">
      <xsl:apply-templates mode="book.titlepage.verso.auto.mode" select="info/title"/>
    </xsl:when>
    <xsl:when test="title">
      <xsl:apply-templates mode="book.titlepage.verso.auto.mode" select="title"/>
    </xsl:when>
  </xsl:choose>
  
  <xsl:apply-templates mode="book.titlepage.verso.auto.mode" select="bookinfo/corpauthor"/>
  <xsl:apply-templates mode="book.titlepage.verso.auto.mode" select="info/corpauthor"/>
  <xsl:apply-templates mode="book.titlepage.verso.auto.mode" select="bookinfo/authorgroup"/>
  <xsl:apply-templates mode="book.titlepage.verso.auto.mode" select="info/authorgroup"/>
  <xsl:apply-templates mode="book.titlepage.verso.auto.mode" select="bookinfo/author"/>
  <xsl:apply-templates mode="book.titlepage.verso.auto.mode" select="info/author"/>
  <xsl:apply-templates mode="book.titlepage.verso.auto.mode" select="bookinfo/othercredit"/>
  <xsl:apply-templates mode="book.titlepage.verso.auto.mode" select="info/othercredit"/>
  <!--<xsl:apply-templates mode="book.titlepage.verso.auto.mode" select="bookinfo/releaseinfo"/>
  <xsl:apply-templates mode="book.titlepage.verso.auto.mode" select="info/releaseinfo"/>-->
    
    <fo:block>
      <xsl:apply-templates mode="book.titlepage.verso.auto.mode"
     select="bookinfo/productname"/>
    <fo:inline>, </fo:inline>
    <xsl:apply-templates mode="book.titlepage.verso.auto.mode"
     select="bookinfo/productnumber"/> 
    </fo:block>
    <xsl:apply-templates mode="book.titlepage.verso.auto.mode"
    select="bookinfo/bibliosource"/>
   
  <xsl:apply-templates mode="book.titlepage.verso.auto.mode" select="bookinfo/pubdate"/>
  <xsl:apply-templates mode="book.titlepage.verso.auto.mode" select="info/pubdate"/>
  <xsl:apply-templates mode="book.titlepage.verso.auto.mode" select="bookinfo/copyright"/>
  <xsl:apply-templates mode="book.titlepage.verso.auto.mode" select="info/copyright"/>
  <xsl:apply-templates mode="book.titlepage.verso.auto.mode" select="bookinfo/abstract"/>
  <xsl:apply-templates mode="book.titlepage.verso.auto.mode" select="info/abstract"/>
  <xsl:apply-templates mode="book.titlepage.verso.auto.mode" select="bookinfo/legalnotice"/>
  <xsl:apply-templates mode="book.titlepage.verso.auto.mode" select="info/legalnotice"/>
</xsl:template>
  
  <!--<xsl:template match="bibliosource" name="book.titlepage.verso.auto.mode">
    <xsl:param name="url" select="normalize-space(.)"/>
    <xsl:variable name ="ulink.url">
      
      <xsl:message></xsl:message>
      
    <xsl:call-template name="fo-external-image">
      <xsl:with-param name="filename" select="$url"/>
    </xsl:call-template>
  </xsl:variable>
    <fo:block hyphenate="false">
      <xsl:call-template name="hyphenate-url">
        <xsl:with-param name="url" select="$url"/>
      </xsl:call-template>
    </fo:block>
  </xsl:template>-->
</xsl:stylesheet>