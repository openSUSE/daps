<xsl:stylesheet version="1.0"
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:exsl="http://exslt.org/common"
	xmlns:t="http://nwalsh.com/docbook/xsl/template/1.0"
	exclude-result-prefixes="exsl">

<xsl:import href="http://docbook.sourceforge.net/release/xsl/current/xhtml/docbook.xsl"/>
<xsl:import href="param.xsl"/>

<xsl:output method="xml"/>

<xsl:include href="../version.xsl"/>

<xsl:include href="lists.xsl"/>
<xsl:include href="callout.xsl"/>
<xsl:include href="xref.xsl" />
<xsl:include href="formal.xsl"/>
<xsl:include href="sections.xsl"/>
<xsl:include href="inline.xsl"/>
<xsl:include href="toc.xsl"/>
<xsl:include href="component.xsl"/>
<xsl:include href="synop.xsl"/>
<xsl:include href="../common/l10n.xsl"/>
<!-- <xsl:include href="../common/titles.xsl"/> -->
<xsl:include href="html.xsl"/>
<xsl:include href="admon.xsl"/>
<!-- Overwrite with our own implementation -->
<xsl:include href="redefinitions.xsl"/>
<!-- Overwrite HTML header, because of productname, productnumber -->
<xsl:include href="html.head.xsl"/>
<!-- Returns metadata from our XML files -->
<xsl:include href="metadata.xsl"/>
<!-- Overwrite standard header and footer with our own definitions -->
<xsl:include  href="navig.header.footer.xsl"/>
<!-- Overwrites some template rules for graphics -->
<xsl:include href="graphics.xsl"/>
<!--<xsl:include href="titlepage.xsl"/>-->
<xsl:include href="suse-titlepage.xsl"/>
<xsl:include href="pi.xsl"/>
<!-- Overwrite parameter from param.xsl: -->
<xsl:param name="generate.legalnotice.link" select="0"/>

</xsl:stylesheet>
