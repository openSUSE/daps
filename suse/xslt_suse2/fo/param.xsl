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
  <!ENTITY % fontsizes SYSTEM "font-sizes.ent">
  %fontsizes;
]>
<xsl:stylesheet version="1.0"
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:fo="http://www.w3.org/1999/XSL/Format">

<!-- 1. Admonitions  ============================================ -->
  
  
<!-- 2. Callouts ================================================ -->
  
  
<!-- 3. ToC/LoT/Index Generation ================================ -->
  
  
<!-- 4. Processor Extensions ==================================== -->
  
  
<!-- 5. Stylesheet Extensions =================================== -->
  
  
<!-- 6. Automatic labelling ===================================== -->
  
  
<!-- 7. XSLT Processing  ======================================== -->
  
  
<!-- 8. Meta/*Info ============================================== -->
  
  
<!-- 9. Reference Pages ========================================= -->
  
  
<!-- 10. Tabels ================================================= -->
  
  
<!-- 11. Linking ================================================ -->
  
  
<!-- 12. Cross References ======================================= -->
  
  
<!-- 13. Lists ================================================== -->
  
  
<!-- 14. QAndASet =============================================== -->
  
  
<!-- 15. Bibliography =========================================== -->
  
  
<!-- 16. Glossary =============================================== -->
  
  
<!-- 17. Miscellaneous ========================================== -->
  
  
<!-- 18. Graphics =============================================== -->
  
  
<!-- 19. Pagination and General Styles ========================== -->
  <xsl:param name="paper.type" select="'A4'"/>
  <xsl:param name="double.sided" select="1"/>

  <xsl:param name="page.margin.top" select="'19mm'"/>
  <xsl:param name="body.margin.top" select="'0mm'"/>
  <xsl:param name="page.margin.bottom" select="'18.9mm'"/>
  <xsl:param name="body.margin.bottom" select="'30.5mm'"/>
  <xsl:param name="page.margin.inner" select="'22.5mm'"/>
  <xsl:param name="body.margin.inner" select="'0mm'"/>
  <xsl:param name="page.margin.outer" select="'22.5mm'"/>
  <xsl:param name="body.margin.outer" select="'0mm'"/>

<!-- 20. Font Families ========================================== -->
  
  
<!-- 21. Property Sets ========================================== -->
  
  
<!-- 22. Profiling ============================================== -->
  
  
<!-- 23. Localization =========================================== -->
  
  
<!-- 24. EBNF =================================================== -->
  
  
<!-- 25. Prepress =============================================== -->
  
  
</xsl:stylesheet>
