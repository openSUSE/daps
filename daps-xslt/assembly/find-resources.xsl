<?xml version="1.0" encoding="UTF-8"?>
<!--
   Purpose:
     Find used resources in an assembly file.

   Input:
     DocBook 5 assembly

   Output:
     Plain text with all used resource files.

   Parameters:
     * "sep" (string, default "&#10;"): String to separate each filename
     * "structure.id" (string, default ''): May be used to select one structure
       among several to process
     * "header" (int/boolean, default  1): If enabled, the stylesheet creates
       a separate line starting with "#" and displays the ID of the structure

   References:
     * https://github.com/openSUSE/daps/issues/732

   Author:
     Tom Schraitle, 2025
-->
<xsl:stylesheet version="1.0" xmlns:d="http://docbook.org/ns/docbook"
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform">

  <xsl:output method="text" />
  <xsl:strip-space elements="d:structure d:module"/>


  <!-- ===== Keys -->
  <xsl:key name="id" match="*" use="@id | @xml:id" />

  <xsl:param name="sep">
    <xsl:text>&#10;</xsl:text>
  </xsl:param>


  <!-- ===== Parameters -->
  <xsl:param name="structure.id" select="''" />
  <xsl:param name="header" select="1" />

  
  <!-- ===== Disabled Templates  -->
  <xsl:template match="d:merge" />
  

  <!-- ===== Templates -->
  <xsl:template match="d:assembly">
    <xsl:choose>
      <xsl:when test="$structure.id != ''">
        <xsl:variable name="id.structure" select="key('id', $structure.id)" />
        <xsl:choose>
          <xsl:when test="count($id.structure) = 0">
            <xsl:message terminate="yes">
              <xsl:text>ERROR: structure.id param set to '</xsl:text>
              <xsl:value-of select="$structure.id" />
              <xsl:text>' but no element with that xml:id exists in assembly.</xsl:text>
            </xsl:message>
          </xsl:when>
          <xsl:when test="local-name($id.structure) != 'structure'">
            <xsl:message terminate="yes">
              <xsl:text>ERROR: structure.id param set to '</xsl:text>
              <xsl:value-of select="$structure.id" />
              <xsl:text>' but no structure with that xml:id exists in assembly.</xsl:text>
            </xsl:message>
          </xsl:when>
          <xsl:otherwise>
            <xsl:apply-templates select="key('id', $structure.id)" />
          </xsl:otherwise>
        </xsl:choose>
      </xsl:when>
      <xsl:otherwise>
        <!-- otherwise process the first structure -->
        <xsl:apply-templates select="d:structure[1]" />
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:template match="d:structure">
    <xsl:if test="$header">
      <xsl:text># structure/@xml:id=</xsl:text>
      <xsl:value-of select="concat(@xml:id, '&#10;')"/>
    </xsl:if>
    
    <xsl:apply-templates />
  </xsl:template>

  <xsl:template match="d:module[@resourceref] | d:structure[@resourceref]">
    <xsl:variable name="resource" select="key('id', @resourceref)" />
    <xsl:variable name="href" select="$resource/@href" />

    <xsl:choose>
      <xsl:when test="count($resource) = 0">
        <xsl:message terminate="yes">
          <xsl:text>ERROR: resourceref/@xml:id=</xsl:text>
          <xsl:value-of select="@resourceref" />
          <xsl:text> does not point to a resource. Typo?</xsl:text>
        </xsl:message>
      </xsl:when>
      <xsl:when test="$href = ''">
        <xsl:message terminate="yes">
          <xsl:text>ERROR: The resource/@xml:id=</xsl:text>
          <xsl:value-of select="@resourceref" />
          <xsl:text> does not have a href attribute</xsl:text>
        </xsl:message>
      </xsl:when>
      <xsl:otherwise>
        <xsl:value-of select="concat($href, $sep)" />
      </xsl:otherwise>
    </xsl:choose>
    <xsl:apply-templates select="d:module" />
  </xsl:template>

</xsl:stylesheet>
