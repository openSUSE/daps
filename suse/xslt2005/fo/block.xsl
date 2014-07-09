<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0"
  xmlns:fo="http://www.w3.org/1999/XSL/Format"
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform" >

<xsl:template match="formalpara/title|formalpara/info/title">
  <xsl:variable name="titleStr">
      <xsl:apply-templates/>
  </xsl:variable>
  <xsl:variable name="lastChar">
    <xsl:if test="$titleStr != ''">
      <xsl:value-of select="substring($titleStr,string-length($titleStr),1)"/>
    </xsl:if>
  </xsl:variable>

  <fo:inline font-weight="bold"
             keep-with-next.within-line="always"
             padding-end=".25em">
    <xsl:copy-of select="$titleStr"/>
    <xsl:if test="$lastChar != ''
                  and not(contains($runinhead.title.end.punct, $lastChar))">
      <xsl:value-of select="$runinhead.default.title.end.punct"/>
    </xsl:if>
    <xsl:text>&#160;</xsl:text>
  </fo:inline>
</xsl:template>


<!-- Generate a manual page break. -->
<xsl:template match="processing-instruction('pdfpagebreak')">
  <xsl:param name="arguments" select="."/>
  <xsl:param name="selected-stylesheets">
    <xsl:choose>
      <xsl:when test="contains($arguments, 'style=&quot;')">
        <xsl:value-of select="normalize-space(substring-before(substring-after($arguments, 'style=&quot;'), '&quot;'))"/>
      </xsl:when>
      <xsl:otherwise>any</xsl:otherwise>
    </xsl:choose>
  </xsl:param>
  <xsl:param name="selected-formatter">
    <xsl:choose>
      <xsl:when test="contains($arguments, 'formatter=&quot;')">
        <xsl:value-of select="normalize-space(substring-before(substring-after($arguments, 'formatter=&quot;'), '&quot;'))"/>
      </xsl:when>
      <xsl:otherwise>any</xsl:otherwise>
    </xsl:choose>
  </xsl:param>
  <xsl:param name="these-stylesheets">
    <xsl:choose>
      <xsl:when test="$selected-stylesheets = 'any' or
                      $selected-stylesheets = $name-stylesheets">
        <xsl:text>1</xsl:text>
      </xsl:when>
      <xsl:otherwise>0</xsl:otherwise>
    </xsl:choose>
  </xsl:param>
  <xsl:param name="this-formatter">
    <xsl:choose>
      <xsl:when test="$selected-formatter = 'any' or
                      ($selected-formatter = 'fop' and $fop1.extensions = 1) or
                      ($selected-formatter = 'xep' and $xep.extensions = 1)">
        <xsl:text>1</xsl:text>
      </xsl:when>
      <xsl:otherwise>0</xsl:otherwise>
    </xsl:choose>
  </xsl:param>

  <xsl:if test="$this-formatter = 1 and $these-stylesheets = 1">
      <xsl:message>Creating a manual page break.</xsl:message>
      <xsl:if test="$selected-stylesheets = 'any'">
        <xsl:message>(!) Use style="<xsl:value-of select="$STYLE.ID"/>" to limit this page break to these stylesheets.</xsl:message>
      </xsl:if>
      <xsl:if test="$selected-formatter = 'any'">
        <xsl:message>(!) Use formatter="<xsl:choose>
            <xsl:when test="$fop1.extensions = 1">fop</xsl:when>
            <xsl:when test="$xep.extensions = 1">xep</xsl:when>
            <xsl:otherwise>???</xsl:otherwise>
          </xsl:choose>" to limit this page break to this formatter.</xsl:message>
      </xsl:if>
      <fo:block page-break-after="always"/>
  </xsl:if>
</xsl:template>

</xsl:stylesheet>
