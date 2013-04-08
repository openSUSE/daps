<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0"
  xmlns:l="http://docbook.sourceforge.net/xmlns/l10n/1.0"
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:dc="http://purl.org/dc/elements/1.1/"
  exclude-result-prefixes="l">
  
<xsl:import href="http://docbook.sourceforge.net/release/xsl/current/epub/docbook.xsl"/>

<xsl:param name="base.dir">epub/OEBPS/</xsl:param>
<xsl:param name="use.id.as.filename" select="1"/>

<xsl:param name="header.rule" select="false()"/>
<xsl:param name="footer.rule" select="false()"/>
<xsl:param name="img.src.path"/><!-- DB XSL Version >=1.67.1 -->
<xsl:param name="preferred.mediaobject.role">epub</xsl:param>
<xsl:param name="local.l10n.xml" select="document('../common/l10n/l10n.xml')"/>

<xsl:param name="epub.oebps.dir"   select="'epub/OEBPS/'"/>
<xsl:param name="epub.metainf.dir" select="'epub/META-INF/'"/>   
  
  
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
