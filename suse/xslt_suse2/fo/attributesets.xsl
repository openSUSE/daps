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

<!-- 1. Admonitions  ============================================ -->

<xsl:attribute-set name="admonition.title.properties"
  use-attribute-sets="sans.bold">
  <xsl:attribute name="font-family"><xsl:value-of select="$title.font.family"/></xsl:attribute>
  <xsl:attribute name="font-size">&x-large;pt</xsl:attribute>
  <xsl:attribute name="hyphenate">false</xsl:attribute>
  <xsl:attribute name="keep-with-next.within-column">always</xsl:attribute>
</xsl:attribute-set>

<xsl:attribute-set name="graphical.admonition.properties">
  <xsl:attribute name="space-before.optimum">1.5em</xsl:attribute>
  <xsl:attribute name="space-before.minimum">1.2em</xsl:attribute>
  <xsl:attribute name="space-before.maximum">1.7em</xsl:attribute>
  <xsl:attribute name="space-after.optimum">1.5em</xsl:attribute>
  <xsl:attribute name="space-after.minimum">1.2em</xsl:attribute>
  <xsl:attribute name="space-after.maximum">1.7em</xsl:attribute>
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

<xsl:attribute-set name="variablelist.term.properties"
  use-attribute-sets="sans.bold">
  <xsl:attribute name="font-family"><xsl:value-of select="$sans.font.family"/></xsl:attribute>
</xsl:attribute-set>

<xsl:attribute-set name="lists.label.properties" use-attribute-sets="dark-green">
  <xsl:attribute name="text-align">end</xsl:attribute>
</xsl:attribute-set>

<xsl:attribute-set name="orderedlist.label.properties"
  use-attribute-sets="lists.label.properties sans.bold">
  <xsl:attribute name="font-family"><xsl:value-of select="$sans-stack"/></xsl:attribute>
  <xsl:attribute name="font-size"><xsl:value-of select="1 * $fontsize-adjust * $sans-xheight-adjust"/>em</xsl:attribute>
  <xsl:attribute name="line-height"><xsl:value-of select="$base-lineheight * $sans-xheight-adjust"/>em</xsl:attribute>
</xsl:attribute-set>
<xsl:attribute-set name="itemizedlist.label.properties"
  use-attribute-sets="lists.label.properties">
</xsl:attribute-set>

<xsl:attribute-set name="list.block.properties">
  <xsl:attribute name="provisional-label-separation">&gutterfragment;mm</xsl:attribute>
  <xsl:attribute name="provisional-distance-between-starts">&columnfragment;mm</xsl:attribute>
</xsl:attribute-set>


<!-- 14. QAndASet =============================================== -->


<!-- 15. Bibliography =========================================== -->


<!-- 16. Glossary =============================================== -->

<xsl:attribute-set name="glossterm.block.properties"
  use-attribute-sets="sans.bold">
  <xsl:attribute name="font-family"><xsl:value-of select="$sans.font.family"/></xsl:attribute>
</xsl:attribute-set>


<!-- 17. Miscellaneous ========================================== -->

<xsl:variable name="verbatim-start-end-indent">
  <!-- XEP does not like adding a length value to the result of a core
       function – the result seems ok, though -->
  inherited-property-value() + 0.5em
</xsl:variable>

<xsl:attribute-set name="shade.verbatim.style">
  <xsl:attribute name="background-color">&extra-light-gray-old;</xsl:attribute>
  <xsl:attribute name="border">&thinline;mm solid &light-gray;</xsl:attribute>
  <xsl:attribute name="padding">0.5em</xsl:attribute>
  <xsl:attribute name="start-indent">
    <xsl:value-of select="$verbatim-start-end-indent"/>
  </xsl:attribute>
  <xsl:attribute name="end-indent">
    <xsl:value-of select="$verbatim-start-end-indent"/>
  </xsl:attribute>
  
</xsl:attribute-set>


<!-- 18. Graphics =============================================== -->


<!-- 19. Pagination and General Styles ========================== -->

<xsl:attribute-set name="footer.content.properties">
  <xsl:attribute name="font-family">
    <xsl:value-of select="$sans.font.family"/>
  </xsl:attribute>
  <xsl:attribute name="font-size">
    <xsl:text>&small;pt</xsl:text>
  </xsl:attribute>
  <xsl:attribute name="margin-left">
    <xsl:value-of select="$title.margin.left"/>
  </xsl:attribute>
</xsl:attribute-set>

<xsl:attribute-set name="para.properties" use-attribute-sets="normal.para.spacing">
    <xsl:attribute name="text-align">
      <xsl:choose>
        <!-- or ancestor::procedure or ancestor::orderedlist or
             ancestor::itemizedlist or ancestor::calloutlist ??-->
        <xsl:when test="ancestor::entry">start</xsl:when>
        <xsl:otherwise>inherit</xsl:otherwise>
      </xsl:choose>
    </xsl:attribute>
    <xsl:attribute name="line-height"><xsl:value-of select="$base-lineheight"/>em</xsl:attribute>
</xsl:attribute-set>


<!-- 20. Font Families ========================================== -->


<!-- 21. Property Sets ========================================== -->

<xsl:variable name="hook">
  <xsl:choose>
    <xsl:when test="$fop1.extensions != 0">&#160;</xsl:when>
      <!-- FOP doesn't like either " " or "&#32;" – no-break space works however. -->
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
<xsl:attribute-set name="section.title.level4.properties"
  use-attribute-sets="sans.bold">
  <xsl:attribute name="font-size">&large;pt</xsl:attribute>
</xsl:attribute-set>
<xsl:attribute-set name="section.title.level5.properties">
  <xsl:attribute name="font-size">&large;pt</xsl:attribute>
</xsl:attribute-set>
<xsl:attribute-set name="section.title.level6.properties"
  use-attribute-sets="sans.bold">
  <xsl:attribute name="font-size">&normal;pt</xsl:attribute>
</xsl:attribute-set>

<xsl:attribute-set name="formal.title.properties"
  use-attribute-sets="normal.para.spacing dark-green sans.bold">
  <xsl:attribute name="font-family"><xsl:value-of select="$sans.font.family"/></xsl:attribute>
  <xsl:attribute name="font-size">&small;pt</xsl:attribute>
  <xsl:attribute name="text-transform">uppercase</xsl:attribute>
  <xsl:attribute name="hyphenate">false</xsl:attribute>
  <xsl:attribute name="space-after.optimum">0.4em</xsl:attribute>
  <xsl:attribute name="space-after.optimum">0.6em</xsl:attribute>
  <xsl:attribute name="space-after.maximum">0.8em</xsl:attribute>
</xsl:attribute-set>


<!-- 22. Profiling ============================================== -->


<!-- 23. Localization =========================================== -->

<xsl:attribute-set name="serif.bold.noreplacement">
  <xsl:attribute name="font-weight">
    <xsl:choose>
      <xsl:when test="$enable-bold = 1">
        <xsl:choose>
          <xsl:when test="$enable-serif-semibold = 1">600</xsl:when>
          <xsl:otherwise>700</xsl:otherwise>
        </xsl:choose>
      </xsl:when>
      <xsl:otherwise>inherit</xsl:otherwise>
    </xsl:choose>
  </xsl:attribute>
</xsl:attribute-set>

<xsl:attribute-set name="serif.bold"  use-attribute-sets="serif.bold.noreplacement">
  <xsl:attribute name="background-color">
    <xsl:choose>
      <xsl:when test="$enable-bold != 1">&light-gray-old;</xsl:when>
      <xsl:otherwise>transparent</xsl:otherwise>
    </xsl:choose>
  </xsl:attribute>
</xsl:attribute-set>

<xsl:attribute-set name="sans.bold.noreplacement">
  <xsl:attribute name="font-weight">
    <xsl:choose>
      <xsl:when test="$enable-bold = 1">
        <xsl:choose>
          <xsl:when test="$enable-sans-semibold = 1">600</xsl:when>
          <xsl:otherwise>700</xsl:otherwise>
        </xsl:choose>
      </xsl:when>
      <xsl:otherwise>inherit</xsl:otherwise>
    </xsl:choose>
  </xsl:attribute>
</xsl:attribute-set>

<xsl:attribute-set name="sans.bold" use-attribute-sets="sans.bold.noreplacement">
  <xsl:attribute name="background-color">
    <xsl:choose>
      <xsl:when test="$enable-bold != 1">&light-gray-old;</xsl:when>
      <xsl:otherwise>transparent</xsl:otherwise>
    </xsl:choose>
  </xsl:attribute>
</xsl:attribute-set>

<xsl:attribute-set name="mono.bold.noreplacement">
  <xsl:attribute name="font-weight">
    <xsl:choose>
      <xsl:when test="$enable-bold = 1">
        <xsl:choose>
          <xsl:when test="$enable-mono-semibold = 1">600</xsl:when>
          <xsl:otherwise>700</xsl:otherwise>
        </xsl:choose>
      </xsl:when>
      <xsl:otherwise>inherit</xsl:otherwise>
    </xsl:choose>
  </xsl:attribute>
</xsl:attribute-set>

<xsl:attribute-set name="mono.bold" use-attribute-sets="mono.bold.noreplacement">
  <xsl:attribute name="background-color">
    <xsl:choose>
      <xsl:when test="$enable-bold != 1">&light-gray-old;</xsl:when>
      <xsl:otherwise>transparent</xsl:otherwise>
    </xsl:choose>
  </xsl:attribute>
</xsl:attribute-set>

<xsl:attribute-set name="italicized.noreplacement">
  <xsl:attribute name="font-weight">
    <xsl:choose>
      <xsl:when test="$enable-italic != 1">italic</xsl:when>
      <xsl:otherwise>normal</xsl:otherwise>
    </xsl:choose>
  </xsl:attribute>
</xsl:attribute-set>

<xsl:attribute-set name="italicized" use-attribute-sets="italicized.noreplacement">
  <xsl:attribute name="background-color">
    <xsl:choose>
      <xsl:when test="$enable-italic != 1">&light-gray-old;</xsl:when>
      <xsl:otherwise>transparent</xsl:otherwise>
    </xsl:choose>
  </xsl:attribute>
</xsl:attribute-set>

<!-- 24. EBNF =================================================== -->


<!-- 25. Prepress =============================================== -->


<!-- 26. Custom ================================================= -->
<xsl:attribute-set name="title.name.color" use-attribute-sets="dark-green">
</xsl:attribute-set>

<xsl:attribute-set name="title.number.color">
  <xsl:attribute name="color">&mid-gray;</xsl:attribute>
</xsl:attribute-set>

<xsl:attribute-set name="dark-green">
  <xsl:attribute name="color">
    <xsl:call-template name="dark-green"/>
  </xsl:attribute>
</xsl:attribute-set>

<xsl:template name="dark-green">
  <!-- This naming solution is somewhat pathetic – but unfortunately, while we
       need the green color as a text color most of the time, sometimes we use
       it for other attributes as well… maybe this could be separated by
       function in the future. -->
  <xsl:choose>
    <xsl:when test="$format.print = 1">&darker-gray;</xsl:when>
    <xsl:otherwise>&dark-green;</xsl:otherwise>
  </xsl:choose>
</xsl:template>

</xsl:stylesheet>
