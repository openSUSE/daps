<?xml version="1.0" encoding="UTF-8"?>
<!--
  Purpose:
    Contains all attribute sets for XSL-FO.
    (Sorted against the list in "Part 2. FO Parameter Reference" in
    the DocBook XSL Stylesheets User Reference, see link below)

    See Also:
    * http://docbook.sourceforge.net/release/xsl/current/doc/fo/index.html

  Author(s):  Stefan Knorr <sknorr@suse.de>
              Thomas Schraitle <toms@opensuse.org>

  Copyright:  2013, Stefan Knorr, Thomas Schraitle

-->
<!DOCTYPE xsl:stylesheets 
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

<!-- 1. Admonitions  ============================================ -->

<xsl:attribute-set name="admonition.title.properties">
  <xsl:attribute name="font-family"><xsl:value-of select="$title.font.family"/></xsl:attribute>
  <xsl:attribute name="font-size">&x-large;pt</xsl:attribute>
  <xsl:attribute name="font-weight">600</xsl:attribute>
  <xsl:attribute name="hyphenate">false</xsl:attribute>
  <xsl:attribute name="keep-with-next.within-column">always</xsl:attribute>
</xsl:attribute-set>


<!-- 2. Callouts ================================================ -->


<!-- 3. ToC/LoT/Index Generation ================================ -->


<!-- 4. Processor Extensions ==================================== -->


<!-- 5. Stylesheet Extensions =================================== -->


<!-- 6. Automatic labelling ===================================== -->


<!-- 7. XSLT Processing  ======================================== -->


<!-- 8. Meta/*Info ============================================== -->


<!-- 9. Reference Pages ========================================= -->


<!-- 10. Tables ================================================= -->


<!-- 11. Linking ================================================ -->


<!-- 12. Cross References ======================================= -->


<!-- 13. Lists ================================================== -->

<xsl:attribute-set name="variablelist.term.properties">
  <xsl:attribute name="font-weight">600</xsl:attribute>
  <xsl:attribute name="font-family"><xsl:value-of select="$sans.font.family"/></xsl:attribute>
</xsl:attribute-set>


<!-- 14. QAndASet =============================================== -->


<!-- 15. Bibliography =========================================== -->


<!-- 16. Glossary =============================================== -->

<xsl:attribute-set name="glossterm.block.properties">
  <xsl:attribute name="font-weight">600</xsl:attribute>
  <xsl:attribute name="font-family"><xsl:value-of select="$sans.font.family"/></xsl:attribute>
</xsl:attribute-set>


<!-- 17. Miscellaneous ========================================== -->

<xsl:variable name="verbatim-start-end-indent">
  <!-- XEP does not allow adding a length value to the result of a core
       function -->
  inherited-property-value()
  <xsl:if test="$xep.extensions = 0">+ 0.5em</xsl:if>
</xsl:variable>

<xsl:attribute-set name="shade.verbatim.style">
  <xsl:attribute name="background-color">&light-gray-old;</xsl:attribute>
  <xsl:attribute name="padding">0.5em</xsl:attribute>
  <xsl:attribute name="start-indent"><xsl:value-of select="$verbatim-start-end-indent"/>
  </xsl:attribute>
  <xsl:attribute name="end-indent"><xsl:value-of select="$verbatim-start-end-indent"/>
  </xsl:attribute>
</xsl:attribute-set>


<!-- 18. Graphics =============================================== -->


<!-- 19. Pagination and General Styles ========================== -->

<xsl:attribute-set name="footer.content.properties">
  <xsl:attribute name="font-family">
    <xsl:value-of select="$sans.font.family"/>, <xsl:value-of select="$symbol.font.family"/>
  </xsl:attribute>
  <xsl:attribute name="font-size">
    <xsl:text>&small;pt</xsl:text>
  </xsl:attribute>
  <xsl:attribute name="margin-left">
    <xsl:value-of select="$title.margin.left"/>
  </xsl:attribute>
</xsl:attribute-set>


<!-- 20. Font Families ========================================== -->


<!-- 21. Property Sets ========================================== -->

<xsl:variable name="hook">
  <xsl:choose>
    <xsl:when test="$fop1.extensions != 0">&#160;</xsl:when>
      <!-- FOP doesn't like either " " or "&#32;" – no-break space works however-->
    <xsl:otherwise>&#8617;</xsl:otherwise>
  </xsl:choose>
</xsl:variable>

<xsl:attribute-set name="monospace.verbatim.properties" use-attribute-sets="verbatim.properties monospace.properties">
  <xsl:attribute name="text-align">start</xsl:attribute>
  <xsl:attribute name="wrap-option">wrap</xsl:attribute>
  <xsl:attribute name="hyphenation-character"><xsl:value-of select="$hook"/></xsl:attribute>
  <xsl:attribute name="font-size">&small;pt</xsl:attribute>
</xsl:attribute-set>

<xsl:attribute-set name="section.title.properties">
  <xsl:attribute name="font-family">
    <xsl:value-of select="$title.fontset"></xsl:value-of>
  </xsl:attribute>
  <xsl:attribute name="font-weight">normal</xsl:attribute>
  <xsl:attribute name="keep-with-next.within-column">always</xsl:attribute>
  <xsl:attribute name="space-before.minimum">2.8em</xsl:attribute>
  <xsl:attribute name="space-before.optimum">3.0em</xsl:attribute>
  <xsl:attribute name="space-before.maximum">3.2em</xsl:attribute>
  <xsl:attribute name="space-after.minimum">0.5em</xsl:attribute>
  <xsl:attribute name="space-after.optimum">0.7em</xsl:attribute>
  <xsl:attribute name="space-after.maximum">0.9em</xsl:attribute>
  <xsl:attribute name="text-align">start</xsl:attribute>
  <xsl:attribute name="start-indent"><xsl:value-of select="$title.margin.left"></xsl:value-of></xsl:attribute>
</xsl:attribute-set>

<xsl:attribute-set name="section.title.level1.properties">
  <xsl:attribute name="font-size">&xxx-large;pt</xsl:attribute>
</xsl:attribute-set>
<xsl:attribute-set name="section.title.level2.properties">
  <xsl:attribute name="font-size">&xx-large;pt</xsl:attribute>
</xsl:attribute-set>
<xsl:attribute-set name="section.title.level3.properties">
  <xsl:attribute name="font-size">&x-large;pt</xsl:attribute>
</xsl:attribute-set>
<xsl:attribute-set name="section.title.level4.properties">
  <xsl:attribute name="font-size">&large;pt</xsl:attribute>
  <xsl:attribute name="font-weight">700</xsl:attribute>
</xsl:attribute-set>
<xsl:attribute-set name="section.title.level5.properties">
  <xsl:attribute name="font-size">&large;pt</xsl:attribute>
</xsl:attribute-set>
<xsl:attribute-set name="section.title.level6.properties">
  <xsl:attribute name="font-size">&normal;pt</xsl:attribute>
  <xsl:attribute name="font-weight">700</xsl:attribute>
</xsl:attribute-set>

<xsl:attribute-set name="formal.title.properties" use-attribute-sets="normal.para.spacing">
  <xsl:attribute name="font-family"><xsl:value-of select="$sans.font.family"/></xsl:attribute>
  <xsl:attribute name="font-weight">600</xsl:attribute>
  <xsl:attribute name="font-size">&small;pt</xsl:attribute>
  <xsl:attribute name="text-transform">uppercase</xsl:attribute>
  <xsl:attribute name="color">&dark-green;</xsl:attribute>
  <xsl:attribute name="hyphenate">false</xsl:attribute>
  <xsl:attribute name="space-after.minimum">0.4em</xsl:attribute>
  <xsl:attribute name="space-after.optimum">0.6em</xsl:attribute>
  <xsl:attribute name="space-after.maximum">0.8em</xsl:attribute>
</xsl:attribute-set>


<!-- 22. Profiling ============================================== -->


<!-- 23. Localization =========================================== -->


<!-- 24. EBNF =================================================== -->


<!-- 25. Prepress =============================================== -->


<!-- 26. Custom ================================================= -->
<xsl:attribute-set name="title.name.color">
  <xsl:attribute name="color">&dark-green;</xsl:attribute>
</xsl:attribute-set>

<xsl:attribute-set name="title.number.color">
  <xsl:attribute name="color">&mid-gray;</xsl:attribute>
</xsl:attribute-set>


</xsl:stylesheet>
