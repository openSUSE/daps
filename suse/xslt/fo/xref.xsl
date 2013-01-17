<?xml version="1.0" encoding="UTF-8"?>
<!-- $Id: xref.xsl 38284 2009-01-08 08:29:58Z toms $ -->
<!DOCTYPE xsl:stylesheet>

<xsl:stylesheet version="1.0"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:fo="http://www.w3.org/1999/XSL/Format"
    xmlns:xlink='http://www.w3.org/1999/xlink'
    xmlns:svg="http://www.w3.org/2000/svg">


<xsl:key name="chapters" match="chapter" use="@lang"/>


<xsl:template match="*/@id">
  <xsl:message>ID: "<xsl:value-of select="."/>"</xsl:message>
  <xsl:value-of select="."/>
</xsl:template>

<xsl:template match="xref" name="xref">
  <xsl:variable name="targets" select="key('id',@linkend)"/>
  <xsl:variable name="target" select="$targets[1]"/>
  <xsl:variable name="refelem" select="local-name($target)"/>
  <xsl:variable name="target.book" select="($target/ancestor-or-self::article|$target/ancestor-or-self::book)[1]"/>
  <xsl:variable name="this.book" select="(ancestor-or-self::article|ancestor-or-self::book)[1]"/>
  <xsl:variable name="lang" select="ancestor-or-self::*/@lang"/>

  <!--<xsl:if test="$this.book/@id != $target.book/@id">-->
 <!--<xsl:message>-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
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
    <xsl:when test="(generate-id($target.book) = generate-id($this.book)) or
                     not(/set) or /article">
      <!-- An xref that stays inside the current book; use the defaults -->
       <!--<xsl:apply-imports/>-->
       <xsl:call-template name="xref.old"/>
    </xsl:when>
    <xsl:otherwise>
      <xsl:choose>
        <xsl:when test="/set/@id=$rootid or
                        /article/@id=$rootid">
           <!--<xsl:apply-imports/>--><!-- If we use the whole set, do the usual stuff -->
           <xsl:call-template name="xref.old"/>
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
    </xsl:otherwise>
  </xsl:choose>
</xsl:template>


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
  
  <xsl:if test="$lang != 'ko'"> 
    <xsl:apply-templates select="$target" mode="xref-to">
      <xsl:with-param name="referrer" select="."/>
      <xsl:with-param name="xrefstyle">
        <xsl:choose>
          <xsl:when test="$refelem = 'chapter' or
            $refelem = 'appendix'">number</xsl:when>
          <xsl:otherwise>nonumber</xsl:otherwise>
        </xsl:choose>
      </xsl:with-param>
    </xsl:apply-templates>
  </xsl:if>
  
  <xsl:text> (</xsl:text>
  <xsl:if test="$target/self::sect1 or
    $target/self::sect2 or
    $target/self::sect3 or
    $target/self::sect4">
    <xsl:variable name="hierarchy.node" 
      select="(
      $target/ancestor-or-self::chapter |
      $target/ancestor-or-self::appendix |
      $target/ancestor-or-self::preface)[1]"/>
    <xsl:if test="$hierarchy.node">
      <xsl:apply-templates select="$hierarchy.node"
      mode="xref-to">
      <xsl:with-param name="referrer" select="."/>
      <!--<xsl:with-param name="xrefstyle">select: labelnumber title</xsl:with-param>-->
      </xsl:apply-templates>
      <xsl:text>, </xsl:text>
    </xsl:if>
  </xsl:if>
  <xsl:text>&#x2191;</xsl:text>
  
  <xsl:choose>
    <xsl:when test="$target.article">
      <xsl:apply-templates
        select="$target.article/title|$target.article/articleinfo/title" mode="xref-to"/>
    </xsl:when>
    <xsl:otherwise>
      <xsl:apply-templates 
        select="$target.book" mode="xref-to"/>
    </xsl:otherwise>
  </xsl:choose>
  <xsl:text>)</xsl:text>
  
  <xsl:if test="$lang = 'ko'"> 
    <xsl:apply-templates select="$target" mode="xref-to">
      <xsl:with-param name="referrer" select="."/>
      <xsl:with-param name="xrefstyle">
        <xsl:choose>
          <xsl:when test="$refelem = 'chapter' or
            $refelem = 'appendix'">number</xsl:when>
          <xsl:otherwise>nonumber</xsl:otherwise>
        </xsl:choose>
      </xsl:with-param>
    </xsl:apply-templates>
  </xsl:if>
</xsl:template>


<!-- ================================================= -->
<xsl:template name="xref.old">
  <xsl:param name="xhref" select="@xlink:href"/>
  <!-- is the @xlink:href a local idref link? -->
  <xsl:param name="xlink.idref">
    <xsl:if test="starts-with($xhref,'#')
                  and (not(contains($xhref,'&#40;'))
                  or starts-with($xhref, '#xpointer&#40;id&#40;'))">
      <xsl:call-template name="xpointer.idref">
        <xsl:with-param name="xpointer" select="$xhref"/>
      </xsl:call-template>
   </xsl:if>
  </xsl:param>
  <xsl:param name="xlink.targets" select="key('id',$xlink.idref)"/>
  <xsl:param name="linkend.targets" select="key('id',@linkend)"/>
  <xsl:param name="target" select="($xlink.targets | $linkend.targets)[1]"/>
  <xsl:param name="refelem" select="local-name($target)"/>
  <xsl:variable name="lang" select="ancestor-or-self::*/@lang"/>
 
  <xsl:variable name="xrefstyle">
    <xsl:choose>
      <xsl:when test="@role and not(@xrefstyle) 
                      and $use.role.as.xrefstyle != 0">
        <xsl:value-of select="@role"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:value-of select="@xrefstyle"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:variable>

  <xsl:variable name="content">
    <fo:inline xsl:use-attribute-sets="xref.properties">
      <xsl:choose>
        <xsl:when test="@endterm">
          <xsl:variable name="etargets" select="key('id',@endterm)"/>
          <xsl:variable name="etarget" select="$etargets[1]"/>
          <xsl:choose>
            <xsl:when test="count($etarget) = 0">
              <xsl:message>
                <xsl:value-of select="count($etargets)"/>
                <xsl:text>Endterm points to nonexistent ID: </xsl:text>
                <xsl:value-of select="@endterm"/>
              </xsl:message>
              <xsl:text>???</xsl:text>
            </xsl:when>
            <xsl:otherwise>
              <xsl:apply-templates select="$etarget" mode="endterm"/>
            </xsl:otherwise>
          </xsl:choose>
        </xsl:when>

        <xsl:when test="$target/@xreflabel">
          <xsl:call-template name="xref.xreflabel">
            <xsl:with-param name="target" select="$target"/>
          </xsl:call-template>
        </xsl:when>

        <xsl:when test="$target">
          <xsl:if test="not(parent::citation)">
            <xsl:apply-templates select="$target" mode="xref-to-prefix"/>
          </xsl:if>

          <xsl:apply-templates select="$target" mode="xref-to">
            <xsl:with-param name="referrer" select="."/>
            <xsl:with-param name="xrefstyle" select="$xrefstyle"/>
          </xsl:apply-templates>

          <xsl:if test="not(parent::citation)">
            <xsl:apply-templates select="$target" mode="xref-to-suffix"/>
          </xsl:if>
        </xsl:when>
        <xsl:otherwise>
          <xsl:message>
            <xsl:text>ERROR: xref linking to </xsl:text>
            <xsl:value-of select="@linkend|@xlink:href"/>
            <xsl:text> has no generated link text.</xsl:text>
          </xsl:message>
          <xsl:text>???</xsl:text>
        </xsl:otherwise>
      </xsl:choose>
    </fo:inline>
  </xsl:variable>

 <xsl:variable name="std.page.ref">
  <!-- Add standard page reference? -->
  <xsl:choose>
   <xsl:when test="not($target)">
    <!-- page numbers only for local targets -->
   </xsl:when>
   <xsl:when
    test="starts-with(normalize-space($xrefstyle), 'select:') 
    and contains($xrefstyle, 'nopage')">
    <!-- negative xrefstyle in instance turns it off -->
   </xsl:when>
   <!-- positive xrefstyle already handles it -->
   <xsl:when
    test="not(starts-with(normalize-space($xrefstyle), 'select:') 
    and (contains($xrefstyle, 'page')
    or contains($xrefstyle, 'Page')))
    and ( $insert.xref.page.number = 'yes' 
    or $insert.xref.page.number = '1')
    or (local-name($target) = 'para' and
    $xrefstyle = '')">
    <xsl:apply-templates select="$target" mode="page.citation">
     <xsl:with-param name="id" select="$target/@id|$target/@xml:id"/>
    </xsl:apply-templates>
   </xsl:when>
  </xsl:choose>
 </xsl:variable>
 

  <xsl:if test="$lang = 'ko'">
   <xsl:copy-of select="$std.page.ref"/>
  </xsl:if>

  <!-- Convert it into an active link -->
  <xsl:call-template name="simple.xlink">
    <xsl:with-param name="content" select="$content"/>
  </xsl:call-template>

  <xsl:if test="$lang != 'ko'">
   <xsl:copy-of select="$std.page.ref"/>
  </xsl:if>

</xsl:template>


<!--  -->
<!--<xsl:template match="*" mode="page.citation">
  <xsl:param name="id" select="'???'"/>

  <fo:inline>
    <xsl:call-template name="substitute-markup">
      <xsl:with-param name="template">
        <xsl:call-template name="gentext.template">
          <xsl:with-param name="name" select="'page.citation'"/>
          <xsl:with-param name="context" select="'xref'"/>
        </xsl:call-template>
      </xsl:with-param>
    </xsl:call-template>
  </fo:inline>
</xsl:template>-->

 <xsl:template match="varlistentry/term" mode="xref-to">
  <xsl:param name="referrer"/>
  <xsl:param name="xrefstyle"/> 
  <xsl:param name="verbose" select="1"/>

  <!-- to avoid the comma that will be generated if there are several terms -->
  <xsl:choose>
    <xsl:when test="quote">
      <xsl:apply-templates/>
    </xsl:when>
    <xsl:otherwise>
      <xsl:call-template name="gentext.startquote"/>
      <xsl:apply-templates/>
      <xsl:call-template name="gentext.endquote"/>
    </xsl:otherwise>
  </xsl:choose>
   
</xsl:template>

 <xsl:template match="question" mode="xref-to">
   <xsl:param name="referrer"/>
   <xsl:param name="xrefstyle"/>
   <xsl:param name="verbose" select="1"/>
   
   <xsl:call-template name="gentext">
     <xsl:with-param name="key">Question</xsl:with-param>
   </xsl:call-template>
   <xsl:text> </xsl:text>
   <fo:inline font-style="italic">
     <xsl:apply-templates select="para[1]" mode="question"/>
   </fo:inline>
 </xsl:template>
  
  <xsl:template match="question/para[1]" mode="question">
    <!-- We don't want a block here, that's why we just process the next
         child inside a para
    -->
    <xsl:apply-templates mode="question"/>
  </xsl:template>
  
  <xsl:template match="*" mode="qanda">
    <!-- Fallback to default mode -->
    <xsl:apply-templates select="."/>
  </xsl:template>
</xsl:stylesheet>