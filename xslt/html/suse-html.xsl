<?xml version="1.0" encoding="ISO-8859-1"?>
<!-- $Id: suse-html.xsl 2436 2005-11-29 09:09:28Z toms $ -->
<xsl:stylesheet
	version="1.0"
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:exsl="http://exslt.org/common"
	xmlns:t="http://nwalsh.com/docbook/xsl/template/1.0"
	exclude-result-prefixes="exsl">

<xsl:import  href="http://docbook.sourceforge.net/release/xsl/current/html/docbook.xsl"/>
<!--<xsl:include href="suse-titlepage.xsl"/>//-->
<xsl:include href="param.xsl" />

<xsl:output indent="yes"/>


<!-- Overwrite with our own implementation -->
<xsl:include href="redefinitions.xsl"/>

<!-- Overwrites some template rules for graphics -->
<xsl:include href="graphics.xsl"/>

<xsl:param name="base.dir">./html/</xsl:param>
<xsl:param name="generate.legalnotice.link" select="0"/>

</xsl:stylesheet>
