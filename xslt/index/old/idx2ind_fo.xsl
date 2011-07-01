<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE xsl:stylesheet [
  <!ENTITY db "http://docbook.sourceforge.net/release/xsl/current">
]>
<xsl:stylesheet version="1.0"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform">

<!--
    This stylesheet works only with Saxon.
    It generates from the structure the sorted index entries.
-->

<xsl:import href="&db;/fo/docbook.xsl"/>
<xsl:import href="../fo/param.xsl"/>
<xsl:import href="&db;/fo/autoidx-kosek.xsl"/>

<!-- Set some important parameters: -->
<xsl:param name="index.method">kosek</xsl:param>
<xsl:param name="generate.index">1</xsl:param>

<xsl:template match="/">
    <xsl:variable name="rootidname">
     <xsl:choose>
        <xsl:when test="name(key('id', $rootid))">
           <xsl:value-of select="name(key('id', $rootid))"/>
        </xsl:when>
        <xsl:otherwise>
           <xsl:value-of select="name(/*)"/>
        </xsl:otherwise>
     </xsl:choose>
    </xsl:variable>
    
       <xsl:if test="$use.xep.cropmarks != 0 and $xep.extensions != 0">
    <xsl:processing-instruction
      name="xep-pdf-crop-offset">1cm</xsl:processing-instruction>
    <xsl:processing-instruction
      name="xep-pdf-bleed">3.5mm</xsl:processing-instruction>
    <xsl:processing-instruction
      name="xep-pdf-crop-mark-width">0.5pt</xsl:processing-instruction>
   </xsl:if>

   <xsl:if test="$xep.extensions != 0">
     <xsl:processing-instruction
     name="xep-pdf-view-mode">show-bookmarks</xsl:processing-instruction>
   </xsl:if>


     <xsl:choose>
        <xsl:when test="$rootid != ''">
          <xsl:variable name="root.element" select="key('id', $rootid)"/>
          <xsl:choose>
            <xsl:when test="count($root.element) = 0">
              <xsl:message terminate="yes">
                <xsl:text>ID '</xsl:text>
                <xsl:value-of select="$rootid"/>
                <xsl:text>' not found in document.</xsl:text>
              </xsl:message>
            </xsl:when>
            <xsl:when test="not(contains($root.elements, concat(' ', local-name($root.element), ' ')))">
              <xsl:message terminate="yes">
                <xsl:text>ERROR: Document root element ($rootid=</xsl:text>
                <xsl:value-of select="$rootid"/>
                <xsl:text>) for FO output </xsl:text>
                <xsl:text>must be one of the following elements:</xsl:text>
                <xsl:value-of select="$root.elements"/>
              </xsl:message>
            </xsl:when>
            <!-- Otherwise proceed -->
            <xsl:otherwise>
              <xsl:message>Generating index...</xsl:message>
              <xsl:if test="$collect.xref.targets = 'yes' or
                            $collect.xref.targets = 'only'">
                <!--<xsl:apply-templates select="$root.element/index[1]"
                                     mode="collect.targets"/>-->
              </xsl:if>
              <xsl:if test="$collect.xref.targets != 'only'">
                <xsl:apply-templates select="$root.element/index[1]"
                                     mode="process.root"/>
              </xsl:if>
              <xsl:message>Finished index generating.</xsl:message>
            </xsl:otherwise>
          </xsl:choose>
        </xsl:when>
        <!-- Otherwise process the document root element -->
        <xsl:otherwise>
          <xsl:variable name="document.element" select="*[1]"/>
          <xsl:choose>
            <xsl:when test="not(contains($root.elements,
                     concat(' ', local-name($document.element), ' ')))">
              <xsl:message terminate="yes">
                <xsl:text>ERROR: Document root element for FO output </xsl:text>
                <xsl:text>must be one of the following elements:</xsl:text>
                <xsl:value-of select="$root.elements"/>
              </xsl:message>
            </xsl:when>
            <!-- Otherwise proceed -->
            <xsl:otherwise>
              <!--<xsl:if test="$collect.xref.targets = 'yes' or
                            $collect.xref.targets = 'only'">
                <xsl:apply-templates select="/"
                                     mode="collect.targets"/>
              </xsl:if>
              <xsl:if test="$collect.xref.targets != 'only'">
                <xsl:apply-templates select="/"
                                     mode="process.root"/>
              </xsl:if>-->
            </xsl:otherwise>
          </xsl:choose>
        </xsl:otherwise>
      </xsl:choose>

</xsl:template>

</xsl:stylesheet>