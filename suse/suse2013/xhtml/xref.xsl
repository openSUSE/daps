<?xml version="1.0"?>
<!--
  Purpose:
     Make the anchor template dysfunctional.

   See Also:
     * http://docbook.sourceforge.net/release/xsl/current/doc/html/index.html

   Author(s): Stefan Knorr <sknorr@suse.de>
   Copyright: 2012, Stefan Knorr

-->

<xsl:stylesheet version="1.0"
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns="http://www.w3.org/1999/xhtml">


  <xsl:template name="anchor">
    <xsl:param name="node" select="."/>
    <xsl:param name="conditional" select="1"/>

    <xsl:if test="local-name($node) = 'figure'">
      <xsl:attribute name="id">
        <xsl:call-template name="object.id">
          <xsl:with-param name="object" select="$node"/>
        </xsl:call-template>
      </xsl:attribute>
    </xsl:if>
  </xsl:template>

  <xsl:template match="question" mode="xref-to">
    <xsl:param name="referrer"/>
    <xsl:param name="xrefstyle"/>
    <xsl:param name="verbose" select="1"/>
    <xsl:variable name="teaser">
      <xsl:apply-templates select="para[1]" mode="question"/>
    </xsl:variable>
    <xsl:variable name="teaser-length">
      <xsl:value-of select="string-length(normalize-space($teaser))"/>
    </xsl:variable>
    <xsl:variable name="interpunction">
      <xsl:if test="$teaser-length &gt; 100">
        <xsl:choose>
          <xsl:when test="substring-before(substring($teaser,99,$teaser-length),'?')
            != ''">..?</xsl:when>
          <xsl:otherwise>…</xsl:otherwise>
        </xsl:choose>
      </xsl:if>
    </xsl:variable>

    <em>
      <xsl:choose>
        <xsl:when test="$teaser-length &gt; 100">
            <xsl:value-of select="substring(normalize-space($teaser),1,100)"/>
            <xsl:value-of select="$interpunction"/>
        </xsl:when>
        <xsl:otherwise>
          <xsl:apply-templates select="para[1]" mode="question"/>
        </xsl:otherwise>
      </xsl:choose>
    </em>
  </xsl:template>

  <xsl:template match="question/para[1]" mode="question">
    <!-- We don't want a block here: we just process the next
         child inside a para
    -->
    <xsl:apply-templates mode="question"/>
  </xsl:template>

  <xsl:template match="*" mode="qanda">
    <!-- Fallback to default mode -->
    <xsl:apply-templates select="."/>
  </xsl:template>

  <xsl:template match="ulink" name="ulink">
    <xsl:param name="url" select="@url"/>

    <a>
      <xsl:apply-templates select="." mode="common.html.attributes"/>
      <xsl:if test="@id or @xml:id">
        <xsl:choose>
          <xsl:when test="$generate.id.attributes = 0">
            <xsl:attribute name="name">
              <xsl:value-of select="(@id|@xml:id)[1]"/>
            </xsl:attribute>
          </xsl:when>
          <xsl:otherwise>
            <xsl:attribute name="id">
              <xsl:value-of select="(@id|@xml:id)[1]"/>
            </xsl:attribute>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:if>
      <xsl:attribute name="href"><xsl:value-of select="$url"/></xsl:attribute>
      <xsl:if test="$ulink.target != ''">
        <xsl:attribute name="target">
          <xsl:value-of select="$ulink.target"/>
        </xsl:attribute>
      </xsl:if>
      <xsl:choose>
        <xsl:when test="count(child::node())=0">
          <xsl:value-of select="$url"/>
        </xsl:when>
        <xsl:otherwise>
          <xsl:apply-templates mode="no.anchor.mode"/>
          <span class="ulink-url"> (<xsl:value-of select="$url"/>)</span>
        </xsl:otherwise>
      </xsl:choose>
    </a>
  </xsl:template>

<!-- ================ -->

<!-- FIXME: We have (almost) the same template in fo/xref.xsl. This is
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
    <span>
      <xsl:if test="not($target/self::book or $target/self::article)">
        <xsl:apply-templates select="$target" mode="xref-to">
          <xsl:with-param name="referrer" select="."/>
          <xsl:with-param name="xrefstyle">
            <xsl:choose>
              <xsl:when test="$refelem = 'chapter' or
                              $refelem = 'appendix'"
                            >number</xsl:when>
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
          select="($target/ancestor-or-self::chapter |
                   $target/ancestor-or-self::appendix |
                   $target/ancestor-or-self::preface)[1]"/>
        <xsl:if test="$hierarchy.node">
          <xsl:apply-templates select="$hierarchy.node" mode="xref-to">
            <xsl:with-param name="referrer" select="."/>
            <!--<xsl:with-param name="xrefstyle">select: labelnumber title</xsl:with-param>-->
          </xsl:apply-templates>
          <xsl:text>, </xsl:text>
        </xsl:if>
      </xsl:if>

      <em>
        <xsl:choose>
          <xsl:when test="$target.article">
            <xsl:apply-templates
              select="$target.article/title|$target.article/articleinfo/title"
              mode="xref-to"/>
          </xsl:when>
          <xsl:otherwise>
            <xsl:apply-templates select="$target.book" mode="xref-to"/>
          </xsl:otherwise>
        </xsl:choose>
      </em>
    </span>
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
