<?xml version="1.0"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
   version="1.0">

   <xsl:output method="text"/>

<!-- this stylesheets extracts all ids -->
<xsl:param name="separator" select="' '"/>
<xsl:param name="endseparator" select="'&#10;'"/>


<xsl:template match="text()"/>


<xsl:template match="/">
   <xsl:apply-templates />
</xsl:template>


<xsl:template match="*[@id]">
   <xsl:value-of select="concat(name(.), $separator)"/>
   <xsl:call-template name="getid"/>
   <xsl:apply-templates />
</xsl:template>


<xsl:template match="article|book|part|chapter|appendix|preface|glossary|
                    sect1|sect2|sect3|sect4">

   <xsl:choose>
      <xsl:when test="@id">
            <xsl:value-of select="concat(name(.), $separator)"/>
            <xsl:call-template name="getid"/>
            <xsl:apply-templates />
      </xsl:when>
      <xsl:otherwise>
         <xsl:value-of select="concat(name(.),
                               $separator,
                               '**Missing ID**',
                               $separator)"/>
         <xsl:call-template name="gettitle"/>
         <xsl:value-of select="$endseparator"/>
         <xsl:apply-templates />
      </xsl:otherwise>
   </xsl:choose>
</xsl:template>


<xsl:template match="procedure|example|table|variablelist|itemizedlist|orderedlist">
   <xsl:choose>
      <xsl:when test="@id">
            <xsl:value-of select="concat(name(.), $separator)"/>
            <xsl:call-template name="getid"/>
            <xsl:call-template name="gettitle"/>
            <xsl:value-of select="$endseparator"/>
            <xsl:apply-templates />
      </xsl:when>
      <xsl:otherwise>
      </xsl:otherwise>
   </xsl:choose>
</xsl:template>


<!-- ****************************************** -->
<xsl:template name="getid">
   <xsl:param name="node" select="."/>

   <xsl:value-of select="concat($node/@id, $separator)"/>
   <xsl:call-template name="gettitle"/>
   <xsl:value-of select="$endseparator"/>
</xsl:template>


<xsl:template name="gettitle">
   <xsl:param name="node" select="."/>

   <xsl:choose>
      <xsl:when test="$node/self::chapter or
                      $node/self::preface or
                      $node/self::appendix or
                      $node/self::glossary or
                      $node/self::example or
                      $node/self::figure or
                      $node/self::table or
                      $node/self::sect1 or
                      $node/self::sect2 or
                      $node/self::sect3 or
                      $node/self::sect4
                      ">
         <xsl:value-of select="concat('&quot;', normalize-space(title), '&quot;')"/>
      </xsl:when>
      <xsl:otherwise>
      </xsl:otherwise>
   </xsl:choose>

</xsl:template>

</xsl:stylesheet>