<?xml version="1.0"?>
<!--
  Purpose:
     Contains all parameters for (X)HTML
     (Sorted against the list in "Part 1. HTML Parameter Reference" in
      the DocBook XSL Stylesheets User Reference, see link below)

   See Also:
     * http://docbook.sourceforge.net/release/xsl/current/doc/html/index.html

   Author(s):     Thomas Schraitle <toms@opensuse.org>,
                  Stefan Knorr <sknorr@suse.de>
   Copyright: 2012, 2013, Thomas Schraitle, Stefan Knorr

-->

<xsl:stylesheet version="1.0"
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:saxon="http://icl.com/saxon"
  extension-element-prefixes="saxon"
  exclude-result-prefixes="saxon"
  xmlns="http://www.w3.org/1999/xhtml">

<!-- 0. Parameters for External Manipulation =================== -->
  <!-- Add a link to a product/company homepage to the logo -->
  <xsl:param name="homepage" select="''"/>
    <!-- Override this parameter from the command line by adding
             ––xsltparam="'––stringparam homepage=http://www.example.com'"
         (don't copy from here, for technical reasons I can't use hyphens and
         must use dashes). -->

  <!-- Add a link back (up) to an external overview page. -->
  <xsl:param name="overview-page" select="''"/>
  <xsl:param name="overview-page-title" select="''"/>
    <!-- Override with
             ––xsltparam="'––stringparam homepage=http://www.example.com'"
         (don't copy from here, for technical reasons I can't use hyphens and
         must use dashes). -->

  <!-- Toggle the SUSE footer and SUSE e-mail button. Set to 0 if the
       documentation won't be available at a suse.com address.-->
  <xsl:param name="suse.content" select="1"/>
    <!-- Ovverride with:
            ––xsltparam="'––param suse.content=0'"
         (don't copy from here, for technical reasons I can't use hyphens and
         must use dashes). -->

  <!-- Toggle inclusion of @font-face CSS. Set to 1 if you want to host
       the HTML on the internet or 0 if you are building for a locally
       installed package. -->
  <xsl:param name="build.for.web" select="1"/>
    <!-- Override with:
            ––xsltparam="'––param build.for.web=0'"
         (don't copy from here, for technical reasons I can't use hyphens and
         must use dashes). -->

<!-- 1. Admonitions  ============================================ -->
  <!-- Use graphics in admonitions?  0=no, 1=yes -->
  <xsl:param name="admon.graphics" select="1"/>
  <!-- Path to admonition graphics -->
  <xsl:param name="admon.graphics.path">static/images/</xsl:param>
  <!-- Specifies the CSS style attribute that should be added to admonitions -->
  <xsl:param name="admon.style" select="''"/>


 <xsl:param name="chunker.output.method">
   <xsl:choose>
     <xsl:when test="contains(system-property('xsl:vendor'), 'SAXON')">saxon:xhtml</xsl:when>
     <xsl:otherwise>xml</xsl:otherwise>
   </xsl:choose>
 </xsl:param>

<!-- 2. Callouts ================================================ -->
  <xsl:param name="callout.graphics.path">static/images/</xsl:param>
  <xsl:param name="callout.graphics" select="0"/>

<!-- 3. EBNF ==================================================== -->

<!-- 4. ToC/LoT/Index Generation ================================ -->
  <xsl:param name="toc.section.depth" select="1"/>
  <xsl:param name="generate.toc">
appendix  toc,title
article/appendix  nop
article   toc,title
book      toc,title,figure,table,example,equation
chapter   toc,title
part      toc,title
preface   toc,title
qandaset  nop
reference toc,title
sect1     toc
sect2     toc
sect3     toc
sect4     toc
sect5     toc
section   toc
set       toc,title
</xsl:param>

<!-- 5. Stylesheet Extensions =================================== -->

<!-- 6. Automatic labeling ====================================== -->
  <xsl:param name="section.autolabel" select="1"/>
  <xsl:param name="section.label.includes.component.label" select="1"/>

<!-- 7. HTML ==================================================== -->
  <xsl:param name="css.decoration" select="0"/>
  <xsl:param name="docbook.css.link" select="0"/>
  <xsl:param name="docbook.css.source"/>
    <!-- Intentionally left empty – we already have a stylesheet, with this, we
         only override DocBook's default. -->
  <xsl:param name="html.stylesheet">
<xsl:if test="$build.for.web = 1">//static.opensuse.org/fonts/fonts.css</xsl:if>
static/css/style.css
</xsl:param>
  <xsl:param name="make.clean.html" select="1"/>
  <xsl:param name="make.valid.html" select="1"/>

<!-- 8. XSLT Processing ========================================= -->
  <!-- Rule over footers? -->
  <xsl:param name="footer.rule" select="0"/>

<!-- 9. Meta/*Info and Titlepages =============================== -->
  <xsl:param name="generate.legalnotice.link" select="0"/>

<!-- 10. Reference Pages ======================================== -->

<!-- 11. Tables ================================================= -->

<!-- 12. QAndASet =============================================== -->
<xsl:param name="qanda.defaultlabel">none</xsl:param>
<xsl:param name="qandadiv.autolabel" select="0"></xsl:param>

<!-- 13. Linking ================================================ -->
<xsl:param name="ulink.target">_blank</xsl:param>

<!-- 14. Cross References ======================================= -->

<!-- 15. Lists ================================================== -->

<!-- 16. Bibliography =========================================== -->

<!-- 17. Glossary =============================================== -->

<!-- 18. Miscellaneous ========================================== -->
  <xsl:param name="menuchoice.separator" select="$daps.breadcrumbs.sep"/>
  <xsl:param name="formal.title.placement">
figure after
example before
equation before
table before
procedure before
task before
  </xsl:param>

  <!-- From the DocBook XHMTL stylesheet's "formal.xsl" -->
  <xsl:param name="formal.object.break.after">0</xsl:param>

<!-- 19. Annotations ============================================ -->

<!-- 20. Graphics =============================================== -->
  <xsl:param name="img.src.path">images/</xsl:param><!-- DB XSL Version >=1.67.1 -->
  <xsl:param name="make.graphic.viewport" select="0"/> <!-- Do not create tables around graphics. -->
  <xsl:param name="link.to.self.for.mediaobject" select="1"/> <!-- Create links to the image itself around images. -->


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
  <xsl:param name="is.chunk" select="0"/>

  <xsl:param name="admon.graphics.prefix">icon-</xsl:param>

  <xsl:param name="daps.header.logo">static/images/logo.png</xsl:param>
  <xsl:param name="daps.header.logo.alt">Logo</xsl:param>
  <xsl:param name="daps.header.js.library">static/js/jquery-1.10.2.min.js</xsl:param>
  <xsl:param name="daps.header.js.custom">static/js/script.js</xsl:param>

  <xsl:param name="add.suse.footer" select="$suse.content"/>

  <!-- Create breadcrumbs navigation?  -->
  <xsl:param name="generate.breadcrumbs" select="1"/>
  <xsl:param name="breadcrumbs.prev">&#9664;<!--&#9668;--></xsl:param>
  <xsl:param name="breadcrumbs.next">&#9654;<!--&#9658;--></xsl:param>

  <!--  Bubble TOC options -->
  <xsl:param name="rootelementname">
    <xsl:choose>
      <xsl:when test="local-name(key('id', $rootid)) != ''">
        <xsl:value-of select="local-name(key('id', $rootid))"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:value-of select="local-name(/*)"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:param>

  <xsl:param name="bubbletoc.section.depth">2</xsl:param>
  <xsl:param name="bubbletoc.max.depth">2</xsl:param>

  <xsl:param name="bubbletoc.max.depth.shallow">
    <xsl:choose>
      <xsl:when test="$rootelementname = 'article'">
        <xsl:value-of select="1"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:value-of select="0"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:param>

  <!-- Separator for chapter and book name in the XHTML output -->
  <xsl:param name="head.content.title.separator"> | </xsl:param>

  <!-- Create version information before title? -->
  <xsl:param name="generate.version.info" select="1"/>

  <!-- Create the language and format areas in the header? -->
  <xsl:param name="generate.pickers" select="0"/>

  <!-- Create sharing links for Facebook, Google+, Twitter? -->
  <xsl:param name="generate.sharelinks" select="1"/>

  <!-- The email share link only works with suse.com content. -->
  <xsl:param name="allow.email.sharelink" select="$suse.content"/>

  <!-- Separator between breadcrumbs links: -->
  <xsl:param name="daps.breadcrumbs.sep">&#xa0;›&#xa0;</xsl:param>

  <!--  Create permalinks?-->
  <xsl:param name="generate.permalinks" select="1"/>

  <!-- Should information from SVN properties be used? yes=1|no=0 -->
  <xsl:param name="use.meta" select="0"/>

  <!-- Show arrows before and after a paragraph that applies only to a certain
       architecture? -->
  <xsl:param name="para.use.arch" select="1"/>

  <!-- Output a warning, if chapter/@lang is different from book/@lang ?
       0=no, 1=yes
  -->
<xsl:param name="warn.xrefs.into.diff.lang" select="1"/>


</xsl:stylesheet>
