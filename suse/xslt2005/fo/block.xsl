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
  <xsl:choose>
    <xsl:when test=". = '' or . = 'suse2005'">
      <xsl:message>Creating a manual page break.</xsl:message>
      <xsl:if test=". = ''">
        <xsl:message>(!) Add suse2005 to the processing instruction to limit this page break to this version of the SUSE stylesheets.</xsl:message>
      </xsl:if>
      <fo:block page-break-after="always"/>
    </xsl:when>
    <xsl:otherwise/>
  </xsl:choose>
</xsl:template>

</xsl:stylesheet>
