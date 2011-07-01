<?xml version="1.0" encoding="UTF-8"?>
<!-- 

-->
<xsl:stylesheet version="1.0"
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform">

  <xsl:key name="id" match="*" use="@id|@xml:id"/>
  <xsl:param name="rootid"/>
  <!-- Controls some log messages: 0=off, 1=on -->
  <xsl:param name="rootid.debug" select="0"/>

  <xsl:template match="/" name="process.rootid.node">
    <xsl:choose>
      <xsl:when test="$rootid !=''">
        <xsl:if test="count(key('id',$rootid)) = 0">
          <xsl:message terminate="yes">
            <xsl:text>ID '</xsl:text>
            <xsl:value-of select="$rootid"/>
            <xsl:text>' not found in document.</xsl:text>
          </xsl:message>
        </xsl:if>
        <xsl:call-template name="rootid.debug.message"/>
        <xsl:call-template name="rootid.process"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:call-template name="normal.process"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:template name="rootid.debug.message">
    <xsl:if test="$rootid.debug != 0">
      <xsl:message>
        <xsl:text>Using ID </xsl:text>
        <xsl:value-of select="concat('&quot;', $rootid, '&quot;')"/>
      </xsl:message>
    </xsl:if>
  </xsl:template>
  
  <xsl:template name="rootid.process">
    <xsl:apply-templates select="key('id',$rootid)"/>
  </xsl:template>

  <xsl:template name="normal.process">
    <xsl:apply-templates/>
  </xsl:template>
  
</xsl:stylesheet>
