<?xml version="1.0" encoding="ASCII"?>
<!-- 
   Purpose:  Contains templates for toc specific creations
-->

<xsl:stylesheet version="1.0"
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform" 
  xmlns="http://www.w3.org/1999/xhtml">


<xsl:template name="set.toc">
  <xsl:param name="toc-context" select="."/>
  <xsl:param name="toc.title.p" select="true()"/>
  <xsl:variable name="nodes" select="book|book/article|setindex|qandaset"/>
  <xsl:variable name="toc.title">
    <xsl:if test="$toc.title.p">
      <p>
        <strong xmlns:xslo="http://www.w3.org/1999/XSL/Transform">
          <xsl:call-template name="gentext">
            <xsl:with-param name="key">TableofContents</xsl:with-param>
          </xsl:call-template>
        </strong>
      </p>
    </xsl:if>
  </xsl:variable>

  <!--<xsl:call-template name="make.toc">
    <xsl:with-param name="toc-context" select="$toc-context"/>
    <xsl:with-param name="toc.title.p" select="$toc.title.p"/>
    <xsl:with-param name="nodes" select="book|book/article|setindex"/>
  </xsl:call-template>-->
  
  <!-- We want our own set toc, therefor we use mode=set-toc: -->
    <div class="toc">
      <div class="set-toc-title">
      <xsl:copy-of select="$toc.title"/>
      </div>
      <div>
         <xsl:apply-templates select="$nodes" mode="set-toc">
           <xsl:with-param name="toc-context" select="$toc-context"/>
         </xsl:apply-templates>
      </div>
    </div>
</xsl:template>

<xsl:template match="*|text()" mode="set-toc">
  <!-- Nope -->
</xsl:template>


<xsl:template match="book" mode="set-toc">
  <xsl:param name="toc-context" select="."/>
  
  <div class="set-book">
  <a>
    <xsl:attribute name="href">
      <xsl:call-template name="href.target">
        <xsl:with-param name="object" select="."/>
        <xsl:with-param name="toc-context" select="$toc-context"/>
      </xsl:call-template>
    </xsl:attribute>
    <xsl:apply-templates select="." mode="title.markup"/>
  </a>
  </div>
</xsl:template>


<xsl:template match="book/article" mode="set-toc">
  <xsl:param name="toc-context" select="."/>
  
  <div class="set-book-article">
   <a>
    <xsl:attribute name="href">
      <xsl:call-template name="href.target">
        <xsl:with-param name="object" select="."/>
        <xsl:with-param name="toc-context" select="$toc-context"/>
      </xsl:call-template>
    </xsl:attribute>
    <xsl:apply-templates select="." mode="title.markup"/>
  </a>
  </div>
</xsl:template>


<!--<xsl:template name="section.toc">
  <xsl:param name="toc-context" select="."/>
  <xsl:param name="toc.title.p" select="true()"/>

  <xsl:call-template name="make.toc">
    <xsl:with-param name="toc-context" select="$toc-context"/>
    <xsl:with-param name="toc.title.p" select="$toc.title.p"/>
    <xsl:with-param name="nodes"
                    select="section|sect1|sect2|sect3|sect4|sect5|refentry
                           |title/processing-instruction('suse')
                           |bridgehead[$bridgehead.in.toc != 0]"/>

  </xsl:call-template>
  </xsl:template>-->
  
<xsl:template name="toc.line">
  <xsl:param name="toc-context" select="."/>
  <xsl:param name="depth" select="1"/>
  <xsl:param name="depth.from.context" select="8"/>

  <!--<xsl:message>toc.line
    context: <xsl:value-of select="name(.)"/>
    parent:  <xsl:value-of select="name(..)"/>
  </xsl:message>-->

 <span>
  <xsl:attribute name="class"><xsl:value-of select="local-name(.)"/></xsl:attribute>

  <!-- * if $autotoc.label.in.hyperlink is zero, then output the label -->
  <!-- * before the hyperlinked title (as the DSSSL stylesheet does) -->
  <xsl:if test="$autotoc.label.in.hyperlink = 0">
    <xsl:variable name="label">
      <xsl:apply-templates select="." mode="label.markup"/>
    </xsl:variable>
    <xsl:copy-of select="$label"/>
    <xsl:if test="$label != ''">
      <xsl:value-of select="$autotoc.label.separator"/>
    </xsl:if>
  </xsl:if>

  <a>
    <xsl:attribute name="href">
      <xsl:call-template name="href.target">
        <xsl:with-param name="context" select="$toc-context"/>
        <xsl:with-param name="toc-context" select="$toc-context"/>
      </xsl:call-template>
    </xsl:attribute>

  <!-- * if $autotoc.label.in.hyperlink is non-zero, then output the label -->
  <!-- * as part of the hyperlinked title -->
  <xsl:if test="not($autotoc.label.in.hyperlink = 0)">
    <xsl:variable name="label">
      <xsl:apply-templates select="." mode="label.markup"/>
    </xsl:variable>
    <xsl:copy-of select="$label"/>
    <xsl:if test="$label != ''">
      <xsl:value-of select="$autotoc.label.separator"/>
    </xsl:if>
  </xsl:if>

    <xsl:apply-templates select=".|title/processing-instruction('suse')" mode="titleabbrev.markup"/>
  </a>
   <!-- Support status attribute -->
   <xsl:if test="($draft.mode = 'yes' or $draft.mode = 'maybe') and @status">
     <span class="status">
       <xsl:value-of select="@status"/>
     </span>
   </xsl:if>
   <!-- Show os attribute when set to hidden -->
   <xsl:if test="($draft.mode = 'yes' or $draft.mode = 'maybe') and normalize-space(@os) = 'hidden'">
     <span class="os">
       <xsl:value-of select="@os"/>
     </span>
   </xsl:if>
  </span>
</xsl:template>


<xsl:template match="figure|table|example|equation|procedure" mode="toc">
  <xsl:param name="toc-context" select="."/>

  <xsl:element name="{$toc.listitem.type}" namespace="http://www.w3.org/1999/xhtml">
    <xsl:variable name="label">
      <xsl:apply-templates select="." mode="label.markup"/>
    </xsl:variable>
    <xsl:copy-of select="$label"/>
    <xsl:if test="$label != ''">
      <xsl:value-of select="$autotoc.label.separator"/>
    </xsl:if>
    <a>
      <xsl:attribute name="href">
        <xsl:call-template name="href.target">
          <xsl:with-param name="toc-context" select="$toc-context"/>
        </xsl:call-template>
      </xsl:attribute>
      <xsl:apply-templates select=".|title/processing-instruction('suse')" mode="titleabbrev.markup"/>
    </a>
  </xsl:element>
</xsl:template>

</xsl:stylesheet>
