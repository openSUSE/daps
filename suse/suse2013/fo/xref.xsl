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


<xsl:template match="ulink" name="ulink">
  <xsl:param name="url" select="@url"/>

  <xsl:variable name ="ulink.url">
    <xsl:call-template name="fo-external-image">
      <xsl:with-param name="filename" select="$url"/>
    </xsl:call-template>
  </xsl:variable>

  <xsl:variable name="hyphenated-url">
    <xsl:call-template name="hyphenate-url">
      <xsl:with-param name="url" select="$url"/>
    </xsl:call-template>
  </xsl:variable>

  <fo:basic-link xsl:use-attribute-sets="xref.properties"
                 external-destination="{$ulink.url}">
    <xsl:choose>
      <xsl:when test="count(child::node()) = 0 or
                      (string(.) = $url) or
                      (count(child::*) = 0 and
                       normalize-space(string(.)) = '')">
        <fo:inline hyphenate="false">
          <xsl:value-of select="$hyphenated-url"/>
        </fo:inline>
      </xsl:when>
      <xsl:otherwise>
        <xsl:apply-templates/>

        <xsl:if test="$ulink.show != 0">
        <!-- Display the URL for this hyperlink only if it is non-empty,
             and the value of its content is not a URL that is the same as
             URL it links to, and if ulink.show is non-zero. -->
          <fo:inline hyphenate="false">
            <xsl:text> (</xsl:text>
            <xsl:value-of select="$hyphenated-url"/>
            <xsl:text>)</xsl:text>
          </fo:inline>
        </xsl:if>
      </xsl:otherwise>
    </xsl:choose>
    <xsl:call-template name="image-after-link"/>
  </fo:basic-link>
</xsl:template>


<xsl:template name="image-after-link">
  <xsl:variable name="fill" select="$dark-green"/>

  <fo:leader leader-pattern="space" leader-length="0.2em"/>
  <fo:instream-foreign-object content-height="0.65em">
    <svg:svg xmlns:svg="http://www.w3.org/2000/svg" width="100"
      height="100">
      <svg:g>
        <xsl:if test="$writing.mode = 'rl'">
          <xsl:attribute name="transform">matrix(-1,0,0,1,100,0)</xsl:attribute>
        </xsl:if>
        <svg:rect width="54" height="54" x="0" y="46" fill-opacity="0.4"
          fill="{$fill}"/>
        <svg:path d="M 27,0 27,16 72.7,16 17,71.75 28.25,83 84,27.3 84,73 l 16,0 0,-73 z"
          fill="{$fill}"/>
      </svg:g>
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
      <fo:inline xsl:use-attribute-sets="italicized.noreplacement">
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

  <fo:inline xsl:use-attribute-sets="italicized.noreplacement">
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
      <fo:inline xsl:use-attribute-sets="italicized.noreplacement">
        <xsl:apply-templates select="$target" mode="title.markup"/>
      </fo:inline>
    </xsl:otherwise>
  </xsl:choose>
</xsl:template>


<!-- ================ -->
<xsl:template match="*" mode="intra.title.markup">
  <xsl:message>Unknown element <xsl:value-of select="local-name(.)"/> for intra xref linking</xsl:message>
</xsl:template>  


<xsl:template match="sect1" mode="intra.title.markup">
  <!--<xsl:message>sect1 intra.title.markup
  <xsl:call-template name="xpath.location"/>
  </xsl:message>-->
  <xsl:apply-templates select="parent::*" mode="intra.title.markup"/>
    <xsl:call-template name="substitute-markup">
      <xsl:with-param name="template">
        <xsl:call-template name="gentext.template">
          <xsl:with-param name="context" select="'xref'"/>
          <xsl:with-param name="name"  select="concat('intra-', local-name())"/>
        </xsl:call-template>
      </xsl:with-param>
    </xsl:call-template>  
</xsl:template>


<xsl:template match="sect2|sect3|sect4|sect5" mode="intra.title.markup">
  <!--<xsl:message><xsl:value-of select="local-name(.)"/> intra.title.markup
  <xsl:call-template name="xpath.location"/>
  </xsl:message>-->
  <xsl:apply-templates 
    select="ancestor::appendix|ancestor::article|
            ancestor::chapter|ancestor::glossary|ancestor::preface" 
    mode="intra.title.markup"/>
    <xsl:call-template name="substitute-markup">
      <xsl:with-param name="template">
        <xsl:call-template name="gentext.template">
          <xsl:with-param name="context" select="'xref'"/>
          <xsl:with-param name="name"  select="concat('intra-', local-name())"/>
        </xsl:call-template>
      </xsl:with-param>
    </xsl:call-template>  
</xsl:template>

  
<xsl:template match="appendix|chapter" mode="intra.title.markup">
  <!--<xsl:message><xsl:value-of select="local-name(.)"/> intra.title.markup
  <xsl:call-template name="xpath.location"/>
  </xsl:message>-->
  <!-- We don't want parts -->
  <xsl:apply-templates select="ancestor::book" mode="intra.title.markup"/>
    <xsl:call-template name="substitute-markup">
      <xsl:with-param name="template">
        <xsl:call-template name="gentext.template">
          <xsl:with-param name="context" select="'xref'"/>
          <xsl:with-param name="name"  select="concat('intra-', local-name())"/>
        </xsl:call-template>
      </xsl:with-param>
    </xsl:call-template>
</xsl:template>

<xsl:template match="part" mode="intra.title.markup">
  <!-- We don't want parts, so skip them -->
  <xsl:apply-templates select="parent::*" mode="intra.title.markup"/>
</xsl:template>

<xsl:template match="article|book" mode="intra.title.markup">
  <!--<xsl:message><xsl:value-of select="local-name(.)"/> intra.title.markup
  <xsl:call-template name="xpath.location"/>
  </xsl:message>-->
  <xsl:call-template name="substitute-markup">
      <xsl:with-param name="template">
        <xsl:call-template name="gentext.template">
          <xsl:with-param name="context" select="'xref'"/>
          <xsl:with-param name="name"  select="concat('intra-', local-name())"/>
        </xsl:call-template>
      </xsl:with-param>
    </xsl:call-template>
</xsl:template>


<!-- FIXME: We have (almost) the same template in xhtml/xref.xsl. This is
     (almost) needless duplication. -->
<xsl:template name="create.linkto.other.book">
  <xsl:param name="target"/>
  <xsl:variable name="refelem" select="local-name($target)"/>
  <xsl:variable name="target.article" select="$target/ancestor-or-self::article"/>
  <xsl:variable name="target.book" select="$target/ancestor-or-self::book"/>
  <xsl:variable name="lang" select="ancestor-or-self::*/@lang"/>
  <xsl:variable name="text">
    <xsl:apply-templates select="$target" mode="intra.title.markup"/>
  </xsl:variable>

  <!--<xsl:message>====== create.linkto.other.book:
    linkend=<xsl:value-of select="@linkend"/>
     target=<xsl:value-of select="local-name($target)"/>
    refelem=<xsl:value-of select="$refelem"/>
       text=<xsl:value-of select="$text"/>
  </xsl:message>-->
  
  <fo:inline xsl:use-attribute-sets="italicized">
    <xsl:copy-of select="$text"/>
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

  <xsl:call-template name="check.id.unique">
    <xsl:with-param name="linkend" select="@linkend"/>
  </xsl:call-template>

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
</xsl:template>

</xsl:stylesheet>
