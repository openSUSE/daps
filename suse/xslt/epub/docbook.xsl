<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0"
  xmlns:l="http://docbook.sourceforge.net/xmlns/l10n/1.0"
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  exclude-result-prefixes="l">
  
<xsl:import href="http://docbook.sourceforge.net/release/xsl/current/epub/docbook.xsl"/>

<xsl:param name="base.dir">./epub/</xsl:param>
<xsl:param name="use.id.as.filename" select="1"/>

<xsl:param name="header.rule" select="false()"/>
<xsl:param name="footer.rule" select="false()"/>
<xsl:param name="img.src.path"/><!-- DB XSL Version >=1.67.1 -->
<xsl:param name="preferred.mediaobject.role">epub</xsl:param>
<xsl:param name="local.l10n.xml" select="document('../common/l10n/l10n.xml')"/>

<xsl:param name="epub.oebps.dir"   select="concat($base.dir, 'OEBPS/')"/>
<xsl:param name="epub.metainf.dir" select="concat($base.dir, 'META-INF/')"/>   
<xsl:param name="epub.container.filename" select="concat($epub.metainf.dir, 'container.xml')"/>
  
  <xsl:template name="container">
    <xsl:call-template name="write.chunk">
      <!-- This is needed to fix generation of META-INF/ directory -->
      <xsl:with-param name="filename" select="$epub.container.filename"/>
      <xsl:with-param name="method" select="'xml'" />
      <xsl:with-param name="encoding" select="'utf-8'" />
      <xsl:with-param name="indent" select="'no'" />
      <xsl:with-param name="quiet" select="$chunk.quietly" />
      <xsl:with-param name="doctype-public" select="''"/> <!-- intentionally blank -->
      <xsl:with-param name="doctype-system" select="''"/> <!-- intentionally blank -->

      <xsl:with-param name="content">
        <xsl:element namespace="urn:oasis:names:tc:opendocument:xmlns:container" name="container">
          <xsl:attribute name="version">1.0</xsl:attribute>
          <xsl:element namespace="urn:oasis:names:tc:opendocument:xmlns:container" name="rootfiles">
            <xsl:element namespace="urn:oasis:names:tc:opendocument:xmlns:container" name="rootfile">
              <xsl:attribute name="full-path">
                <xsl:value-of select="$epub.opf.filename" />
              </xsl:attribute>
              <xsl:attribute name="media-type">
                <xsl:text>application/oebps-package+xml</xsl:text>
              </xsl:attribute>
            </xsl:element>
          </xsl:element>
        </xsl:element>
      </xsl:with-param>
    </xsl:call-template>
  </xsl:template>
<xsl:template match="keycap">
   <!-- See also Ticket#84 -->
   <xsl:param name="key.contents"  select="."/>
   <xsl:variable name="key.length" select="string-length($key.contents)"/>

   <xsl:choose>
       <xsl:when test="@function">
         <xsl:call-template name="inline.charseq">
            <xsl:with-param name="content">
               <xsl:call-template name="gentext.template">
                  <xsl:with-param name="context" select="'msgset'"/>
                  <xsl:with-param name="name" select="@function"/>
               </xsl:call-template>
            </xsl:with-param>
         </xsl:call-template>
       </xsl:when>
       <xsl:otherwise>
         <xsl:call-template name="inline.charseq"/>
       </xsl:otherwise>
   </xsl:choose>
</xsl:template>
  
</xsl:stylesheet>
