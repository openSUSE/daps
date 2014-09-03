<?xml version="1.0" encoding="UTF-8"?>
<!--
  Purpose:
    Some parameters need to change from language to language. To
    organize such properties, we created the l10n.properties.xml file.
    The get.l10n.property template reads any given property from this
    file.

  Author(s):  Stefan Knorr <sknorr@suse.de>
              Thomas Schraitle <toms@opensuse.org>

  Copyright:  2013, 2014, Stefan Knorr, Thomas Schraitle

-->
<!DOCTYPE xsl:stylesheet
[
  <!ENTITY % fonts SYSTEM "fonts.ent">
  <!ENTITY % colors SYSTEM "colors.ent">
  <!ENTITY % metrics SYSTEM "metrics.ent">
  %fonts;
  %colors;
  %metrics;
]>
<xsl:stylesheet version="1.0"
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:fo="http://www.w3.org/1999/XSL/Format">

  <xsl:variable name="properties" select="document('l10n.properties.xml')/properties"/>

  <!-- FIXME: We currently do not check whether the property type
       matches the type specified in <prop-types/> at all -->
  <xsl:template name="get.l10n.property">
    <xsl:param name="property"/>
    <xsl:param name="property.language" select="$document.language"/>

    <xsl:variable name="property-type">
      <xsl:choose>
        <xsl:when test="$properties/prop-types/prop-type/@name = $property">
          <xsl:value-of select="$properties/prop-types/prop-type[@name = $property]"/>
        </xsl:when>
        <xsl:otherwise>
          <xsl:message terminate="yes">(!!) The requested property <xsl:value-of select="$property"/> has no registered property type.</xsl:message>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:variable>
    <xsl:variable name="property-language-to-use">
      <xsl:choose>
        <xsl:when test="$properties/lang/@code = $property.language">
          <xsl:value-of select="$property.language"/>
        </xsl:when>
        <xsl:otherwise>default</xsl:otherwise>
      </xsl:choose>
    </xsl:variable>

    <xsl:choose>
      <xsl:when test="$properties/lang[@code = $property-language-to-use]/prop[@name = $property]">
        <xsl:variable name="xml-property"
          select="$properties/lang[@code = $property-language-to-use]/prop[@name = $property]"/>

        <xsl:choose>
          <xsl:when test="$xml-property[@ref-name] or $xml-property[@ref-lang]">
            <xsl:call-template name="get.l10n.property">
              <xsl:with-param name="property">
                <xsl:choose>
                  <xsl:when test="$xml-property/@ref-name">
                    <xsl:value-of select="$xml-property/@ref-name"/>
                  </xsl:when>
                  <xsl:otherwise>
                    <xsl:value-of select="$property"/>
                  </xsl:otherwise>
                </xsl:choose>
              </xsl:with-param>
              <xsl:with-param name="property.language">
                <xsl:choose>
                  <xsl:when test="$xml-property/@ref-lang">
                    <xsl:value-of select="$xml-property/@ref-lang"/>
                  </xsl:when>
                  <xsl:otherwise>
                    <xsl:value-of select="$property-language-to-use"/>
                  </xsl:otherwise>
                </xsl:choose>
              </xsl:with-param>
            </xsl:call-template>
          </xsl:when>
          <xsl:otherwise><xsl:value-of select="$xml-property"/></xsl:otherwise>
        </xsl:choose>

      </xsl:when>
      <xsl:when test="$properties/lang[@code = 'default']/prop[@name = $property]">
        <xsl:message>(!) The requested property <xsl:value-of select="$property"/> does not exist in the target language. Expected a <xsl:value-of select="'property-type'"/>. Using property of the default language.
        </xsl:message>

        <xsl:call-template name="get.l10n.property">
          <xsl:with-param name="property" select="$property"/>
          <xsl:with-param name="property.language" select="'default'"/>
        </xsl:call-template>
      </xsl:when>
      <xsl:otherwise>
        <xsl:message terminate="yes">(!) The requested property <xsl:value-of select="$property"/> does not exist. Expected a <xsl:value-of select="'property-type'"/>.
        </xsl:message>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

</xsl:stylesheet>
