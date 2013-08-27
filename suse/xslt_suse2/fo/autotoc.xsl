<?xml version='1.0'?>
<!--
  Purpose:
    Rework the structure of Tables of Contents in Parts.

  Author(s):  Thomas Schraitle <toms@opensuse.org>,
              Stefan Knorr <sknorr@suse.de>

  Copyright:  2013, Thomas Schraitle, Stefan Knorr

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
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:fo="http://www.w3.org/1999/XSL/Format"
                version='1.0'>

<xsl:template name="division.part.toc">
  <xsl:param name="toc-context" select="."/>

  <xsl:variable name="cid">
    <xsl:call-template name="object.id">
      <xsl:with-param name="object" select="$toc-context"/>
    </xsl:call-template>
  </xsl:variable>

  <xsl:variable name="nodes"
                select="$toc-context/part
                        |$toc-context/reference
                        |$toc-context/preface
                        |$toc-context/chapter
                        |$toc-context/appendix
                        |$toc-context/article
                        |$toc-context/topic
                        |$toc-context/bibliography
                        |$toc-context/glossary
                        |$toc-context/index"/>


  <xsl:apply-templates select="$nodes" mode="part.toc">
    <xsl:with-param name="toc-context" select="$toc-context"/>
  </xsl:apply-templates>
</xsl:template>

<xsl:template match="reference" mode="part.toc">
  <xsl:param name="toc-context" select="."/>

  <xsl:variable name="id">
    <xsl:call-template name="object.id"/>
  </xsl:variable>

  <xsl:variable name="cid">
    <xsl:call-template name="object.id">
      <xsl:with-param name="object" select="$toc-context"/>
    </xsl:call-template>
  </xsl:variable>

  <xsl:call-template name="toc.part.line">
    <xsl:with-param name="toc-context" select="$toc-context"/>
  </xsl:call-template>

</xsl:template>

<xsl:template match="preface|chapter|appendix|article" mode="part.toc">
  <xsl:param name="toc-context" select="."/>

  <xsl:variable name="id">
    <xsl:call-template name="object.id"/>
  </xsl:variable>

  <xsl:variable name="cid">
    <xsl:call-template name="object.id">
      <xsl:with-param name="object" select="$toc-context"/>
    </xsl:call-template>
  </xsl:variable>

  <xsl:call-template name="toc.part.line">
    <xsl:with-param name="toc-context" select="$toc-context"/>
  </xsl:call-template>
</xsl:template>


<xsl:template match="bibliography|glossary" mode="part.toc">
  <xsl:param name="toc-context" select="."/>

  <xsl:call-template name="toc.part.line">
    <xsl:with-param name="toc-context" select="$toc-context"/>
  </xsl:call-template>
</xsl:template>


<xsl:template match="index" mode="part.toc">
  <xsl:param name="toc-context" select="."/>

  <xsl:if test="* or $generate.index != 0">
    <xsl:call-template name="toc.part.line">
      <xsl:with-param name="toc-context" select="$toc-context"/>
    </xsl:call-template>
  </xsl:if>
</xsl:template>


<xsl:template name="toc.part.line">
  <xsl:param name="toc-context" select="NOTANODE"/>

  <xsl:variable name="line-height" select="concat($base-lineheight, 'em')"/>

  <xsl:variable name="id">
    <xsl:call-template name="object.id"/>
  </xsl:variable>

  <xsl:variable name="label">
    <xsl:apply-templates select="." mode="label.markup"/>
  </xsl:variable>

  <fo:list-item>
    <fo:list-item-label end-indent="label-end()">
      <fo:block text-align="end" width="&column;mm" font-family="{$title.fontset}"
        font-size="&large;pt" line-height="{$line-height}">
        <fo:basic-link internal-destination="{$id}">
          <xsl:if test="$label != ''">
            <xsl:copy-of select="$label"/>
          </xsl:if>
        </fo:basic-link>
      </fo:block>
    </fo:list-item-label>
    <fo:list-item-body start-indent="body-start()">
      <fo:block line-height="{$line-height}" padding-after="{&gutter; div 2}mm">
        <fo:basic-link internal-destination="{$id}">
          <fo:inline keep-with-next.within-line="always"
            font-family="{$title.fontset}" font-size="&large;pt">
            <xsl:apply-templates select="." mode="titleabbrev.markup"/>
          </fo:inline>
          <fo:leader leader-pattern="space" leader-length="&gutterfragment;mm"
            keep-with-next.within-line="always"/>
          <fo:inline keep-together.within-line="always" font-size="&large;pt"
            xsl:use-attribute-sets="toc.pagenumber.properties">
            <fo:page-number-citation ref-id="{$id}"/>
          </fo:inline>
        </fo:basic-link>
      </fo:block>
    </fo:list-item-body>
  </fo:list-item>
</xsl:template>


<!-- =================================================================== -->
<xsl:param name="page.debug" select="0"/>

<xsl:template name="toc.label">
    <xsl:param name="node" select="."/>

    <fo:block text-align="start">
        <xsl:if test="$page.debug != 0">
          <xsl:attribute name="border">0.25pt solid green</xsl:attribute>
        </xsl:if>
        <xsl:apply-templates select="$node" mode="label.markup"/>
      </fo:block>
</xsl:template>

<xsl:template name="toc.title">
    <xsl:param name="node" select="."/>
    <xsl:param name="wrapper.name">fo:block</xsl:param>
    <xsl:variable name="id">
      <xsl:call-template name="object.id"/>
    </xsl:variable>
  
    <xsl:element name="{$wrapper.name}">
      <xsl:if test="$page.debug != 0">
        <xsl:attribute name="border">0.25pt solid blue</xsl:attribute>
      </xsl:if>
      <fo:basic-link internal-destination="{$id}">
        <fo:inline hyphenate="false">
          <xsl:apply-templates select="$node" mode="titleabbrev.markup"/>
        </fo:inline>
        <fo:leader leader-pattern="space" leader-length="&gutterfragment;mm"
          keep-with-next.within-line="always"/>
        <fo:inline xsl:use-attribute-sets="toc.pagenumber.properties">
          <fo:page-number-citation ref-id="{$id}"/>
        </fo:inline>
      </fo:basic-link>
    </xsl:element>
</xsl:template>

<xsl:template name="toc.line">
    <xsl:param name="toc-context" select="NOTANODE"/>
    <xsl:apply-templates select="." mode="susetoc"/>
</xsl:template>

<xsl:template match="*" mode="susetoc">
    <xsl:call-template name="log.message">
      <xsl:with-param name="level">WARNING</xsl:with-param>
      <!--<xsl:with-param name="source">select.user.pagemaster</xsl:with-param>-->
      <xsl:with-param name="context-desc">toc</xsl:with-param>
      <xsl:with-param name="context-desc-field-length" select="4"/>
      <!--<xsl:with-param name="message-field-length" select="50"/>-->
      <xsl:with-param name="message">
        <xsl:text>Unknown TOC element </xsl:text>
        <xsl:value-of select="local-name()"/>
      </xsl:with-param>
    </xsl:call-template>
</xsl:template>

<xsl:template match="part" mode="susetoc">
    <xsl:variable name="id">
      <xsl:call-template name="object.id"/>
    </xsl:variable>

    <xsl:variable name="label">
      <xsl:call-template name="toc.label"/>
    </xsl:variable>
    
    <xsl:variable name="title">
      <xsl:call-template name="toc.title"/>
    </xsl:variable>
    
    
    <fo:list-block xsl:use-attribute-sets="toc.level1.properties" relative-align="baseline"
       space-before="&columnfragment;mm"
       space-after="&gutterfragment;mm"
       keep-with-next.within-column="always"
       provisional-distance-between-starts="{&column; + &gutter;}mm"
       provisional-label-separation="{&gutter;}mm">
        <fo:list-item>
          <fo:list-item-label end-indent="label-end()">
            <fo:block  text-align-last="end">
              <fo:basic-link internal-destination="{$id}">
                <xsl:value-of select="$label"/>
              </fo:basic-link>
            </fo:block>
          </fo:list-item-label>
          <fo:list-item-body start-indent="body-start()"
            hyphenate="false">
            <xsl:copy-of select="$title"/>
          </fo:list-item-body>
        </fo:list-item>
      </fo:list-block>
</xsl:template> 

<xsl:template match="preface|glossary|index" mode="susetoc">
    <xsl:variable name="id">
      <xsl:call-template name="object.id"/>
    </xsl:variable>
    <xsl:variable name="title">
      <xsl:call-template name="toc.title"/>
    </xsl:variable>
    
    <fo:block start-indent="{&column; + &gutter;}mm"
      space-before="&columnfragment;mm"
      xsl:use-attribute-sets="toc.level2.properties dark-green">
      <xsl:if test="not(following-sibling::part)">
        <xsl:attribute name="space-after">0.75em</xsl:attribute>
      </xsl:if>
        <xsl:copy-of select="$title"/>
    </fo:block>
</xsl:template>

<xsl:template match="chapter|appendix" mode="susetoc">
    <xsl:variable name="id">
      <xsl:call-template name="object.id"/>
    </xsl:variable>
    <xsl:variable name="label">
      <xsl:call-template name="toc.label"/>
    </xsl:variable>
    <xsl:variable name="title">
      <xsl:call-template name="toc.title"/>
    </xsl:variable>

    <fo:list-block role="TOC.{local-name()}" relative-align="baseline"
       font-size="&xx-large;pt"
       keep-with-next.within-column="always"
       xsl:use-attribute-sets="toc.level2.properties dark-green sans.bold.noreplacement"
       provisional-distance-between-starts="{&column; + &gutter;}mm"
       provisional-label-separation="{&gutter;}mm">
      <xsl:if test="preceding-sibling::chapter or
                    preceding-sibling::appendix">
        <xsl:attribute name="space-before">2* &gutterfragment;mm</xsl:attribute>
        <xsl:attribute name="space-after">&gutterfragment;mm</xsl:attribute>
      </xsl:if>
      <fo:list-item>
        <fo:list-item-label end-indent="label-end()" xsl:use-attribute-sets="dark-green">
          <fo:block text-align="right">
            <fo:basic-link internal-destination="{$id}">
              <xsl:value-of select="$label"/>
            </fo:basic-link>
          </fo:block>
        </fo:list-item-label>
        <fo:list-item-body start-indent="body-start()">
          <fo:block>
            <xsl:copy-of select="$title"/>
          </fo:block>
        </fo:list-item-body>
      </fo:list-item>
    </fo:list-block>
</xsl:template>

<xsl:template match="preface/sect1" mode="susetoc">
<!--
  <xsl:variable name="id">
      <xsl:call-template name="object.id"/>
  </xsl:variable>
  
  <fo:block xsl:use-attribute-sets="toc.level3.properties"
     margin-left="{&column; + &gutter;}mm"
     role="TOC.{local-name()}" >
    <fo:basic-link internal-destination="{$id}">
      <xsl:call-template name="toc.title"/>
    </fo:basic-link>
  </fo:block>
  -->
</xsl:template>

<xsl:template match="sect1|refentry" mode="susetoc">
    <xsl:variable name="id">
      <xsl:call-template name="object.id"/>
    </xsl:variable>
    <xsl:variable name="label">
      <xsl:call-template name="toc.label"/>
    </xsl:variable>
    <xsl:variable name="title">
      <xsl:call-template name="toc.title"/>
    </xsl:variable>
    <fo:list-block  role="TOC.{local-name()}"  xsl:use-attribute-sets="toc.level3.properties"
       relative-align="baseline"
       provisional-distance-between-starts="{&column; + &gutter;}mm"
       provisional-label-separation="{&gutter;}mm">
      
      <xsl:choose>
        <xsl:when test="child::sect2">
          <xsl:attribute name="space-after">0.1em</xsl:attribute>
        </xsl:when>
        <xsl:otherwise>
          <xsl:attribute name="space-after">0.75em</xsl:attribute>
        </xsl:otherwise>
      </xsl:choose>
        <fo:list-item>
          <fo:list-item-label end-indent="label-end()"
            text-align="end">
            <fo:block text-align-last="end">
            <xsl:choose>
              <xsl:when test="self::sect1">
                <fo:basic-link internal-destination="{$id}">
                  <xsl:value-of select="$label"/>
                </fo:basic-link>
              </xsl:when>
              <xsl:otherwise>
                <!-- We need an empty block -->
                <fo:leader/>
              </xsl:otherwise>
            </xsl:choose>
            </fo:block>
          </fo:list-item-label>
          <fo:list-item-body start-indent="body-start()" text-align="start">
            <xsl:copy-of select="$title"/>
          </fo:list-item-body>
        </fo:list-item>
      </fo:list-block>
    <xsl:if test="child::sect2">
      <fo:block keep-with-previous.within-column="always" role="sect2" xsl:use-attribute-sets="toc.level4.properties" 
        text-align="start"
        space-after="0.75em"
        start-indent="{&column; + &gutter;}mm">
        <xsl:apply-templates select="sect2" mode="sect2.susetoc"/>
      </fo:block>
    </xsl:if>
</xsl:template>

<xsl:template match="sect2" mode="sect2.susetoc">
    <xsl:variable name="id">
      <xsl:call-template name="object.id"/>
    </xsl:variable>
   <xsl:variable name="title">
     <xsl:call-template name="toc.title">
       <xsl:with-param name="wrapper.name">fo:inline</xsl:with-param>
     </xsl:call-template>
  </xsl:variable>
  
  <fo:inline>
    <fo:basic-link internal-destination="{$id}">
    <xsl:copy-of select="$title"/>
    <xsl:if test="following-sibling::sect2">
      <fo:leader keep-together.within-line="always"
        leader-pattern="space" leader-length="1.2 * &gutterfragment;mm"/>
      <fo:inline><xsl:text>&#x2022;</xsl:text></fo:inline>
      <fo:leader leader-pattern="space" leader-length="1.2 * &gutterfragment;mm"/>
    </xsl:if>
    </fo:basic-link>
  </fo:inline>
</xsl:template>

<xsl:template match="sect2" mode="susetoc">
<!--    <xsl:param name="sect2.style" select="'inline'"/>
    <xsl:variable name="id">
      <xsl:call-template name="object.id"/>
    </xsl:variable>
    <xsl:variable name="label">
      <xsl:call-template name="toc.label"/>
    </xsl:variable>
    <xsl:variable name="title">
      <xsl:call-template name="toc.title"/>
    </xsl:variable>
    
    
    <xsl:choose>
      <xsl:when test="$sect2.style = 'block'">
          <fo:list-block  role="TOC.{local-name()}" 
      xsl:use-attribute-sets="toc.level4.properties"
       relative-align="baseline"
       provisional-distance-between-starts="{&column; + &gutter;}mm"
       provisional-label-separation="{&gutter;}mm">
        <fo:list-item>
          <fo:list-item-label end-indent="label-end()"
            text-align="end">
            <fo:block text-align-last="end">
                <fo:basic-link internal-destination="{$id}">
                  <xsl:value-of select="$label"/>
                </fo:basic-link>
            </fo:block>
          </fo:list-item-label>
          <fo:list-item-body start-indent="body-start()" text-align="start">
            <xsl:copy-of select="$title"/>
          </fo:list-item-body>
        </fo:list-item>
      </fo:list-block>
      </xsl:when>
      <xsl:otherwise>
        <!-\-<fo:inline><xsl:copy-of select="$title"/>
          <xsl:if test="../following-sibling::sect2">
            <xsl:text> * </xsl:text>
          </xsl:if>
        </fo:inline>-\->
      </xsl:otherwise>
    </xsl:choose>-->
</xsl:template>

</xsl:stylesheet>
