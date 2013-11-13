<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0"
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
  
  <xsl:import href="http://docbook.sourceforge.net/release/xsl/current/lib/lib.xsl"/>
  <xsl:import href="http://docbook.sourceforge.net/release/xsl/current/common/pi.xsl"/>
  <xsl:import href="http://docbook.sourceforge.net/release/xsl/current/common/l10n.xsl"/>

  <xsl:import href="../common/rootid.xsl"/>
  
  <xsl:output method="text"/>
  
  <xsl:param name="l10n.gentext.language"/>
  <xsl:param name="l10n.gentext.use.xref.language" select="0"/>
  <xsl:param name="l10n.lang.value.rfc.compliant" select="1"/>
  
  <xsl:param name="linebreak" select="0"/>
  <xsl:param name="exsl.node.set.available">
  <xsl:choose>
    <xsl:when xmlns:exsl="http://exslt.org/common" exsl:foo="" 
      test="function-available('exsl:node-set') or contains(system-property('xsl:vendor'), 'Apache Software Foundation')">1</xsl:when>
    <xsl:otherwise>0</xsl:otherwise>
  </xsl:choose>
</xsl:param>
  
  <xsl:template match="text()"/>
  
  <xsl:template match="processing-instruction('dbjsp')">
    <xsl:variable name="pi-dir">
      <xsl:call-template name="pi-attribute">
        <xsl:with-param name="pis" select="."/>
        <xsl:with-param name="attribute">dir</xsl:with-param>
      </xsl:call-template>
    </xsl:variable>
    
    <xsl:if test="$pi-dir != ''">
      <xsl:value-of select="$pi-dir"/>
      <xsl:if test="$linebreak != 0">
        <xsl:text>&#10;</xsl:text>
      </xsl:if>
    </xsl:if>
  </xsl:template>
  
  <xsl:template match="processing-instruction('dbtimestamp')"/>
  
</xsl:stylesheet>