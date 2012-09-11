<?xml version="1.0" encoding="ASCII"?>
<!--This file was created automatically by html2xhtml-->
<!--from the HTML stylesheets.-->
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:sverb="http://nwalsh.com/xslt/ext/com.nwalsh.saxon.Verbatim" xmlns:xverb="xalan://com.nwalsh.xalan.Verbatim" xmlns:lxslt="http://xml.apache.org/xslt" xmlns:exsl="http://exslt.org/common" xmlns="http://www.w3.org/1999/xhtml" exclude-result-prefixes="sverb xverb lxslt exsl" version="1.0">

<!-- 
    Purpose:
    Add a wrapper div around screens, so only the inner part of a screen scrolls.
    
    Author(s):    Stefan Knorr <sknorr@suse.de>
    Copyright: 2012, Stefan Knorr
    
-->

<xsl:template match="programlisting|screen|synopsis">
<div class="screen-wrap">
  <xsl:apply-imports/>
</div>  
</xsl:template>

</xsl:stylesheet>
