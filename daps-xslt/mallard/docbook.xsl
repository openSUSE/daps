<?xml version="1.0" encoding="UTF-8"?>
<!--
   Purpose:
     Creates a "page" XML output file which is compatible with
     project Mallard (see http://projectmallard.org)

   Parameters:
     * packagename: Needed for Page format of the package name
       (default: @PACKAGENAME@)
     * productid: Used to differentiate of several products in
       the new Yelp page (default: /*/*/productname, this XPath
       matches both for article, book, or set root elements)
     * generate.xml-model.pi: Creates the PI <?xml-model href="..."
       type="application/relax-ng-compact-syntax"?>.
       This is useful for validation with RELAX NG and oXygen.

   Input:
     DocBook 4/Novdoc document

   Output:
     Page XML output according to the RELAX NG schema from
     http://projectmallard.org/1.0/mallard-1.0.rnc

   Note:
     If an article or book does NOT contain an @id, it won't be
     included into the output format. In such a case, the stlyesheet
     prints a warning.

-->
<!DOCTYPE xsl:stylesheet [
  <!ENTITY lowercase "'abcdefghijklmnopqrstuvwxyz'">
  <!ENTITY uppercase "'ABCDEFGHIJKLMNOPQRSTUVWXYZ'">
]>
<xsl:stylesheet version="1.0"
  xmlns="http://projectmallard.org/1.0/"
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform">

  <xsl:output method="xml" indent="yes"/>
  <xsl:strip-space elements="*"/>

  <xsl:param name="productid">
    <xsl:call-template name="discard.space">
      <xsl:with-param name="string">
        <xsl:call-template name="string.lower">
          <xsl:with-param name="string" select="normalize-space(*/*/productname)"/>
        </xsl:call-template>
      </xsl:with-param>
    </xsl:call-template>
  </xsl:param>
  <xsl:param name="packagename">@PACKAGENAME@</xsl:param>
  <xsl:param name="generate.xml-model.pi" select="1"/>

  <xsl:template name="string.lower">
    <xsl:param name="string" select="''"/>
    <xsl:value-of select="translate($string,&uppercase;,&lowercase;)"/>
  </xsl:template>
  <xsl:template name="discard.space">
    <xsl:param name="string" select="''"/>
    <xsl:value-of select="translate($string, ' ', '')"/>
  </xsl:template>

  <xsl:template name="create-info">
    <xsl:param name="node" select="."/>
    <xsl:param name="subnodes" select="book"/>

    <info>
      <link type="guide" xref="index" group="{$packagename}"/>
      <credit type="author">
        <name>Documentation Team</name>
        <email>doc-team@suse.de</email>
      </credit>

      <desc>
        <xsl:choose>
          <xsl:when test="*/productname">
            <xsl:value-of select="normalize-space(*/productname)"/>
            <xsl:text> comes with the following documents:</xsl:text>
          </xsl:when>
          <xsl:otherwise>
            <xsl:text>This product comes with the following documents: </xsl:text>
          </xsl:otherwise>
        </xsl:choose>
        <xsl:apply-templates select="$subnodes"/>
      </desc>
    </info>
  </xsl:template>

  <xsl:template name="warning">
    <xsl:message>
      <xsl:text>Warning: Missing @id in </xsl:text>
      <xsl:value-of select="local-name()"/>
      <xsl:text>, skipped </xsl:text>
      <xsl:value-of select="(*/title|title)[1]"/>
    </xsl:message>
  </xsl:template>

  <xsl:template match="/">
    <xsl:if test="$generate.xml-model.pi != 0">
      <xsl:processing-instruction name="xml-model"
      >href="mallard-1.0.rnc" type="application/relax-ng-compact-syntax"</xsl:processing-instruction>
    </xsl:if>
    <xsl:text>&#10;</xsl:text>
    <xsl:apply-templates/>
  </xsl:template>

  <xsl:template match="/set">
    <xsl:param name="node" select="."/>
    <page type="guide" id="{$packagename}">
      <xsl:call-template name="create-info"/>
      <title>
        <xsl:apply-templates select="(*/title|title)[1]"/>
      </title>
      <p>The complete set of <link href="help:{$packagename}">
        <xsl:choose>
          <xsl:when test="*/productname">
            <xsl:value-of select="normalize-space(*/productname)"/>
            <xsl:text> documents</xsl:text>
          </xsl:when>
          <xsl:otherwise>
            <xsl:value-of select="/*/title"/>
          </xsl:otherwise>
        </xsl:choose>
         </link>
        consists of the following books and guides:
      </p>
      <xsl:apply-templates select="book[not(article)]|book[article]/article"
        mode="summary"/>
    </page>
  </xsl:template>

  <xsl:template match="/book">
    <page type="guide" id="{$packagename}">
      <xsl:call-template name="create-info">
        <xsl:with-param name="subnodes"
          select="article|chapter|preface|appendix|glossary"/>
      </xsl:call-template>
      <title>
        <xsl:apply-templates select="(bookinfo/title|title)[1]"/>
      </title>
      <p>
       <link href="help:{$packagename}">The complete book of
         <xsl:value-of select="normalize-space(*/productname)"/> documents</link>
        consists of the following chapters:
      </p>
      <xsl:apply-templates mode="summary"/>
    </page>
  </xsl:template>

  <xsl:template match="book">
    <xsl:param name="node" select="."/>
    <link href="help:{$packagename}/{@id}">
      <xsl:apply-templates select="(*/title|title)[1]"/>
    </link>
    <xsl:if test="following-sibling::book">
      <xsl:text>, </xsl:text>
    </xsl:if>
    <xsl:text>&#10;</xsl:text>
  </xsl:template>

  <xsl:template match="book[article]">
    <xsl:apply-templates select="book/article"/>
  </xsl:template>

  <xsl:template match="book/article[not(@id)]">
    <xsl:call-template name="warning"/>
  </xsl:template>

  <xsl:template match="book/article">
    <xsl:param name="node" select="."/>
    <link href="help:{$packagename}/{@id}">
      <xsl:apply-templates select="(*/title|title)[1]"/>
    </link>
    <xsl:text>&#10;</xsl:text>
  </xsl:template>

  <!-- ***************** -->
  <xsl:template match="*" mode="summary"/>

  <xsl:template match="book[not(article)][@id]" mode="summary">
    <xsl:param name="node" select="."/>

    <section id="{@id}">
      <title>
        <link href="help:{$packagename}/{@id}">
          <xsl:apply-templates select="(*/title|title)[1]"/>
        </link>
      </title>
      <xsl:if test="*/abstract">
        <xsl:apply-templates select="*/abstract"/>
      </xsl:if>
    </section>
  </xsl:template>

  <xsl:template match="book[not(article)][not(@id)]" mode="summary">
    <xsl:call-template name="warning"/>
  </xsl:template>

  <xsl:template match="book[article[@id]]" mode="summary">
    <xsl:message>Process article...</xsl:message>
    <xsl:apply-templates select="article"/>
  </xsl:template>

  <xsl:template match="book/article[not(@id)]" mode="summary">
    <xsl:call-template name="warning"/>
  </xsl:template>

  <xsl:template match="book/article[@id]" mode="summary">
    <xsl:param name="node" select="."/>
    <section id="{@id}">
      <title>
        <link href="help:{$packagename}/{@id}">
          <xsl:apply-templates select="(*/title|title)[1]"/>
        </link>
      </title>
      <xsl:if test="*/abstract">
        <xsl:apply-templates select="*/abstract"/>
      </xsl:if>
    </section>
  </xsl:template>

  <!-- ***************** -->
  <xsl:template match="abstract/para">
    <p>
      <xsl:apply-templates/>
    </p>
  </xsl:template>

  <xsl:template match="abstract/para/emphasis">
    <em>
      <xsl:apply-templates/>
    </em>
  </xsl:template>

  <xsl:template match="para/quote">
    <xsl:text>"</xsl:text>
    <xsl:apply-templates/>
    <xsl:text>"</xsl:text>
  </xsl:template>

  <xsl:template match="para/systemitem">
    <xsl:apply-templates/>
  </xsl:template>

  <xsl:template match="para/phrase">
    <!-- Generally, we want phrases to be unhyphenated, but there does
         not seem to be a [style hint](https://wiki.gnome.org/Apps/Yelp/Mallard/Styles)
         for that yet and Yelp does not seem to hyphenate ever, so ...
         lets just add a span. -->
    <span>
      <xsl:apply-templates/>
    </span>
  </xsl:template>

  <xsl:template match="abstract/*|para/*">
    <xsl:message>Unknown element <xsl:value-of
      select="local-name()"/> in <xsl:value-of select="local-name(..)"/>
    </xsl:message>
    <xsl:apply-templates/>
  </xsl:template>

</xsl:stylesheet>
