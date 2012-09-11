<?xml version="1.0" encoding="UTF-8"?>

<xsl:stylesheet version="1.0"
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:exsl="http://exslt.org/common"
  xmlns="http://www.w3.org/1999/xhtml"
  exclude-result-prefixes="exsl">
 
<xsl:param name="formal.object.break.after">0</xsl:param>

<xsl:template name="formal.object.heading">
  <xsl:param name="object" select="."/>
  <xsl:param name="title">
<!--    <xsl:apply-templates select="$object" mode="object.title.markup">
      <xsl:with-param name="allow-anchors" select="1"/>
    </xsl:apply-templates>-->
    <xsl:call-template name="create.header.title">
      <xsl:with-param name="node" select="$object"/>
    </xsl:call-template>
  </xsl:param>
  
  <xsl:choose>
    <xsl:when test="$make.clean.html != 0">
      <xsl:variable name="html.class" select="concat(local-name($object),'-title')"/>
      <div class="{$html.class}">
        <xsl:copy-of select="$title"/>
      </div>
    </xsl:when>
    <xsl:otherwise>
      <p class="title">
          <xsl:copy-of select="$title"/>
      </p>
    </xsl:otherwise>
  </xsl:choose>
</xsl:template>
  

</xsl:stylesheet>
