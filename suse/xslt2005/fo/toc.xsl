<?xml version="1.0" encoding="UTF-8"?>
<!-- $Id: toc.xsl 43787 2009-08-25 13:31:36Z toms $ -->
<xsl:stylesheet version="1.0"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:fo="http://www.w3.org/1999/XSL/Format">


<xsl:template name="set.toc.indent">
  <xsl:param name="reldepth"/>
  <xsl:variable name="toc.depth" select="3"/>

  <xsl:variable name="depth">
    <xsl:choose>
      <xsl:when test="$reldepth != ''">
        <xsl:value-of select="$reldepth"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:value-of select="count(ancestor::*) -$toc.depth"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:variable>

  <!--<xsl:message>set.toc.indent <xsl:value-of
    select="concat('(',local-name(),'): ', $depth)"/></xsl:message>-->

  <xsl:choose>
    <xsl:when test="$depth &lt;= 0">0pt</xsl:when>
    <xsl:when test="$fop.extensions != 0 or $passivetex.extensions != 0">
       <xsl:value-of select="concat($depth*$toc.indent.width, 'pt')"/>
    </xsl:when>
    <xsl:otherwise>
      <xsl:value-of select="concat($toc.indent.width, 'pt')"/>
    </xsl:otherwise>
  </xsl:choose>
</xsl:template>

<xsl:template name="toc.line">
  <xsl:param name="toc-context" select="NOTANODE"/>

  <xsl:variable name="id">
    <xsl:call-template name="object.id"/>
  </xsl:variable>

  <xsl:variable name="label">
    <xsl:apply-templates select="." mode="label.markup"/>
  </xsl:variable>

  <fo:block xsl:use-attribute-sets="toc.line.properties">
    <fo:inline keep-with-next.within-line="always">
      <fo:basic-link internal-destination="{$id}">
        <xsl:if test="$label != ''">
          <xsl:copy-of select="$label"/>
          <xsl:value-of select="$autotoc.label.separator"/>
        </xsl:if>
        <xsl:apply-templates select="." mode="titleabbrev.markup"/>
      </fo:basic-link>
    </fo:inline>
    <fo:inline keep-together.within-line="always">
      <xsl:text> </xsl:text>
      <fo:leader 
                 leader-pattern-width="3pt"
                 leader-length.minimum="0pt"
                 leader-alignment="reference-area"
                 keep-with-next.within-line="always">
      <xsl:attribute name="leader-pattern">
        <xsl:choose>
          <xsl:when test="self::part or 
                          self::chapter or 
                          self::appendix or 
                          self::preface">space</xsl:when>
          <xsl:otherwise>dots</xsl:otherwise>
        </xsl:choose>
      </xsl:attribute>
      </fo:leader>
      <xsl:text> </xsl:text> 
      <fo:basic-link internal-destination="{$id}">
        <fo:page-number-citation ref-id="{$id}"/>
      </fo:basic-link>
    </fo:inline>
  </fo:block>
</xsl:template>


</xsl:stylesheet>
