<?xml version="1.0" encoding="ASCII"?>
<!-- 
   Purpose:  Contains customizations for admonition elements like note,
             tip, caution etc.
-->

<xsl:stylesheet version="1.0"
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns="http://www.w3.org/1999/xhtml">


<xsl:template name="graphical.admonition">
  <xsl:variable name="admon.type">
    <xsl:choose>
      <xsl:when test="local-name(.)='note'">Note</xsl:when>
      <xsl:when test="local-name(.)='warning'">Warning</xsl:when>
      <xsl:when test="local-name(.)='caution'">Caution</xsl:when>
      <xsl:when test="local-name(.)='tip'">Tip</xsl:when>
      <xsl:when test="local-name(.)='important'">Important</xsl:when>
      <xsl:otherwise>Note</xsl:otherwise>
    </xsl:choose>
  </xsl:variable>

  <div class="{name(.)}">
    <xsl:if test="$admon.style != ''">
      <xsl:attribute name="style">
        <xsl:value-of select="$admon.style"/>
      </xsl:attribute>
    </xsl:if>

    <table border="0" cellpadding="3" cellspacing="0" width="100%">
      <xsl:attribute name="summary">
        <xsl:value-of select="$admon.type"/>
        <xsl:if test="title">
          <xsl:text>: </xsl:text>
          <xsl:value-of select="title"/>
        </xsl:if>
      </xsl:attribute>
      <tr class="head">
        <td><!-- ***  -->
          <xsl:attribute name="width">
            <!--<xsl:apply-templates mode="admon.graphic.width"/>-->
            <xsl:value-of select="$admon.graphic.width"/>
          </xsl:attribute>
          <img alt="[{$admon.type}]">
            <xsl:attribute name="src">
              <xsl:call-template name="admon.graphic"/>
            </xsl:attribute>
          </img>
        </td>
        <th align="left">
          <xsl:call-template name="anchor"/>
          <xsl:if test="$admon.textlabel != 0 or title">
            <xsl:apply-templates select="title" mode="object.title.markup"/>
          </xsl:if>
        </th>
      </tr>
      <tr>
        <td colspan="2" align="left" valign="top">
          <xsl:apply-templates/>
        </td>
      </tr>
    </table>
  </div>
</xsl:template>

<xsl:template name="nongraphical.admonition">
  <div>
    <xsl:apply-templates select="." mode="class.attribute"/>
    <xsl:if test="$admon.style">
      <xsl:attribute name="style">
        <xsl:value-of select="$admon.style"/>
      </xsl:attribute>
    </xsl:if>

    <xsl:if test="$admon.textlabel != 0 or title or info/title">
      <h3 class="title">
        <xsl:call-template name="anchor"/>
        <xsl:message>nongraphical-admon-title: <xsl:value-of select="title"/> <xsl:value-of select="boolean(processing-instruction('suse'))"/></xsl:message>
        <xsl:apply-templates select="title" mode="object.title.markup"/>
      </h3>
    </xsl:if>

    <xsl:apply-templates/>
  </div>
</xsl:template>

<xsl:template match="note/title| 
                     important/title|
                     warning/title|
                     caution/title|
                     tip/title" mode="object.title.markup">
  <xsl:apply-templates/>
</xsl:template>

  
</xsl:stylesheet>
