<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0"
   xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
   xmlns:fo="http://www.w3.org/1999/XSL/Format"
   xmlns:exsl="http://exslt.org/common"
   exclude-result-prefixes="exsl">

<xsl:template match="programlisting|screen|synopsis">
  <xsl:param name="suppress-numbers" select="'0'"/>
  <xsl:variable name="id"><xsl:call-template name="object.id"/></xsl:variable>

  <xsl:variable name="content">
    <xsl:choose>
      <xsl:when test="$suppress-numbers = '0'
                      and @linenumbering = 'numbered'
                      and $use.extensions != '0'
                      and $linenumbering.extension != '0'">
        <xsl:call-template name="number.rtf.lines">
          <xsl:with-param name="rtf">
            <xsl:choose>
              <xsl:when test="$highlight.source != 0">
                <xsl:call-template name="apply-highlighting"/>
              </xsl:when>
              <xsl:otherwise>
                <xsl:apply-templates/>
              </xsl:otherwise>
            </xsl:choose>
          </xsl:with-param>
        </xsl:call-template>
      </xsl:when>
      <xsl:otherwise>
        <xsl:choose>
          <xsl:when test="$highlight.source != 0">
            <xsl:call-template name="apply-highlighting"/>
          </xsl:when>
          <xsl:otherwise>
            <xsl:apply-templates/>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:variable>

  <xsl:variable name="font.size">
    <xsl:call-template name="pi-attribute">
      <xsl:with-param name="pis"
                      select="(processing-instruction('dbsuse-fo') |
                              ../processing-instruction('dbsuse-fo')[parent::example])[last()]"/>
      <xsl:with-param name="attribute" select="'font-size'"/>
    </xsl:call-template>
  </xsl:variable>
  <xsl:variable name="keep.together">
    <xsl:call-template name="pi.dbfo_keep-together"/>
  </xsl:variable>
  
  <!--<xsl:message>programlisting|screen|synopsis
     pi="<xsl:value-of select="$font.size"/>"
     keep-together="<xsl:value-of select="$keep.together"/>"
  </xsl:message>
  -->
  <xsl:variable name="block.content">
    <xsl:choose>
      <xsl:when test="$shade.verbatim != 0">
        <fo:block id="{$id}"
             xsl:use-attribute-sets="monospace.verbatim.properties shade.verbatim.style">
          <xsl:if test="$keep.together != ''">
            <xsl:attribute name="keep-together.within-column"><xsl:value-of
              select="$keep.together"/></xsl:attribute>
          </xsl:if>
          <xsl:if test="$font.size != ''">
            <xsl:attribute name="font-size"><xsl:value-of
              select="$font.size"/></xsl:attribute>
          </xsl:if> 
          <xsl:if test="$xep.extensions != 0">
              <xsl:attribute name="float">none</xsl:attribute>
              <xsl:attribute name="clear">both</xsl:attribute>
              <!-- For some reasons, XEP needs this invisible border -->
              <xsl:attribute name="border">0.05pt solid white</xsl:attribute>
          </xsl:if> 
          <xsl:choose>
            <xsl:when test="$hyphenate.verbatim != 0 and 
                            $exsl.node.set.available != 0">
              <xsl:apply-templates select="exsl:node-set($content)" 
                                   mode="hyphenate.verbatim"/>
            </xsl:when>
            <xsl:otherwise>
              <xsl:copy-of select="$content"/>
            </xsl:otherwise>
          </xsl:choose>
        </fo:block>
      </xsl:when>
      <xsl:otherwise>
        <fo:block id="{$id}" role="non-shade-{local-name()}" 
                  xsl:use-attribute-sets="monospace.verbatim.properties">
          <xsl:if test="$keep.together != ''">
            <xsl:attribute name="keep-together.within-column"><xsl:value-of
              select="$keep.together"/></xsl:attribute>
          </xsl:if>
          <xsl:if test="$font.size != ''">
            <xsl:attribute name="font-size"><xsl:value-of
              select="$font.size"/></xsl:attribute>
          </xsl:if>  
          <!-- Apply it only for XEP -->
          <xsl:if test="$xep.extensions != 0 and 
                        (parent::example or parent::step)">
             <xsl:attribute name="margin-top">-1em</xsl:attribute>
          </xsl:if>
           <xsl:if test="$xep.extensions != 0">
              <xsl:attribute name="float">none</xsl:attribute>
              <xsl:attribute name="clear">both</xsl:attribute>
              <!-- For some reasons, XEP needs this invisible border -->
              <xsl:attribute name="border">0.05pt solid white</xsl:attribute>
           </xsl:if>
           <xsl:choose>
            <xsl:when test="$hyphenate.verbatim != 0 and 
                            $exsl.node.set.available != 0">
              <xsl:apply-templates select="exsl:node-set($content)" 
                                   mode="hyphenate.verbatim"/>
            </xsl:when>
            <xsl:otherwise>
              <xsl:copy-of select="$content"/>
            </xsl:otherwise>
          </xsl:choose>
        </fo:block>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:variable>

  <xsl:choose>
    <!-- Need a block-container for these features -->
    <xsl:when test="@width != '' or
                    (self::programlisting and
                    starts-with($writing.mode, 'rl'))">
      <fo:block-container start-indent="0pt" end-indent="0pt">
        <xsl:if test="@width != ''">
          <xsl:attribute name="width">
            <xsl:value-of select="concat(@width, '*', $monospace.verbatim.font.width)"/>
          </xsl:attribute>
        </xsl:if>
        <!-- All known program code is left-to-right -->
        <xsl:if test="self::programlisting and
                      starts-with($writing.mode, 'rl')">
          <xsl:attribute name="writing-mode">lr-tb</xsl:attribute>
        </xsl:if>
        <xsl:copy-of select="$block.content"/>
      </fo:block-container>
    </xsl:when>
    <xsl:otherwise>
      <xsl:copy-of select="$block.content"/>
    </xsl:otherwise>
  </xsl:choose>

</xsl:template>


</xsl:stylesheet>