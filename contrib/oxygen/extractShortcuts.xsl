<?xml version="1.0" encoding="UTF-8"?>
<!--
  Creates a list of all shortcuts as HTML output

  Run it as:
  xsltproc -o shortcuts_oxygen.html PATH_TO_NOVDOC/xslt/oxygen/extractShortcuts.xsl ~/.com.oxygenxml/optionsSa7.1.xml

-->
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0">
  <xsl:template match="/">
    <table border="1">
      <xsl:apply-templates select="//entry"/>
    </table>
  </xsl:template>
  <xsl:template match="entry[String='accel.tags']">
    <xsl:for-each select="String-array/String">
      <xsl:variable name="pos" select="position()"/>
      <xsl:variable name="key" select="../../../entry[String='accel.ks']/String-array/*[self::String or self::null][$pos]"/>
      <!-- Remove the xsl:if below to get also the actions without a shortcut -->
      <xsl:if test="$key!=''">
        <tr>
          <td><xsl:value-of select="."/></td>
          <td><xsl:value-of select="$key"/></td>
        </tr>
      </xsl:if>
    </xsl:for-each>
  </xsl:template>
  <xsl:template match="*"/>
</xsl:stylesheet>
