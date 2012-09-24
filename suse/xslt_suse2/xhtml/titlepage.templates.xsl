<?xml version="1.0" encoding="UTF-8"?>
<!-- 
   Purpose:
     Create customized title pages for book and article
     
   See Also:
     * http://doccookbook.sf.net/html/en/dbc.common.dbcustomize.html
     * http://sagehill.net/docbookxsl/CustomMethods.html#WriteCustomization

   Author:    Thomas Schraitle <toms@opensuse.org>
              Stefan Knorr <sknorr (AT) suse DOT de>
   Copyright: 2012, Thomas Schraitle

-->
<xsl:stylesheet version="1.0"
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns="http://www.w3.org/1999/xhtml">

  <xsl:template name="add.version.info">
    <xsl:variable name="products"
      select="ancestor-or-self::*/*/productname | ancestor-or-self::*/*/productnumber"/>
    <xsl:if test="$generate.version.info != 0 and $products">
      <div class="version-info">
        <xsl:call-template name="gentext">
          <xsl:with-param name="key">version.info</xsl:with-param>
        </xsl:call-template>
        <xsl:apply-templates select="ancestor-or-self::*/*/productname"/>
        <xsl:text> </xsl:text>
        <xsl:apply-templates select="ancestor-or-self::*/*/productnumber"/>
      </div>
    </xsl:if>
  </xsl:template>


  <!-- ===================================================== -->
  <!-- article titlepage templates -->
  <xsl:template match="authorgroup" mode="article.titlepage.recto.auto.mode">
    <div xsl:use-attribute-sets="article.titlepage.recto.style">
      <span class="contributor-label">
      <xsl:call-template name="gentext">
        <xsl:with-param name="key">Authors</xsl:with-param>
      </xsl:call-template>
      <xsl:text>: </xsl:text>
      </span>
      <xsl:call-template name="person.name.list">
        <xsl:with-param name="person.list" select="author|corpauthor"/>
      </xsl:call-template>
    </div>
    <xsl:if test="othercredit|editor">
      <div>
        <xsl:call-template name="person.name.list">
          <xsl:with-param name="person.list" select="othercredit|editor"/>
        </xsl:call-template>
      </div>
    </xsl:if>
  </xsl:template>
  
  <xsl:template match="author" mode="article.titlepage.recto.auto.mode">
    <div xsl:use-attribute-sets="book.titlepage.recto.style">
      <span class="contributor-label">
      <xsl:call-template name="gentext">
        <xsl:with-param name="key">Author</xsl:with-param>
      </xsl:call-template>
      <xsl:text>: </xsl:text>
      </span>
      <xsl:call-template name="person.name"/>
    </div>
  </xsl:template>

  <xsl:template match="abstract" mode="article.titlepage.recto.auto.mode">
    <xsl:apply-templates select="."/>
  </xsl:template>

  <xsl:template name="article.titlepage.recto">
        <xsl:call-template name="add.version.info"/>
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
        
        <xsl:apply-templates mode="article.titlepage.recto.auto.mode" select="articleinfo/othercredit"/>
        <xsl:apply-templates mode="article.titlepage.recto.auto.mode" select="artheader/othercredit"/>
        <xsl:apply-templates mode="article.titlepage.recto.auto.mode" select="info/othercredit"/>
        <xsl:apply-templates mode="article.titlepage.recto.auto.mode" select="articleinfo/releaseinfo"/>
        <xsl:apply-templates mode="article.titlepage.recto.auto.mode" select="artheader/releaseinfo"/>
        <xsl:apply-templates mode="article.titlepage.recto.auto.mode" select="info/releaseinfo"/>
        <xsl:apply-templates mode="article.titlepage.recto.auto.mode" select="articleinfo/copyright"/>
        <xsl:apply-templates mode="article.titlepage.recto.auto.mode" select="artheader/copyright"/>
        <xsl:apply-templates mode="article.titlepage.recto.auto.mode" select="info/copyright"/>
        <!-- Legal notice removed from here, now positioned at the bottom of the page, see: division.xsl -->
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
        <!-- Moved authors and authorgroups here: -->
        <xsl:apply-templates mode="article.titlepage.recto.auto.mode" select="articleinfo/corpauthor"/>
        <xsl:apply-templates mode="article.titlepage.recto.auto.mode" select="artheader/corpauthor"/>
        <xsl:apply-templates mode="article.titlepage.recto.auto.mode" select="info/corpauthor"/>
        <xsl:apply-templates mode="article.titlepage.recto.auto.mode" select="articleinfo/authorgroup"/>
        <xsl:apply-templates mode="article.titlepage.recto.auto.mode" select="artheader/authorgroup"/>
        <xsl:apply-templates mode="article.titlepage.recto.auto.mode" select="info/authorgroup"/>
        <xsl:apply-templates mode="article.titlepage.recto.auto.mode" select="articleinfo/author"/>
        <xsl:apply-templates mode="article.titlepage.recto.auto.mode" select="artheader/author"/>
       <xsl:apply-templates mode="article.titlepage.recto.auto.mode" select="info/author"/>
  </xsl:template>

  <!-- ===================================================== -->
  <!-- book titlepage templates --> 
  <xsl:template name="set.titlepage.separator"/>
  <xsl:template name="book.titlepage.separator"/>
  
  <xsl:template name="book.titlepage.recto">
    <xsl:call-template name="add.version.info"/>
    
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
        
        <xsl:apply-templates mode="book.titlepage.recto.auto.mode" select="bookinfo/releaseinfo"/>
        <xsl:apply-templates mode="book.titlepage.recto.auto.mode" select="info/releaseinfo"/>
        <xsl:apply-templates mode="book.titlepage.recto.auto.mode" select="bookinfo/copyright"/>
        <xsl:apply-templates mode="book.titlepage.recto.auto.mode" select="info/copyright"/>
    
        <!-- Legal notice removed from here, now positioned at the bottom of the page, see: division.xsl -->
        <xsl:apply-templates mode="book.titlepage.recto.auto.mode" select="bookinfo/pubdate"/>
        <xsl:apply-templates mode="book.titlepage.recto.auto.mode" select="info/pubdate"/>
    
        <xsl:apply-templates mode="book.titlepage.recto.auto.mode" select="bookinfo/revision"/>
        <xsl:apply-templates mode="book.titlepage.recto.auto.mode" select="info/revision"/>
        <xsl:apply-templates mode="book.titlepage.recto.auto.mode" select="bookinfo/revhistory"/>
        <xsl:apply-templates mode="book.titlepage.recto.auto.mode" select="info/revhistory"/>
    
        <xsl:apply-templates mode="book.titlepage.recto.auto.mode" select="bookinfo/abstract"/>
        <xsl:apply-templates mode="book.titlepage.recto.auto.mode" select="info/abstract"/>
    
        <xsl:apply-templates mode="book.titlepage.recto.auto.mode" select="bookinfo/corpauthor"/>
        <xsl:apply-templates mode="book.titlepage.recto.auto.mode" select="info/corpauthor"/>
        <xsl:apply-templates mode="book.titlepage.recto.auto.mode" select="bookinfo/authorgroup"/>
        <xsl:apply-templates mode="book.titlepage.recto.auto.mode" select="info/authorgroup"/>
        <xsl:apply-templates mode="book.titlepage.recto.auto.mode" select="bookinfo/author"/>
        <xsl:apply-templates mode="book.titlepage.recto.auto.mode" select="info/author"/>
        <xsl:apply-templates mode="book.titlepage.recto.auto.mode" select="bookinfo/othercredit"/>
        <xsl:apply-templates mode="book.titlepage.recto.auto.mode" select="info/othercredit"/>
  </xsl:template>

  <xsl:template match="authorgroup" mode="book.titlepage.recto.auto.mode">
    <div>
      <xsl:call-template name="generate.class.attribute"/>
      <div xsl:use-attribute-sets="book.titlepage.recto.style">
        <span class="authorgroup-label">
          <xsl:call-template name="gentext">
            <xsl:with-param name="key">Authors</xsl:with-param>
          </xsl:call-template>
          <xsl:text>: </xsl:text>
        </span>
        <xsl:call-template name="person.name.list">
          <xsl:with-param name="person.list" select="author|corpauthor"
          />
        </xsl:call-template>
      </div>
      <xsl:if test="othercredit|editor">
        <div>
          <span class="contributor-label">
            <xsl:call-template name="gentext">
              <xsl:with-param name="key">
                <xsl:choose>
                  <xsl:when test="count(othercredit|editor) > 1"
                    >Contributors</xsl:when>
                  <xsl:otherwise>Contributor</xsl:otherwise>
                </xsl:choose>
              </xsl:with-param>
            </xsl:call-template>
            <xsl:text>: </xsl:text>
          </span>
          <xsl:call-template name="person.name.list">
            <xsl:with-param name="person.list"
              select="othercredit|editor"/>
          </xsl:call-template>
        </div>
      </xsl:if>
    </div>
  </xsl:template>

  <xsl:template match="author" mode="book.titlepage.recto.auto.mode">
    <div xsl:use-attribute-sets="book.titlepage.recto.style">
      <span class="contributor-label">
      <xsl:call-template name="gentext">
        <xsl:with-param name="key">Author</xsl:with-param>
      </xsl:call-template>
      <xsl:text>: </xsl:text>
      </span>
      <xsl:call-template name="person.name"/>
    </div>
  </xsl:template>

  <xsl:template match="abstract" mode="book.titlepage.recto.auto.mode">
    <xsl:apply-templates select="."/>
  </xsl:template>  
</xsl:stylesheet>
