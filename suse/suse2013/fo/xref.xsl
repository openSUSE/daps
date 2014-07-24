<?xml version="1.0" encoding="UTF-8"?>
<!--
  Purpose:
    Add an arrow after outward links to highlight them.

  Author(s):  Stefan Knorr <sknorr@suse.de>
              Thomas Schraitle <toms@opensuse.org>

  Copyright:  2013, Stefan Knorr, Thomas Schraitle

-->
<!DOCTYPE xsl:stylesheet
[
  <!ENTITY % fonts SYSTEM "fonts.ent">
  <!ENTITY % colors SYSTEM "colors.ent">
  <!ENTITY % metrics SYSTEM "metrics.ent">
  %fonts;
  %colors;
  %metrics;
]>
<xsl:stylesheet  version="1.0"
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:xlink='http://www.w3.org/1999/xlink'
  xmlns:fo="http://www.w3.org/1999/XSL/Format"
  exclude-result-prefixes="xlink">


<xsl:template name="hyperlink.url.display">
  <!-- * This template is called for all external hyperlinks (ulinks and -->
  <!-- * for all simple xlinks); it determines whether the URL for the -->
  <!-- * hyperlink is displayed, and how to display it. -->
  <xsl:param name="url"/>
  <xsl:param name="ulink.url">
    <!-- * ulink.url is just the value of the URL wrapped in 'url(...)' -->
    <xsl:call-template name="fo-external-image">
      <xsl:with-param name="filename" select="$url"/>
    </xsl:call-template>
  </xsl:param>

  <fo:basic-link external-destination="{$ulink.url}" xsl:use-attribute-sets="dark-green">
    <xsl:if test="count(child::node()) != 0
                and string(.) != $url
                and $ulink.show != 0">
    <!-- * Display the URL for this hyperlink only if it is non-empty, -->
    <!-- * and the value of its content is not a URL that is the same as -->
    <!-- * URL it links to, and if ulink.show is non-zero. -->
        <fo:inline hyphenate="false">
          <xsl:text> (</xsl:text>
          <fo:inline>
              <xsl:call-template name="hyphenate-url">
                <xsl:with-param name="url" select="$url"/>
              </xsl:call-template>
          </fo:inline>
          <xsl:text>)</xsl:text>
        </fo:inline>
    </xsl:if>

    <xsl:call-template name="image-after-link"/>
  </fo:basic-link>
</xsl:template>


<xsl:template name="image-after-link">
  <xsl:variable name="fill" select="$dark-green"/>

  <fo:leader leader-pattern="space" leader-length="0.2em"/>
  <fo:instream-foreign-object content-height="0.65em">
    <svg:svg xmlns:svg="http://www.w3.org/2000/svg" width="100"
      height="100">
      <svg:rect width="54" height="54" x="0" y="46" fill-opacity="0.4"
        fill="{$fill}"/>

      <svg:path d="M 27,0 27,16 72.7,16 17,71.75 28.25,83 84,27.3 84,73 l 16,0 0,-73 z"
        fill="{$fill}"/>
    </svg:svg>
  </fo:instream-foreign-object>
  <fo:leader leader-pattern="space" leader-length="0.2em"/>
</xsl:template>

<xsl:template match="chapter|appendix" mode="insert.title.markup">
  <xsl:param name="purpose"/>
  <xsl:param name="xrefstyle"/>
  <xsl:param name="title"/>

  <xsl:choose>
    <xsl:when test="$purpose = 'xref'">
      <fo:inline xsl:use-attribute-sets="italicized">
        <xsl:copy-of select="$title"/>
      </fo:inline>
    </xsl:when>
    <xsl:otherwise>
      <xsl:copy-of select="$title"/>
    </xsl:otherwise>
  </xsl:choose>
</xsl:template>

<xsl:template match="*" mode="insert.olink.docname.markup">
  <xsl:param name="docname" select="''"/>

  <fo:inline xsl:use-attribute-sets="italicized">
    <xsl:value-of select="$docname"/>
  </fo:inline>
</xsl:template>

<xsl:template name="title.xref">
  <xsl:param name="target" select="."/>
  <xsl:choose>
    <xsl:when test="local-name($target) = 'figure'
                    or local-name($target) = 'example'
                    or local-name($target) = 'equation'
                    or local-name($target) = 'table'
                    or local-name($target) = 'dedication'
                    or local-name($target) = 'acknowledgements'
                    or local-name($target) = 'preface'
                    or local-name($target) = 'bibliography'
                    or local-name($target) = 'glossary'
                    or local-name($target) = 'index'
                    or local-name($target) = 'setindex'
                    or local-name($target) = 'colophon'">
      <xsl:call-template name="gentext.startquote"/>
      <xsl:apply-templates select="$target" mode="title.markup"/>
      <xsl:call-template name="gentext.endquote"/>
    </xsl:when>
    <xsl:otherwise>
      <fo:inline xsl:use-attribute-sets="italicized">
        <xsl:apply-templates select="$target" mode="title.markup"/>
      </fo:inline>
    </xsl:otherwise>
  </xsl:choose>
</xsl:template>


<!-- ================ -->

<!-- FIXME: We have (almost) the same template in xhtml/xref.xsl. This is
     (almost) needless duplication. -->
<xsl:template name="create.linkto.other.book">
  <xsl:param name="target"/>
  <xsl:variable name="refelem" select="local-name($target)"/>
  <xsl:variable name="target.article"
    select="$target/ancestor-or-self::article"/>
  <xsl:variable name="target.book"
    select="$target/ancestor-or-self::book"/>

  <xsl:variable name="lang" select="ancestor-or-self::*/@lang"/>

  <!--<xsl:message>create.linkto.other.book:
    linkend: <xsl:value-of select="@linkend"/>
    refelem: <xsl:value-of select="$refelem"/>
    target:  <xsl:value-of select="concat(count($target), ':',
      name($target))"/>
    target/@id:  <xsl:value-of select="$target/@id"/>
    target.article: <xsl:value-of select="count($target.article)"/>
    target.book: <xsl:value-of select="count($target.book)"/>
  </xsl:message>-->

  <xsl:if test="not($target/self::book or $target/self::article)">
    <xsl:apply-templates select="$target" mode="xref-to">
      <xsl:with-param name="referrer" select="."/>
      <xsl:with-param name="xrefstyle">
        <xsl:choose>
          <xsl:when test="$refelem = 'chapter' or $refelem = 'appendix'">number</xsl:when>
          <xsl:otherwise>nonumber</xsl:otherwise>
        </xsl:choose>
      </xsl:with-param>
    </xsl:apply-templates>
    <xsl:text>, </xsl:text>
  </xsl:if>

  <xsl:if test="$target/self::sect1 or
    $target/self::sect2 or
    $target/self::sect3 or
    $target/self::sect4 or
    $target/self::sect5 or
    $target/self::section">
    <xsl:variable name="hierarchy.node"
      select="(
      $target/ancestor-or-self::chapter |
      $target/ancestor-or-self::appendix |
      $target/ancestor-or-self::preface)[1]"/>
    <xsl:if test="$hierarchy.node">
      <xsl:apply-templates select="$hierarchy.node"
      mode="xref-to">
      <xsl:with-param name="referrer" select="."/>
      </xsl:apply-templates>
      <xsl:text>, </xsl:text>
    </xsl:if>
  </xsl:if>

  <fo:inline xsl:use-attribute-sets="italicized">
  <xsl:choose>
    <xsl:when test="$target.article">
      <xsl:apply-templates select="$target.article/title|$target.article/articleinfo/title" mode="xref-to"/>
    </xsl:when>
    <xsl:otherwise>
      <xsl:apply-templates select="$target.book" mode="xref-to"/>
    </xsl:otherwise>
  </xsl:choose>
  </fo:inline>
</xsl:template>

<xsl:template match="xref" name="xref">
  <xsl:variable name="targets" select="key('id',@linkend)"/>
  <xsl:variable name="target" select="$targets[1]"/>
  <xsl:variable name="refelem" select="local-name($target)"/>
  <xsl:variable name="target.book" select="($target/ancestor-or-self::article|$target/ancestor-or-self::book)[1]"/>
  <xsl:variable name="this.book" select="(ancestor-or-self::article|ancestor-or-self::book)[1]"/>
  <xsl:variable name="lang" select="ancestor-or-self::*/@lang"/>
  <xsl:variable name="xref.in.samebook">
    <xsl:call-template name="is.xref.in.samebook">
      <xsl:with-param name="target" select="$target"/>
    </xsl:call-template>
  </xsl:variable>

  <!--<xsl:if test="$this.book/@id != $target.book/@id">-->
  <!--<xsl:message>-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
 xref.in.samebook: <xsl:value-of select="$xref.in.samebook"/>
 linkend:        <xsl:value-of select="@linkend"/>
 count(targets): <xsl:value-of select="count($targets)"/>
 target:         <xsl:value-of select="name($target)"/>
 <!-\-refelem:        <xsl:value-of select="$refelem"/>-\->
 article         <xsl:value-of select="count($target/ancestor-or-self::article)"/>
 article-title   <xsl:value-of
   select="$target/ancestor-or-self::article/title"/>
 $this.book/@id: <xsl:value-of select="$this.book/@id"/>
 $target.book/@id: <xsl:value-of select="$target.book/@id"/>
 $target/xml:base  <xsl:value-of select="$target/ancestor-or-self::*[1]/@xml:base"/>
 $target.book/title          "<xsl:value-of select="$target.book/title"/>"
 $target.book/bookinfo/title "<xsl:value-of select="$target.book/bookinfo/title"/>"
</xsl:message>-->
 <!--</xsl:if>-->

  <xsl:call-template name="check.id.unique">
    <xsl:with-param name="linkend" select="@linkend"/>
  </xsl:call-template>


  <!-- We add this fo:inline, so xrefs are always displayed in sans...
       This is a workaround for inline mono styles expecting titles to be
       in the sans font, thus being able to use xheight scaling adapted
       to work inside sans text. Welp. -->
  <fo:inline xsl:use-attribute-sets="title.font">
    <xsl:choose>
      <!-- Someone might be crazy enough to put an xref inside a verbatim
           element. -->
      <xsl:then test="ancestor::screen or ancestor::computeroutput or
                  ancestor::userinput or ancestor::programlisting or
                  ancestor::synopsis">
        <xsl:attribute name="font-size"><xsl:value-of select="$sans-xheight-adjust div $mono-xheight-adjust"/>em</xsl:attribute>
      </xsl:then>
      <!-- term and most titles are already sans'd, thus there is no need to
           adapt font size further. -->
      <xsl:then test="not(ancestor::title[not(parent::formalpara)] or
                      ancestor::term)">
        <xsl:attribute name="font-size"><xsl:value-of select="$sans-xheight-adjust"/>em</xsl:attribute>
      </xsl:then>
      <xsl:otherwise/>
    </xsl:choose>

    <xsl:choose>
      <xsl:when test="$xref.in.samebook != 0 or
                      /set/@id=$rootid or
                      /article/@id=$rootid">
         <!-- An xref that stays inside the current book or when $rootid
           pointing to the root element, then use the defaults -->
         <xsl:apply-imports/>
      </xsl:when>
      <xsl:otherwise>
            <!-- A reference into another book -->
            <xsl:variable name="target.chapandapp"
                          select="$target/ancestor-or-self::chapter[@lang!='']
                                  | $target/ancestor-or-self::appendix[@lang!='']"/>

            <xsl:if test="$warn.xrefs.into.diff.lang != 0 and
                          $target.chapandapp/@lang != $this.book/@lang">
              <xsl:message>WARNING: The xref '<xsl:value-of
              select="@linkend"/>' points to a chapter (id='<xsl:value-of
                select="$target.chapandapp/@id"/>') with a different language than the main book.</xsl:message>
            </xsl:if>

            <xsl:call-template name="create.linkto.other.book">
              <xsl:with-param name="target" select="$target"/>
            </xsl:call-template>
      </xsl:otherwise>
    </xsl:choose>
  </fo:inline>
</xsl:template>

</xsl:stylesheet>
