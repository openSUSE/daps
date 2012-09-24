<?xml version="1.0" encoding="UTF-8"?>

<xsl:stylesheet version="1.0"
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:exsl="http://exslt.org/common"
  xmlns="http://www.w3.org/1999/xhtml"
  exclude-result-prefixes="exsl">
  
  <xsl:template name="make.toc">
  <xsl:param name="toc-context" select="."/>
  <xsl:param name="toc.title.p" select="true()"/>
  <xsl:param name="nodes" select="/NOT-AN-ELEMENT"/>

  <xsl:variable name="nodes.plus" select="$nodes | qandaset"/>
  
  <xsl:choose>
    <xsl:when test="$manual.toc != ''">
      <xsl:variable name="id">
        <xsl:call-template name="object.id"/>
      </xsl:variable>
      <xsl:variable name="toc" select="document($manual.toc, .)"/>
      <xsl:variable name="tocentry" select="$toc//tocentry[@linkend=$id]"/>
      <xsl:if test="$tocentry and $tocentry/*">
        <div class="toc">
          <!--<xsl:copy-of select="$toc.title"/>-->
          <xsl:element name="{$toc.list.type}" namespace="http://www.w3.org/1999/xhtml">
            <xsl:call-template name="manual-toc">
              <xsl:with-param name="tocentry" select="$tocentry/*[1]"/>
            </xsl:call-template>
          </xsl:element>
        </div>
      </xsl:if>
    </xsl:when>
    <xsl:otherwise>
      <xsl:choose>
        <xsl:when test="$qanda.in.toc != 0">
          <xsl:if test="$nodes.plus">
            <div class="toc">
              <!--<xsl:copy-of select="$toc.title"/>-->
              <xsl:element name="{$toc.list.type}" namespace="http://www.w3.org/1999/xhtml">
                <xsl:apply-templates select="$nodes.plus" mode="toc">
                  <xsl:with-param name="toc-context" select="$toc-context"/>
                </xsl:apply-templates>
              </xsl:element>
            </div>
          </xsl:if>
        </xsl:when>
        <xsl:otherwise>
          <xsl:if test="$nodes">
            <div class="toc">
              <xsl:element name="{$toc.list.type}" namespace="http://www.w3.org/1999/xhtml">
                <xsl:apply-templates select="$nodes" mode="toc">
                  <xsl:with-param name="toc-context" select="$toc-context"/>
                </xsl:apply-templates>
              </xsl:element>
            </div>
          </xsl:if>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:otherwise>
  </xsl:choose>
  </xsl:template>

<xsl:template name="toc.line">
  <xsl:param name="toc-context" select="."/>
  <xsl:param name="depth" select="1"/>
  <xsl:param name="depth.from.context" select="8"/>
  
  <xsl:variable name="label.in.toc">
    <!-- Flag all elements which do not need an label 
        0 = no, don't create a label
        1 = yes, create a label
    -->
    <xsl:choose>
      <xsl:when test="self::article">0</xsl:when>
      <xsl:when test="self::book">0</xsl:when>
      <xsl:when test="ancestor-or-self::preface and
        number($preface.autolabel) = 0">0</xsl:when>
      <xsl:when test="ancestor-or-self::glossary">0</xsl:when>
      <xsl:when test="ancestor-or-self::bibliography">0</xsl:when>
      <xsl:otherwise>1</xsl:otherwise>
    </xsl:choose>
  </xsl:variable>

 <!-- <xsl:message>label.in.toc: <xsl:value-of select="concat(local-name(),
    ':', $label.in.toc )"/></xsl:message>-->

 <span>
  <xsl:attribute name="class"><xsl:value-of select="local-name(.)"/></xsl:attribute>
  <!-- * if $autotoc.label.in.hyperlink is zero, then output the label -->
  <!-- * before the hyperlinked title (as the DSSSL stylesheet does) -->
  <a>
    <xsl:attribute name="href">
      <xsl:call-template name="href.target">
        <xsl:with-param name="context" select="$toc-context"/>
        <xsl:with-param name="toc-context" select="$toc-context"/>
      </xsl:call-template>
    </xsl:attribute>
    
  <!-- * if $autotoc.label.in.hyperlink is non-zero, then output the label -->
  <!-- * as part of the hyperlinked title -->
  <xsl:if test="not($autotoc.label.in.hyperlink = 0) and 
                number($label.in.toc) != 0">
      <xsl:variable name="label">
        <span class="number">
          <xsl:apply-templates select="." mode="label.markup"/>
          <xsl:value-of select="$autotoc.label.separator"/>
          <xsl:text> </xsl:text>
        </span>
      </xsl:variable>
      <xsl:copy-of select="$label"/>
  </xsl:if>

  <span class="name">
    <xsl:apply-templates select="." mode="titleabbrev.markup"/>
  </span>
  </a>
  </span>
</xsl:template>
  
  <!-- http://sagehill.net/docbookxsl/TOCcontrol.html#BriefSetToc -->
  <xsl:template match="book" mode="toc">
    <xsl:param name="toc-context" select="."/>

    <xsl:call-template name="subtoc">
      <xsl:with-param name="toc-context" select="$toc-context"/>
      <xsl:with-param name="nodes" select="EMPTY"/>
    </xsl:call-template>
    
    <xsl:apply-templates select="(bookinfo/abstract|abstract)[1]" mode="toc"/>
  </xsl:template>
  
  <xsl:template match="abstract" mode="toc">
    <dd class="toc-abstract">
      <xsl:apply-templates/>
    </dd>
  </xsl:template>


  <!-- ===================================================== -->
  
  <xsl:template name="bubble-toc">
    <xsl:param name="node" 
      select="(ancestor-or-self::book | ancestor-or-self::article)[1]"/>
    
     <ol>
       <xsl:apply-templates select="$node" mode="bubble-toc"/>
     </ol>
  </xsl:template>

  <xsl:template name="bubble-subtoc">
    <xsl:param name="toc-context" select="."/>
    <xsl:param name="nodes" select="NOT-AN-ELEMENT"/>
    
    <xsl:variable name="depth">
      <xsl:choose>
        <xsl:when test="local-name(.) = 'section'">
          <xsl:value-of select="count(ancestor::section) + 1"/>
        </xsl:when>
        <xsl:when test="local-name(.) = 'sect1'">1</xsl:when>
        <xsl:when test="local-name(.) = 'sect2'">2</xsl:when>
        <xsl:when test="local-name(.) = 'sect3'">3</xsl:when>
        <xsl:when test="local-name(.) = 'sect4'">4</xsl:when>
        <xsl:when test="local-name(.) = 'sect5'">5</xsl:when>
        <xsl:when test="local-name(.) = 'refsect1'">1</xsl:when>
        <xsl:when test="local-name(.) = 'refsect2'">2</xsl:when>
        <xsl:when test="local-name(.) = 'refsect3'">3</xsl:when>
        <xsl:when test="local-name(.) = 'topic'">1</xsl:when>
        <xsl:when test="local-name(.) = 'simplesect'">
          <!-- sigh... -->
          <xsl:choose>
            <xsl:when test="local-name(..) = 'section'">
              <xsl:value-of select="count(ancestor::section)"/>
            </xsl:when>
            <xsl:when test="local-name(..) = 'sect1'">2</xsl:when>
            <xsl:when test="local-name(..) = 'sect2'">3</xsl:when>
            <xsl:when test="local-name(..) = 'sect3'">4</xsl:when>
            <xsl:when test="local-name(..) = 'sect4'">5</xsl:when>
            <xsl:when test="local-name(..) = 'sect5'">6</xsl:when>
            <xsl:when test="local-name(..) = 'topic'">2</xsl:when>
            <xsl:when test="local-name(..) = 'refsect1'">2</xsl:when>
            <xsl:when test="local-name(..) = 'refsect2'">3</xsl:when>
            <xsl:when test="local-name(..) = 'refsect3'">4</xsl:when>
            <xsl:otherwise>1</xsl:otherwise>
          </xsl:choose>
        </xsl:when>
        <xsl:otherwise>0</xsl:otherwise>
      </xsl:choose>
    </xsl:variable>
    
    <xsl:variable name="depth.from.context" select="count(ancestor::*)-count($toc-context/ancestor::*)"/>
    
    <!--<xsl:call-template name="toc.line">
      <xsl:with-param name="toc-context" select="$toc-context"/>
    </xsl:call-template>-->
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
      <xsl:if test="not($autotoc.label.in.hyperlink = 0)">
        <xsl:variable name="label">
          <xsl:apply-templates select="." mode="label.markup"/>
        </xsl:variable>
        <xsl:copy-of select="$label"/>
        <xsl:if test="$label != ''">
          <xsl:value-of select="$autotoc.label.separator"/>
        </xsl:if>
      </xsl:if>

      <xsl:apply-templates select="." mode="titleabbrev.markup"/>
    </a>
    <!--  -->
    <xsl:if test="( (self::set or self::book or self::part) or 
                  $bubbletoc.section.depth &gt; $depth) and 
                  count($nodes)>0 and 
                  $bubbletoc.max.depth > $depth.from.context">
      <li>
        <xsl:apply-templates mode="bubble-toc" select="$nodes">
          <xsl:with-param name="toc-context" select="$toc-context"/>
        </xsl:apply-templates>
      </li>
    </xsl:if>
  </xsl:template>


  <xsl:template match="book" mode="bubble-toc">
    <xsl:param name="toc-context" select="."/>
    
    <xsl:call-template name="bubble-subtoc">
    <xsl:with-param name="toc-context" select="$toc-context"/>
    <xsl:with-param name="nodes" 
      select="part|reference|preface|chapter|appendix|article|topic|bibliography|
              glossary|index|refentry|bridgehead[$bridgehead.in.toc != 0]"/>
  </xsl:call-template>
  </xsl:template>

  <xsl:template match="part|reference" mode="bubble-toc">
    <xsl:param name="toc-context" select="."/>

    <xsl:call-template name="bubble-subtoc">
      <xsl:with-param name="toc-context" select="$toc-context"/>
      <xsl:with-param name="nodes"
        select="appendix|chapter|article|topic|index|glossary|bibliography|preface|
                reference|refentry|bridgehead[$bridgehead.in.toc != 0]"
      />
    </xsl:call-template>
  </xsl:template>
  
  <xsl:template match="preface|chapter|appendix|article|topic" mode="bubble-toc">
    <xsl:param name="toc-context" select="."/>

    <xsl:call-template name="bubble-subtoc">
      <xsl:with-param name="toc-context" select="$toc-context"/>
      <xsl:with-param name="nodes"
        select="section|sect1|simplesect[$simplesect.in.toc != 0]|
                topic|refentry|glossary|bibliography|index|
                bridgehead[$bridgehead.in.toc != 0]"/>
    </xsl:call-template>
  </xsl:template>
  
  <xsl:template match="sect1" mode="bubble-toc">
    <xsl:param name="toc-context" select="."/>
    <xsl:call-template name="bubble-subtoc">
      <xsl:with-param name="toc-context" select="$toc-context"/>
      <xsl:with-param name="nodes"
        select="sect2|bridgehead[$bridgehead.in.toc != 0]"/>
    </xsl:call-template>
  </xsl:template>

  <xsl:template match="sect2" mode="bubble-toc">
    <xsl:param name="toc-context" select="."/>

    <xsl:call-template name="bubble-subtoc">
      <xsl:with-param name="toc-context" select="$toc-context"/>
      <xsl:with-param name="nodes"
        select="sect3|bridgehead[$bridgehead.in.toc != 0]"/>
    </xsl:call-template>
  </xsl:template>

  <xsl:template match="sect3" mode="bubble-toc">
    <xsl:param name="toc-context" select="."/>

    <xsl:call-template name="bubble-subtoc">
      <xsl:with-param name="toc-context" select="$toc-context"/>
      <xsl:with-param name="nodes"
        select="sect4|bridgehead[$bridgehead.in.toc != 0]"
      />
    </xsl:call-template>
  </xsl:template>
  
  <xsl:template match="sect4" mode="bubble-toc">
    <xsl:param name="toc-context" select="."/>

    <xsl:call-template name="bubble-subtoc">
      <xsl:with-param name="toc-context" select="$toc-context"/>
      <xsl:with-param name="nodes"
        select="sect5|bridgehead[$bridgehead.in.toc != 0]"
      />
    </xsl:call-template>
  </xsl:template>

  <xsl:template match="sect5" mode="bubble-toc">
    <xsl:param name="toc-context" select="."/>

    <xsl:call-template name="bubble-subtoc">
      <xsl:with-param name="toc-context" select="$toc-context"/>
    </xsl:call-template>
  </xsl:template>
  
  <xsl:template match="simplesect" mode="bubble-toc">
    <xsl:param name="toc-context" select="."/>

    <xsl:call-template name="bubble-subtoc">
      <xsl:with-param name="toc-context" select="$toc-context"/>
    </xsl:call-template>
  </xsl:template>
  
  <xsl:template match="section" mode="bubble-toc">
    <xsl:param name="toc-context" select="."/>

    <xsl:call-template name="bubble-subtoc">
      <xsl:with-param name="toc-context" select="$toc-context"/>
      <xsl:with-param name="nodes"
        select="section|refentry|simplesect[$simplesect.in.toc != 0]|
               bridgehead[$bridgehead.in.toc != 0]"/>
    </xsl:call-template>
  </xsl:template>
  
  <xsl:template match="bibliography|glossary" mode="bubble-toc">
    <xsl:param name="toc-context" select="."/>

    <xsl:call-template name="bubble-subtoc">
      <xsl:with-param name="toc-context" select="$toc-context"/>
    </xsl:call-template>
  </xsl:template>
  
  <xsl:template match="title" mode="bubble-toc">
    <xsl:param name="toc-context" select="."/>

    <a>
      <xsl:attribute name="href">
        <xsl:call-template name="href.target">
          <xsl:with-param name="object" select=".."/>
          <xsl:with-param name="toc-context" select="$toc-context"/>
        </xsl:call-template>
      </xsl:attribute>
      <xsl:apply-templates/>
    </a>
  </xsl:template>
  
  <xsl:template match="index" mode="bubble-toc">
    <xsl:param name="toc-context" select="."/>

    <!-- If the index tag is not empty, it should be it in the TOC -->
    <xsl:if test="* or $generate.index != 0">
      <xsl:call-template name="bubble-subtoc">
        <xsl:with-param name="toc-context" select="$toc-context"/>
      </xsl:call-template>
    </xsl:if>
  </xsl:template>


</xsl:stylesheet>