<?xml version="1.0" encoding="UTF-8"?>
<!-- $Id: admon.xsl 36288 2008-10-24 06:45:55Z toms $ -->
<!DOCTYPE xsl:stylesheet
[
  <!ENTITY lowercase "'abcdefghijklmnopqrstuvwxyz'">
  <!ENTITY uppercase "'ABCDEFGHIJKLMNOPQRSTUVWXYZ'">
]>

<xsl:stylesheet version="1.0"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:fo="http://www.w3.org/1999/XSL/Format" >

<xsl:template name="nongraphical.admonition">
  <xsl:variable name="id">
    <xsl:call-template name="object.id"/>
  </xsl:variable>

  <fo:block id="{$id}"
            xsl:use-attribute-sets="nongraphical.admonition.properties">
    <xsl:choose>
       <xsl:when test="$admon.textlabel != 0">
         <fo:block keep-with-next.within-column='always'
                  xsl:use-attribute-sets="admonition.title.properties">
            <xsl:call-template name="gentext">
               <xsl:with-param name="key" select="translate(name(.),
                                                  &lowercase;, &uppercase;)"/>
            </xsl:call-template>
            <xsl:if test="title">
              <xsl:call-template name="gentext">
               <xsl:with-param name="key" select="'admonseparator'"/>
              </xsl:call-template>
              <xsl:apply-templates select="title" mode="object.title.markup"/>
            </xsl:if>
         </fo:block>
       </xsl:when>
       <xsl:otherwise>
       <fo:block keep-with-next.within-column='always'
                xsl:use-attribute-sets="admonition.title.properties">
         <xsl:apply-templates select="." mode="object.title.markup"/>
      </fo:block>
      </xsl:otherwise>
    </xsl:choose>

    <fo:block xsl:use-attribute-sets="admonition.properties">
      <xsl:apply-templates/>
    </fo:block>
  </fo:block>
</xsl:template>


<xsl:template match="note/title|
                     important/title|
                     warning/title|
                     caution/title|
                     tip/title" mode="object.title.markup">
  <xsl:apply-templates />
</xsl:template>

</xsl:stylesheet>