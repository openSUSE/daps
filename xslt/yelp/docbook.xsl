<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE xsl:stylesheet [
  <!ENTITY db "http://docbook.sourceforge.net/release/xsl/current">
]>
<xsl:stylesheet version="1.0"
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:exsl="http://exslt.org/common"
  xmlns:suse="urn:x-suse:namespace:1.0"
  extension-element-prefixes="exsl suse" >


  <xsl:import href="&db;/html/docbook.xsl"/>

  <xsl:import href="&db;/common/pi.xsl"/>
  <xsl:import href="&db;/html/chunk-common.xsl"/>
  <xsl:import href="&db;/html/chunk-code.xsl"/>

  <xsl:output method="text" encoding="UTF-8"/>
  

  <xsl:include href="../profiling/suse-pi.xsl"/>
  
  <xsl:key name="id" match="*" use="@id|@xml:id" />

  <!-- use.id.as.filename: Use id attribute as filename instead of
                         "standard" numbering schema            -->
  <xsl:param name="use.id.as.filename" select="1" />
  
  <!-- categories: Comma-separated list of categories             -->
  <xsl:param name="categories"/>
  
  <!-- docid: Identifier for this document -->
  <xsl:param name="docid"/>
  
  <!-- docpath: Inserts string in desktop files DocPath           -->
  <xsl:param name="docpath" select="'@PATH@/'" />
  
  <!-- docweight: The "weight" of this documentation -->
  <xsl:param name="docweight" select="0"/>
  
  <!-- file.encoding: Use selected encoding for each file         -->
  <xsl:param name="file.encoding" select="'UTF-8'" />
  
  <!-- file.ext: Each filename contains this suffix               -->
  <xsl:param name="file.ext" select="'.document'" />
  
  <!-- html.ext: suffix for HTML                                  -->
  <xsl:param name="html.ext" select="'.html'" />
  
  <!-- rootid: Process only this element and their childs         -->
  <xsl:param name="rootid"/>

  <!-- outformat: -->
  <xsl:param name="outformat"/>
  
  <!-- outputdir: Sets the output directory for each desktop file -->
  <xsl:param name="outputdir" select="'yelp/'" />
  
  <!-- Remove any space -->
  <xsl:strip-space elements="*"/>


<xsl:template match="*"/>

<xsl:template match="/">
  <xsl:choose>
      <xsl:when test="$rootid != ''">
        <xsl:choose>
          <xsl:when test="count(key('id',$rootid)) = 0">
            <xsl:message terminate="yes">
              <xsl:text>ID '</xsl:text>
              <xsl:value-of select="$rootid" />
              <xsl:text>' not found in document.</xsl:text>
            </xsl:message>
          </xsl:when>
          <xsl:otherwise>
            <xsl:apply-templates select="key('id',$rootid)" />
          </xsl:otherwise>
        </xsl:choose>
      </xsl:when>
      <xsl:otherwise>
        <xsl:apply-templates />
      </xsl:otherwise>
    </xsl:choose>
</xsl:template>


<xsl:template match="set">
  <xsl:variable name="lang">
    <xsl:choose>
      <xsl:when test="@lang">
        <xsl:value-of select="@lang"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:message>Missing Language in book!&#10;</xsl:message>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:variable>
  <xsl:variable name="localdocpath">
      <xsl:value-of select="$docpath" />
      <xsl:apply-templates select="self::*" mode="recursive-chunk-filename"/>
  </xsl:variable>
  <xsl:variable name="name">
    <xsl:apply-templates select="title"/>
  </xsl:variable>
  <xsl:variable name="setfilename">
    <!--<xsl:value-of select="current()/@id"/>-->
    <xsl:apply-templates select="self::*" mode="recursive-chunk-filename"/>
    <xsl:value-of select="$file.ext"/>
  </xsl:variable>
  <xsl:variable name="setfilecontent">
    <xsl:text>[Document]</xsl:text>
    <xsl:text>&#10;DocPath=</xsl:text>
    <xsl:value-of select="$localdocpath"/>

    <xsl:text>&#10;DocType=text/</xsl:text>
    <xsl:value-of select="$outformat"/>

    <xsl:text>&#10;DocLang=</xsl:text>
    <xsl:value-of select="$lang"/>

    <xsl:text>&#10;Icon=document2</xsl:text>

    <xsl:text>&#10;Categories=</xsl:text>
    <xsl:value-of select="$categories"/>

    <xsl:text>&#10;Name=</xsl:text>
    <xsl:value-of select="$name"/>

    <xsl:text>&#10;Name[</xsl:text>
    <xsl:value-of select="$lang"/>
    <xsl:text>]=</xsl:text>
    <xsl:value-of select="$name"/>

    <xsl:text>&#10;DocIdentifier=</xsl:text>
    <xsl:value-of select="normalize-space( $docid )"/>

    <xsl:text>&#10;DocWeight=</xsl:text>
    <xsl:value-of select="$docweight"/>
    <xsl:text>&#10;</xsl:text>
  </xsl:variable>
  
  <xsl:call-template name="write.text.chunk">
      <xsl:with-param name="filename"
        select="concat($outputdir, $setfilename)" />
      <xsl:with-param name="content" select="$setfilecontent" />
      <xsl:with-param name="encoding" select="$file.encoding" />
  </xsl:call-template>
  
  
  <xsl:for-each select="book|article">
    <xsl:variable name="filecontent">
      <xsl:apply-templates select="current()" />
    </xsl:variable>
    <xsl:variable name="filename">
      <xsl:value-of select="current()/@id"/>
      <xsl:value-of select="$file.ext"/>
    </xsl:variable>
    
    <xsl:call-template name="write.text.chunk">
      <xsl:with-param name="filename"
        select="concat($outputdir, $filename)" />
      <xsl:with-param name="content" select="$filecontent" />
      <xsl:with-param name="encoding" select="$file.encoding" />
    </xsl:call-template>
  </xsl:for-each>
  
</xsl:template>

<xsl:template match="book|article">
  <xsl:variable name="lang">
    <xsl:choose>
      <xsl:when test="@lang">
        <xsl:value-of select="@lang"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:message>Missing Language in book!&#10;</xsl:message>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:variable>
  <xsl:variable name="localdocpath">
      <xsl:value-of select="$docpath" />
      <xsl:apply-templates select="self::*" mode="recursive-chunk-filename"/>
  </xsl:variable>
  <xsl:variable name="name">
    <xsl:choose>
      <xsl:when test="self::book">
        <xsl:value-of select="normalize-space( (title|bookinfo/title)[1] )"/>
      </xsl:when>
      <xsl:when test="self::article">
        <xsl:value-of select="normalize-space( (title|articleinfo/title)[1] )"/>
      </xsl:when>
      <xsl:otherwise>???</xsl:otherwise>
    </xsl:choose>
  </xsl:variable>
  
  <!--<xsl:message><xsl:value-of select="name(.)"/>
  lang: = <xsl:value-of select="$lang"/>
  localdocpath = <xsl:value-of select="$localdocpath"/>
  name = <xsl:value-of select="$name"/>
  </xsl:message>-->
  
  <xsl:text>[Document]</xsl:text>
  <xsl:text>&#10;DocPath=</xsl:text>
  <xsl:value-of select="$localdocpath"/>

  <xsl:text>&#10;DocType=text/</xsl:text>
  <xsl:value-of select="$outformat"/>
  
  <xsl:text>&#10;DocLang=</xsl:text>
  <xsl:value-of select="$lang"/>
  
  <xsl:text>&#10;Icon=document2</xsl:text>
  
  <xsl:text>&#10;Categories=</xsl:text>
  <xsl:value-of select="$categories"/>
  
  <xsl:text>&#10;Name=</xsl:text>
  <xsl:value-of select="$name"/>
  
  <xsl:text>&#10;Name[</xsl:text>
  <xsl:value-of select="$lang"/>
  <xsl:text>]=</xsl:text>
  <xsl:value-of select="$name"/>
  
  <xsl:text>&#10;DocIdentifier=</xsl:text>
  <xsl:value-of select="normalize-space( $docid )"/>
  
  <xsl:text>&#10;DocWeight=</xsl:text>
  <xsl:value-of select="$docweight"/>
  <xsl:text>&#10;</xsl:text>
</xsl:template>

<xsl:template match="set/title">
  <xsl:apply-templates/>
</xsl:template>

</xsl:stylesheet>
