<?xml version="1.0" encoding="UTF-8"?>
<!-- 
  Purpose:
     Create permalink for divisions and formal object
     
  Parameters:
     * object (default ".")
       object node
     
     * generate.permalinks
       Flag which enables or disables the complete permalink generation
     
  Output:
     Creates an <a> tag with a href attribute, pointing to the
     respective ID.

   Author(s):    Thomas Schraitle <toms@opensuse.org>
   Copyright: 2012, Thomas Schraitle

-->
<xsl:stylesheet version="1.0"
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns="http://www.w3.org/1999/xhtml">

  <!-- The below template is replaced by a template of the same name in
       chunk-common, if that file is included. -->
  <xsl:template name="create.permalink.singlehtml">
    <xsl:param name="object" select="."/>
    <xsl:call-template name="create.permalink">
      <xsl:with-param name="object" select="$object"/>
    </xsl:call-template>
  </xsl:template>

  <xsl:template name="create.permalink">
    <xsl:param name="object" select="."/>
    
    <xsl:if test="$generate.permalinks != 0">
      <a title="Permalink" class="permalink">
        <xsl:attribute name="href">
          <xsl:call-template name="href.target">
            <xsl:with-param name="object" select="$object"/>
          </xsl:call-template>
        </xsl:attribute>
        <xsl:text>#</xsl:text>
      </a>
    </xsl:if>
  </xsl:template>  
</xsl:stylesheet>
