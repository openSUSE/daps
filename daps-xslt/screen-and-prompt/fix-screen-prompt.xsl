<?xml version="1.0" encoding="UTF-8"?>
<!--
  Fix screens with prompt

  Purpose:
    This stylesheet fixes unfortunate linebreaks between a <screen> and a <prompt> tag
    
  Input:
    DocBook 5 document

  Output:
    DocBook 5 document

-->
<xsl:stylesheet version="1.0"
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:d="http://docbook.org/ns/docbook"
  exclude-result-prefixes="d">
  
  <xsl:output method="xml" indent="no"/>
  <xsl:preserve-space elements="*"/>
  
  <!-- HILFS-VORLAGE: Entfernt führende Leerzeichen (ltrim) -->
  <xsl:template name="ltrim">
    <xsl:param name="text"/>
    <xsl:choose>
      <!-- Prüft auf die häufigsten Whitespace-Zeichen am Anfang -->
      <xsl:when test="starts-with($text, '&#x20;') or
        starts-with($text, '&#xA;') or
        starts-with($text, '&#xD;') or
        starts-with($text, '&#x9;')">
        <!-- Ruft sich selbst ohne das erste Zeichen erneut auf -->
        <xsl:call-template name="ltrim">
          <xsl:with-param name="text" select="substring($text, 2)"/>
        </xsl:call-template>
      </xsl:when>
      <xsl:otherwise>
        <!-- Gibt den Text aus, wenn kein Leerzeichen am Anfang steht -->
        <xsl:value-of select="$text"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>
  
  <!-- REGEL 1: Die "Identitätstransform" (Fallback für alles) -->
  <xsl:template match="@* | node()">
    <xsl:copy>
      <xsl:apply-templates select="@* | node()"/>
    </xsl:copy>
  </xsl:template>
  
  <!-- REGEL 2: Fall "prompt gefolgt von command" -->
  <xsl:template match="d:screen[d:prompt/following-sibling::*[1][self::d:command]]">
    <xsl:copy>
      <xsl:apply-templates select="node()[not(self::text() and normalize-space() = '')]"/>
    </xsl:copy>
  </xsl:template>
  
  <!-- REGEL 3 (NEU): Fall "prompt gefolgt von Text" -->
  <!-- Diese Regel zielt direkt auf den Text-Knoten selbst ab -->
  <xsl:template match="d:screen/text()[preceding-sibling::node()[1][self::d:prompt]]">
    <!-- Rufe die Hilfs-Vorlage auf, um die führenden Leerzeichen zu entfernen -->
    <xsl:call-template name="ltrim">
      <xsl:with-param name="text" select="."/>
    </xsl:call-template>
  </xsl:template>
  
</xsl:stylesheet>