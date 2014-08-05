<?xml version="1.0" encoding="UTF-8"?>
<!--
  Purpose:
     Contains all parameters for EPUB3/XHTML
     (Sorted against the list in "Part 1. HTML Parameter Reference" in
      the DocBook XSL Stylesheets User Reference, see link below)

   See Also:
     * http://docbook.sourceforge.net/release/xsl/current/doc/html/index.html

   Author(s):     Thomas Schraitle <toms@opensuse.org>,
                  Stefan Knorr <sknorr@suse.de>
   Copyright 2013 Thomas Schraitle, Stefan Knorr

-->
<xsl:stylesheet  version="1.0"
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns="http://www.w3.org/1999/xhtml"
  xmlns:saxon="http://icl.com/saxon"
  extension-element-prefixes="saxon"
  exclude-result-prefixes="saxon" >

<!-- 0. Parameters for External Manipulation =================== -->
  <xsl:param name="suse.content" select="0"/>


<!-- 1. Admonitions  ============================================ -->

<!-- 2. Callouts ================================================ -->

<!-- 3. EBNF ==================================================== -->

<!-- 4. ToC/LoT/Index Generation ================================ -->

<!-- 7. HTML ==================================================== -->

<!-- 8. XSLT Processing ========================================= -->

<!-- 9. Meta/*Info and Titlepages =============================== -->

<!-- 10. Reference Pages ======================================== -->

<!-- 11. Tables ================================================= -->

<!-- 12. QAndASet =============================================== -->

<!-- 13. Linking ================================================ -->

<!-- 14. Cross References ======================================= -->

<!-- 15. Lists ================================================== -->

<!-- 16. Bibliography =========================================== -->

<!-- 17. Glossary =============================================== -->

<!-- 18. Miscellaneous ========================================== -->

<!-- 19. Annotations ============================================ -->

<!-- 20. Graphics =============================================== -->

<!-- 21. Chunking =============================================== -->

<!--   <xsl:param name="base.dir"></xsl:param> -->


<!-- 27. Localization =========================================== -->

<!-- 28. SUSE specific parameters =============================== -->

  <xsl:param name="generate.permalinks" select="0"/>

</xsl:stylesheet>
