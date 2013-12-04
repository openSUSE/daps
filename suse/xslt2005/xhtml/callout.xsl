<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0"
	xmlns="http://www.w3.org/1999/xhtml"
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:exsl="http://exslt.org/common"
	xmlns:t="http://nwalsh.com/docbook/xsl/template/1.0"
	exclude-result-prefixes="exsl">


<!-- 
   Create anchor and insert the callout image/charachter inside the
   <a> element.
-->
<xsl:template match="co" name="co">
   <!-- Support a single linkend in HTML -->
  <xsl:variable name="targets" select="key('id', @linkends)"/>
  <xsl:variable name="target" select="$targets[1]"/>
  
  <xsl:choose>
    <xsl:when test="$target">
      <a>
        <xsl:apply-templates select="." mode="common.html.attributes"/>
        <xsl:if test="@id or @xml:id">
          <xsl:attribute name="id">
            <xsl:value-of select="(@id|@xml:id)[1]"/>
          </xsl:attribute>
        </xsl:if>
        <xsl:attribute name="href">
          <xsl:call-template name="href.target">
            <xsl:with-param name="object" select="$target"/>
          </xsl:call-template>
        </xsl:attribute>
        <xsl:apply-templates select="." mode="callout-bug"/>
      </a>
    </xsl:when>
    <xsl:otherwise>
      <xsl:call-template name="anchor">
         <xsl:with-param name="insertnode">
               <xsl:apply-templates select="." mode="callout-bug"/>
         </xsl:with-param>
      </xsl:call-template>
    </xsl:otherwise>
  </xsl:choose>
</xsl:template>

</xsl:stylesheet>