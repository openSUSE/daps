<?xml version="1.0" encoding="UTF-8"?>
<!-- $Id: header.xsl 2158 2005-09-26 11:20:40Z toms $ -->
<!DOCTYPE xsl:stylesheet >
<xsl:stylesheet version="1.0"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:fo="http://www.w3.org/1999/XSL/Format">


<!-- ==================================================================== -->
<!-- Code below used to customize running headers                         -->

<xsl:template name="footer.content">
  <xsl:param name="pageclass" select="''"/>
  <xsl:param name="sequence" select="''"/>
  <xsl:param name="gentext-key" select="''"/>
  <xsl:param name="position" select="''"/>

<!--  <xsl:message>
    pageclass   = <xsl:value-of select="$pageclass"/>
    sequence    = <xsl:value-of select="$sequence"/>
    gentext-key = <xsl:value-of select="$gentext-key"/>
    position    = <xsl:value-of select="$position"/>
  </xsl:message>-->

  <fo:block>
  <xsl:choose>
    <xsl:when test="$position = 'center'">
      <fo:block font-size="{$body.font.master}pt">
        <xsl:if test="$fop1.extensions != 0">
          <xsl:attribute name="padding-top">-1em</xsl:attribute>
        </xsl:if>
        <fo:page-number/>
      </fo:block>
    </xsl:when>
    <!--<xsl:when test="$pageclass = 'titlepage'"/>-->
    <!--<xsl:when test="$sequence = 'odd' or $sequence = 'even'">
       <fo:page-number/>
    </xsl:when>-->
    <!--<xsl:when test="$sequence = 'odd' and $position = 'left'">
       <xsl:message> even/left</xsl:message>
       <fo:page-number/>
    </xsl:when>
    <xsl:when test="($sequence = 'odd' or $sequence = 'first') and $position='right'">
       <xsl:message> odd/right</xsl:message>
       <fo:page-number/>
    </xsl:when>-->
    <xsl:otherwise>
       <!-- nop -->
    </xsl:otherwise>
  </xsl:choose>
  </fo:block>
</xsl:template>

</xsl:stylesheet>