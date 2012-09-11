<?xml version="1.0" encoding="ASCII"?>
<!-- 
    Purpose:
    Add a wrapper div around screens, so only the inner part of a screen scrolls.
    
    Author(s):    Stefan Knorr <sknorr@suse.de>
    Copyright: 2012, Stefan Knorr
    
-->
<xsl:stylesheet version="1.0"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:exsl="http://exslt.org/common"
    xmlns="http://www.w3.org/1999/xhtml"
    exclude-result-prefixes="exsl">
    
<xsl:template match="programlisting|screen|synopsis">
<div class="screen-wrap">
  <xsl:apply-imports/>
</div>  
</xsl:template>

</xsl:stylesheet>
