<?xml version="1.0" encoding="ASCII"?>
<!--This file was created automatically by html2xhtml-->
<!--from the HTML stylesheets.-->
<!-- $Id: suse-html.xsl 2436 2005-11-29 09:09:28Z toms $ -->
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:exsl="http://exslt.org/common" xmlns:t="http://nwalsh.com/docbook/xsl/template/1.0" xmlns="http://www.w3.org/1999/xhtml" version="1.0" exclude-result-prefixes="exsl">

<xsl:import href="http://docbook.sourceforge.net/release/xsl/current/xhtml/docbook.xsl"/>
<!--<xsl:include href="suse-titlepage.xsl"/>//-->
<xsl:include href="param.xsl"/>

<xsl:output indent="yes" method="xml" encoding="UTF-8" doctype-public="-//W3C//DTD XHTML 1.0 Transitional//EN" doctype-system="http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd"/>


<!-- Overwrite with our own implementation -->
<xsl:include href="redefinitions.xsl"/>

<!-- Overwrites some template rules for graphics -->
<xsl:include href="graphics.xsl"/>

<xsl:param name="base.dir">./html/</xsl:param>
<xsl:param name="generate.legalnotice.link" select="0"/>

</xsl:stylesheet>
