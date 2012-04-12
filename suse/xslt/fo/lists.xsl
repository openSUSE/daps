<?xml version="1.0" encoding="UTF-8"?>
<!-- $Id: lists.xsl 17656 2007-02-22 14:43:34Z toms $ -->
<!DOCTYPE xsl:stylesheet>
<xsl:stylesheet version="1.0"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:fo="http://www.w3.org/1999/XSL/Format">

<xsl:include href="mode-object.title.markup.xsl"/>

<xsl:template match="itemizedlist">
  <xsl:variable name="id">
    <xsl:call-template name="object.id"/>
  </xsl:variable>

  <xsl:variable name="label-width">
    <xsl:call-template name="dbfo-attribute">
      <xsl:with-param name="pis"
                      select="processing-instruction('dbfo')"/>
      <xsl:with-param name="attribute" select="'label-width'"/>
    </xsl:call-template>
  </xsl:variable>

  <xsl:if test="title">
    <xsl:apply-templates select="title" mode="list.title.mode"/>
  </xsl:if>

  <!-- Preserve order of PIs and comments -->
 <xsl:apply-templates
      select="*[not(self::listitem
                or self::title
                or self::titleabbrev)]
              |comment()[not(preceding-sibling::listitem)]
              |processing-instruction()[not(preceding-sibling::listitem)]"/>

  <xsl:variable name="content">
    <xsl:apply-templates
          select="listitem
                  |comment()[preceding-sibling::listitem]
                  |processing-instruction()[preceding-sibling::listitem]"/>
  </xsl:variable>

  <!-- nested lists don't add extra list-block spacing -->
  <xsl:choose>
    <xsl:when test="ancestor::listitem">
      <fo:list-block id="{$id}"
                     provisional-label-separation="6pt">
        <xsl:attribute name="provisional-distance-between-starts">
          <xsl:choose>
            <xsl:when test="$label-width != ''">
              <xsl:value-of select="$label-width"/>
            </xsl:when>
            <xsl:otherwise>10pt</xsl:otherwise>
          </xsl:choose>
        </xsl:attribute>
        <xsl:attribute name="start-indent">
          <xsl:choose>
            <xsl:when test="parent::procedure or
                            parent::listitem or
                            parent::calloutlist or
                            parent::simplelist">
              <xsl:text>2em</xsl:text><!-- 15pt -->
            </xsl:when>
            <xsl:otherwise>inherit</xsl:otherwise>
          </xsl:choose>
        </xsl:attribute>
        <xsl:copy-of select="$content"/>
      </fo:list-block>
    </xsl:when>
    <xsl:otherwise>
      <fo:list-block id="{$id}"
                     xsl:use-attribute-sets="list.block.spacing"
                     provisional-label-separation="6pt">
        <xsl:attribute name="provisional-distance-between-starts">
          <xsl:choose>
            <xsl:when test="$label-width != ''">
              <xsl:value-of select="$label-width"/>
            </xsl:when>
            <xsl:otherwise>10pt</xsl:otherwise>
          </xsl:choose>
        </xsl:attribute>
        <xsl:copy-of select="$content"/>
      </fo:list-block>
    </xsl:otherwise>
  </xsl:choose>
</xsl:template>


<!-- ==================================================================== -->
<xsl:template match="variablelist" mode="vl.as.blocks">
  <xsl:variable name="id">
    <xsl:call-template name="object.id"/>
  </xsl:variable>

  <!-- termlength is irrelevant -->

  <xsl:if test="title">
    <xsl:apply-templates select="title" mode="list.title.mode"/>
  </xsl:if>


  <!-- Preserve order of PIs and comments -->
  <xsl:apply-templates
    select="*[not(self::varlistentry
              or self::title
              or self::titleabbrev)]
            |comment()[not(preceding-sibling::varlistentry)]
            |processing-instruction()[not(preceding-sibling::varlistentry)]"/>

  <xsl:variable name="content">
    <xsl:apply-templates mode="vl.as.blocks"
      select="varlistentry
              |comment()[preceding-sibling::varlistentry]
              |processing-instruction()[preceding-sibling::varlistentry]"/>
  </xsl:variable>

  <!-- nested lists don't add extra list-block spacing -->
  <xsl:choose>
    <xsl:when test="ancestor::listitem">
      <fo:block id="blub{$id}">
        <xsl:copy-of select="$content"/>
      </fo:block>
    </xsl:when>
    <xsl:otherwise>
      <fo:block id="foo{$id}">
        <xsl:copy-of select="$content"/>
      </fo:block>
    </xsl:otherwise>
  </xsl:choose>
</xsl:template>


<!--<xsl:template match="varlistentry/term[position()=last()]" >
  <fo:inline><xsl:apply-templates/>
    <xsl:if test="../listitem/indexterm">
      <xsl:message> ******** indexterm <xsl:value-of select="../listitem/indexterm/@class"/>/<xsl:value-of select="../listitem/indexterm/@startref"/></xsl:message>
      <xsl:apply-templates select="../listitem/indexterm" />
    </xsl:if>
  </fo:inline>
</xsl:template>-->



<!-- ==================================================================== -->
<xsl:template match="procedure">
  <xsl:variable name="id">
    <xsl:call-template name="object.id"/>
  </xsl:variable>
  <xsl:variable name="dotafter">
    <xsl:call-template name="gentext.template">
     <xsl:with-param name="name" select="'dot.after.step'"/>
     <xsl:with-param name="context" select="'parameters'"/>
    </xsl:call-template>
  </xsl:variable>
 
  <xsl:variable name="param.placement"
                select="substring-after(normalize-space($formal.title.placement),
                                        concat(local-name(.), ' '))"/>
  <xsl:variable name="count.steps"
                select="count(step)"/>

  <xsl:variable name="placement">
    <xsl:choose>
      <xsl:when test="contains($param.placement, ' ')">
        <xsl:value-of select="substring-before($param.placement, ' ')"/>
      </xsl:when>
      <xsl:when test="$param.placement = ''">before</xsl:when>
      <xsl:otherwise>
        <xsl:value-of select="$param.placement"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:variable>

  <!-- Preserve order of PIs and comments -->
  <xsl:variable name="preamble"
        select="*[not(self::step
                  or self::title
                  or self::titleabbrev)]
                |comment()[not(preceding-sibling::step)]
                |processing-instruction()[not(preceding-sibling::step)]"/>

  <xsl:variable name="steps"
                select="step
                        |comment()[preceding-sibling::step]
                        |processing-instruction()[preceding-sibling::step]"/>


  <fo:block id="{$id}" xsl:use-attribute-sets="list.block.spacing">
    <xsl:if test="./title and $placement = 'before'">
      <!-- n.b. gentext code tests for $formal.procedures and may make an "informal" -->
      <!-- heading even though we called formal.object.heading. odd but true. -->
      <xsl:call-template name="formal.object.heading"/>
    </xsl:if>

    <xsl:apply-templates select="$preamble"/>

    <fo:list-block xsl:use-attribute-sets="list.block.spacing">
     <xsl:attribute name="provisional-label-separation">6pt</xsl:attribute>
     <xsl:choose>
          <xsl:when test="$count.steps &lt; 10">
           <xsl:choose>
            <xsl:when test="$dotafter != ''">
             <xsl:attribute
              name="provisional-distance-between-starts">12pt + 4pt</xsl:attribute>
            </xsl:when>
            <xsl:otherwise>
             <xsl:attribute name="provisional-distance-between-starts">12pt</xsl:attribute>
            </xsl:otherwise>
           </xsl:choose>
          </xsl:when>
          <xsl:otherwise>
           <xsl:choose>
            <xsl:when test="$dotafter != ''">
             <xsl:attribute
              name="provisional-distance-between-starts">24pt + 4pt</xsl:attribute>
            </xsl:when>
            <xsl:otherwise>
             <xsl:attribute name="provisional-distance-between-starts">24pt</xsl:attribute>
            </xsl:otherwise>
           </xsl:choose>
          </xsl:otherwise>
       </xsl:choose>
      <xsl:apply-templates select="$steps">
       <xsl:with-param name="dotafter" select="$dotafter"/>
      </xsl:apply-templates>
    </fo:list-block>

    <xsl:if test="./title and $placement != 'before'">
      <!-- n.b. gentext code tests for $formal.procedures and may make an "informal" -->
      <!-- heading even though we called formal.object.heading. odd but true. -->
      <xsl:call-template name="formal.object.heading"/>
    </xsl:if>
  </fo:block>
</xsl:template>


<xsl:template match="procedure/step|substeps/step">
  <xsl:param name="dotafter" select="''"/>
  <xsl:variable name="id">
    <xsl:call-template name="object.id"/>
  </xsl:variable>
 
<!-- <xsl:message><xsl:value-of 
  select="local-name(.)"/>: dotafter = "<xsl:value-of select="$dotafter"/>"</xsl:message>
-->
 
  <fo:list-item xsl:use-attribute-sets="list.item.spacing">
    <xsl:if test="ancestor::procedure or ancestor::step">
       <xsl:attribute name="space-before">0em</xsl:attribute>
    </xsl:if>
    <fo:list-item-label end-indent="label-end()">
      <fo:block id="{$id}" xsl:use-attribute-sets="procedure.label.properties">
        <xsl:choose>
          <xsl:when test="count(../step) = 1">
            <xsl:text>&#x2022;</xsl:text>
          </xsl:when>
          <xsl:otherwise>
            <xsl:apply-templates select="." mode="number">
              <xsl:with-param name="recursive" 
                              select="$procedure.number.recursive"/>
            </xsl:apply-templates>
           <xsl:copy-of select="$dotafter"/>
          </xsl:otherwise>
        </xsl:choose>
      </fo:block>
    </fo:list-item-label>
    <fo:list-item-body start-indent="body-start()">
      <fo:block>
        <xsl:apply-templates/>
      </fo:block>
    </fo:list-item-body>
  </fo:list-item>
</xsl:template>

<xsl:template match="substeps">
  <fo:list-block xsl:use-attribute-sets="list.block.spacing"
                 provisional-label-separation="6pt">
   <!--provisional-distance-between-starts="24pt"-->
   <xsl:choose>
    <xsl:when test="$procedure.number.recursive">
     <xsl:attribute
       name="provisional-distance-between-starts">30pt</xsl:attribute><!-- 24pt -->
     <xsl:attribute name="start-indent">inherit</xsl:attribute><!--15pt + 6pt -->
    </xsl:when>
    <xsl:otherwise>
     <xsl:attribute name="provisional-distance-between-starts">12pt</xsl:attribute>
     <xsl:attribute name="start-indent">inherit</xsl:attribute><!-- 15pt + 6pt + 15pt -->
    </xsl:otherwise>
   </xsl:choose>   
   <xsl:apply-templates/>
  </fo:list-block>
</xsl:template>


<!-- **************************************** -->

<xsl:template match="procedure|table|figure|example" mode="object.title.markup_safe">
  <xsl:param name="allow-anchors" select="0"/>

  <xsl:variable name="label.label">
     <xsl:call-template name="substitute-markup">
        <xsl:with-param name="allow-anchors" select="$allow-anchors"/>
        <xsl:with-param name="template">
           <xsl:call-template name="gentext.template">
              <xsl:with-param name="context" select="'styles'"/>
              <xsl:with-param name="name"
                 select="concat(name(.), '-label')"/>
           </xsl:call-template>
        </xsl:with-param>
     </xsl:call-template>
  </xsl:variable>
  <xsl:variable name="label.title">
    <xsl:call-template name="substitute-markup">
      <xsl:with-param name="allow-anchors" select="$allow-anchors"/>
      <xsl:with-param name="template">
         <xsl:call-template name="gentext.template">
            <xsl:with-param name="context" select="'styles'"/>
            <xsl:with-param name="name"
                 select="concat(name(.), '-title')"/>
         </xsl:call-template>
      </xsl:with-param>
    </xsl:call-template>
  </xsl:variable>

   <fo:block><fo:inline  xsl:use-attribute-sets="formal.inline.number.properties">
           <xsl:value-of select="$label.label"/>
      </fo:inline><!-- <xsl:text>&#x2003;&#x2003;</xsl:text>EM SPACE
      --><fo:inline space-start.minimum="0.5em"
                    space-start.optimum="1em"
                    space-start.maximum="1.1em"
                    xsl:use-attribute-sets="formal.inline.title.properties">
            <xsl:value-of select="normalize-space($label.title)"/>
      </fo:inline>
   </fo:block>

</xsl:template>



</xsl:stylesheet>
