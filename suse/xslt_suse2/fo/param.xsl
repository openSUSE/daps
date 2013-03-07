<?xml version="1.0" encoding="UTF-8"?>
<!--
  Purpose:
    Contains all parameters for XSL-FO
    (Sorted against the list in "Part 2. FO Parameter Reference" in
    the DocBook XSL Stylesheets User Reference, see link below)

   See Also:
     * http://docbook.sourceforge.net/release/xsl/current/doc/fo/index.html

   Author(s):    Stefan Knorr <sknorr@suse.de>
                 Thomas Schraitle <toms@opensuse.org>

   Copyright: 2013, Stefan Knorr, Thomas Schraitle

-->
<!DOCTYPE xsl:stylesheets 
[
  <!ENTITY % fonts SYSTEM "fonts.ent">
  %fonts;
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

<!-- 18. Graphics =============================================== -->


<!-- 19. Pagination and General Styles ========================== -->
  <xsl:param name="paper.type" select="'A4'"/>
  <xsl:param name="double.sided" select="1"/>
  <!-- <xsl:param name="force.blank.pages" select="0"/> – This doesn't work with
       DocBook stylesheets 1.77.1 or below, hence keep the adaptations in
       pagesetup.xsl for now.-->

  <xsl:param name="page.margin.top" select="'19mm'"/>
  <xsl:param name="body.margin.top" select="'0mm'"/>
  <xsl:param name="page.margin.bottom" select="'18.9mm'"/>
  <xsl:param name="body.margin.bottom" select="'30.5mm'"/>
  <xsl:param name="page.margin.inner" select="'22.5mm'"/>
  <xsl:param name="body.margin.inner" select="'0mm'"/>
  <xsl:param name="page.margin.outer" select="'22.5mm'"/>
  <xsl:param name="body.margin.outer" select="'0mm'"/>

  <xsl:param name="header.rule" select="0"/>
  <xsl:param name="footer.rule" select="0"/>
  <xsl:param name="footer.column.widths" select="'28.5 108 28.5'"/>
    <!-- These are actual millimeters, even though this only needs to be a
         proportion. -->

  <xsl:param name="body.start.indent" select="'0'"/>

<!-- 20. Font Families ========================================== -->
  <xsl:param name="body.font.family">&serif;, serif</xsl:param>
  <xsl:param name="dingbat.font.family">'FreeSerif', serif</xsl:param>
  <xsl:param name="sans.font.family">&sans;, sans-serif</xsl:param>
  <xsl:param name="title.font.family">&sans;, sans-serif</xsl:param>
  <xsl:param name="monospace.font.family">&mono;, monospace</xsl:param>
  <xsl:param name="symbol.font.family">'FreeSerif'</xsl:param>

  <xsl:param name="body.font.master" select="'&normal;'"/>
  <xsl:param name="body.font.size">
    <xsl:value-of select="$body.font.master"/><xsl:text>*&serif-factor;pt</xsl:text>
  </xsl:param>
  <xsl:param name="footnote.font.size" select="'&small;'"/>

<!-- 21. Property Sets ========================================== -->


<!-- 22. Profiling ============================================== -->


<!-- 23. Localization =========================================== -->
  <xsl:param name="local.l10n.xml" select="document('../common/l10n/l10n.xml')"/>

<!-- 24. EBNF =================================================== -->


<!-- 25. Prepress =============================================== -->


</xsl:stylesheet>
