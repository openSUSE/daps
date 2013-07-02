<?xml version="1.0" encoding="UTF-8"?>
<!--
  Purpose:
    Contains all parameters for XSL-FO.
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


<!-- 2. Callouts ================================================ -->


<!-- 3. ToC/LoT/Index Generation ================================ -->
<xsl:param name="autotoc.label.separator" select="' '"/>


<!-- 4. Processor Extensions ==================================== -->


<!-- 5. Stylesheet Extensions =================================== -->


<!-- 6. Automatic labelling ===================================== -->
<xsl:param name="section.autolabel" select="1"/>
<xsl:param name="section.label.includes.component.label" select="1"/>


<!-- 7. XSLT Processing  ======================================== -->


<!-- 8. Meta/*Info ============================================== -->


<!-- 9. Reference Pages ========================================= -->


<!-- 10. Tables ================================================= -->
<xsl:param name="default.table.width">100%</xsl:param>
<xsl:param name="table.frame.border.color">&light-gray;</xsl:param>
<xsl:param name="table.frame.border.thickness">&thinline;mm</xsl:param>
<xsl:param name="table.cell.border.color">&light-gray;</xsl:param>
<xsl:param name="table.cell.border.thickness">&thinline;mm</xsl:param>
<xsl:attribute-set name="table.cell.padding">
  <xsl:attribute name="padding-start">1.5mm</xsl:attribute>
  <xsl:attribute name="padding-end">1.5mm</xsl:attribute>
  <xsl:attribute name="padding-top">1.5mm</xsl:attribute>
  <xsl:attribute name="padding-bottom">1.25mm</xsl:attribute>
    <!-- Smaller than padding-top, to compensate for the fact that descenders
         reserve some area at the bottom too. -->
</xsl:attribute-set>

<!-- 11. Linking ================================================ -->


<!-- 12. Cross References ======================================= -->


<!-- 13. Lists ================================================== -->
<xsl:param name="variablelist.term.break.after" select="1"/>


<!-- 14. QAndASet =============================================== -->


<!-- 15. Bibliography =========================================== -->


<!-- 16. Glossary =============================================== -->
<xsl:param name="glossary.as.blocks" select="1"/>

<!-- 17. Miscellaneous ========================================== -->
<xsl:param name="hyphenate.verbatim" select="'1'"/>
<xsl:param name="variablelist.as.blocks" select="1"/>
<xsl:param name="formal.title.placement">
figure after
example before
equation before
table before
procedure before
task before
</xsl:param>
<xsl:param name="menuchoice.separator" select ="' › '"/>
<xsl:param name="menuchoice.menu.separator" select ="' › '"/>
<xsl:param name="shade.verbatim" select="1"/>


<!-- 18. Graphics =============================================== -->


<!-- 19. Pagination and General Styles ========================== -->
<xsl:param name="paper.type" select="'A4'"/>
<xsl:param name="double.sided" select="1"/>
<xsl:param name="force.blank.pages" select="0"/>

<xsl:param name="page.margin.top" select="'19mm'"/>
<xsl:param name="body.margin.top" select="'0mm'"/>
<xsl:param name="page.margin.bottom" select="'18.9mm'"/>
<xsl:param name="body.margin.bottom" select="'30.5mm'"/>
<xsl:param name="page.margin.inner" select="'&column;mm'"/>
<xsl:param name="body.margin.inner" select="'0mm'"/>
<xsl:param name="page.margin.outer" select="'&column;mm'"/>
<xsl:param name="body.margin.outer" select="'0mm'"/>

<xsl:param name="header.rule" select="0"/>
<xsl:param name="footer.rule" select="0"/>
<xsl:param name="footer.column.widths"
  select="concat(&column; + &gutter;, ' ', 4 * &column; + 3 * &gutter;, ' ', &column; + &gutter;)"/>
  <!-- These are actual millimeters, even though this only needs to be a
       proportion. -->

<xsl:param name="body.start.indent" select="'0'"/>

<xsl:param name="draft.watermark.image"><xsl:value-of select="$styleroot"/>images/draft.svg</xsl:param>


<!-- 20. Font Families ========================================== -->

<xsl:param name="document.language">
  <xsl:call-template name="l10n.language">
    <xsl:with-param name="target"
      select="(/* | key('id', $rootid))[last()]"/>
  </xsl:call-template>
</xsl:param>

<xsl:param name="sans-stack">
  <xsl:choose>
    <xsl:when test="$document.language = 'ar'">
      &arabic;
    </xsl:when>
    <xsl:when test="$document.language = 'zh_cn'">
      &chinese-sim;
    </xsl:when>
    <xsl:when test="$document.language = 'zh_tw'">
      &chinese-trad;
    </xsl:when>
    <xsl:when test="$document.language = 'ja'">
      &japanese-sans;
    </xsl:when>
    <xsl:when test="$document.language = 'ko'">
      &korean-sans;
    </xsl:when>
    <xsl:otherwise>
      &western-sans;
    </xsl:otherwise>
  </xsl:choose>
</xsl:param>

<xsl:param name="serif-stack">
  <xsl:choose>
    <xsl:when test="$document.language = 'ar'">
      &arabic;
    </xsl:when>
    <xsl:when test="$document.language = 'zh_cn'">
      &chinese-sim;
    </xsl:when>
    <xsl:when test="$document.language = 'zh_tw'">
      &chinese-trad;
    </xsl:when>
    <xsl:when test="$document.language = 'ja'">
      &japanese-serif;
    </xsl:when>
    <xsl:when test="$document.language = 'ko'">
      &korean-serif;
    </xsl:when>
    <xsl:otherwise>
      &western-serif;
    </xsl:otherwise>
  </xsl:choose>
</xsl:param>

<xsl:param name="body.font.family"><xsl:value-of select="$serif-stack"/></xsl:param>
<xsl:param name="dingbat.font.family">&symbol;</xsl:param>
<xsl:param name="sans.font.family"><xsl:value-of select="$sans-stack"/></xsl:param>
<xsl:param name="title.font.family"><xsl:value-of select="$sans-stack"/></xsl:param>
<xsl:param name="monospace.font.family">&mono;, monospace</xsl:param>
<xsl:param name="symbol.font.family">&symbol;</xsl:param>

<xsl:param name="body.font.master" select="'&normal;'"/>
<xsl:param name="body.font.size">
  <xsl:value-of select="$body.font.master"/><xsl:text>*&serif-factor;pt</xsl:text>
</xsl:param>
<xsl:param name="footnote.font.size" select="'&small;'"/>


<!-- 21. Property Sets ========================================== -->


<!-- 22. Profiling ============================================== -->


<!-- 23. Localization =========================================== -->
<xsl:param name="local.l10n.xml" select="document('../common/l10n/l10n.xml')"/>

<!-- For some languages, enabling the bold/italic features that exist for
     Western text is rather undesirable, as fonts may not exist or become
     unreadable. -->
<xsl:param name="enable.bold">
<xsl:choose>
  <xsl:when test="$document.language = 'zh_cn' or
                  $document.language = 'zh_tw'
                  $document.language = 'ja'">0</xsl:when>
  <xsl:otherwise>1</xsl:otherwise>
</xsl:choose>
</xsl:param>

<xsl:param name="enable.italic">
<xsl:choose>
  <xsl:when test="$document.language = 'zh_cn' or $document.language = 'zh_tw' or
                  $document.language = 'ja' or $document.language = 'ko' or
                  $document.language = 'ar'">0</xsl:when>
  <xsl:otherwise>1</xsl:otherwise>
</xsl:choose>
</xsl:param>

<xsl:param name="writing.mode">
<xsl:choose>
  <xsl:when test="$document.language = 'ar'">rl</xsl:when>
  <xsl:otherwise>lr</xsl:otherwise>
</xsl:choose>
</xsl:param>


<!-- 24. EBNF =================================================== -->


<!-- 25. Prepress =============================================== -->


<!-- 26. Custom ================================================= -->
<!-- Saxon will fail if these parameters aren't declared. -->
<xsl:param name="format.print" select="0"/>
<xsl:param name="styleroot" select="'WARNING: styleroot unset!'"/>

</xsl:stylesheet>
