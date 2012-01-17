<xsl:stylesheet
	version="1.0"
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:exsl="http://exslt.org/common"
	xmlns:t="http://nwalsh.com/docbook/xsl/template/1.0"
	exclude-result-prefixes="exsl">

<xsl:import href="http://docbook.sourceforge.net/release/xsl/current/xhtml/docbook.xsl"/>
<xsl:import href="../html/param.xsl"/>

<xsl:output method="xml"/>
  

<xsl:include href="../profiling/suse-pi.xsl"/>

<xsl:include href="../html/lists.xsl"/>
<xsl:include href="../html/xref.xsl" />
<xsl:include href="../html/formal.xsl"/>
<xsl:include href="../html/sections.xsl"/>
<xsl:include href="../html/inline.xsl"/>
<xsl:include href="../html/toc.xsl"/>
<xsl:include href="../html/component.xsl"/>
<xsl:include href="../html/synop.xsl"/>
<xsl:include href="../common/l10n.xsl"/>
<xsl:include href="../html/admon.xsl"/>

<!-- Overwrite with our own implementation -->
<xsl:include href="../html/redefinitions.xsl"/>

<!-- Overwrite HTML header, because of productname, productnumber -->
<xsl:include href="../html/html.head.xsl"/>

<!-- Returns metadata from our XML files -->
<xsl:include href="../html/metadata.xsl"/>


<!-- Overwrite standard header and footer with our own definitions -->
<xsl:include  href="../html/navig.header.footer.xsl"/>

<!-- Overwrites some template rules for graphics -->
<xsl:include href="../html/graphics.xsl"/>
<!--<xsl:include href="../html/titlepage.xsl"/>-->

<xsl:include href="../html/suse-titlepage.xsl"/>

<xsl:include href="../html/pi.xsl"/>
<xsl:include href="../html/autotoc.xsl"/>

<!-- Overwrite parameter from param.xsl: -->
<xsl:param name="generate.legalnotice.link" select="0"/>

</xsl:stylesheet>