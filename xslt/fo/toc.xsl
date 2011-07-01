<?xml version="1.0" encoding="UTF-8"?>
<!-- $Id: toc.xsl 43787 2009-08-25 13:31:36Z toms $ -->
<xsl:stylesheet version="1.0"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:fo="http://www.w3.org/1999/XSL/Format">


<xsl:template name="insert.dot">
 <xsl:if test="ancestor-or-self::*[@lang][1]/@lang = 'hu'">
  <xsl:text>.</xsl:text>
 </xsl:if>
</xsl:template>

<!-- Disable the following elements in mode toc: -->
<xsl:template match="preface/sect1" mode="toc"/>
<xsl:template match="preface/sect1/sect2" mode="toc"/>
<xsl:template match="preface/sect1/sect2/sect3" mode="toc"/>

<xsl:template match="refentry" mode="toc"/>

<!-- Special rules for appendix and chapters: -->
<xsl:template name="toc.line.appendix">
  <xsl:call-template name="toc.line.chapter"/>
</xsl:template>


<xsl:template name="toc.line.chapter">
  <xsl:variable name="label">
      <xsl:apply-templates select="." mode="label.markup"/>
  </xsl:variable>

  <fo:list-block
                 keep-with-next.within-line="always"
                 keep-with-next.within-column="always"
                 space-before="27pt -1em"
                 space-after="16pt -1em"><!-- provisional-distance-between-starts="15pt" -->
   <xsl:choose>
      <xsl:when test="string-length($label)=0"/>

      <xsl:when test="string-length($label)=1">
         <xsl:attribute name="provisional-distance-between-starts">15pt</xsl:attribute>
      </xsl:when>

      <xsl:otherwise>
         <xsl:attribute name="provisional-distance-between-starts">20pt</xsl:attribute>
      </xsl:otherwise>
   </xsl:choose>

   <fo:list-item>
    <fo:list-item-label end-indent="label-end()">
      <xsl:call-template name="toc.line.chapter.number"/>
    </fo:list-item-label>
    <fo:list-item-body start-indent="body-start()">
      <xsl:call-template name="toc.line.chapter.title"/>
    </fo:list-item-body>
   </fo:list-item>
  </fo:list-block>
</xsl:template>

<xsl:template name="toc.line.chapter.number">
  <xsl:variable name="label">
    <xsl:apply-templates select="." mode="label.markup"/>
    <xsl:call-template name="insert.dot"/>
  </xsl:variable>

 <fo:block>
   <fo:inline>
      <xsl:if test="$label != ''">
         <xsl:copy-of select="$label"/>
         <xsl:value-of select="$autotoc.label.separator"/>
      </xsl:if>
   </fo:inline>
 </fo:block>
</xsl:template>

<xsl:template name="toc.line.chapter.title">
  <xsl:variable name="id">
    <xsl:call-template name="object.id"/>
  </xsl:variable>

  <fo:block text-align-last="justify"
            text-align="left"
            end-indent="2pt"
            last-line-end-indent="-2pt"
     ><fo:basic-link internal-destination="{$id}">
        <xsl:apply-templates
          select="." mode="titleabbrev.markup"/>
   </fo:basic-link><fo:inline
    ><fo:leader leader-pattern="space"
    />&#xa0;<fo:basic-link internal-destination="{$id}"
    ><fo:page-number-citation ref-id="{$id}" letter-spacing="0"
    /></fo:basic-link></fo:inline
  ></fo:block>
</xsl:template>


<xsl:template name="toc.line.section">
  <fo:list-block>
   <xsl:choose>
    <xsl:when test="self::sect1">
      <xsl:attribute name="start-indent">15pt</xsl:attribute>
      <xsl:attribute name="provisional-distance-between-starts">27pt</xsl:attribute>
    </xsl:when>
    <xsl:when test="self::sect2">
      <xsl:attribute name="start-indent">42pt</xsl:attribute>
      <xsl:attribute name="provisional-distance-between-starts">36pt</xsl:attribute>
    </xsl:when>
    <xsl:otherwise/>
   </xsl:choose>
   <fo:list-item>
    <fo:list-item-label end-indent="label-end()">
      <xsl:call-template name="toc.line.section.number"/>
    </fo:list-item-label>
    <fo:list-item-body start-indent="body-start()">
      <xsl:call-template name="toc.line.section.title"/>
    </fo:list-item-body>
   </fo:list-item>
  </fo:list-block>
</xsl:template>

<xsl:template name="toc.line.section.number">
  <xsl:variable name="label">
     <xsl:apply-templates select="." mode="label.markup"/>
     <xsl:call-template name="insert.dot"/>
  </xsl:variable>

  <fo:block letter-spacing="0"><fo:inline>
      <xsl:if test="$label != ''">
         <xsl:copy-of select="$label"/>
         <xsl:value-of select="$autotoc.label.separator"/>
      </xsl:if>
      </fo:inline>
  </fo:block>
</xsl:template>

<xsl:template name="toc.line.section.title">
  <xsl:variable name="id">
    <xsl:call-template name="object.id"/>
  </xsl:variable>

  <fo:block text-align-last="justify" hyphenate="false"
    ><fo:basic-link internal-destination="{$id}">
       <xsl:apply-templates
         select="." 
         mode="titleabbrev.markup"/>
    </fo:basic-link>
    
    <xsl:call-template name="addstatus"/>
    
    <fo:inline><fo:leader
         leader-pattern="dots"
         leader-pattern-width="1em"
      /></fo:inline><fo:basic-link internal-destination="{$id}"
       ><fo:page-number-citation ref-id="{$id}" letter-spacing="0"
      /></fo:basic-link></fo:block>
</xsl:template>


<xsl:template name="toc.line">
  <xsl:variable name="id">
    <xsl:call-template name="object.id"/>
  </xsl:variable>
  <xsl:variable name="label">
     <xsl:apply-templates select="." mode="label.markup"/>
  </xsl:variable>


  <!--<xsl:message> toc.line = <xsl:value-of select="$label"/> <xsl:call-template name="gentext"
         /> <xsl:call-template name="gentext.template">
      <xsl:with-param name="name"><xsl:value-of select="name(.)"/></xsl:with-param>
    </xsl:call-template>
  </xsl:message>-->


  <xsl:choose>
    <xsl:when test="self::part">
      <fo:block xsl:use-attribute-sets="toc.title.part.properties">
          <xsl:choose>
            <xsl:when test="/*[@lang='hu']">
              <fo:basic-link internal-destination="{$id}">
                <xsl:if test="$label != ''">
                  <xsl:copy-of select="$label"/>
                  <xsl:text>. </xsl:text>
                </xsl:if>
                <xsl:call-template name="gentext"/>
                <xsl:text> </xsl:text>
                <xsl:apply-templates
                  select="." 
                  mode="titleabbrev.markup"/>
              </fo:basic-link>
            </xsl:when>
            <xsl:when test="/*[@lang='ko']">
             <fo:basic-link internal-destination="{$id}">
                <xsl:if test="$label != ''">
                  <xsl:copy-of select="$label"/>
                </xsl:if>
                <xsl:call-template name="gentext"/>
                <xsl:text> </xsl:text>
                <xsl:apply-templates
                  select="." 
                  mode="titleabbrev.markup"/>
              </fo:basic-link>
            </xsl:when>
            <xsl:otherwise>
              <fo:basic-link internal-destination="{$id}">
                <xsl:call-template name="gentext" />
                <xsl:text> </xsl:text>
                <xsl:if test="$label != ''">
                  <xsl:copy-of select="$label"/>
<!--             <xsl:value-of select="$autotoc.label.separator"/> -->
                  <fo:leader leader-length="1em" leader-pattern="space"/>
                </xsl:if>
                <xsl:apply-templates
                  select="." 
                  mode="titleabbrev.markup"/>
              </fo:basic-link>
            </xsl:otherwise>
          </xsl:choose>
        
         <fo:inline
        ><fo:leader leader-alignment="reference-area"
                 leader-pattern="space"
        /><fo:basic-link internal-destination="{$id}"
         ><fo:page-number-citation ref-id="{$id}"/></fo:basic-link>
       </fo:inline>
      </fo:block>
    </xsl:when>
    <xsl:when test="self::preface or
                    self::refentry or
                    self::bibliography or
                    self::index or
                    self::article or
                    self::glossary">
     <fo:block xsl:use-attribute-sets="toc.title.chapapp.properties"
               space-before="27pt -1em">
       <xsl:if test="self::preface">
         <xsl:attribute name="start-indent">15pt</xsl:attribute>
         <xsl:attribute name="margin-top">54pt -1em</xsl:attribute>
       </xsl:if>
       <fo:inline width="15pt">
         <xsl:if test="$label != ''">
           <xsl:copy-of select="$label"/>
           <xsl:value-of select="$autotoc.label.separator"/>
         </xsl:if>
       </fo:inline><fo:basic-link internal-destination="{$id}">
          <xsl:apply-templates
            select="." mode="titleabbrev.markup"/>
       </fo:basic-link>
       <fo:inline><fo:leader leader-alignment="reference-area"
                 keep-with-next.within-line="always"
                 leader-pattern="space"
         /><fo:basic-link internal-destination="{$id}"
         ><fo:page-number-citation ref-id="{$id}"/></fo:basic-link>
       </fo:inline>
     </fo:block>
    </xsl:when>
    <xsl:when test="self::chapter">
      <fo:block xsl:use-attribute-sets="toc.title.chapapp.properties"
                keep-with-next.within-line="always">
       <xsl:call-template name="toc.line.chapter"/>
      </fo:block>
    </xsl:when>
    <xsl:when test="self::appendix">
      <fo:block xsl:use-attribute-sets="toc.title.chapapp.properties"
                keep-with-next.within-line="always">
       <xsl:call-template name="toc.line.appendix"/>
      </fo:block>
    </xsl:when>
    <xsl:when test="self::sect1 or
                    self::sect2 or
                    self::sect3 or
                    self::sect4 or
                    self::section">
      <fo:block xsl:use-attribute-sets="toc.title.section.properties"
                keep-with-next.within-line="always">
        <xsl:call-template name="toc.line.section"/>
      </fo:block>
    </xsl:when>
    <xsl:when test="self::book">
      <!-- FIXME -->
    </xsl:when>
    <xsl:otherwise>
      <xsl:message> STRANGE TOC!!! <xsl:value-of select="name()"/></xsl:message>
    </xsl:otherwise>
  </xsl:choose>
</xsl:template>


<xsl:template name="toc.line.block">
  <xsl:variable name="id">
    <xsl:call-template name="object.id"/>
  </xsl:variable>

  <xsl:variable name="label">
    <xsl:apply-templates select="." mode="label.markup"/>
  </xsl:variable>

  <xsl:variable name="depth">
    <xsl:value-of select="count(ancestor::*)"/>
  </xsl:variable>

  <xsl:message>
  label = "<xsl:value-of select="$label"/>"
  depth = "<xsl:value-of select="$depth"/>"
  name  = "<xsl:value-of select="name(.)"/>"
  </xsl:message>

  <xsl:choose>
    <xsl:when test="self::part">
      <fo:block xsl:use-attribute-sets="toc.title.part.properties"
         keep-with-next.within-line="always"
         keep-with-next.within-column="always">
       <fo:inline><xsl:call-template name="gentext"
         /><xsl:text> </xsl:text
          ><fo:basic-link internal-destination="{$id}">
         <xsl:if test="$label != ''">
           <xsl:copy-of select="$label"/>
           <xsl:value-of select="$autotoc.label.separator"/>
           <xsl:text> </xsl:text>
         </xsl:if>
         <xsl:apply-templates
           select="." mode="titleabbrev.markup"/>
        </fo:basic-link>
       </fo:inline><fo:inline
        ><fo:leader leader-alignment="reference-area"
                 keep-with-next.within-line="always"
                 leader-pattern="space"
        /><fo:basic-link internal-destination="{$id}"
         ><fo:page-number-citation ref-id="{$id}"/></fo:basic-link>
       </fo:inline>
      </fo:block>
    </xsl:when>
    <xsl:when test="self::chapter or
                  self::appendix or
                  self::index or
                  self::preface or
                  self::glossary">
     <fo:block xsl:use-attribute-sets="toc.title.chapapp.properties">
       <fo:inline width="15pt">
         <xsl:if test="$label != ''">
           <xsl:copy-of select="$label"/>
           <xsl:value-of select="$autotoc.label.separator"/>
<!--            <xsl:text> </xsl:text> -->
         </xsl:if>
       </fo:inline><fo:basic-link internal-destination="{$id}">
          <xsl:apply-templates select="." mode="titleabbrev.markup"/>
       </fo:basic-link>
       <fo:inline><fo:leader leader-alignment="reference-area"
                 keep-with-next.within-line="always"
                 leader-pattern="space"
         /><fo:basic-link internal-destination="{$id}"
         ><fo:page-number-citation ref-id="{$id}"/></fo:basic-link>
       </fo:inline>
     </fo:block>
    </xsl:when>
    <xsl:otherwise>
     <fo:block xsl:use-attribute-sets="toc.title.properties">
       <xsl:attribute name="margin-left">
         <xsl:choose>
            <xsl:when test="self::sect1">
               <xsl:text>15pt</xsl:text>
         <xsl:message> name=<xsl:value-of select="name(.)"/>
         </xsl:message>
            </xsl:when>
            <xsl:when test="self::sect2">
               <xsl:text>42pt</xsl:text>
            </xsl:when>
            <xsl:otherwise>
             <xsl:value-of select="$toc.indent.width"/>
             <xsl:text>pt</xsl:text>
            </xsl:otherwise>
         </xsl:choose>
       </xsl:attribute>
       <fo:inline>
         <xsl:choose>
            <xsl:when test="self::sect1">
              <xsl:attribute name="width">27pt</xsl:attribute>
            </xsl:when>
            <xsl:otherwise>
              <xsl:attribute name="width">21pt + 15pt</xsl:attribute>
            </xsl:otherwise>
         </xsl:choose>
         <xsl:if test="$label != ''">
           <xsl:copy-of select="$label"/>
           <xsl:value-of select="$autotoc.label.separator"/>
           <!--<xsl:text> </xsl:text>-->
         </xsl:if>
       </fo:inline>
       <fo:basic-link internal-destination="{$id}">
           <xsl:apply-templates select="." mode="titleabbrev.markup"/>
       </fo:basic-link><fo:inline><fo:leader leader-alignment="reference-area"
                 keep-with-next.within-line="always"
                 leader-pattern-width="1em"
                 leader-pattern="dots"/>
        <fo:basic-link internal-destination="{$id}"
         ><fo:page-number-citation ref-id="{$id}"/></fo:basic-link>
       </fo:inline>
     </fo:block>
    </xsl:otherwise>
  </xsl:choose>

</xsl:template>


<xsl:template name="toc.line.old">
  <xsl:variable name="id">
    <xsl:call-template name="object.id"/>
  </xsl:variable>

  <xsl:variable name="label">
    <xsl:apply-templates select="." mode="label.markup"/>
  </xsl:variable>

  <fo:block text-align-last="justify"
            end-indent="{$toc.indent.width}pt"
            last-line-end-indent="-{$toc.indent.width}pt"
            font-family="{$title.font.family}">
    <xsl:if test="self::part">
        <xsl:attribute name="space-before">27pt -1em</xsl:attribute>
        <xsl:attribute name="space-after"> 27pt -1em</xsl:attribute>
        <xsl:attribute name="keep-with-next.within-line">always</xsl:attribute>
    </xsl:if>
    <xsl:if test="self::chapter or
                  self::appendix or
                  self::index or
                  self::preface or
                  self::glossary">
        <xsl:attribute name="space-before">27pt -1em</xsl:attribute>
        <xsl:attribute name="space-after">16pt -1em</xsl:attribute>
        <xsl:attribute name="keep-with-next.within-line">always</xsl:attribute>
    </xsl:if>

    <xsl:choose>
      <xsl:when test="self::part">
        <fo:inline xsl:use-attribute-sets="toc.title.part.properties">
          <xsl:call-template name="gentext">
          </xsl:call-template>
        </fo:inline>
      </xsl:when>
    </xsl:choose>

    <fo:inline>
     <xsl:choose>
      <xsl:when test="self::part">
        <xsl:attribute name="font-weight">
            <xsl:text>bold</xsl:text>
        </xsl:attribute>
        <xsl:attribute name="font-size">
            <xsl:value-of select="$body.font.master"/>
            <xsl:text>pt</xsl:text>
        </xsl:attribute>
      </xsl:when>
      <xsl:when test="self::chapter or
                      self::preface or
                      self::appendix or
                      self::glossary or
                      self::index">
         <xsl:attribute name="font-size">
           <xsl:value-of select="$body.font.master"/>
           <xsl:text>pt</xsl:text>
         </xsl:attribute>
         <xsl:attribute name="font-weight">bold</xsl:attribute>
      </xsl:when>
      <xsl:otherwise>
        <xsl:attribute name="font-size">9pt</xsl:attribute>
      </xsl:otherwise>
     </xsl:choose>
     <fo:basic-link internal-destination="{$id}">
        <xsl:if test="$label != ''">
          <xsl:copy-of select="$label"/>
          <xsl:value-of select="$autotoc.label.separator"/>
        </xsl:if>
        <xsl:apply-templates select=".|processing-instruction()" mode="titleabbrev.markup"/>
     </fo:basic-link>
    </fo:inline>
    <fo:inline keep-together.within-line="always">
      <!--<xsl:text> </xsl:text>-->
      <fo:leader leader-alignment="reference-area"
                 keep-with-next.within-line="always">
        <xsl:choose>
          <xsl:when test="self::part or self::preface or self::chapter or self::appendix">
            <xsl:attribute name="leader-pattern">space</xsl:attribute>
          </xsl:when>
          <xsl:otherwise>
            <xsl:attribute name="leader-pattern">dots</xsl:attribute>
            <xsl:attribute name="leader-pattern-width">1em</xsl:attribute>
          </xsl:otherwise>
        </xsl:choose>
      </fo:leader>
      <fo:basic-link internal-destination="{$id}"
       ><fo:page-number-citation ref-id="{$id}"/></fo:basic-link>
    </fo:inline>
  </fo:block>
</xsl:template>

<xsl:template name="set.toc.indent">
  <xsl:param name="reldepth"/>
  <xsl:text>0pt</xsl:text>
</xsl:template>

</xsl:stylesheet>
