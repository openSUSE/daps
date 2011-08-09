<?xml version="1.0" encoding="UTF-8"?>
<!-- $Id: xep.xsl 40505 2009-03-31 13:44:10Z toms $ -->
<xsl:stylesheet version="1.0"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:fo="http://www.w3.org/1999/XSL/Format"
    xmlns:rx="http://www.renderx.com/XSL/Extensions"
>

<xsl:template name="xep-document-information">
  <rx:meta-info>
    <xsl:variable name="authors" select="(//author|//editor|//authorgroup)[1]"/>
    <xsl:element name="rx:meta-field">
      <xsl:choose>
      <xsl:when test="$authors">
        <xsl:attribute name="name">author</xsl:attribute>
        <xsl:attribute name="value">
          <xsl:choose>
            <xsl:when test="$authors[self::authorgroup]">
              <xsl:call-template name="person.name.list">
                <xsl:with-param name="person.list" select="$authors/*[self::author|self::corpauthor|self::othercredit|self::editor]"/>
              </xsl:call-template>
            </xsl:when>
            <xsl:otherwise>
              <xsl:call-template name="person.name">
                <xsl:with-param name="node" select="$authors"/>
              </xsl:call-template>
            </xsl:otherwise>
          </xsl:choose>
        </xsl:attribute>
      </xsl:when>
      <xsl:otherwise>
        <xsl:attribute name="name">author</xsl:attribute>
        <xsl:attribute name="value">SUSE</xsl:attribute>
      </xsl:otherwise>
    </xsl:choose>
    </xsl:element>
    
    <xsl:element name="rx:meta-field">
      <xsl:attribute name="name">title</xsl:attribute>
      <xsl:attribute name="value">
        <xsl:choose>
          <xsl:when test="/set/title">
            <xsl:value-of select="normalize-space(/set/title)"/>
          </xsl:when>
          <xsl:when test="/book/bookinfo/title">
            <xsl:value-of select="normalize-space(/book/bookinfo/title)"/>
          </xsl:when>
          <xsl:when test="/book/bookinfo/productname and
                          /book/bookinfo/titleabbrev">
            <xsl:value-of select="concat(normalize-space(/book/bookinfo/productname),
                                  ' ',
                                  normalize-space(/book/bookinfo/productnumber))"/>
          </xsl:when>
          <xsl:when test="/article/title">
            <xsl:value-of select="normalize-space(/article/title)"/>
          </xsl:when>
          <xsl:otherwise>
            <xsl:apply-templates select="/*[1]" mode="label.markup"/>
            <xsl:apply-templates select="/*[1]" mode="title.markup"/>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:attribute>
    </xsl:element>

    <xsl:if test="//keyword">
      <xsl:element name="rx:meta-field">
        <xsl:attribute name="name">keywords</xsl:attribute>
        <xsl:attribute name="value">
          <xsl:for-each select="//keyword">
            <xsl:value-of select="."/>
            <xsl:if test="position() != last()">
              <xsl:text>, </xsl:text>
            </xsl:if>
          </xsl:for-each>
        </xsl:attribute>
      </xsl:element>
    </xsl:if>

    <xsl:if test="//subjectterm">
      <xsl:element name="rx:meta-field">
        <xsl:attribute name="name">subject</xsl:attribute>
        <xsl:attribute name="value">
          <xsl:for-each select="//subjectterm">
            <xsl:value-of select="."/>
            <xsl:if test="position() != last()">
              <xsl:text>, </xsl:text>
            </xsl:if>
          </xsl:for-each>
        </xsl:attribute>
      </xsl:element>
    </xsl:if>
    
    <xsl:element name="rx:meta-field">
      <xsl:attribute name="name">creator</xsl:attribute>
      <xsl:attribute name="value">
        <xsl:text>DocBook </xsl:text>
        <!-- <xsl:value-of select="$DistroTitle"/> -->
        <xsl:text> V</xsl:text>
        <xsl:value-of select="$VERSION"/>
      </xsl:attribute>
    </xsl:element>
    
  </rx:meta-info>
</xsl:template>


<!--
<xsl:template match="*" mode="xep.outline">
  <xsl:apply-templates select="*" mode="xep.outline"/>
</xsl:template>
-->

<xsl:template match="set|book|part|reference|preface|chapter|appendix|article
                     |glossary|bibliography|index|setindex
                     |refentry|refsynopsisdiv
                     |refsect1|refsect2|refsect3|refsection
                     |sect1|sect2|sect3|sect4|sect5|section"
              mode="xep.outline">
  <xsl:variable name="id">
    <xsl:call-template name="object.id"/>
  </xsl:variable>
  <xsl:variable name="bookmark-label">
    <xsl:apply-templates select=".|title/processing-instruction('suse')" 
                         mode="object.xep.title.markup"/>
  </xsl:variable>

  <!-- Put the root element bookmark at the same level as its children -->
  <!-- If the object is a set or book, generate a bookmark for the toc -->

  <xsl:choose>
    <xsl:when test="parent::*">
      <rx:bookmark internal-destination="{$id}">
        <xsl:choose>
          <xsl:when test="self::set|self::part|self::book">
            <xsl:attribute name="collapse-subtree"
              >false</xsl:attribute>
          </xsl:when>
          <xsl:when test="self::chapter|self::appendix|self::glossary">
            <xsl:attribute name="collapse-subtree"
              >true</xsl:attribute>
          </xsl:when>
        </xsl:choose>
        <rx:bookmark-label>
          <xsl:value-of select="$bookmark-label"/>
        </rx:bookmark-label>
        <xsl:apply-templates select="*" mode="xep.outline"/>
      </rx:bookmark>
    </xsl:when>
    <xsl:otherwise>
      <xsl:if test="$bookmark-label != ''">
        <rx:bookmark internal-destination="{$id}">
          <rx:bookmark-label>
            <xsl:value-of select="$bookmark-label"/>
          </rx:bookmark-label>
        </rx:bookmark>
      </xsl:if>

      <xsl:variable name="toc.params">
        <xsl:call-template name="find.path.params">
          <xsl:with-param name="table" select="normalize-space($generate.toc)"/>
        </xsl:call-template>
      </xsl:variable>
      <xsl:if test="contains($toc.params, 'toc')
                    and set|book|part|reference|section|sect1|refentry
                        |article|bibliography|glossary|chapter
                        |appendix">
        <rx:bookmark internal-destination="toc...{$id}">
          <rx:bookmark-label>
            <xsl:call-template name="gentext">
              <xsl:with-param name="key" select="'TableofContents'"/>
            </xsl:call-template>
          </rx:bookmark-label>
        </rx:bookmark>
      </xsl:if>
      <xsl:apply-templates select="*" mode="xep.outline"/>
    </xsl:otherwise>
  </xsl:choose>
</xsl:template>

<xsl:template match="*" mode="object.xep.title.markup">
  <xsl:param name="allow-anchors" select="0"/>
  <xsl:variable name="template">
    <xsl:apply-templates select="." mode="object.xep.title.template"/>
  </xsl:variable>
  
  <xsl:call-template name="substitute-markup">
    <xsl:with-param name="allow-anchors" select="$allow-anchors"/>
    <xsl:with-param name="template" select="$template"/>
  </xsl:call-template> 
</xsl:template>


<xsl:template match="*" mode="object.xep.title.template">
  <xsl:call-template name="gentext.template">
    <xsl:with-param name="context" select="'xep-bookmark-title'"/>
    <xsl:with-param name="name">
      <xsl:call-template name="xpath.location"/>
    </xsl:with-param>
  </xsl:call-template>
</xsl:template>

<xsl:template match="appendix|chapter|part
                     |refsect1
                     |section|sect1|sect2|sect3|sect4|sect5|simplesect
                     |bridgehead"
              mode="object.xep.title.template">
  <xsl:call-template name="gentext.template">
     <!-- title-unnumbered -->
     <xsl:with-param name="context" select="'xep-bookmark-title'"/>
     <xsl:with-param name="name">
        <xsl:call-template name="xpath.location"/>
     </xsl:with-param>
  </xsl:call-template>
</xsl:template>

</xsl:stylesheet>
