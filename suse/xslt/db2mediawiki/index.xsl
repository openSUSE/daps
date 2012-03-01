<?xml version="1.0" encoding="UTF-8"?>
<!-- $Id: index.xsl 10194 2006-06-08 13:38:26Z toms $ -->

<xsl:stylesheet version="1.0"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:svg="http://www.w3.org/2000/svg"
    xmlns:exslt="http://exslt.org/common"
    exclude-result-prefixes="exslt"
>


<xsl:template match="index"/>
<xsl:template match="index" mode="wiki"/>

<xsl:template match="indexterm"/>
<xsl:template match="indexterm" mode="wiki"/>
<xsl:template match="primary"/>
<xsl:template match="primary" mode="wiki"/>
<xsl:template match="secondary"/>
<xsl:template match="secondary" mode="wiki"/>
<xsl:template match="tertiary"/>
<xsl:template match="tertiary" mode="wiki"/>

<xsl:template match="indexterm" mode="wrap"/>
<xsl:template match="primary" mode="wrap"/>
<xsl:template match="secondary" mode="wrap"/>
<xsl:template match="tertiary" mode="wrap"/>




</xsl:stylesheet>