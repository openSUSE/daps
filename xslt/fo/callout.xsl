<?xml version="1.0" encoding="UTF-8"?>
<!-- $Id: callout.xsl 2170 2005-09-26 12:01:33Z toms $ -->
<!DOCTYPE xsl:stylesheet>
<xsl:stylesheet version="1.0"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:fo="http://www.w3.org/1999/XSL/Format">


<xsl:template match="callout">
  <xsl:variable name="id"><xsl:call-template name="object.id"/></xsl:variable>

  <fo:list-item id="{$id}"
                xsl:use-attribute-sets="callout.spacing.properties">
    <fo:list-item-label end-indent="label-end()">
      <fo:block>
        <xsl:call-template name="callout.arearefs">
          <xsl:with-param name="arearefs" select="@arearefs"/>
        </xsl:call-template>
      </fo:block>
    </fo:list-item-label>
    <fo:list-item-body start-indent="body-start()">
      <fo:block>
        <xsl:apply-templates/>
      </fo:block>
    </fo:list-item-body>
  </fo:list-item>
</xsl:template>


<xsl:template name="callout-bug">
  <xsl:param name="conum" select='1'/>

  <xsl:choose>
    <!-- Draw callouts as images -->
    <xsl:when test="$callout.graphics != '0'
                    and $conum &lt;= $callout.graphics.number.limit">
      <xsl:variable name="filename"
                    select="concat($callout.graphics.path, $conum,
                                   $callout.graphics.extension)"/>

      <fo:external-graphic content-width="{$callout.icon.size}"
                           width="{$callout.icon.size}">
        <xsl:attribute name="src">
          <xsl:choose>
            <xsl:when test="$passivetex.extensions != 0
                            or $fop.extensions != 0
                            or $arbortext.extensions != 0">
              <xsl:value-of select="$filename"/>
            </xsl:when>
            <xsl:otherwise>
              <xsl:text>url(</xsl:text>
              <xsl:value-of select="$filename"/>
              <xsl:text>)</xsl:text>
            </xsl:otherwise>
          </xsl:choose>
        </xsl:attribute>
      </fo:external-graphic>
    </xsl:when>
    <xsl:when test="$callout.unicode != 0
                    and $conum &lt;= $callout.unicode.number.limit">
      <xsl:variable name="comarkup">
        <xsl:choose>
          <xsl:when test="$callout.unicode.start.character = 10102">
            <xsl:call-template name="toms-calloutbug">
             <xsl:with-param name="conum" select="$conum"/>
            </xsl:call-template>
          </xsl:when>
          <xsl:otherwise>
            <xsl:message>
              <xsl:text>Don't know how to generate Unicode callouts </xsl:text>
              <xsl:text>when $callout.unicode.start.character is </xsl:text>
              <xsl:value-of select="$callout.unicode.start.character"/>
            </xsl:message>
            <fo:inline background-color="#404040"
                       color="white"
                       padding-top="0.1em"
                       padding-bottom="0.1em"
                       padding-start="0.2em"
                       padding-end="0.2em"
                       baseline-shift="0.1em"
                       font-family="{$body.fontset}"
                       font-weight="bold"
                       font-size="75%">
              <xsl:value-of select="$conum"/>
            </fo:inline>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:variable>
      <xsl:choose>
        <xsl:when test="$callout.unicode.font != ''">
          <fo:inline font-family="{$callout.unicode.font}">
            <xsl:copy-of select="$comarkup"/>
          </fo:inline>
        </xsl:when>
        <xsl:otherwise>
          <xsl:copy-of select="$comarkup"/>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:when>

    <!-- Most safe: draw a dark gray square with a white number inside -->
    <xsl:otherwise>
      <fo:inline background-color="#404040"
                 color="white"
                 padding-top="0.1em"
                 padding-bottom="0.1em"
                 padding-start="0.2em"
                 padding-end="0.2em"
                 baseline-shift="0.1em"
                 font-family="{$body.fontset}"
                 font-weight="bold"
                 font-size="75%">
        <xsl:value-of select="$conum"/>
      </fo:inline>
    </xsl:otherwise>
  </xsl:choose>
</xsl:template>


<xsl:template name="toms-calloutbug">
 <xsl:param name="conum"/>
 
  <xsl:choose>
   <xsl:when test="$callout.unicode.start.character = 10102">
    <xsl:choose>
     <xsl:when test="$conum = 1">&#x2776;</xsl:when>
     <xsl:when test="$conum = 2">&#x2777;</xsl:when>
     <xsl:when test="$conum = 3">&#x2778;</xsl:when>
     <xsl:when test="$conum = 4">&#x2779;</xsl:when>
     <xsl:when test="$conum = 5">&#x277a;</xsl:when>
     <xsl:when test="$conum = 6">&#x277b;</xsl:when>
     <xsl:when test="$conum = 7">&#x277c;</xsl:when>
     <xsl:when test="$conum = 8">&#x277d;</xsl:when>
     <xsl:when test="$conum = 9">&#x277e;</xsl:when>
     <xsl:when test="$conum = 10">&#x277f;</xsl:when>
     <!--  -->
     <xsl:when test="$conum = 11">&#x24eb;</xsl:when>
     <xsl:when test="$conum = 12">&#x24ec;</xsl:when>
     <xsl:when test="$conum = 13">&#x24ed;</xsl:when>
     <xsl:when test="$conum = 14">&#x24ee;</xsl:when>
     <xsl:when test="$conum = 15">&#x24ef;</xsl:when>
     <xsl:when test="$conum = 16">&#x24f0;</xsl:when>
     <xsl:when test="$conum = 17">&#x24f1;</xsl:when>
     <xsl:when test="$conum = 18">&#x24f2;</xsl:when>
     <xsl:when test="$conum = 19">&#x24f3;</xsl:when>
     <xsl:when test="$conum = 20">&#x24f4;</xsl:when>

    </xsl:choose>
   </xsl:when>

   <xsl:otherwise>
    <xsl:message>
     <xsl:text>Don't know how to generate Unicode callouts </xsl:text>
     <xsl:text>when $callout.unicode.start.character is </xsl:text>
     <xsl:value-of select="$callout.unicode.start.character"/>
    </xsl:message>
    <fo:inline background-color="#404040" color="white"
     padding-top="0.1em" padding-bottom="0.1em" padding-start="0.2em"
     padding-end="0.2em" baseline-shift="0.1em"
     font-family="{$body.fontset}" font-weight="bold" font-size="75%">
     <xsl:value-of select="$conum"/>
    </fo:inline>
   </xsl:otherwise>
  </xsl:choose>
</xsl:template>


</xsl:stylesheet>
