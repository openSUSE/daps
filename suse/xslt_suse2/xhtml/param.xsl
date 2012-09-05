<?xml version="1.0"?>
<!-- 
  Purpose:
     Contains all parameters for (X)HTML
     (Sorted against the list in "Part 1. HTML Parameter Reference" in
      the DocBook XSL Stylesheets User Reference, see link below)
     
   See Also:
     * http://docbook.sourceforge.net/release/xsl/current/doc/html/index.html

   Author(s):    Thomas Schraitle <toms@opensuse.org>
   Copyright: 2012, Thomas Schraitle

-->

<xsl:stylesheet version="1.0"
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns="http://www.w3.org/1999/xhtml">


<!-- 1. Admonitions  ============================================ -->
  <!-- Use graphics in admonitions?  0=no, 1=yes -->
  <xsl:param name="admon.graphics" select="1"/>
  <!-- Path to admonition graphics -->
  <xsl:param name="admon.graphics.path">admon/</xsl:param>
  <!-- Specifies the CSS style attribute that should be added to admonitions -->
  <xsl:param name="admon.style" select="''"/>


<!-- 2. Callouts ================================================ -->
  <xsl:param name="callout.graphics.path">callouts/</xsl:param>

<!-- 3. EBNF ==================================================== -->

<!-- 4. ToC/LoT/Index Generation ================================ -->
  <xsl:param name="toc.section.depth" select="1"/>

<!-- 5. Stylesheet Extensions =================================== -->

<!-- 6. Automatic labeling ====================================== -->
  <xsl:param name="section.autolabel" select="1"/>
  <xsl:param name="section.label.includes.component.label" select="1"/>

<!-- 7. HTML ==================================================== -->
  <xsl:param name="draft.watermark.image">style_images/draft_html.png</xsl:param>
  <xsl:param name="html.stylesheet">susebooks.css</xsl:param>


<!-- 8. XSLT Processing ========================================= -->
  <!-- Rule over footers? -->
  <xsl:param name="footer.rule" select="0"/>

<!-- 9. Meta/*Info and Titlepages =============================== -->
  <xsl:param name="generate.legalnotice.link" select="1"/>
  
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
  <xsl:param name="img.src.path">images/</xsl:param><!-- DB XSL Version >=1.67.1 -->
  
<!-- 21. Chunking =============================================== -->
  <!-- The base directory of chunks -->
  <xsl:param name="base.dir">./html/</xsl:param>
  
  <xsl:param name="chunk.fast" select="1"/>
  <!-- Depth to which sections should be chunked -->
  <xsl:param name="chunk.section.depth" select="0"/>
  <!-- Use ID value of chunk elements as the filename? -->
  <xsl:param name="use.id.as.filename" select="1"/>
  
  <!-- Use graphics in navigational headers and footers? -->
  <xsl:param name="navig.graphics" select="1"/>
  <!-- Path to navigational graphics -->
  <xsl:param name="navig.graphics.path">navig/</xsl:param>
  <!-- Extension for navigational graphics -->
  <xsl:param name="navig.graphics.extension" select="'.png'"/>
  <!-- Identifies the name of the root HTML file when chunking -->
  <xsl:param name="root.filename">index</xsl:param>


<!-- 27. Localization =========================================== -->
  <!-- Use customized language files -->
  <xsl:param name="local.l10n.xml" select="document('../common/l10n/l10n.xml')"/>
  

<!-- 28. SUSE specific parameters =============================== -->
  <!--  -->
  <xsl:param name="daps.header.logo">style_images/logo.png</xsl:param>
  <xsl:param name="daps.header.logo.alt">SUSE</xsl:param>
  
  <!-- Should I generate breadcrumbs navigation?  -->
  <xsl:param name="generate.breadcrumbs" select="1"/>
  <!-- Separator between separate links: -->
  <xsl:param name="daps.breadcrumbs.sep"> » </xsl:param>
  
  <xsl:param name="breadcrumbs.prev">&#9664;<!--&#9668;--></xsl:param>
  <xsl:param name="breadcrumbs.next">&#9654;<!--&#9658;--></xsl:param>


  <!-- Should information from SVN properties be used? yes=1|no=0 -->
  <xsl:param name="use.meta" select="0"/>
  
</xsl:stylesheet>
