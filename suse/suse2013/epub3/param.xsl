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
  <xsl:param name="admon.graphics" select="1"/>
  <xsl:param name="admon.graphics.path" select="'static/images/'"/>
  <xsl:param name="admon.graphics.extension">.svg</xsl:param>

<!-- 2. Callouts ================================================ -->

<xsl:param name="callout.graphics" select="1"/>
<xsl:param name="callout.graphics.extension">.svg</xsl:param>
<xsl:param name="callout.graphics.number.limit" select="30"/>
<xsl:param name="callout.graphics.path" select="'static/images/'"/>

<!-- 3. EBNF ==================================================== -->

<!-- 4. ToC/LoT/Index Generation ================================ -->

  <!-- separate file for toc -->
  <xsl:param name="chunk.tocs.and.lots" select="1"/>
  <xsl:param name="toc.section.depth" select="2"/>
  <xsl:param name="generate.toc">
book  toc,title,figure,table,example,equation
article  toc,title,figure,table,example,equation
  </xsl:param>

  <!-- EPUB3: use ol lists in table of contents -->
  <xsl:param name="toc.list.type">ol</xsl:param>
  <xsl:param name="autotoc.label.in.hyperlink" select="1"/>


<!-- 5. Manifest ================================ -->
<xsl:param name="generate.manifest" select="0"/>
<xsl:param name="manifest.in.base.dir" select="1"/>


<!-- 7. CSS ==================================================== -->
  <xsl:param name="html.stylesheet">static/css/style.css</xsl:param>

  <xsl:param name="css.decoration" select="1"/>
  <!-- generate the css file from a source file -->
  <xsl:param name="make.clean.html" select="1"/>
  <!-- specify the default epub3 stylesheet -->
  <xsl:param name="docbook.css.source" select="''"/>
  <!-- for custom CSS, use the custom.css.source param -->
  <xsl:param name="custom.css.source"></xsl:param>


<!-- 8. EPUB ========================================= -->

  <xsl:param name="base.dir" select="'OEBPS/'"/>
  <xsl:param name="index.links.to.section" select="0"/>

  <!-- Epub does not yet support external links -->
  <xsl:param name="activate.external.olinks" select="0"/>
  
  <!-- Turning this on crashes ADE, which is unbelievably awesome -->
  <xsl:param name="formal.object.break.after">0</xsl:param>
  
  <!-- no navigation in .epub -->
  <xsl:param name="suppress.navigation" select="'1'"/>


  <!--  New EPUB3 Parameters -->
  
  <xsl:param name="epub.version">3.0</xsl:param>
  <!-- optional ncx for backwards compatibility -->
  <xsl:param name="epub.include.ncx" select="1"/>
  <xsl:param name="epub.ncx.depth">4</xsl:param> <!-- Not functional until http://code.google.com/p/epubcheck/issues/detail?id=70 is resolved -->
  <!-- currently optional duplicate dcterms properties, may be required in future -->
  <xsl:param name="epub.include.metadata.dcterms" select="1"/>
  <!-- optional guide element for backwards compatibility -->
  <xsl:param name="epub.include.guide" select="1"/>
  <!-- some dc: currently required, to be replaced in future version -->
  <xsl:param name="epub.include.metadata.dc.elements" select="1"/>
  <!-- Some dc: elements will remain optional according to the spec -->
  <xsl:param name="epub.include.optional.metadata.dc.elements" select="1"/>
  <xsl:param name="epub.autolabel" select="0"/>
  <xsl:param
    name="epub.vocabulary.profile.content">http://www.idpf.org/epub/30/profile/content/</xsl:param>
  <xsl:param
    name="epub.vocabulary.profile.package">http://www.idpf.org/epub/30/profile/package/</xsl:param>
  <xsl:param name="epub.output.epub.types" select="1"/>
  <xsl:param name="epub.oebps.dir" select="'OEBPS'"/>
  <xsl:param name="epub.metainf.dir" select="'META-INF/'"/>
  <xsl:param name="epub.ncx.filename" select="'toc.ncx'"/>
  <xsl:param name="epub.mimetype.filename" select="'mimetype'"/>
  <xsl:param name="epub.mimetype.value" select="'application/epub+zip'"/>
  <xsl:param name="epub.container.filename" select="'container.xml'"/>
  <xsl:param name="epub.package.filename" select="'package.opf'"/>
  <xsl:param name="epub.cover.filename" select="concat('cover', $html.ext)"/>
  <xsl:param name="epub.cover.linear" select="0" />
  
  <!-- names of id attributes used in package files -->
  <xsl:param name="epub.meta.identifier.id">meta-identifier</xsl:param>
  <xsl:param name="epub.dc.identifier.id">pub-identifier</xsl:param>
  <xsl:param name="epub.meta.title.id">meta-title</xsl:param>
  <xsl:param name="epub.dc.title.id">pub-title</xsl:param>
  <xsl:param name="epub.meta.language.id">meta-language</xsl:param>
  <xsl:param name="epub.dc.language.id">pub-language</xsl:param>
  <xsl:param name="epub.meta.creator.id">meta-creator</xsl:param>
  <xsl:param name="epub.dc.creator.id">pub-creator</xsl:param>
  <xsl:param name="epub.ncx.toc.id">ncxtoc</xsl:param>
  <xsl:param name="epub.ncx.manifest.id">ncx</xsl:param>
  <xsl:param name="epub.ncx.mediatype">application/x-dtbncx+xml</xsl:param>
  <xsl:param name="epub.xhtml.mediatype">application/xhtml+xml</xsl:param>
  <xsl:param name="epub.html.toc.id">htmltoc</xsl:param>
  <xsl:param name="epub.cover.filename.id" select="'cover'"/>
  <xsl:param name="epub.cover.image.id" select="'cover-image'"/>
  
  <xsl:param name="epub.embedded.fonts"></xsl:param>
  <xsl:param name="epub.namespace">http://www.idpf.org/2007/ops</xsl:param>
  <xsl:param name="opf.namespace">http://www.idpf.org/2007/opf</xsl:param>
  <xsl:param name="ncx.namespace">http://www.daisy.org/z3986/2005/ncx/</xsl:param>
  <xsl:param name="dc.namespace">http://purl.org/dc/elements/1.1/</xsl:param>
  <!-- prefix generated ids in package elements so they differ from content ids -->
  <xsl:param name="epub.package.id.prefix">id-</xsl:param>
  <!-- editor is either a creator or contributor -->
  <xsl:param name="editor.property">contributor</xsl:param>
  
  <!-- Generate full output path -->
  <xsl:param name="epub.package.dir" select="concat($chunk.base.dir, '../')"/>
  
  <xsl:param name="epub.ncx.pathname"
             select="concat($chunk.base.dir, $epub.ncx.filename)"/>
  <xsl:param name="epub.container.pathname"
             select="concat($epub.package.dir, $epub.metainf.dir, $epub.container.filename)"/>
  <xsl:param name="epub.package.pathname"
             select="concat($chunk.base.dir, $epub.package.filename)"/>
  <xsl:param name="epub.cover.pathname"
             select="concat($chunk.base.dir, $epub.cover.filename)"/>
  <xsl:param name="epub.mimetype.pathname"
             select="concat($epub.package.dir, $epub.mimetype.filename)"/>
  
  <xsl:param name="kindle.extensions" select="0"/>
  
<!-- 28. SUSE specific parameters =============================== -->

  <xsl:param name="generate.permalinks" select="0"/>

  <!-- Wrap an <img/> tag <a>
       0=no, 1=yes
  -->
  <xsl:param name="wrap.img.with.a" select="0"/>


</xsl:stylesheet>
