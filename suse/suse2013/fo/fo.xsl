<?xml version="1.0" encoding="UTF-8"?>
<!--
  Purpose:
    It's not completely clear to me why we need to replace the "dingbat"
    template – we should be fine simply setting $dingbat.font.family="''".
    However, in Saxon, that does not seem to work together with the template
    from the original stylesheets (which is essentially the same template).
    Xsltproc does not seem to exhibit this bug. Hurray.

    To check for the bug: build e.g. the DAPS(TM) User Guide. Note, how in the
    footer, the TM-mark appears to be in the wrong (a serifed) font.

  Authors:    Thomas Schraitle <toms@opensuse.org>,
              Stefan Knorr <sknorr@suse.de>
  Copyright:  2013, Thomas Schraitle, Stefan Knorr

-->
<xsl:stylesheet version="1.0"
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform">

<xsl:template name="dingbat">
  <xsl:param name="dingbat">bullet</xsl:param>
  <xsl:variable name="symbol">
    <xsl:choose>
      <xsl:when test="$dingbat='bullet'">o</xsl:when>
      <xsl:when test="$dingbat='copyright'">&#x00A9;</xsl:when>
      <xsl:when test="$dingbat='trademark'">&#x2122;</xsl:when>
      <xsl:when test="$dingbat='trade'">&#x2122;</xsl:when>
      <xsl:when test="$dingbat='registered'">&#x00AE;</xsl:when>
      <xsl:when test="$dingbat='service'">(SM)</xsl:when>
      <xsl:when test="$dingbat='ldquo'">"</xsl:when>
      <xsl:when test="$dingbat='rdquo'">"</xsl:when>
      <xsl:when test="$dingbat='lsquo'">'</xsl:when>
      <xsl:when test="$dingbat='rsquo'">'</xsl:when>
      <xsl:when test="$dingbat='em-dash'">&#x2014;</xsl:when>
      <xsl:when test="$dingbat='en-dash'">-</xsl:when>
      <xsl:otherwise>o</xsl:otherwise>
    </xsl:choose>
  </xsl:variable>

<xsl:copy-of select="$symbol"/>

</xsl:template>

</xsl:stylesheet>
