<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0"
  xmlns:exsl="http://exslt.org/common"
  xmlns="http://www.w3.org/1999/xhtml"
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  exclude-result-prefixes="exsl">
  
  <xsl:import href="../xhtml/param.xsl"/>
  
  <!--<xsl:param name="base.dir"/>-->
  
  <xsl:param name="chunker.output.doctype-public"/>
  <xsl:param name="chunker.output.doctype-system"/>
  <xsl:param name="chunker.output.omit-xml-declaration" select="'yes'"/>
  
  <!-- That is done in Drupal -->
  <xsl:param name="suppress.footer.navigation" select="1"/>
  <xsl:param name="suppress.header.navigation" select="1"/>

  <!-- Don't use admon graphics -->
  <xsl:param name="admon.graphics" select="0"/>
  
  <xsl:param name="css.decoration" select="0"/>
  
  <!-- Intentionally left blank as we don't want toc entries -->
  <xsl:param name="generate.toc"/>
  <!--
  <xsl:param name="callout.unicode" select="1"/>
  <xsl:param name="callout.graphics" select="0"/>
  -->
  
  <xsl:param name="local.l10n.xml" select="document('')"/>
  <l:i18n xmlns:l="http://docbook.sourceforge.net/xmlns/l10n/1.0">
  <l:l10n language="en">
      <!-- 
    HACK for keycap context
    We need to keep this for some time
    See Ticket#84 and https://sf.net/tracker/index.php?func=detail&aid=3540451&group_id=21935&atid=373750
   -->
   <l:context name="msgset">
      <l:template name="alt" text="Alt"/>
      <l:template name="backspace" text="&lt;&#x2014;"/><!-- mdash -->
      <l:template name="command" text="&#x2318;"/>
      <l:template name="control" text="Ctrl"/>
      <l:template name="delete" text="Del"/>
      <l:template name="down" text="&#x02193;"/><!-- darr -->
      <l:template name="end" text="End"/>
      <l:template name="enter" text="Enter"/>
      <l:template name="escape" text="Esc"/>
      <l:template name="home" text="Home"/>
      <l:template name="insert" text="Ins"/>
      <l:template name="left" text="&#x02190;"/><!-- larr -->
      <l:template name="meta" text="Meta"/>
      <l:template name="other" text="???"/>
      <l:template name="pagedown" text="Page &#x02193;"/>
      <l:template name="pageup" text="Page &#x02191;"/>
      <l:template name="right" text="&#x02192;"/><!-- rarr -->
      <l:template name="shift" text="Shift"/>
      <l:template name="space" text="Space"/>
      <l:template name="tab" text="&#x02192;|"/>
      <l:template name="up" text="&#x02191;"/><!-- uarr -->
   </l:context>
   <!--<l:context name="xref-number-and-title">
        <l:template name="appendix" text="“%t”"/>
        <l:template name="bridgehead" text="“%t”"/>
        <l:template name="chapter" text="“%t”"/>
        <l:template name="equation" text="“%t”"/>
        <l:template name="example" text="“%t”"/>
        <l:template name="figure" text="“%t”"/>
        <l:template name="part" text="“%t”"/>
        <l:template name="procedure" text="“%t”"/>
        <l:template name="productionset" text="“%t”"/>
        <l:template name="qandadiv" text="Q &amp; A %n, “%t”"/>
        <l:template name="refsect1" text="“%t”"/>
        <l:template name="refsect2" text="“%t”"/>
        <l:template name="refsect3" text="“%t”"/>
        <l:template name="refsection" text="“%t”"/>
        <l:template name="sect1" text="“%t”"/>
        <l:template name="sect2" text="“%t”"/>
        <l:template name="sect3" text="“%t”"/>
        <l:template name="sect4" text="“%t”"/>
        <l:template name="sect5" text="“%t”"/>
        <l:template name="section" text="“%t”"/>
        <l:template name="simplesect" text="“%t”"/>
        <l:template name="table" text="“%t”"/>
      </l:context>-->
  </l:l10n>
</l:i18n>
</xsl:stylesheet>