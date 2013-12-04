<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0"
	xmlns="http://www.w3.org/1999/xhtml"
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:exsl="http://exslt.org/common"
	xmlns:t="http://nwalsh.com/docbook/xsl/template/1.0"
	exclude-result-prefixes="exsl">

<!-- 
   Extended its behaviour with "insertnode". Needed to copy anything
   from insertnode into the <a> element.
   This is needed to create valid XHTML <a> tags inside <pre>.
-->
   <xsl:template name="anchor">
      <xsl:param name="node" select="."/>
      <xsl:param name="conditional" select="1"/>
      <xsl:param name="insertnode"/>
      <xsl:variable name="id">
         <xsl:call-template name="object.id">
            <xsl:with-param name="object" select="$node"/>
         </xsl:call-template>
      </xsl:variable>
      <xsl:if test="not($node[parent::blockquote])">
         <xsl:if test="$conditional = 0 or $node/@id or $node/@xml:id">
            <a id="{$id}"><xsl:copy-of select="$insertnode"/></a>
         </xsl:if>
      </xsl:if>
   </xsl:template>

</xsl:stylesheet>