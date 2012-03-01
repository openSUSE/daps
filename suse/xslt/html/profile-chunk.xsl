<?xml version="1.0" encoding="ISO-8859-1"?>
<!-- $Id: profile-chunk.xsl 52 2005-05-13 09:23:04Z toms $ -->
<xsl:stylesheet
	version="1.0"
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:exsl="http://exslt.org/common"
	xmlns:t="http://nwalsh.com/docbook/xsl/template/1.0"
	exclude-result-prefixes="exsl">


<xsl:import  href="http://docbook.sourceforge.net/release/xsl/current/html/chunk.xsl"/>
<!--<xsl:include href="suse-titlepage.xsl"/>//-->
<xsl:include href="parameter.xsl" />

<!-- Overwrite with our own implementation -->
<xsl:include href="redefinitions.xsl"/>

<xsl:param name="base.dir">./html/</xsl:param>

</xsl:stylesheet>
