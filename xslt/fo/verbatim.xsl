<?xml version="1.0" encoding="UTF-8"?>
<!-- $Id: verbatim.xsl 38086 2008-12-17 13:26:19Z toms $ -->
<xsl:stylesheet version="1.0"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:fo="http://www.w3.org/1999/XSL/Format"
    xmlns:exsl="http://exslt.org/common"
    exclude-result-prefixes="exsl">


<xsl:template match="programlisting|screen|synopsis">
  <xsl:param name="suppress-numbers" select="'0'"/>
  <xsl:variable name="id"><xsl:call-template name="object.id"/></xsl:variable>
   <xsl:variable name="rtf">
     <xsl:apply-templates select="self::screen" mode="screen-copy-node-normal"/>
   </xsl:variable>

  <xsl:variable name="pi">
    <xsl:call-template name="pi-attribute">
      <xsl:with-param name="pis"
                      select="(processing-instruction('dbsuse-fo') |
                              ../processing-instruction('dbsuse-fo')[parent::example])[last()]"/>
      <xsl:with-param name="attribute" select="'font-size'"/>
    </xsl:call-template>
  </xsl:variable>

  <xsl:variable name="content">
    <xsl:choose>
      <xsl:when test="$suppress-numbers = '0'
                      and @linenumbering = 'numbered'
                      and $use.extensions != '0'
                      and $linenumbering.extension != '0'">
        <xsl:call-template name="number.rtf.lines">
          <xsl:with-param name="rtf">
            <xsl:apply-templates select="exsl:node-set($rtf)" mode="screen"/>
          </xsl:with-param>
        </xsl:call-template>
      </xsl:when>
      <xsl:otherwise>
        <xsl:apply-templates select="exsl:node-set($rtf)" mode="screen"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:variable>

  
  <xsl:choose>
    <xsl:when test="$shade.verbatim != 0">
      <fo:block id="{$id}"
                white-space-collapse='false'
                white-space-treatment='preserve'
                linefeed-treatment='preserve'
                xsl:use-attribute-sets="monospace.verbatim.properties shade.verbatim.style">
        <xsl:if test="$pi!=''">
          <xsl:attribute name="font-size">
            <xsl:value-of select="$pi"/>
          </xsl:attribute>
        </xsl:if>

        <xsl:choose>
          <xsl:when test="$hyphenate.verbatim != 0 and function-available('exsl:node-set')">
            <xsl:apply-templates select="exsl:node-set($content)" mode="hyphenate.verbatim"/>
          </xsl:when>
          <xsl:otherwise>
            <xsl:copy-of select="$content"/>
          </xsl:otherwise>
        </xsl:choose>
      </fo:block>
    </xsl:when>
    <xsl:otherwise>
      <fo:block id="{$id}"
                white-space-collapse='false'
                white-space-treatment='preserve'
                linefeed-treatment="preserve"
                xsl:use-attribute-sets="monospace.verbatim.properties">
        <xsl:if test="$pi!=''">
          <xsl:attribute name="font-size">
            <xsl:value-of select="$pi"/>
          </xsl:attribute>
        </xsl:if>
        <xsl:choose>
          <xsl:when test="$hyphenate.verbatim != 0 and function-available('exsl:node-set')">
            <xsl:apply-templates select="exsl:node-set($content)" mode="hyphenate.verbatim"/>
          </xsl:when>
          <xsl:otherwise>
            <xsl:copy-of select="$content"/>
          </xsl:otherwise>
        </xsl:choose>
      </fo:block>
    </xsl:otherwise>
  </xsl:choose>
</xsl:template>


<xsl:template match="screen" mode="screen">
  <xsl:apply-templates mode="screen"/>
</xsl:template>


<xsl:template match="processing-instruction('suse')" mode="screen">
  <xsl:call-template name="suse-pi"/>
</xsl:template>


<xsl:template name="normalize-left">
  <xsl:param name="node" />
  <xsl:variable name="char" select="substring($node,1,1)"/>

  <xsl:choose>
    <xsl:when test="$node=''" />
    <xsl:when test="$char='&#x0d;' or
                    $char='&#x09;' or
                    $char='&#x0a;' or
                    $char=' '">
      <xsl:call-template name="normalize-left">
         <xsl:with-param name="node" select="substring($node,2)"/>
      </xsl:call-template>
    </xsl:when>
    <xsl:otherwise>
      <xsl:value-of select="$node"/>
    </xsl:otherwise>
  </xsl:choose>
</xsl:template>



<xsl:template name="normalize-right">
  <xsl:param name="node" />
  <xsl:variable name="len" select="string-length($node)"/>
  <xsl:variable name="char" select="substring($node,$len ,1)"/>

  <xsl:choose>
    <xsl:when test="$node=''" />
    <xsl:when test="$char='&#x0d;' or
                    $char='&#x09;' or
                    $char='&#x0a;' or
                    $char=' '">
      <xsl:call-template name="normalize-right">
         <xsl:with-param name="node" select="substring($node,1, $len -1)"/>
      </xsl:call-template>
    </xsl:when>
    <xsl:otherwise>
      <xsl:value-of select="$node"/>
    </xsl:otherwise>
  </xsl:choose>
</xsl:template>


<xsl:template match="textnode" mode="screen">
   <xsl:param name="context" select="."/>
   <xsl:variable name="len" select="string-length($context)"/>
   <xsl:variable name="pre" select="count(preceding-sibling::textnode)"/>
   <xsl:variable name="fol" select="count(following-sibling::textnode)"/>

   <!--<xsl:message> textnode = "<xsl:value-of select="$context"/>"
preceding-sibling::textnode = <xsl:value-of select="count(preceding-sibling::textnode)"/>
following-sibling::textnode = <xsl:value-of select="count(following-sibling::textnode)"/>
   </xsl:message>-->

   <xsl:apply-templates mode="screen"/>
   
</xsl:template>

<xsl:template match="*" mode="screen">
   <xsl:apply-imports/>
</xsl:template>


<xsl:template match="textnode">
   <xsl:value-of select="."/>
</xsl:template>

<!-- The elements, that are allowed in mode="screen" -->

<xsl:template match="co" mode="screen">
   <xsl:apply-templates select="self::co"/>
</xsl:template>
  
<xsl:template match="command" mode="screen">
   <xsl:apply-templates select="self::command"/>
</xsl:template>

<xsl:template match="emphasis" mode="screen">
   <xsl:apply-templates select="self::emphasis"/>
</xsl:template>

<xsl:template match="link" mode="screen">
   <xsl:apply-templates select="self::link"/>
</xsl:template>

<xsl:template match="replaceable" mode="screen">
   <xsl:apply-templates select="self::replaceable"/>
</xsl:template>

<xsl:template match="option" mode="screen">
   <xsl:apply-templates select="self::option"/>
</xsl:template>

<xsl:template match="phrase" mode="screen">
   <xsl:apply-templates select="self::phrase"/>
</xsl:template>

<xsl:template match="ulink" mode="screen">
   <xsl:apply-templates select="self::ulink"/>
</xsl:template>

<xsl:template match="xref" mode="screen">
   <xsl:apply-templates select="self::xref"/>
</xsl:template>


</xsl:stylesheet>
